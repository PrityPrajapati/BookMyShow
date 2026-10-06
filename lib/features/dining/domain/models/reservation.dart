import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

enum ReservationStatus {
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('pending')
  pending,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required String restaurantId,
    String? restaurantName,
    required String userId,
    required String guestName,
    required String guestPhone,
    required int partySize,
    required DateTime date,
    required String timeSlot,
    @Default(ReservationStatus.confirmed) ReservationStatus status,
    String? specialRequests,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) =>
      _$ReservationFromJson(json);
}
