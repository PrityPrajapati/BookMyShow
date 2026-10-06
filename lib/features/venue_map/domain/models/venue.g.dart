// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GeoLocationImpl _$$GeoLocationImplFromJson(Map<String, dynamic> json) =>
    _$GeoLocationImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      formattedAddress: json['formattedAddress'] as String?,
    );

Map<String, dynamic> _$$GeoLocationImplToJson(_$GeoLocationImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'formattedAddress': instance.formattedAddress,
    };

_$VenueImpl _$$VenueImplFromJson(Map<String, dynamic> json) => _$VenueImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: $enumDecode(_$VenueTypeEnumMap, json['type']),
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      geo: GeoLocation.fromJson(json['geo'] as Map<String, dynamic>),
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      parkingLots: (json['parkingLots'] as List<dynamic>?)
              ?.map((e) => ParkingLot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalScreens: (json['totalScreens'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$VenueImplToJson(_$VenueImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$VenueTypeEnumMap[instance.type]!,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'geo': instance.geo,
      'amenities': instance.amenities,
      'parkingLots': instance.parkingLots,
      'imageUrl': instance.imageUrl,
      'rating': instance.rating,
      'totalScreens': instance.totalScreens,
    };

const _$VenueTypeEnumMap = {
  VenueType.cinema: 'cinema',
  VenueType.stadium: 'stadium',
};
