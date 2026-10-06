import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/services/pricing_engine.dart';

void main() {
  group('PricingEngine Pure Dart Calculation Tests', () {
    // 2026 dates for reference:
    // 2026-10-03 is Saturday
    // 2026-10-06 is Tuesday
    // 2026-10-02 is Friday
    // 2026-10-04 is Sunday

    test('Case A: 2x₹320 Saturday = ₹711', () {
      final saturday = DateTime(2026, 10, 3);
      final result = PricingEngine.calculate(
        seatPrices: [320.0, 320.0],
        showDate: saturday,
        isMovie: true,
        occupancyPct: 50.0,
        isGold: false,
        fnbTotal: 0.0,
        parkingCharge: 0.0,
      );

      expect(result.ticketSubtotal, 640.0);
      expect(result.discountType, DiscountType.none);
      expect(result.discountAmount, 0.0);
      expect(result.convenienceFee, 60.0); // 2 * 30
      expect(result.gstOnFee, 11.0); // round(60 * 0.18) = 11
      expect(result.feeWaived, false);
      expect(result.fnbTotal, 0.0);
      expect(result.parking, 0.0);
      expect(result.grandTotal, 711.0);
      expect(result.goldSavings, 0.0);
    });

    test('Case B: 2x₹320 Tuesday = ₹391', () {
      final tuesday = DateTime(2026, 10, 6);
      final result = PricingEngine.calculate(
        seatPrices: [320.0, 320.0],
        showDate: tuesday,
        isMovie: true,
        occupancyPct: 50.0,
        isGold: false,
        fnbTotal: 0.0,
        parkingCharge: 0.0,
      );

      expect(result.ticketSubtotal, 640.0);
      expect(result.discountType, DiscountType.tuesday);
      expect(result.discountAmount, 320.0); // 50% of 640
      expect(result.convenienceFee, 60.0); // on original price
      expect(result.gstOnFee, 11.0);
      expect(result.feeWaived, false);
      expect(result.grandTotal, 391.0); // (640 - 320) + 60 + 11 = 391
    });

    test('Case C: 12x₹250 Friday = ₹3,125', () {
      final friday = DateTime(2026, 10, 2);
      final result = PricingEngine.calculate(
        seatPrices: List.filled(12, 250.0),
        showDate: friday,
        isMovie: true,
        occupancyPct: 50.0,
        isGold: false,
        fnbTotal: 0.0,
        parkingCharge: 0.0,
      );

      expect(result.ticketSubtotal, 3000.0);
      expect(result.discountType, DiscountType.group);
      expect(result.discountAmount, 300.0); // 10% group discount
      expect(result.convenienceFee, 360.0); // 12 * 30
      expect(result.gstOnFee, 65.0); // round(360 * 0.18) = 64.8 -> 65
      expect(result.grandTotal, 3125.0); // 2700 + 360 + 65
    });

    test('Case D: 2x₹550 Gold + ₹449 combo = ₹1,549', () {
      final saturday = DateTime(2026, 10, 3);
      final result = PricingEngine.calculate(
        seatPrices: [550.0, 550.0],
        showDate: saturday,
        isMovie: true,
        occupancyPct: 50.0,
        isGold: true,
        fnbTotal: 449.0,
        parkingCharge: 0.0,
      );

      expect(result.ticketSubtotal, 1100.0);
      expect(result.discountType, DiscountType.none);
      expect(result.discountAmount, 0.0);
      expect(result.convenienceFee, 0.0); // waived
      expect(result.gstOnFee, 0.0); // waived
      expect(result.feeWaived, true);
      expect(result.goldSavings, 71.0); // 60 fee + 11 gst
      expect(result.fnbTotal, 449.0);
      expect(result.grandTotal, 1549.0); // 1100 + 449
    });

    test('Case E: 4x₹180 Sunday + ₹100 parking = ₹914', () {
      final sunday = DateTime(2026, 10, 4);
      final result = PricingEngine.calculate(
        seatPrices: [180.0, 180.0, 180.0, 180.0],
        showDate: sunday,
        isMovie: true,
        occupancyPct: 50.0,
        isGold: false,
        fnbTotal: 0.0,
        parkingCharge: 100.0,
      );

      expect(result.ticketSubtotal, 720.0);
      expect(result.convenienceFee, 80.0); // 4 * 20 (slab <= 199)
      expect(result.gstOnFee, 14.0); // round(80 * 0.18) = 14.4 -> 14
      expect(result.parking, 100.0);
      expect(result.grandTotal, 914.0); // 720 + 80 + 14 + 100
    });

    group('Edge Cases & Slab Boundaries', () {
      test('0 seats edge case', () {
        final result = PricingEngine.calculate(
          seatPrices: [],
          showDate: DateTime(2026, 10, 3),
          isMovie: true,
          fnbTotal: 250.0,
          parkingCharge: 80.0,
        );

        expect(result.ticketSubtotal, 0.0);
        expect(result.convenienceFee, 0.0);
        expect(result.gstOnFee, 0.0);
        expect(result.discountAmount, 0.0);
        expect(result.discountType, DiscountType.none);
        expect(result.fnbTotal, 250.0);
        expect(result.parking, 80.0);
        expect(result.grandTotal, 330.0);
      });

      test('Exactly 10 seats triggers group discount', () {
        final friday = DateTime(2026, 10, 2);
        final result = PricingEngine.calculate(
          seatPrices: List.filled(10, 200.0),
          showDate: friday,
          isMovie: true,
        );

        expect(result.ticketSubtotal, 2000.0);
        expect(result.discountType, DiscountType.group);
        expect(result.discountAmount, 200.0); // 10%
        expect(result.convenienceFee, 300.0); // 10 * 30
        expect(result.gstOnFee, 54.0); // round(300 * 0.18) = 54
        expect(result.grandTotal, 2154.0); // 1800 + 300 + 54
      });

      test('Slab boundary ₹199 vs ₹200', () {
        expect(PricingEngine.getSeatConvenienceFee(199.0), 20.0);
        expect(PricingEngine.getSeatConvenienceFee(200.0), 30.0);

        final result199 = PricingEngine.calculate(
          seatPrices: [199.0],
          showDate: DateTime(2026, 10, 3),
          isMovie: true,
        );
        expect(result199.convenienceFee, 20.0);

        final result200 = PricingEngine.calculate(
          seatPrices: [200.0],
          showDate: DateTime(2026, 10, 3),
          isMovie: true,
        );
        expect(result200.convenienceFee, 30.0);
      });

      test('Slab boundary ₹699 vs ₹700', () {
        expect(PricingEngine.getSeatConvenienceFee(699.0), 30.0);
        expect(PricingEngine.getSeatConvenienceFee(700.0), 40.0);

        final result699 = PricingEngine.calculate(
          seatPrices: [699.0],
          showDate: DateTime(2026, 10, 3),
          isMovie: true,
        );
        expect(result699.convenienceFee, 30.0);

        final result700 = PricingEngine.calculate(
          seatPrices: [700.0],
          showDate: DateTime(2026, 10, 3),
          isMovie: true,
        );
        expect(result700.convenienceFee, 40.0);
      });

      test('Tuesday low occupancy (<30%) grants 70% discount for movies', () {
        final tuesday = DateTime(2026, 10, 6);
        final result = PricingEngine.calculate(
          seatPrices: [1000.0],
          showDate: tuesday,
          isMovie: true,
          occupancyPct: 20.0, // < 30%
        );

        expect(result.discountType, DiscountType.tuesday);
        expect(result.discountAmount, 700.0); // 70% of 1000
      });

      test('Tuesday non-movie does not get Tuesday discount', () {
        final tuesday = DateTime(2026, 10, 6);
        final result = PricingEngine.calculate(
          seatPrices: [500.0],
          showDate: tuesday,
          isMovie: false, // concert or comedy
        );

        expect(result.discountType, DiscountType.none);
        expect(result.discountAmount, 0.0);
      });

      test('Applies larger discount when both Tuesday and Group qualify', () {
        final tuesday = DateTime(2026, 10, 6);
        final result = PricingEngine.calculate(
          seatPrices: List.filled(10, 500.0), // 10 tickets = ₹5000
          showDate: tuesday,
          isMovie: true,
          occupancyPct: 50.0, // Tuesday gives 50% = 2500, Group gives 10% = 500
        );

        expect(result.discountType, DiscountType.tuesday);
        expect(result.discountAmount, 2500.0);
      });
    });
  });
}
