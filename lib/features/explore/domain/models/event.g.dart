// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$EventTypeEnumMap, json['type']),
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      moodTags: (json['moodTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      votesCount: (json['votesCount'] as num?)?.toInt() ?? 0,
      durationMins: (json['durationMins'] as num).toInt(),
      posterUrl: json['posterUrl'] as String,
      bannerUrl: json['bannerUrl'] as String,
      trailerUrl: json['trailerUrl'] as String,
      aiSummary: json['aiSummary'] as String,
      certificate: json['certificate'] as String?,
      releaseDate: json['releaseDate'] == null
          ? null
          : DateTime.parse(json['releaseDate'] as String),
      cast:
          (json['cast'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      crew:
          (json['crew'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      isTrending: json['isTrending'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$EventTypeEnumMap[instance.type]!,
      'genres': instance.genres,
      'moodTags': instance.moodTags,
      'languages': instance.languages,
      'rating': instance.rating,
      'votesCount': instance.votesCount,
      'durationMins': instance.durationMins,
      'posterUrl': instance.posterUrl,
      'bannerUrl': instance.bannerUrl,
      'trailerUrl': instance.trailerUrl,
      'aiSummary': instance.aiSummary,
      'certificate': instance.certificate,
      'releaseDate': instance.releaseDate?.toIso8601String(),
      'cast': instance.cast,
      'crew': instance.crew,
      'isTrending': instance.isTrending,
      'isFeatured': instance.isFeatured,
    };

const _$EventTypeEnumMap = {
  EventType.movie: 'movie',
  EventType.concert: 'concert',
  EventType.sports: 'sports',
  EventType.comedy: 'comedy',
  EventType.theatre: 'theatre',
};
