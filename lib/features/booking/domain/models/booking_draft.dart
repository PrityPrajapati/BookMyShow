import 'package:showscape/features/dining/domain/models/reservation.dart';
import 'package:showscape/features/food/domain/models/fnb_combo.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/services/pricing_engine.dart';

enum PickupTiming {
  beforeShow,
  atInterval,
}

class FnbCartItem {
  final String id;
  final FnbItem? item;
  final FnbCombo? combo;
  final String? size;
  final String? flavour;
  final double unitPrice;
  final int quantity;

  const FnbCartItem({
    required this.id,
    this.item,
    this.combo,
    this.size,
    this.flavour,
    required this.unitPrice,
    this.quantity = 1,
  });

  bool get isCombo => combo != null;
  String get name => combo?.name ?? item?.name ?? 'Item';
  String get imageUrl => combo?.imageUrl ?? item?.imageUrl ?? '';
  double get totalPrice => unitPrice * quantity;

  bool get isVeg {
    if (combo != null) {
      return combo!.items.every((i) => i.isVeg);
    }
    return item?.isVeg ?? true;
  }

  FnbCartItem copyWith({
    String? id,
    FnbItem? item,
    FnbCombo? combo,
    String? size,
    String? flavour,
    double? unitPrice,
    int? quantity,
  }) {
    return FnbCartItem(
      id: id ?? this.id,
      item: item ?? this.item,
      combo: combo ?? this.combo,
      size: size ?? this.size,
      flavour: flavour ?? this.flavour,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ParkingSelection {
  final ParkingLot lot;
  final String vehicleNumber;
  final int durationMinutes;
  final double charge;

  const ParkingSelection({
    required this.lot,
    required this.vehicleNumber,
    required this.durationMinutes,
    required this.charge,
  });

  ParkingSelection copyWith({
    ParkingLot? lot,
    String? vehicleNumber,
    int? durationMinutes,
    double? charge,
  }) {
    return ParkingSelection(
      lot: lot ?? this.lot,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      charge: charge ?? this.charge,
    );
  }
}

class BookingDraft {
  final String id;
  final String showId;
  final String? venueId;
  final String? eventId;
  final String? eventTitle;
  final String? venueName;
  final DateTime? showTime;
  final bool isMovie;
  final bool isGold;
  final double occupancyPct;
  final int durationMinutes;
  final List<String> seatIds;
  final List<double> seatPrices;
  final List<FnbCartItem> fnbItems;
  final PickupTiming pickupTiming;
  final ParkingSelection? parking;
  final Reservation? diningReservation;

  const BookingDraft({
    required this.id,
    required this.showId,
    this.venueId,
    this.eventId,
    this.eventTitle,
    this.venueName,
    this.showTime,
    this.isMovie = true,
    this.isGold = false,
    this.occupancyPct = 50.0,
    this.durationMinutes = 150,
    this.seatIds = const [],
    this.seatPrices = const [],
    this.fnbItems = const [],
    this.pickupTiming = PickupTiming.beforeShow,
    this.parking,
    this.diningReservation,
  });

  int get seatCount =>
      seatIds.isNotEmpty ? seatIds.length : (seatPrices.isNotEmpty ? seatPrices.length : 1);

  double get ticketSubtotal =>
      seatPrices.fold<double>(0.0, (acc, price) => acc + price);

  double get fnbTotal =>
      fnbItems.fold<double>(0.0, (acc, item) => acc + item.totalPrice);

  int get fnbTotalCount =>
      fnbItems.fold<int>(0, (acc, item) => acc + item.quantity);

  double get parkingCharge => parking?.charge ?? 0.0;

  PriceBreakdown get priceBreakdown => PricingEngine.calculate(
        seatPrices: seatPrices,
        showDate: showTime ?? DateTime.now(),
        isMovie: isMovie,
        occupancyPct: occupancyPct,
        isGold: isGold,
        fnbTotal: fnbTotal,
        parkingCharge: parkingCharge,
      );

  BookingDraft copyWith({
    String? id,
    String? showId,
    String? venueId,
    String? eventId,
    String? eventTitle,
    String? venueName,
    DateTime? showTime,
    bool? isMovie,
    bool? isGold,
    double? occupancyPct,
    int? durationMinutes,
    List<String>? seatIds,
    List<double>? seatPrices,
    List<FnbCartItem>? fnbItems,
    PickupTiming? pickupTiming,
    ParkingSelection? parking,
    bool clearParking = false,
    Reservation? diningReservation,
    bool clearDiningReservation = false,
  }) {
    return BookingDraft(
      id: id ?? this.id,
      showId: showId ?? this.showId,
      venueId: venueId ?? this.venueId,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      venueName: venueName ?? this.venueName,
      showTime: showTime ?? this.showTime,
      isMovie: isMovie ?? this.isMovie,
      isGold: isGold ?? this.isGold,
      occupancyPct: occupancyPct ?? this.occupancyPct,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      seatIds: seatIds ?? this.seatIds,
      seatPrices: seatPrices ?? this.seatPrices,
      fnbItems: fnbItems ?? this.fnbItems,
      pickupTiming: pickupTiming ?? this.pickupTiming,
      parking: clearParking ? null : (parking ?? this.parking),
      diningReservation: clearDiningReservation ? null : (diningReservation ?? this.diningReservation),
    );
  }
}
