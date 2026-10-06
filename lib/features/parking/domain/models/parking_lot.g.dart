// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_lot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParkingLotImpl _$$ParkingLotImplFromJson(Map<String, dynamic> json) =>
    _$ParkingLotImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      vehicleType: $enumDecode(_$VehicleTypeEnumMap, json['vehicleType']),
      capacity: (json['capacity'] as num).toInt(),
      available: (json['available'] as num).toInt(),
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      flatRate: (json['flatRate'] as num).toDouble(),
      isCovered: json['isCovered'] as bool? ?? false,
      hasValet: json['hasValet'] as bool? ?? false,
    );

Map<String, dynamic> _$$ParkingLotImplToJson(_$ParkingLotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vehicleType': _$VehicleTypeEnumMap[instance.vehicleType]!,
      'capacity': instance.capacity,
      'available': instance.available,
      'hourlyRate': instance.hourlyRate,
      'flatRate': instance.flatRate,
      'isCovered': instance.isCovered,
      'hasValet': instance.hasValet,
    };

const _$VehicleTypeEnumMap = {
  VehicleType.twoWheeler: 'twoWheeler',
  VehicleType.fourWheeler: 'fourWheeler',
  VehicleType.ev: 'ev',
};
