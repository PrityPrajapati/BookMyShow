import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:showscape/firebase_options.dart';
import 'package:showscape/core/router/app_router.dart';
import 'package:showscape/core/theme/app_theme.dart';
import 'package:showscape/l10n/app_localizations.dart';
import 'package:showscape/core/localization/locale_provider.dart';
import 'package:showscape/core/providers/accessibility_providers.dart';
import 'package:showscape/features/notifications/presentation/providers/notification_providers.dart';
import 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart';
import 'package:showscape/core/providers/preferences_provider.dart';
import 'package:showscape/core/utils/app_haptics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  try {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>('explore_preferences');
    await Hive.openBox<dynamic>('ai_review_summary_cache');
    await Hive.openBox<dynamic>('event_mood_tags_cache');
    await Hive.openBox<dynamic>(appPreferencesBox);
  } catch (e) {
    debugPrint('Hive initialization error: $e');
  }

  runApp(
    const ProviderScope(
      child: ShowScapeApp(),
    ),
  );
}

/// Root widget for ShowScape application
class ShowScapeApp extends ConsumerStatefulWidget {
  const ShowScapeApp({super.key});

  @override
  ConsumerState<ShowScapeApp> createState() => _ShowScapeAppState();
}

class _ShowScapeAppState extends ConsumerState<ShowScapeApp> {
  StreamSubscription<String>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotificationsAndReschedule();
    });
  }

  Future<void> _initNotificationsAndReschedule() async {
    final notifService = ref.read(notificationServiceProvider);
    await notifService.initialize();

    // Listen to deep-link events triggered by notification taps or action buttons
    // ('Show ticket' -> /ticket/:id, 'Directions' -> /venue-map/:id, 'Order food' -> /food/:id)
    _deepLinkSubscription = notifService.onDeepLinkStream.listen((deepLink) {
      if (mounted && deepLink.isNotEmpty) {
        final router = ref.read(appRouterProvider);
        router.push(deepLink);
      }
    });

    if (!mounted) return;

    // Reschedule all upcoming booking reminders on app start & cold boot
    try {
      if (ref.exists(allUserBookingsProvider)) {
        final currentBookings = ref.read(allUserBookingsProvider).asData?.value;
        if (currentBookings != null && currentBookings.isNotEmpty) {
          final preferences = ref.read(notificationPreferencesProvider);
          final now = DateTime.now();
          final upcoming = currentBookings.where((b) => b.showTime.isAfter(now)).toList();
          if (upcoming.isNotEmpty) {
            await notifService.rescheduleAllUpcomingReminders(
              upcomingBookings: upcoming,
              preferences: preferences,
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Startup reschedule notice: $e');
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    AppHaptics.enabled = ref.watch(hapticsEnabledProvider);
    final currentLocale = ref.watch(localeProvider);
    final isSimpleMode = ref.watch(simpleModeProvider);

    return MaterialApp.router(
      title: 'ShowScape',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        if (isSimpleMode) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: const TextScaler.linear(1.35),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
