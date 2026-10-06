// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fnb_combo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FnbComboImpl _$$FnbComboImplFromJson(Map<String, dynamic> json) =>
    _$FnbComboImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => FnbItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      comboPrice: (json['comboPrice'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$FnbComboImplToJson(_$FnbComboImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'items': instance.items,
      'comboPrice': instance.comboPrice,
      'originalPrice': instance.originalPrice,
      'savings': instance.savings,
    };
