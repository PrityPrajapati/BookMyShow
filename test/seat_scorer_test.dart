import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/features/checkout/domain/models/price_breakdown.dart';
import 'package:showscape/features/food/domain/models/fnb_combo.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/food/domain/services/combo_recommender.dart';
import 'package:showscape/features/seats/domain/models/seat_layout.dart';
import 'package:showscape/features/seats/domain/services/seat_scorer.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';

void main() {
  group('SeatScorer Pure Dart Unit Tests', () {
    test('View score prefers middle-to-rear third of rows over front third', () {
      const totalRows = 10; // rows 0 to 9

      // Front third: rows 0, 1, 2
      final scoreRow0 = SeatScorer.calculateViewScore(rowIndex: 0, totalRows: totalRows);
      final scoreRow1 = SeatScorer.calculateViewScore(rowIndex: 1, totalRows: totalRows);
      final scoreRow2 = SeatScorer.calculateViewScore(rowIndex: 2, totalRows: totalRows);

      // Middle-to-rear third: rows 3, 5, 7, 9
      final scoreRow3 = SeatScorer.calculateViewScore(rowIndex: 3, totalRows: totalRows);
      final scoreRow5 = SeatScorer.calculateViewScore(rowIndex: 5, totalRows: totalRows);
      final scoreRow7 = SeatScorer.calculateViewScore(rowIndex: 7, totalRows: totalRows);
      final scoreRow9 = SeatScorer.calculateViewScore(rowIndex: 9, totalRows: totalRows);

      // Front row is lowest
      expect(scoreRow0, closeTo(0.2, 0.01));
      expect(scoreRow1, greaterThan(scoreRow0));
      expect(scoreRow2, greaterThan(scoreRow1));

      // Middle-to-rear third scores are all significantly higher than front third
      expect(scoreRow3, greaterThan(scoreRow2));
      expect(scoreRow5, greaterThan(scoreRow3));
      expect(scoreRow7, greaterThanOrEqualTo(scoreRow5));
      expect(scoreRow7, closeTo(1.0, 0.05)); // sweet spot near row 7
      expect(scoreRow9, greaterThan(scoreRow2)); // even back row is better than front
    });

    test('Centre score computes 1 - |col - centreCol| / halfWidth', () {
      // Row with columns 1 to 11. Center is 6. Half width is 5.
      const minCol = 1.0;
      const maxCol = 11.0;

      // Center column: col = 6 -> score = 1.0
      final centerScore = SeatScorer.calculateCentreScore(col: 6.0, minCol: minCol, maxCol: maxCol);
      expect(centerScore, closeTo(1.0, 0.001));

      // Halfway between center and edge: col = 8.5 -> score = 1 - 2.5 / 5 = 0.5
      final halfScore = SeatScorer.calculateCentreScore(col: 8.5, minCol: minCol, maxCol: maxCol);
      expect(halfScore, closeTo(0.5, 0.001));

      // Left edge: col = 1 -> score = 0.0
      final leftEdge = SeatScorer.calculateCentreScore(col: 1.0, minCol: minCol, maxCol: maxCol);
      expect(leftEdge, closeTo(0.0, 0.001));

      // Right edge: col = 11 -> score = 0.0
      final rightEdge = SeatScorer.calculateCentreScore(col: 11.0, minCol: minCol, maxCol: maxCol);
      expect(rightEdge, closeTo(0.0, 0.001));
    });

    test('Distance score penalises first 3 rows monotonically', () {
      expect(SeatScorer.calculateDistanceScore(rowIndex: 0), 0.2);
      expect(SeatScorer.calculateDistanceScore(rowIndex: 1), 0.5);
      expect(SeatScorer.calculateDistanceScore(rowIndex: 2), 0.75);
      expect(SeatScorer.calculateDistanceScore(rowIndex: 3), 1.0);
      expect(SeatScorer.calculateDistanceScore(rowIndex: 7), 1.0);
    });

    test('Aisle preference is learned from user past bookings share of aisle seats', () {
      final now = DateTime.now();

      // Booking 1: 2 aisle tickets (col 1, col 14)
      final booking1 = Booking(
        id: 'b1',
        bookingNumber: 'SS-01',
        userId: 'u1',
        eventId: 'e1',
        venueId: 'v1',
        showId: 's1',
        showTime: now,
        bookingTime: now,
        tickets: [
          const Ticket(
            id: 't1',
            bookingId: 'b1',
            seatId: 's1',
            seatNumber: 'D1',
            row: 'D',
            col: 1,
            category: 'Classic',
            price: 200,
            qrData: 'qr1',
          ),
          const Ticket(
            id: 't2',
            bookingId: 'b1',
            seatId: 's2',
            seatNumber: 'D14',
            row: 'D',
            col: 14,
            category: 'Classic',
            price: 200,
            qrData: 'qr2',
          ),
        ],
        priceBreakdown: const PriceBreakdown(basePrice: 400, grandTotal: 450),
        qrCodeData: 'qr',
      );

      // Booking 2: 2 center tickets (col 6, col 7)
      final booking2 = Booking(
        id: 'b2',
        bookingNumber: 'SS-02',
        userId: 'u1',
        eventId: 'e1',
        venueId: 'v1',
        showId: 's1',
        showTime: now,
        bookingTime: now,
        tickets: [
          const Ticket(
            id: 't3',
            bookingId: 'b2',
            seatId: 's3',
            seatNumber: 'E6',
            row: 'E',
            col: 6,
            category: 'Classic',
            price: 200,
            qrData: 'qr3',
          ),
          const Ticket(
            id: 't4',
            bookingId: 'b2',
            seatId: 's4',
            seatNumber: 'E7',
            row: 'E',
            col: 7,
            category: 'Classic',
            price: 200,
            qrData: 'qr4',
          ),
        ],
        priceBreakdown: const PriceBreakdown(basePrice: 400, grandTotal: 450),
        qrCodeData: 'qr',
      );

      // 2 aisle seats out of 4 total -> 0.5 preference
      final pref = SeatScorer.learnAislePreference([booking1, booking2]);
      expect(pref, closeTo(0.5, 0.01));

      // Booking 1 only: 2 aisle out of 2 -> 1.0 preference
      final highAislePref = SeatScorer.learnAislePreference([booking1]);
      expect(highAislePref, closeTo(1.0, 0.01));

      // Empty history defaults to neutral 0.5
      expect(SeatScorer.learnAislePreference([]), 0.5);
    });

    test('Together bonus is 1.0 for contiguous available seats in same row and 0.0 otherwise', () {
      final s1 = const Seat(
        id: 's1',
        row: 'D',
        col: 4,
        seatNumber: 'D4',
        type: SeatType.standard,
        category: 'Classic',
        state: SeatState.available,
      );
      final s2 = const Seat(
        id: 's2',
        row: 'D',
        col: 5,
        seatNumber: 'D5',
        type: SeatType.standard,
        category: 'Classic',
        state: SeatState.available,
      );
      final s3 = const Seat(
        id: 's3',
        row: 'D',
        col: 6,
        seatNumber: 'D6',
        type: SeatType.standard,
        category: 'Classic',
        state: SeatState.available,
      );
      final sGap = const Seat(
        id: 'sGap',
        row: 'D',
        col: 8,
        seatNumber: 'D8',
        type: SeatType.standard,
        category: 'Classic',
        state: SeatState.available,
      );
      final sOtherRow = const Seat(
        id: 'sDiff',
        row: 'E',
        col: 5,
        seatNumber: 'E5',
        type: SeatType.standard,
        category: 'Classic',
        state: SeatState.available,
      );
      final sBooked = const Seat(
        id: 'sBooked',
        row: 'D',
        col: 5,
        seatNumber: 'D5',
        type: SeatType.standard,
        category: 'Classic',
        state: SeatState.booked,
      );

      // 3 contiguous available seats in same row
      expect(
        SeatScorer.calculateTogetherBonus(seats: [s1, s2, s3], requestedGroupSize: 3),
        1.0,
      );

      // Gap between seats
      expect(
        SeatScorer.calculateTogetherBonus(seats: [s1, sGap], requestedGroupSize: 2),
        0.0,
      );

      // Split across different rows
      expect(
        SeatScorer.calculateTogetherBonus(seats: [s1, sOtherRow], requestedGroupSize: 2),
        0.0,
      );

      // Contains booked seat
      expect(
        SeatScorer.calculateTogetherBonus(seats: [s1, sBooked], requestedGroupSize: 2),
        0.0,
      );
    });

    test('Composite score accurately applies formula weights: 0.35, 0.25, 0.20, 0.10, 0.10', () {
      final composite = SeatScorer.calculateCompositeScore(
        view: 1.0,
        centre: 1.0,
        distance: 1.0,
        aislePref: 1.0,
        togetherBonus: 1.0,
      );
      expect(composite, closeTo(1.0, 0.001));

      // Individual weight testing
      expect(
        SeatScorer.calculateCompositeScore(view: 1.0, centre: 0, distance: 0, aislePref: 0, togetherBonus: 0),
        closeTo(0.35, 0.001),
      );
      expect(
        SeatScorer.calculateCompositeScore(view: 0, centre: 1.0, distance: 0, aislePref: 0, togetherBonus: 0),
        closeTo(0.25, 0.001),
      );
      expect(
        SeatScorer.calculateCompositeScore(view: 0, centre: 0, distance: 1.0, aislePref: 0, togetherBonus: 0),
        closeTo(0.20, 0.001),
      );
      expect(
        SeatScorer.calculateCompositeScore(view: 0, centre: 0, distance: 0, aislePref: 1.0, togetherBonus: 0),
        closeTo(0.10, 0.001),
      );
      expect(
        SeatScorer.calculateCompositeScore(view: 0, centre: 0, distance: 0, aislePref: 0, togetherBonus: 1.0),
        closeTo(0.10, 0.001),
      );
    });

    test('findTopBlocks returns top 3 non-overlapping blocks with score label', () {
      // Create a 6-row layout with 10 seats per row
      final rows = <SeatRow>[];
      final rowLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

      for (int r = 0; r < rowLabels.length; r++) {
        final seats = <Seat>[];
        for (int c = 1; c <= 10; c++) {
          seats.add(
            Seat(
              id: 's_${rowLabels[r]}_$c',
              row: rowLabels[r],
              col: c,
              seatNumber: '${rowLabels[r]}$c',
              type: SeatType.standard,
              category: 'Classic',
              state: SeatState.available,
            ),
          );
        }
        rows.add(
          SeatRow(
            rowLabel: rowLabels[r],
            category: 'Classic',
            price: 250.0,
            seats: seats,
          ),
        );
      }

      final layout = SeatLayout(
        id: 'lay_test',
        name: 'Test Audi',
        screenType: 'Standard',
        totalSeats: 60,
        rows: rows,
      );

      final topBlocks = SeatScorer.findTopBlocks(layout: layout, groupSize: 2, limit: 3);

      expect(topBlocks.length, 3);

      // Verify each block has 2 seats and formatted score label
      for (final block in topBlocks) {
        expect(block.seats.length, 2);
        expect(block.scoreLabel, startsWith('View '));
        expect(block.scoreLabel, endsWith('/10'));
        expect(block.score, greaterThan(0.7)); // Middle rows should have strong score
      }

      // Verify blocks are distinct and do not overlap
      final allSeatIds = topBlocks.expand((b) => b.seats.map((s) => s.id)).toSet();
      expect(allSeatIds.length, 6);

      // The #1 block should be in the middle-to-rear third (Row D or E) and centered (cols 5-6)
      final topBlock = topBlocks.first;
      expect(['D', 'E'].contains(topBlock.row.rowLabel), isTrue);
      expect(topBlock.togetherBonus, 1.0);
    });
  });

  group('ComboRecommender Pure Dart Unit Tests', () {
    final itemPopcorn = const FnbItem(
      id: 'i1',
      name: 'Caramel & Cheese Duo Popcorn',
      description: 'Artisanal caramel and cheddar cheese',
      imageUrl: 'http://img/1',
      price: 400,
      category: 'Popcorn',
    );
    final itemCoke = const FnbItem(
      id: 'i2',
      name: 'Chilled Coke',
      description: 'Sparkling soda',
      imageUrl: 'http://img/2',
      price: 150,
      category: 'Beverages',
    );
    final itemNachos = const FnbItem(
      id: 'i3',
      name: 'Loaded Mexican Nachos',
      description: 'Corn tortilla with salsa',
      imageUrl: 'http://img/3',
      price: 350,
      category: 'Snacks',
    );

    final combo1 = FnbCombo(
      id: 'c1',
      name: 'Duo Classic Combo',
      description: 'Nachos + Coke',
      imageUrl: 'http://combo/1',
      items: [itemNachos, itemCoke],
      comboPrice: 400.0,
      originalPrice: 500.0,
      savings: 100.0,
    );

    final combo2 = FnbCombo(
      id: 'c2',
      name: 'Sweet & Savory Gourmet Fest',
      description: 'Caramel & Cheese Duo Popcorn + Coke',
      imageUrl: 'http://combo/2',
      items: [itemPopcorn, itemCoke],
      comboPrice: 450.0,
      originalPrice: 550.0,
      savings: 100.0,
    );

    final combo3 = FnbCombo(
      id: 'c3',
      name: 'Mega Family Feast',
      description: 'Popcorn + Nachos + 2 Cokes',
      imageUrl: 'http://combo/3',
      items: [itemPopcorn, itemNachos, itemCoke],
      comboPrice: 700.0,
      originalPrice: 900.0,
      savings: 200.0,
    );

    test('Chooses combo with best savings per person when no flavour history provided', () {
      final best = ComboRecommender.recommendCombo(
        combos: [combo1, combo2, combo3],
        groupSize: 4,
      );

      // Mega Family Feast has ₹200 savings / 4 = ₹50/person vs ₹25/person
      expect(best?.id, 'c3');
    });

    test('Prefers flavours from order history when recommending combo', () {
      // User has caramel history: combo2 has caramel and offers ₹100 savings
      final best = ComboRecommender.recommendCombo(
        combos: [combo1, combo2],
        groupSize: 2,
        orderHistoryFlavours: ['caramel'],
      );

      expect(best?.id, 'c2');
      expect(best?.name, contains('Sweet & Savory'));
    });

    test('Extracts flavour keywords from past bookings', () {
      final now = DateTime.now();
      final booking = Booking(
        id: 'b1',
        bookingNumber: 'SS-01',
        userId: 'u1',
        eventId: 'e1',
        venueId: 'v1',
        showId: 's1',
        showTime: now,
        bookingTime: now,
        fnbItems: [itemPopcorn],
        priceBreakdown: const PriceBreakdown(basePrice: 400, grandTotal: 400),
        qrCodeData: 'qr',
      );

      final flavours = ComboRecommender.extractFlavoursFromBookings([booking]);
      expect(flavours.contains('caramel'), isTrue);
      expect(flavours.contains('cheese'), isTrue);
    });
  });
}
