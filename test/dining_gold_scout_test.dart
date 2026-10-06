import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/features/auth/domain/models/app_user.dart';
import 'package:showscape/features/dining/domain/models/reservation.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/dining/presentation/providers/dining_providers.dart';
import 'package:showscape/features/dining/presentation/widgets/dine_suggestions_card.dart';
import 'package:showscape/features/dining/presentation/widgets/table_reservation_sheet.dart';
import 'package:showscape/features/gold/presentation/screens/gold_screen.dart';
import 'package:showscape/features/scout_ai/presentation/screens/scout_screen.dart';
import 'package:showscape/features/scout_ai/presentation/widgets/plan_card.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/features/showtimes/presentation/widgets/showtime_chip.dart';
import 'package:showscape/core/repositories/repositories.dart';
import 'package:showscape/features/checkout/domain/models/price_breakdown.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/tickets/presentation/widgets/night_out_itinerary_card.dart';
import 'package:showscape/services/ai/ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_dining_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  final dummyRestaurant = const Restaurant(
    id: 'dine_aer_rooftop',
    name: 'AER Rooftop Lounge',
    cuisine: ['Asian Tapas', 'Cocktails', 'Rooftop'],
    rating: 4.8,
    reviewCount: 340,
    costForTwo: 2400.0,
    address: '1/136, Dr E Moses Rd, Worli',
    city: 'Mumbai',
    distanceKm: 0.8,
    imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
    bannerUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947',
    openTime: '5:00 PM',
    closeTime: '1:30 AM',
    amenities: ['Rooftop View', 'Full Bar', 'Valet Parking', 'Live DJ'],
    hasTableBooking: true,
    isPureVeg: false,
    featuredDishes: ['Truffle Dimsums', 'Spicy Salmon Roll', 'Signature Smoked Robata'],
  );

  const dummyUser = AppUser(
    id: 'usr_001',
    name: 'Alex Rivera',
    email: 'alex@example.com',
    phone: '+919876543210',
    isGoldMember: false,
  );

  group('Dining Module Tests', () {
    test('DiningFilterNotifier toggles filters properly', () {
      final notifier = DiningFilterNotifier();
      expect(notifier.state.vegOnly, false);
      expect(notifier.state.selectedCuisine, null);

      notifier.toggleVegOnly(true);
      expect(notifier.state.vegOnly, true);

      notifier.setCuisine('Italian');
      expect(notifier.state.selectedCuisine, 'Italian');

      // Toggling same cuisine clears it
      notifier.setCuisine('Italian');
      expect(notifier.state.selectedCuisine, null);

      notifier.setMaxCostForTwo(2000.0);
      expect(notifier.state.maxCostForTwo, 2000.0);

      notifier.reset();
      expect(notifier.state.vegOnly, false);
      expect(notifier.state.maxCostForTwo, null);
    });

    test('UserReservationsNotifier adds and retrieves booking reservation', () {
      final notifier = UserReservationsNotifier();
      final res = Reservation(
        id: 'res_001',
        restaurantId: 'dine_aer_rooftop',
        restaurantName: 'AER Rooftop Lounge',
        userId: 'usr_001',
        guestName: 'Alex Rivera',
        guestPhone: '+91 98765 43210',
        partySize: 2,
        date: DateTime.now(),
        timeSlot: '6:30 PM',
        specialRequests: 'BOOKING:bkg_test_01;TYPE:DINE BEFORE',
      );

      notifier.addReservation(res);
      expect(notifier.state.length, 1);

      final found = notifier.getReservationForBooking('bkg_test_01');
      expect(found, isNotNull);
      expect(found?.restaurantName, 'AER Rooftop Lounge');

      // Non-existent booking returns null
      expect(notifier.getReservationForBooking('bkg_other'), isNull);
    });

    testWidgets('TableReservationSheet allows party size, slot selection and reservation confirmation',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TableReservationSheet(
                restaurant: dummyRestaurant,
                initialTimeSlot: '6:30 PM',
                linkedBookingId: 'bkg_123',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AER Rooftop Lounge'), findsOneWidget);
      expect(find.text('PARTY SIZE'), findsOneWidget);
      expect(find.text('AVAILABLE TIME SLOTS'), findsOneWidget);

      // Select party size 4
      final partySize4 = find.text('4 Guests');
      if (partySize4.evaluate().isNotEmpty) {
        await tester.tap(partySize4);
        await tester.pump();
      }

      // Tap confirm button
      final confirmBtn = find.textContaining('Confirm Reservation');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      // Should show Reservation Confirmed receipt
      expect(find.text('Table Reserved!'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('DineSuggestionsCard displays suggestions aligned with showtime',
        (tester) async {
      final showStart = DateTime(2026, 10, 2, 19, 30);
      final showEnd = DateTime(2026, 10, 2, 22, 00);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allRestaurantsProvider.overrideWith((ref) => Future.value([dummyRestaurant])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DineSuggestionsCard(
                showStart: showStart,
                showEnd: showEnd,
                venueId: 'venue_01',
                bookingId: 'bkg_sample',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('COMPLETE YOUR NIGHT OUT'), findsOneWidget);
      expect(find.text('Dine Before'), findsOneWidget);
      expect(find.text('Dine After'), findsOneWidget);
    });
  });

  group('Gold Screen & Membership Tests', () {
    testWidgets('GoldScreen renders shimmering card, benefits list, savings tracker and Join Gold button',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Future.value(dummyUser)),
            userGoldSavingsProvider.overrideWithValue(1340.0),
          ],
          child: const MaterialApp(
            home: GoldScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('ShowScape Gold'), findsOneWidget);
      expect(find.text('SHOWSCAPE GOLD'), findsOneWidget);
      expect(find.text('YOUR SAVINGS TRACKER'), findsOneWidget);
      expect(find.text('Zero Convenience Fee'), findsOneWidget);
      expect(find.text('48-Hour Early Access to Presales'), findsOneWidget);
      expect(find.text('₹999'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('ShowtimeChip presale early access locks non-Gold users with 1d 14h countdown & Notify me',
        (tester) async {
      final presaleShow = Show(
        id: 'show_presale_01',
        eventId: 'event_01',
        venueId: 'venue_01',
        screenId: 'screen_01',
        screenName: 'Audi 1 IMAX',
        startTime: DateTime.now().add(const Duration(hours: 40)),
        format: ShowFormat.imax2D,
        language: 'Hindi',
        categoryPrices: {'Standard': 450.0},
        occupancyPct: 0.20,
        isPresale: true,
        seatLayoutId: 'layout_01',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowtimeChip(
              show: presaleShow,
              cinemaName: 'PVR INOX Palladium',
              isUserGold: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Non-gold sees lock and Opens in 1d 14h
      expect(find.text('Opens in 1d 14h'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

      // Tapping opens Gold Presale Window dialog
      await tester.tap(find.byType(ShowtimeChip));
      await tester.pumpAndSettle();

      expect(find.text('Gold Presale Window'), findsOneWidget);
      expect(find.text('Opens for everyone in 1d 14h'), findsOneWidget);
      expect(find.text('Notify me'), findsOneWidget);
      expect(find.text('Upgrade to Gold'), findsOneWidget);
    });
  });

  group('AI Service & Scout Screen Tests', () {
    test('Rate Limiter enforces 20 requests per hour limit', () {
      final limiter = AiRateLimiter();
      const user = 'usr_test_limit';

      for (int i = 0; i < 20; i++) {
        expect(limiter.isAllowed(user), isTrue);
      }

      // 21st request should be blocked
      expect(limiter.isAllowed(user), isFalse);
      expect(limiter.remainingRequests(user), 0);
    });

    test('AiSummaryCache caches and returns generated summaries', () {
      final cache = AiSummaryCache();
      const text = 'Epic sci-fi action film with Paul Atreides uniting with the Fremen.';
      expect(cache.get(text), isNull);

      cache.put(text, 'A magnificent sci-fi spectacle.');
      expect(cache.get(text), 'A magnificent sci-fi spectacle.');
    });

    testWidgets('ScoutScreen renders greeting, context suggestion chips, and mic button',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Future.value(dummyUser)),
          ],
          child: const MaterialApp(
            home: ScoutScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Scout AI'), findsOneWidget);
      expect(find.text('SUGGESTED FOR YOU'), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('PlanCard renders timeline (show -> dinner -> parking), budget meter and PricingEngine total',
        (tester) async {
      final samplePlan = {
        'id': 'plan_bandra_datenight_01',
        'title': 'Date Night Saturday in Bandra',
        'targetBudget': 2500.0,
        'isImpossibleBudget': false,
        'hasParking': true,
        'currentShowIndex': 0,
        'currentRestaurantIndex': 0,
        'shows': [
          {
            'id': 'show_comedy_01',
            'showId': 'show_comedy_bandra_01',
            'eventId': 'event_comedy_01',
            'type': 'show',
            'time': '7:00 PM',
            'title': 'Rahul Subramanian: Who Are You? (Live)',
            'subtitle': 'Bal Gandharva Rang Mandir, Bandra West',
            'imageUrl': 'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=500',
            'price': 998.0,
            'unitPrice': 499.0,
            'seats': ['D-4', 'D-5'],
            'venueId': 'venue_bandra_01',
          },
          {
            'id': 'show_comedy_02',
            'showId': 'show_comedy_bandra_02',
            'eventId': 'event_comedy_02',
            'type': 'show',
            'time': '7:30 PM',
            'title': 'Biswa Kalyan Rath: Live & Raw Stand-Up',
            'subtitle': 'St. Andrews Auditorium, Bandra West',
            'imageUrl': 'https://images.unsplash.com/photo-1514306191717-452ec28c7814?w=500',
            'price': 1198.0,
            'unitPrice': 599.0,
            'seats': ['C-12', 'C-13'],
            'venueId': 'venue_bandra_02',
          },
        ],
        'restaurants': [
          {
            'id': 'dine_01',
            'restaurantId': 'dine_bastian_bandra',
            'type': 'dinner',
            'time': '9:30 PM',
            'title': 'Bastian Bandra',
            'subtitle': 'Seafood & Asian Tapas • Flat 20% off after show',
            'imageUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
            'price': 1050.0,
          },
        ],
        'parking': {
          'id': 'park_01',
          'type': 'parking',
          'time': '6:45 PM',
          'title': 'Reserved Valet & 4-Wheeler Parking',
          'subtitle': 'Basement P1 (Guaranteed spot under venue)',
          'imageUrl': 'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=500',
          'price': 150.0,
        },
      };

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Future.value(dummyUser)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: PlanCard(plan: samplePlan),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify Timeline items
      expect(find.text('Date Night Saturday in Bandra'), findsOneWidget);
      expect(find.text('Rahul Subramanian: Who Are You? (Live)'), findsOneWidget);
      expect(find.text('Bastian Bandra'), findsOneWidget);
      expect(find.text('Reserved Valet & 4-Wheeler Parking'), findsOneWidget);

      // Verify PricingEngine calculation and budget meter
      expect(find.textContaining('under budget'), findsOneWidget);
      expect(find.text('PACKAGE TOTAL'), findsOneWidget);

      // Verify Action buttons
      expect(find.text('Swap show'), findsOneWidget);
      expect(find.text('Swap dining'), findsOneWidget);
      expect(find.text('Remove park'), findsOneWidget);
      expect(find.textContaining('Book this plan'), findsOneWidget);

      // Test Swap Show button
      await tester.tap(find.text('Swap show'));
      await tester.pump();
      expect(find.text('Biswa Kalyan Rath: Live & Raw Stand-Up'), findsOneWidget);

      // Test Remove Parking button
      await tester.tap(find.text('Remove park'));
      await tester.pump();
      expect(find.text('Add park'), findsOneWidget);
    });

    test('MockAiService parses natural language query for Date Night near Bandra under ₹2,500', () async {
      final aiService = MockAiService(
        eventRepo: MockEventRepository(),
        showRepo: MockShowRepository(),
        seatRepo: MockSeatRepository(),
        diningRepo: MockDiningRepository(),
      );

      final stream = aiService.chat([
        AiMessage(
          id: 'user_q1',
          role: AiMessageRole.user,
          content: 'Date night Saturday near Bandra under ₹2,500, something funny',
          timestamp: DateTime.now(),
        ),
      ]);

      final messages = await stream.toList();
      expect(messages.isNotEmpty, isTrue);

      final msg = messages.last;
      expect(msg.plan, isNotNull);
      final plan = msg.plan!;
      expect(plan['targetBudget'], 2500.0);
      expect(plan['isImpossibleBudget'], isFalse);
      expect(plan['shows'], isNotEmpty);
      expect(plan['restaurants'], isNotEmpty);
      expect(plan['parking'], isNotNull);
      expect(msg.content, contains('₹2500'));
    });

    test('MockAiService handles impossible budget queries by explaining and offering closest package', () async {
      final aiService = MockAiService(
        eventRepo: MockEventRepository(),
        showRepo: MockShowRepository(),
        seatRepo: MockSeatRepository(),
        diningRepo: MockDiningRepository(),
      );

      final stream = aiService.chat([
        AiMessage(
          id: 'user_q2',
          role: AiMessageRole.user,
          content: 'Date night under ₹1,000 near Bandra',
          timestamp: DateTime.now(),
        ),
      ]);

      final messages = await stream.toList();
      expect(messages.isNotEmpty, isTrue);

      final msg = messages.last;
      expect(msg.plan, isNotNull);
      final plan = msg.plan!;
      expect(plan['targetBudget'], 1000.0);
      expect(plan['isImpossibleBudget'], isTrue);
      // Explains entry pass pricing and provides closest package
      expect(msg.content, contains('under ₹1000'));
      expect(msg.content, contains('closest, most value-packed option at ₹1,598'));
    });

    testWidgets('NightOutItineraryCard renders grouped show, dining and parking steps with buffer',
        (WidgetTester tester) async {
      final now = DateTime.now();
      final testBooking = Booking(
        id: 'b_datenight_99',
        bookingNumber: 'SS-DN-99',
        userId: 'user_123',
        eventId: 'event_comedy_01',
        eventTitle: 'Rahul Subramanian: Who Are You? (Live)',
        venueId: 'venue_bandra_01',
        venueName: 'Bal Gandharva Rang Mandir, Bandra',
        showId: 'show_comedy_bandra_01',
        showTime: now.add(const Duration(hours: 3)),
        bookingTime: now,
        tickets: [
          Ticket(
            id: 't_01',
            bookingId: 'b_datenight_99',
            seatId: 's_01',
            seatNumber: 'D-4',
            row: 'D',
            col: 4,
            category: 'Gold',
            price: 499.0,
            qrData: 'SECURE_D4',
            status: TicketStatus.active,
          ),
          Ticket(
            id: 't_02',
            bookingId: 'b_datenight_99',
            seatId: 's_02',
            seatNumber: 'D-5',
            row: 'D',
            col: 5,
            category: 'Gold',
            price: 499.0,
            qrData: 'SECURE_D5',
            status: TicketStatus.active,
          ),
        ],
        parkingLot: const ParkingLot(
          id: 'park_bandra_01',
          name: 'Bal Gandharva Basement Valet',
          vehicleType: VehicleType.fourWheeler,
          capacity: 100,
          available: 42,
          hourlyRate: 50.0,
          flatRate: 150.0,
          isCovered: true,
          hasValet: true,
        ),
        priceBreakdown: const PriceBreakdown(
          basePrice: 998.0,
          convenienceFee: 117.76,
          gst: 21.20,
          parkingTotal: 150.0,
          grandTotal: 1286.96,
        ),
        qrCodeData: 'BOOKING:b_datenight_99',
      );

      final testReservation = Reservation(
        id: 'res_b_datenight_99',
        restaurantId: 'dine_bastian_bandra',
        restaurantName: 'Bastian Bandra',
        userId: 'user_123',
        guestName: 'Alex Doe',
        guestPhone: '+91 9876543210',
        partySize: 2,
        date: now,
        timeSlot: '9:30 PM',
        status: ReservationStatus.confirmed,
        specialRequests: 'BOOKING:b_datenight_99;TYPE:NIGHT_OUT',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: NightOutItineraryCard(
                booking: testBooking,
                reservation: testReservation,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Itinerary Header
      expect(find.text('NIGHT OUT ITINERARY'), findsOneWidget);

      // Verify 3 steps rendered
      expect(find.text('Reserved Parking at Bal Gandharva Basement Valet'), findsOneWidget);
      expect(find.text('Direct entrance to venue'), findsOneWidget);
      expect(find.text('Rahul Subramanian: Who Are You? (Live)'), findsOneWidget);
      expect(find.text('15 min walk buffer'), findsOneWidget);
      expect(find.text('Dinner at Bastian Bandra'), findsOneWidget);
      expect(find.text('Party of 2 guests • 20% off with ticket'), findsOneWidget);
    });
  });
}
