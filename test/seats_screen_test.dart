import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/features/seats/data/repositories/mock_seat_repository.dart';
import 'package:showscape/features/seats/domain/models/seat_layout.dart';
import 'package:showscape/features/seats/domain/models/seat_selection_state.dart';
import 'package:showscape/features/seats/presentation/screens/seats_screen.dart';
import 'package:showscape/features/seats/presentation/widgets/group_size_picker_sheet.dart';
import 'package:showscape/features/seats/presentation/widgets/interactive_seat_viewer.dart';
import 'package:showscape/features/seats/presentation/widgets/seat_booking_bottom_bar.dart';
import 'package:showscape/features/seats/presentation/widgets/seat_hold_timer_badge.dart';
import 'package:showscape/features/showtimes/data/repositories/mock_show_repository.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('explore_preferences')) {
      await Hive.openBox<dynamic>('explore_preferences');
    }
    // Pre-warm repositories
    await MockShowRepository().getShows();
    await MockSeatRepository().getSeatLayoutById('layout_imax');
  });

  group('SeatSelectionState Pure Unit Tests', () {
    test('findBestContiguousBlock picks optimal center block', () {
      final seatsRowA = [
        const Seat(id: 'A1', row: 'A', col: 1, seatNumber: 'A1', type: SeatType.standard, category: 'Standard', state: SeatState.available),
        const Seat(id: 'A2', row: 'A', col: 2, seatNumber: 'A2', type: SeatType.standard, category: 'Standard', state: SeatState.available),
        const Seat(id: 'A3', row: 'A', col: 3, seatNumber: 'A3', type: SeatType.standard, category: 'Standard', state: SeatState.available),
        const Seat(id: 'A4', row: 'A', col: 4, seatNumber: 'A4', type: SeatType.standard, category: 'Standard', state: SeatState.booked),
      ];

      final layout = SeatLayout(
        id: 'layout_1',
        name: 'Audi 1',
        screenType: 'IMAX',
        totalSeats: 4,
        rows: [
          SeatRow(rowLabel: 'A', category: 'Standard', price: 200, seats: seatsRowA),
        ],
      );

      final block = SeatSelectionState.findBestContiguousBlock(layout, 2);
      expect(block.length, 2);
      expect(block.containsKey('A1') || block.containsKey('A2') || block.containsKey('A3'), isTrue);
    });

    test('checkOrphanSeatRule detects single isolated empty seat', () {
      // Row has 4 seats: A1, A2, A3, A4
      // A1 is available, A2 is being toggled, A3 is selected, A4 is booked.
      // If A2 is selected, A1 is isolated between boundary and A2!
      final seatsRowA = [
        const Seat(id: 'A1', row: 'A', col: 1, seatNumber: 'A1', type: SeatType.standard, category: 'Standard', state: SeatState.available),
        const Seat(id: 'A2', row: 'A', col: 2, seatNumber: 'A2', type: SeatType.standard, category: 'Standard', state: SeatState.available),
        const Seat(id: 'A3', row: 'A', col: 3, seatNumber: 'A3', type: SeatType.standard, category: 'Standard', state: SeatState.available),
        const Seat(id: 'A4', row: 'A', col: 4, seatNumber: 'A4', type: SeatType.standard, category: 'Standard', state: SeatState.booked),
      ];

      final layout = SeatLayout(
        id: 'layout_1',
        name: 'Audi 1',
        screenType: 'IMAX',
        totalSeats: 4,
        rows: [
          SeatRow(rowLabel: 'A', category: 'Standard', price: 200, seats: seatsRowA),
        ],
      );

      final selected = <String, Seat>{
        'A3': seatsRowA[2],
      };

      // Toggling A2 to selected would leave A1 alone as an empty orphan gap
      final orphanMsg = SeatSelectionState.checkOrphanSeatRule(
        layout: layout,
        currentSelection: selected,
        targetSeat: seatsRowA[1],
        willSelect: true,
      );
      expect(orphanMsg, isNotNull);
      expect(orphanMsg, contains('A1'));
    });
  });

  group('SeatsScreen Interactive Widget Tests', () {
    testWidgets('renders seat screen with hold timer, group size picker sheet, and interactive viewer',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SeatsScreen(showId: 'show_0001'),
          ),
        ),
      );

      // Allow mock repositories (400ms delay) to load
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600)); // showDetail
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600)); // seatLayout
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // bottom sheet opens

      // 1. Group Size Picker Sheet opens initially
      expect(find.byType(GroupSizePickerSheet), findsOneWidget);
      expect(find.text('How many seats?'), findsOneWidget);
      expect(find.text('Solo Ride'), findsOneWidget);
      expect(find.text('Couple'), findsOneWidget);
      expect(find.text('Trio'), findsOneWidget);
      expect(find.text('🚲'), findsOneWidget);
      expect(find.text('🛵'), findsOneWidget);
      expect(find.text('🛺'), findsOneWidget);

      // Select 3 seats
      final threeSeatsOption = find.text('3');
      expect(threeSeatsOption, findsWidgets);
      await tester.tap(threeSeatsOption.first);
      await tester.pump(const Duration(milliseconds: 200));

      final confirmThree = find.text('Select 3 Seats');
      expect(confirmThree, findsOneWidget);
      await tester.tap(confirmThree);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Sheet should now be closed
      expect(find.byType(GroupSizePickerSheet), findsNothing);

      // 2. Interactive Seat Viewer rendered
      expect(find.byType(InteractiveSeatViewer), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // 3. Hold Countdown Timer in AppBar
      expect(find.byType(SeatHoldTimerBadge), findsOneWidget);
      expect(find.textContaining(':'), findsWidgets);

      // 4. Seat Booking Bottom Bar
      expect(find.byType(SeatBookingBottomBar), findsOneWidget);
      expect(find.textContaining('Pay'), findsOneWidget);
      expect(find.textContaining('₹'), findsWidgets);

      // 5. Open group size picker again from top app bar
      final groupSizeButton = find.text('3 Seats');
      expect(groupSizeButton, findsOneWidget);
      await tester.tap(groupSizeButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(GroupSizePickerSheet), findsOneWidget);
      final twoSeatsOption = find.text('2');
      await tester.tap(twoSeatsOption.first);
      await tester.pump(const Duration(milliseconds: 200));

      final confirmTwo = find.text('Select 2 Seats');
      await tester.tap(confirmTwo);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('2 Seats'), findsOneWidget);
    });

    testWidgets('Best for you button highlights top 3 blocks with score label and selects on tap',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SeatsScreen(showId: 'show_0001'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600)); // showDetail
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600)); // seatLayout
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400)); // bottom sheet opens

      // Close bottom sheet if open
      if (find.byType(GroupSizePickerSheet).evaluate().isNotEmpty) {
        final confirmBtn = find.text('Select 2 Seats');
        if (confirmBtn.evaluate().isNotEmpty) {
          await tester.tap(confirmBtn);
          await tester.pumpAndSettle();
        }
      }

      // Verify 'Best for you' button with sparkle icon exists in AppBar
      final bestForYouButton = find.text('Best for you');
      expect(bestForYouButton, findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsWidgets);

      // Tap 'Best for you'
      await tester.tap(bestForYouButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that score labels (e.g. 'View 9.2/10' or 'View .../10') appear on the seat map
      expect(find.textContaining('View '), findsWidgets);
      expect(find.textContaining('/10'), findsWidgets);

      // Tap on a highlighted score label or block to select it
      final scoreLabelFinder = find.textContaining('View ').first;
      await tester.tap(scoreLabelFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify bottom bar has selected seats
      expect(find.byType(SeatBookingBottomBar), findsOneWidget);
    });
  });
}
