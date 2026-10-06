import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:showscape/features/checkout/domain/models/price_breakdown.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum BookingStatus {
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('pending')
  pending,
  @JsonValue('expired')
  expired,
}

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String bookingNumber,
    required String userId,
    required String eventId,
    String? eventTitle,
    String? eventPosterUrl,
    required String venueId,
    String? venueName,
    required String showId,
    required DateTime showTime,
    String? showFormat,
    required DateTime bookingTime,
    @Default([]) List<Ticket> tickets,
    @Default([]) List<FnbItem> fnbItems,
    ParkingLot? parkingLot,
    required PriceBreakdown priceBreakdown,
    @Default(BookingStatus.confirmed) BookingStatus status,
    required String qrCodeData,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
