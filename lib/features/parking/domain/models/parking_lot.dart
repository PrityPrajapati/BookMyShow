import 'package:freezed_annotation/freezed_annotation.dart';

part 'parking_lot.freezed.dart';
part 'parking_lot.g.dart';

enum VehicleType {
  @JsonValue('twoWheeler')
  twoWheeler,
  @JsonValue('fourWheeler')
  fourWheeler,
  @JsonValue('ev')
  ev,
}

@freezed
class ParkingLot with _$ParkingLot {
  const factory ParkingLot({
    required String id,
    required String name,
    required VehicleType vehicleType,
    required int capacity,
    required int available,
    required double hourlyRate,
    required double flatRate,
    @Default(false) bool isCovered,
    @Default(false) bool hasValet,
  }) = _ParkingLot;

  factory ParkingLot.fromJson(Map<String, dynamic> json) =>
      _$ParkingLotFromJson(json);
}
