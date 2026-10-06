import 'package:freezed_annotation/freezed_annotation.dart';

part 'seat_layout.freezed.dart';
part 'seat_layout.g.dart';

enum SeatType {
  @JsonValue('standard')
  standard,
  @JsonValue('recliner')
  recliner,
  @JsonValue('sofa')
  sofa,
  @JsonValue('wheelchair')
  wheelchair,
}

enum SeatState {
  @JsonValue('available')
  available,
  @JsonValue('booked')
  booked,
  @JsonValue('blocked')
  blocked,
}

@freezed
class Seat with _$Seat {
  const factory Seat({
    required String id,
    required String row,
    required int col,
    required String seatNumber,
    required SeatType type,
    required String category,
    required SeatState state,
  }) = _Seat;

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
}

@freezed
class SeatRow with _$SeatRow {
  const factory SeatRow({
    required String rowLabel,
    required String category,
    required double price,
    required List<Seat> seats,
  }) = _SeatRow;

  factory SeatRow.fromJson(Map<String, dynamic> json) =>
      _$SeatRowFromJson(json);
}

@freezed
class SeatLayout with _$SeatLayout {
  const factory SeatLayout({
    required String id,
    required String name,
    required String screenType,
    required int totalSeats,
    required List<SeatRow> rows,
  }) = _SeatLayout;

  factory SeatLayout.fromJson(Map<String, dynamic> json) =>
      _$SeatLayoutFromJson(json);
}
