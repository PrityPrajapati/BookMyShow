import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/router/auth_state.dart';
import 'package:showscape/core/router/placeholder_screens.dart'
    hide TicketsScreen, TicketDetailScreen, ProfileScreen, DiningScreen, DiningDetailScreen, GoldScreen, ScoutScreen;
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/router/scaffold_with_nav_bar.dart';
import 'package:showscape/core/router/page_transitions.dart';
import 'package:showscape/core/widgets/design_preview_screen.dart';
import 'package:showscape/features/debug/presentation/screens/ai_debug_screen.dart';
import 'package:showscape/features/dining/presentation/screens/dining_detail_screen.dart';
import 'package:showscape/features/dining/presentation/screens/dining_screen.dart';
import 'package:showscape/features/gold/presentation/screens/gold_screen.dart';
import 'package:showscape/features/notifications/presentation/screens/notifications_centre_screen.dart';
import 'package:showscape/features/auth/presentation/screens/signup_screen.dart';
import 'package:showscape/features/profile/presentation/screens/profile_screen.dart';
import 'package:showscape/features/scanner/presentation/screens/staff_scanner_screen.dart';
import 'package:showscape/features/scout_ai/presentation/screens/scout_screen.dart';
import 'package:showscape/features/tickets/presentation/screens/ticket_detail_screen.dart';
import 'package:showscape/features/tickets/presentation/screens/tickets_screen.dart';

// Navigator Keys for Root and Tab Shells
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _rootNavigatorKey = rootNavigatorKey;
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeTab');
final _exploreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'exploreTab');
final _scoutNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'scoutTab');
final _ticketsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'ticketsTab');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileTab');

/// Provider for Application GoRouter configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final location = state.uri.toString();

      // Support deep link handling for custom URI scheme (e.g. showscape://ticket/123)
      if (state.uri.scheme == 'showscape') {
        if (state.uri.host == 'ticket' || state.uri.path.startsWith('/ticket')) {
          final ticketId = state.uri.pathSegments.isNotEmpty
              ? state.uri.pathSegments.last
              : (state.uri.queryParameters['id'] ?? 'default');
          return AppRoutes.ticketPath(ticketId);
        }
      }

      final isAuthRoute = location == AppRoutes.onboarding ||
          location == AppRoutes.login ||
          location == AppRoutes.signup;

      // 1. Unauthenticated users are redirected to /onboarding
      if (!isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.onboarding;
      }

      // 2. Authenticated users trying to access onboarding/login are routed to Home
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // -----------------------------------------------------------------
      // StatefulShellRoute for 5 Bottom Navigation Tabs
      // -----------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 1. Home Branch
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),

          // 2. Explore Branch
          StatefulShellBranch(
            navigatorKey: _exploreNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ExploreScreen(),
                ),
              ),
            ],
          ),

          // 3. Scout AI Branch (Center Tab)
          StatefulShellBranch(
            navigatorKey: _scoutNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.scout,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ScoutScreen(),
                ),
              ),
            ],
          ),

          // 4. Tickets Branch
          StatefulShellBranch(
            navigatorKey: _ticketsNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.tickets,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TicketsScreen(),
                ),
              ),
            ],
          ),

          // 5. Profile Branch
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),

      // -----------------------------------------------------------------
      // Auth & Onboarding Routes
      // -----------------------------------------------------------------
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.login,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.signup,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const SignupScreen(),
        ),
      ),

      // -----------------------------------------------------------------
      // Event & Booking Flow Routes
      // -----------------------------------------------------------------
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.eventDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: EventDetailScreen(id: id),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.showtimes,
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: ShowtimesScreen(eventId: eventId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.seats,
        pageBuilder: (context, state) {
          final showId = state.pathParameters['showId'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: SeatsScreen(showId: showId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.food,
        pageBuilder: (context, state) {
          final bookingDraftId = state.pathParameters['bookingDraftId'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: FoodScreen(bookingDraftId: bookingDraftId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.parking,
        pageBuilder: (context, state) {
          final venueId = state.pathParameters['venueId'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: ParkingScreen(venueId: venueId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.checkout,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.paymentResult,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const PaymentResultScreen(),
        ),
      ),

      // -----------------------------------------------------------------
      // Ticket & Post-Booking Routes
      // -----------------------------------------------------------------
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.ticketDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: TicketDetailScreen(id: id),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.transferTicket,
        pageBuilder: (context, state) {
          final ticketId = state.pathParameters['ticketId'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: TransferTicketScreen(ticketId: ticketId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.venueMap,
        pageBuilder: (context, state) {
          final venueId = state.pathParameters['venueId'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: VenueMapScreen(venueId: venueId),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.staffScanner,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const StaffScannerScreen(),
        ),
      ),

      // -----------------------------------------------------------------
      // Dining & Membership Routes
      // -----------------------------------------------------------------
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.dining,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const DiningScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.diningDetail,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? 'unknown';
          return buildSharedAxisTransitionPage(
            context: context,
            state: state,
            child: DiningDetailScreen(id: id),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.gold,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const GoldScreen(),
        ),
      ),

      // -----------------------------------------------------------------
      // Notifications & Reminders
      // -----------------------------------------------------------------
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const NotificationsCentreScreen(),
        ),
      ),

      // -----------------------------------------------------------------
      // Development & Design System Preview & AI Debug
      // -----------------------------------------------------------------
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.designPreview,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const DesignPreviewScreen(),
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.aiDebug,
        pageBuilder: (context, state) => buildSharedAxisTransitionPage(
          context: context,
          state: state,
          child: const AiDebugScreen(),
        ),
      ),
    ],
  );
});
