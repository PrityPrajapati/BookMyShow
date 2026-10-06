import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/features/seats/domain/models/seat_layout.dart';
import 'package:showscape/features/seats/presentation/widgets/interactive_seat_viewer.dart';

void main() {
  group('SeatMap (InteractiveSeatViewer) Widget Tests', () {
    testWidgets('Tap selects available seat and ignores booked seat', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final availableSeat = const Seat(
        id: 'A1',
        row: 'A',
        col: 1,
        seatNumber: 'A1',
        type: SeatType.standard,
        category: 'Classic',
        state: SeatState.available,
      );

      final bookedSeat = const Seat(
        id: 'A2',
        row: 'A',
        col: 2,
        seatNumber: 'A2',
        type: SeatType.standard,
        category: 'Classic',
        state: SeatState.booked,
      );

      final layout = SeatLayout(
        id: 'test_layout',
        name: 'Test Screen',
        screenType: 'Standard',
        totalSeats: 2,
        rows: [
          SeatRow(
            rowLabel: 'A',
            category: 'Classic',
            price: 250,
            seats: [availableSeat, bookedSeat],
          ),
        ],
      );

      final tappedSeats = <Seat>[];
      final selectedSeatIds = <String>{};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return InteractiveSeatViewer(
                  layout: layout,
                  selectedSeatIds: selectedSeatIds,
                  onSeatTapped: (seat) {
                    tappedSeats.add(seat);
                    setState(() {
                      if (selectedSeatIds.contains(seat.id)) {
                        selectedSeatIds.remove(seat.id);
                      } else {
                        selectedSeatIds.add(seat.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Allow initial paint & layout callback to compute seat boxes
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state<InteractiveSeatViewerState>(find.byType(InteractiveSeatViewer));

      // Find the computed box for available seat A1
      final a1Box = state.computedBoxes.firstWhere((b) => b.seat.id == 'A1');

      // Find the computed box for booked seat A2
      final a2Box = state.computedBoxes.firstWhere((b) => b.seat.id == 'A2');

      // 1. Tap on available seat A1
      state.handleTapAt(a1Box.rect.center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify available seat A1 was selected
      expect(tappedSeats.length, 1);
      expect(tappedSeats.first.id, 'A1');
      expect(selectedSeatIds.contains('A1'), isTrue);

      // 2. Tap on booked seat A2
      state.handleTapAt(a2Box.rect.center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify booked seat A2 was ignored (not added to tappedSeats or selectedSeatIds)
      expect(tappedSeats.length, 1);
      expect(selectedSeatIds.contains('A2'), isFalse);
    });
  });
}
