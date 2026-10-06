// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_breakdown.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PriceBreakdownImpl _$$PriceBreakdownImplFromJson(Map<String, dynamic> json) =>
    _$PriceBreakdownImpl(
      basePrice: (json['basePrice'] as num).toDouble(),
      convenienceFee: (json['convenienceFee'] as num?)?.toDouble() ?? 0.0,
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      fnbTotal: (json['fnbTotal'] as num?)?.toDouble() ?? 0.0,
      parkingTotal: (json['parkingTotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num).toDouble(),
      donationAmount: (json['donationAmount'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$PriceBreakdownImplToJson(
        _$PriceBreakdownImpl instance) =>
    <String, dynamic>{
      'basePrice': instance.basePrice,
      'convenienceFee': instance.convenienceFee,
      'gst': instance.gst,
      'fnbTotal': instance.fnbTotal,
      'parkingTotal': instance.parkingTotal,
      'discount': instance.discount,
      'grandTotal': instance.grandTotal,
      'donationAmount': instance.donationAmount,
    };
