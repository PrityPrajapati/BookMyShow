// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fnb_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FnbItemImpl _$$FnbItemImplFromJson(Map<String, dynamic> json) =>
    _$FnbItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      isVeg: json['isVeg'] as bool? ?? true,
      calories: (json['calories'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$FnbItemImplToJson(_$FnbItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'price': instance.price,
      'category': instance.category,
      'isVeg': instance.isVeg,
      'calories': instance.calories,
      'rating': instance.rating,
    };
