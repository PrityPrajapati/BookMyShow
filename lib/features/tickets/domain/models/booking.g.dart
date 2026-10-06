// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      id: json['id'] as String,
      bookingNumber: json['bookingNumber'] as String,
      userId: json['userId'] as String,
      eventId: json['eventId'] as String,
      eventTitle: json['eventTitle'] as String?,
      eventPosterUrl: json['eventPosterUrl'] as String?,
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String?,
      showId: json['showId'] as String,
      showTime: DateTime.parse(json['showTime'] as String),
      showFormat: json['showFormat'] as String?,
      bookingTime: DateTime.parse(json['bookingTime'] as String),
      tickets: (json['tickets'] as List<dynamic>?)
              ?.map((e) => Ticket.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fnbItems: (json['fnbItems'] as List<dynamic>?)
              ?.map((e) => FnbItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      parkingLot: json['parkingLot'] == null
          ? null
          : ParkingLot.fromJson(json['parkingLot'] as Map<String, dynamic>),
      priceBreakdown: PriceBreakdown.fromJson(
          json['priceBreakdown'] as Map<String, dynamic>),
      status: $enumDecodeNullable(_$BookingStatusEnumMap, json['status']) ??
          BookingStatus.confirmed,
      qrCodeData: json['qrCodeData'] as String,
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingNumber': instance.bookingNumber,
      'userId': instance.userId,
      'eventId': instance.eventId,
      'eventTitle': instance.eventTitle,
      'eventPosterUrl': instance.eventPosterUrl,
      'venueId': instance.venueId,
      'venueName': instance.venueName,
      'showId': instance.showId,
      'showTime': instance.showTime.toIso8601String(),
      'showFormat': instance.showFormat,
      'bookingTime': instance.bookingTime.toIso8601String(),
      'tickets': instance.tickets,
      'fnbItems': instance.fnbItems,
      'parkingLot': instance.parkingLot,
      'priceBreakdown': instance.priceBreakdown,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'qrCodeData': instance.qrCodeData,
    };

const _$BookingStatusEnumMap = {
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.pending: 'pending',
  BookingStatus.expired: 'expired',
};
