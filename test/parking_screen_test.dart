import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/features/parking/presentation/screens/parking_screen.dart';
import 'package:showscape/features/parking/presentation/widgets/parking_lot_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testLot2W = const ParkingLot(
    id: 'prk_test_2w',
    name: 'Basement 1 Two-Wheeler',
    vehicleType: VehicleType.twoWheeler,
    capacity: 200,
    available: 42,
    hourlyRate: 40.0,
    flatRate: 100.0,
    isCovered: true,
  );

  final testLot4W = const ParkingLot(
    id: 'prk_test_4w',
    name: 'Basement 2 Four-Wheeler',
    vehicleType: VehicleType.fourWheeler,
    capacity: 300,
    available: 120,
    hourlyRate: 80.0,
    flatRate: 250.0,
    isCovered: true,
    hasValet: true,
  );

  final testLotEV = const ParkingLot(
    id: 'prk_test_ev',
    name: 'Basement 2 EV Supercharging',
    vehicleType: VehicleType.ev,
    capacity: 25,
    available: 0, // Sold out
    hourlyRate: 120.0,
    flatRate: 350.0,
    isCovered: true,
  );

  final testVenue = Venue(
    id: 'test_venue_1',
    name: 'PVR INOX Grand',
    type: VenueType.cinema,
    address: '462 High Street',
    city: 'Mumbai',
    state: 'Maharashtra',
    geo: const GeoLocation(
      latitude: 18.99,
      longitude: 72.82,
      formattedAddress: 'High Street, Mumbai',
    ),
    amenities: ['IMAX', 'Valet Parking'],
    parkingLots: [testLot2W, testLot4W, testLotEV],
    imageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c',
    rating: 4.8,
    totalScreens: 8,
  );

  group('Parking Screen & Components Tests', () {
    testWidgets('ParkingLotCard shows availability, walking distance, and rate',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParkingLotCard(
              lot: testLot2W,
              isSelected: false,
              durationMinutes: 180, // 3 hours
              onSelect: () {},
            ),
          ),
        ),
      );

      // Verify availability
      expect(find.text('42 of 200 left'), findsOneWidget);
      expect(find.text('2-Wheeler Parking'), findsOneWidget);
      expect(find.text('2 min walk • Level -1, Bay A'), findsOneWidget);

      // 3 hours @ 40/hr = 120
      expect(find.text('₹120'), findsOneWidget);
      expect(find.text('₹40/hr × 3h'), findsOneWidget);
    });

    testWidgets('Sold out parking lot card is disabled and displays Sold Out',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ParkingLotCard(
              lot: testLotEV, // available: 0
              isSelected: false,
              durationMinutes: 180,
              onSelect: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Sold Out'), findsOneWidget);
      expect(find.text('0 of 25 slots left'), findsOneWidget);

      // Attempt to tap sold out card
      await tester.tap(find.text('Sold Out'));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets(
        'ParkingScreen calculates duration as show runtime + 30 mins buffer and validates plate',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          venueDetailProvider('test_venue_1')
              .overrideWith((ref) => Future.value(testVenue)),
        ],
      );
      addTearDown(container.dispose);

      // Set show runtime to 150 mins
      container.read(bookingDraftProvider.notifier).initForShow(
            draftId: 'draft_test',
            showId: 'show_001',
            venueId: 'test_venue_1',
            durationMinutes: 150,
          );

      final router = GoRouter(
        initialLocation: '/parking',
        routes: [
          GoRoute(
            path: '/parking',
            builder: (context, state) =>
                const ParkingScreen(venueId: 'test_venue_1'),
          ),
          GoRoute(
            path: '/checkout',
            builder: (context, state) =>
                const Scaffold(body: Text('Checkout Screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Wait for venue detail to load
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify auto-calculated duration: 150m show + 30m buffer = 180m (~3.0 hrs)
      expect(
        find.text('Auto-calculated Parking Duration: 180m (~3.0 hrs)'),
        findsOneWidget,
      );

      // Verify Skip parking button exists
      expect(find.text('Skip parking'), findsNWidgets(2)); // in AppBar and bottom

      // Verify all lot types
      expect(find.text('2-Wheeler Parking'), findsOneWidget);
      expect(find.text('4-Wheeler Parking'), findsOneWidget);
      expect(find.text('EV Charging & Parking'), findsOneWidget);

      // Enter an invalid Indian vehicle registration plate
      final vehicleInput = find.byType(TextFormField);
      expect(vehicleInput, findsOneWidget);

      await tester.enterText(vehicleInput, 'INVALID123');
      await tester.pump();

      // Tap 4-Wheeler parking lot to select it
      await tester.tap(find.text('4-Wheeler Parking'));
      await tester.pump();

      // Tap Proceed button
      final proceedButton = find.text('Add Parking • Proceed');
      expect(proceedButton, findsOneWidget);
      await tester.tap(proceedButton);
      await tester.pump();

      // Validation error should show
      expect(
        find.text('Enter a valid Indian vehicle number (e.g. MH12AB1234)'),
        findsOneWidget,
      );

      // Now enter valid vehicle plate: MH12AB1234
      await tester.enterText(vehicleInput, 'MH12AB1234');
      await tester.pump();

      // Tap proceed again
      await tester.tap(proceedButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Navigated to checkout!
      expect(find.text('Checkout Screen'), findsOneWidget);

      // Check draft was updated
      final updatedDraft = container.read(bookingDraftProvider);
      expect(updatedDraft.parking, isNotNull);
      expect(updatedDraft.parking!.vehicleNumber, 'MH12AB1234');
      expect(updatedDraft.parking!.charge, 240.0); // 3 hrs * 80
    });
  });
}
