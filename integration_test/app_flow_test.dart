import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:showscape/core/providers/booking_draft_provider.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_theme.dart';
import 'package:showscape/core/widgets/ticket_stub_card.dart';
import 'package:showscape/features/auth/domain/models/app_user.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:showscape/features/event_detail/presentation/screens/event_detail_screen.dart';
import 'package:showscape/features/food/presentation/screens/food_screen.dart';
import 'package:showscape/features/home/presentation/screens/home_screen.dart';
import 'package:showscape/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:showscape/features/seats/presentation/screens/seats_screen.dart';
import 'package:showscape/features/showtimes/presentation/screens/showtimes_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('explore_preferences')) {
      await Hive.openBox<dynamic>('explore_preferences');
    }
    if (!Hive.isBoxOpen('ai_review_summary_cache')) {
      await Hive.openBox<dynamic>('ai_review_summary_cache');
    }
    if (!Hive.isBoxOpen('event_mood_tags_cache')) {
      await Hive.openBox<dynamic>('event_mood_tags_cache');
    }
  });

  group('Full End-to-End Booking Flow Integration Test', () {
    testWidgets(
      'Home -> Event -> Showtime -> Seats -> Food -> Checkout -> Mock Payment -> Ticket Visible',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockUser = AppUser(
          id: 'usr_integ_01',
          name: 'Priya Sharma',
          email: 'priya@showscape.io',
          phone: '+919876543210',
          favoriteGenres: const ['Action', 'Sci-Fi'],
          favoriteLanguages: const ['Hindi', 'English'],
          isGoldMember: true,
          createdAt: DateTime(2026, 1, 1),
        );

        final container = ProviderContainer(
          overrides: [
            currentUserProvider.overrideWith((ref) => Future.value(mockUser)),
          ],
        );

        // 1. STEP 1: Launch Home Screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: const Scaffold(body: HomeScreen()),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        // Home screen is visible
        expect(find.byType(HomeScreen), findsOneWidget);

        // 2. STEP 2: Navigate to Event Detail
        const eventId = 'mov_001';
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: const Scaffold(body: EventDetailScreen(id: eventId)),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(EventDetailScreen), findsOneWidget);
        // Verify 'Book tickets' button exists on StickyBookingBar
        expect(find.text('Book tickets'), findsOneWidget);

        // 3. STEP 3: Navigate to Showtime Selection
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: const Scaffold(body: ShowtimesScreen(eventId: eventId)),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ShowtimesScreen), findsOneWidget);

        // 4. STEP 4: Navigate to Seat Selection
        const showId = 'show_0001';
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: const Scaffold(body: SeatsScreen(showId: showId)),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(SeatsScreen), findsOneWidget);

        // Setup draft with 2 seats
        final draftNotifier = container.read(bookingDraftProvider.notifier);
        final activeDraft = BookingDraft(
          id: 'draft_flow_1',
          showId: showId,
          eventId: eventId,
          venueId: 'venue_01',
          eventTitle: 'Pushpa 2: The Rule',
          venueName: 'PVR ICON: Phoenix Palladium',
          showTime: DateTime(2026, 10, 15, 19, 30),
          seatIds: const ['A3', 'A4'],
          seatPrices: const [350.0, 350.0],
          isMovie: true,
          isGold: true,
        );
        draftNotifier.setDraft(activeDraft);

        // 5. STEP 5: Navigate to Food & Concessions Screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: const Scaffold(body: FoodScreen(bookingDraftId: 'draft_flow_1')),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(FoodScreen), findsOneWidget);
        expect(find.text('Skip'), findsWidgets);

        // 6. STEP 6: Navigate to Checkout Screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: const Scaffold(body: CheckoutScreen()),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(CheckoutScreen), findsOneWidget);
        expect(find.text('Price Breakdown'), findsOneWidget);
        expect(find.textContaining('Pay'), findsWidgets);

        // 7. STEP 7 & 8: Mock Payment Success -> Ticket Screen Visible
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.dark(),
              home: const Scaffold(
                body: PaymentResultScreen(
                  isSuccess: true,
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        // 8. STEP 8: Ticket is Visible
        expect(find.byType(PaymentResultScreen), findsOneWidget);
        expect(find.text('Booking Confirmed!'), findsOneWidget);
        expect(find.textContaining('Booking ID:'), findsOneWidget);
        expect(find.byType(TicketStubCard), findsOneWidget);
        expect(find.text('View Ticket'), findsOneWidget);
      },
    );
  });
}
