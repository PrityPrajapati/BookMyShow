// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantImpl _$$RestaurantImplFromJson(Map<String, dynamic> json) =>
    _$RestaurantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      cuisine: (json['cuisine'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      costForTwo: (json['costForTwo'] as num).toDouble(),
      address: json['address'] as String,
      city: json['city'] as String,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.0,
      imageUrl: json['imageUrl'] as String,
      bannerUrl: json['bannerUrl'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hasTableBooking: json['hasTableBooking'] as bool? ?? true,
      isPureVeg: json['isPureVeg'] as bool? ?? false,
      featuredDishes: (json['featuredDishes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$RestaurantImplToJson(_$RestaurantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cuisine': instance.cuisine,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'costForTwo': instance.costForTwo,
      'address': instance.address,
      'city': instance.city,
      'distanceKm': instance.distanceKm,
      'imageUrl': instance.imageUrl,
      'bannerUrl': instance.bannerUrl,
      'openTime': instance.openTime,
      'closeTime': instance.closeTime,
      'amenities': instance.amenities,
      'hasTableBooking': instance.hasTableBooking,
      'isPureVeg': instance.isPureVeg,
      'featuredDishes': instance.featuredDishes,
    };
