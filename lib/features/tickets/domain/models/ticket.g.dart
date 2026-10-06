// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TicketImpl _$$TicketImplFromJson(Map<String, dynamic> json) => _$TicketImpl(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      seatId: json['seatId'] as String,
      seatNumber: json['seatNumber'] as String,
      row: json['row'] as String,
      col: (json['col'] as num).toInt(),
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      qrData: json['qrData'] as String,
      status: $enumDecodeNullable(_$TicketStatusEnumMap, json['status']) ??
          TicketStatus.active,
    );

Map<String, dynamic> _$$TicketImplToJson(_$TicketImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'seatId': instance.seatId,
      'seatNumber': instance.seatNumber,
      'row': instance.row,
      'col': instance.col,
      'category': instance.category,
      'price': instance.price,
      'qrData': instance.qrData,
      'status': _$TicketStatusEnumMap[instance.status]!,
    };

const _$TicketStatusEnumMap = {
  TicketStatus.active: 'active',
  TicketStatus.pendingTransfer: 'pendingTransfer',
  TicketStatus.used: 'used',
  TicketStatus.transferred: 'transferred',
  TicketStatus.cancelled: 'cancelled',
};
