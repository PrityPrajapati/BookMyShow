// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isGoldMember: json['isGoldMember'] as bool? ?? false,
      goldExpiry: json['goldExpiry'] == null
          ? null
          : DateTime.parse(json['goldExpiry'] as String),
      preferredCities: (json['preferredCities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteGenres: (json['favoriteGenres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      favoriteLanguages: (json['favoriteLanguages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'isGoldMember': instance.isGoldMember,
      'goldExpiry': instance.goldExpiry?.toIso8601String(),
      'preferredCities': instance.preferredCities,
      'favoriteGenres': instance.favoriteGenres,
      'favoriteLanguages': instance.favoriteLanguages,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
