// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat_layout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeatImpl _$$SeatImplFromJson(Map<String, dynamic> json) => _$SeatImpl(
      id: json['id'] as String,
      row: json['row'] as String,
      col: (json['col'] as num).toInt(),
      seatNumber: json['seatNumber'] as String,
      type: $enumDecode(_$SeatTypeEnumMap, json['type']),
      category: json['category'] as String,
      state: $enumDecode(_$SeatStateEnumMap, json['state']),
    );

Map<String, dynamic> _$$SeatImplToJson(_$SeatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'row': instance.row,
      'col': instance.col,
      'seatNumber': instance.seatNumber,
      'type': _$SeatTypeEnumMap[instance.type]!,
      'category': instance.category,
      'state': _$SeatStateEnumMap[instance.state]!,
    };

const _$SeatTypeEnumMap = {
  SeatType.standard: 'standard',
  SeatType.recliner: 'recliner',
  SeatType.sofa: 'sofa',
  SeatType.wheelchair: 'wheelchair',
};

const _$SeatStateEnumMap = {
  SeatState.available: 'available',
  SeatState.booked: 'booked',
  SeatState.blocked: 'blocked',
};

_$SeatRowImpl _$$SeatRowImplFromJson(Map<String, dynamic> json) =>
    _$SeatRowImpl(
      rowLabel: json['rowLabel'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      seats: (json['seats'] as List<dynamic>)
          .map((e) => Seat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SeatRowImplToJson(_$SeatRowImpl instance) =>
    <String, dynamic>{
      'rowLabel': instance.rowLabel,
      'category': instance.category,
      'price': instance.price,
      'seats': instance.seats,
    };

_$SeatLayoutImpl _$$SeatLayoutImplFromJson(Map<String, dynamic> json) =>
    _$SeatLayoutImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      screenType: json['screenType'] as String,
      totalSeats: (json['totalSeats'] as num).toInt(),
      rows: (json['rows'] as List<dynamic>)
          .map((e) => SeatRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SeatLayoutImplToJson(_$SeatLayoutImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'screenType': instance.screenType,
      'totalSeats': instance.totalSeats,
      'rows': instance.rows,
    };
