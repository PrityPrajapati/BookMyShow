// Pure Dart Pricing Engine - No Flutter imports allowed

enum DiscountType {
  none,
  tuesday,
  group,
}

class PriceBreakdown {
  final double ticketSubtotal;
  final DiscountType discountType;
  final double discountAmount;
  final double convenienceFee;
  final double gstOnFee;
  final bool feeWaived;
  final double fnbTotal;
  final double parking;
  final double grandTotal;
  final double goldSavings;

  const PriceBreakdown({
    required this.ticketSubtotal,
    required this.discountType,
    required this.discountAmount,
    required this.convenienceFee,
    required this.gstOnFee,
    required this.feeWaived,
    required this.fnbTotal,
    required this.parking,
    required this.grandTotal,
    required this.goldSavings,
  });

  @override
  String toString() {
    return 'PriceBreakdown('
        'ticketSubtotal: $ticketSubtotal, '
        'discountType: $discountType, '
        'discountAmount: $discountAmount, '
        'convenienceFee: $convenienceFee, '
        'gstOnFee: $gstOnFee, '
        'feeWaived: $feeWaived, '
        'fnbTotal: $fnbTotal, '
        'parking: $parking, '
        'grandTotal: $grandTotal, '
        'goldSavings: $goldSavings)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceBreakdown &&
          runtimeType == other.runtimeType &&
          (ticketSubtotal - other.ticketSubtotal).abs() < 0.001 &&
          discountType == other.discountType &&
          (discountAmount - other.discountAmount).abs() < 0.001 &&
          (convenienceFee - other.convenienceFee).abs() < 0.001 &&
          (gstOnFee - other.gstOnFee).abs() < 0.001 &&
          feeWaived == other.feeWaived &&
          (fnbTotal - other.fnbTotal).abs() < 0.001 &&
          (parking - other.parking).abs() < 0.001 &&
          (grandTotal - other.grandTotal).abs() < 0.001 &&
          (goldSavings - other.goldSavings).abs() < 0.001;

  @override
  int get hashCode => Object.hash(
        ticketSubtotal,
        discountType,
        discountAmount,
        convenienceFee,
        gstOnFee,
        feeWaived,
        fnbTotal,
        parking,
        grandTotal,
        goldSavings,
      );
}

class PricingEngine {
  const PricingEngine();

  /// Calculates the convenience fee for a single seat based on price slabs:
  /// - Price <= ₹199: ₹20 / seat
  /// - ₹200 to ₹699: ₹30 / seat
  /// - Price >= ₹700: ₹40 / seat
  static double getSeatConvenienceFee(double seatPrice) {
    if (seatPrice <= 199.0) {
      return 20.0;
    } else if (seatPrice <= 699.0) {
      return 30.0;
    } else {
      return 40.0;
    }
  }

  /// Pure Dart pricing calculation method.
  ///
  /// Inputs:
  /// - [seatPrices]: list of seat prices
  /// - [showDate]: date of the show
  /// - [isMovie]: whether the event is a movie
  /// - [occupancyPct]: occupancy percentage (e.g. 25.0 or 0.25)
  /// - [isGold]: whether user has Gold membership
  /// - [fnbTotal]: food & beverage total charge
  /// - [parkingCharge]: parking total charge
  static PriceBreakdown calculate({
    required List<double> seatPrices,
    required DateTime showDate,
    required bool isMovie,
    double occupancyPct = 50.0,
    bool isGold = false,
    double fnbTotal = 0.0,
    double parkingCharge = 0.0,
    bool forceTuesday = false,
  }) {
    final ticketSubtotal = seatPrices.fold<double>(
      0.0,
      (sum, price) => sum + price,
    );

    // If no seats, return zeroed breakdown with FnB/parking preserved
    if (seatPrices.isEmpty) {
      return PriceBreakdown(
        ticketSubtotal: 0.0,
        discountType: DiscountType.none,
        discountAmount: 0.0,
        convenienceFee: 0.0,
        gstOnFee: 0.0,
        feeWaived: isGold,
        fnbTotal: fnbTotal,
        parking: parkingCharge,
        grandTotal: fnbTotal + parkingCharge,
        goldSavings: 0.0,
      );
    }

    // 1. Calculate Discount
    // Tuesday discount: movies only, 50% or 70% if occupancy < 30%
    double tuesdayDiscountAmount = 0.0;
    final isTuesday = forceTuesday || (showDate.weekday == DateTime.tuesday);
    if (isMovie && isTuesday) {
      final normalizedOccupancy =
          occupancyPct > 1.0 ? occupancyPct : occupancyPct * 100.0;
      final discountRate = normalizedOccupancy < 30.0 ? 0.70 : 0.50;
      tuesdayDiscountAmount = ticketSubtotal * discountRate;
    }

    // Group discount: >= 10 tickets -> 10%
    double groupDiscountAmount = 0.0;
    if (seatPrices.length >= 10) {
      groupDiscountAmount = ticketSubtotal * 0.10;
    }

    DiscountType discountType = DiscountType.none;
    double discountAmount = 0.0;

    // Apply the larger discount
    if (tuesdayDiscountAmount > 0 || groupDiscountAmount > 0) {
      if (tuesdayDiscountAmount >= groupDiscountAmount) {
        discountType = DiscountType.tuesday;
        discountAmount = tuesdayDiscountAmount;
      } else {
        discountType = DiscountType.group;
        discountAmount = groupDiscountAmount;
      }
    }

    // 2. Convenience Fee: slab on each seat's original price
    double rawConvenienceFee = 0.0;
    for (final price in seatPrices) {
      rawConvenienceFee += getSeatConvenienceFee(price);
    }

    // GST 18% on fee rounded to nearest rupee
    final rawGstOnFee = (rawConvenienceFee * 0.18).roundToDouble();

    // 3. Gold Member benefits: waives fee and GST
    final feeWaived = isGold;
    final convenienceFee = feeWaived ? 0.0 : rawConvenienceFee;
    final gstOnFee = feeWaived ? 0.0 : rawGstOnFee;
    final goldSavings = feeWaived ? (rawConvenienceFee + rawGstOnFee) : 0.0;

    // 4. Grand Total
    final discountedTicketPrice = ticketSubtotal - discountAmount;
    final grandTotal = discountedTicketPrice +
        convenienceFee +
        gstOnFee +
        fnbTotal +
        parkingCharge;

    return PriceBreakdown(
      ticketSubtotal: ticketSubtotal,
      discountType: discountType,
      discountAmount: discountAmount,
      convenienceFee: convenienceFee,
      gstOnFee: gstOnFee,
      feeWaived: feeWaived,
      fnbTotal: fnbTotal,
      parking: parkingCharge,
      grandTotal: grandTotal,
      goldSavings: goldSavings,
    );
  }

  /// Instance method proxy for convenience
  PriceBreakdown compute({
    required List<double> seatPrices,
    required DateTime showDate,
    required bool isMovie,
    double occupancyPct = 50.0,
    bool isGold = false,
    double fnbTotal = 0.0,
    double parkingCharge = 0.0,
  }) =>
      calculate(
        seatPrices: seatPrices,
        showDate: showDate,
        isMovie: isMovie,
        occupancyPct: occupancyPct,
        isGold: isGold,
        fnbTotal: fnbTotal,
        parkingCharge: parkingCharge,
      );
}
