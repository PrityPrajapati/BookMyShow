// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationImpl _$$ReservationImplFromJson(Map<String, dynamic> json) =>
    _$ReservationImpl(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      restaurantName: json['restaurantName'] as String?,
      userId: json['userId'] as String,
      guestName: json['guestName'] as String,
      guestPhone: json['guestPhone'] as String,
      partySize: (json['partySize'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['timeSlot'] as String,
      status: $enumDecodeNullable(_$ReservationStatusEnumMap, json['status']) ??
          ReservationStatus.confirmed,
      specialRequests: json['specialRequests'] as String?,
    );

Map<String, dynamic> _$$ReservationImplToJson(_$ReservationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurantId': instance.restaurantId,
      'restaurantName': instance.restaurantName,
      'userId': instance.userId,
      'guestName': instance.guestName,
      'guestPhone': instance.guestPhone,
      'partySize': instance.partySize,
      'date': instance.date.toIso8601String(),
      'timeSlot': instance.timeSlot,
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'specialRequests': instance.specialRequests,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.confirmed: 'confirmed',
  ReservationStatus.pending: 'pending',
  ReservationStatus.cancelled: 'cancelled',
};
