// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShowImpl _$$ShowImplFromJson(Map<String, dynamic> json) => _$ShowImpl(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      venueId: json['venueId'] as String,
      screenId: json['screenId'] as String,
      screenName: json['screenName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      format: $enumDecode(_$ShowFormatEnumMap, json['format']),
      language: json['language'] as String? ?? 'Hindi',
      categoryPrices: (json['categoryPrices'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      occupancyPct: (json['occupancyPct'] as num?)?.toDouble() ?? 0.0,
      isPresale: json['isPresale'] as bool? ?? false,
      seatLayoutId: json['seatLayoutId'] as String,
    );

Map<String, dynamic> _$$ShowImplToJson(_$ShowImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'venueId': instance.venueId,
      'screenId': instance.screenId,
      'screenName': instance.screenName,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'format': _$ShowFormatEnumMap[instance.format]!,
      'language': instance.language,
      'categoryPrices': instance.categoryPrices,
      'occupancyPct': instance.occupancyPct,
      'isPresale': instance.isPresale,
      'seatLayoutId': instance.seatLayoutId,
    };

const _$ShowFormatEnumMap = {
  ShowFormat.twoD: '2D',
  ShowFormat.threeD: '3D',
  ShowFormat.imax2D: 'IMAX2D',
  ShowFormat.imax3D: 'IMAX3D',
  ShowFormat.fourDX: '4DX',
};
