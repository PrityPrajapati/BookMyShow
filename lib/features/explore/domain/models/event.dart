import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

enum EventType {
  @JsonValue('movie')
  movie,
  @JsonValue('concert')
  concert,
  @JsonValue('sports')
  sports,
  @JsonValue('comedy')
  comedy,
  @JsonValue('theatre')
  theatre,
}

@freezed
class Event with _$Event {
  const factory Event({
    required String id,
    required String title,
    required String description,
    required EventType type,
    @Default([]) List<String> genres,
    @Default([]) List<String> moodTags,
    @Default([]) List<String> languages,
    @Default(0.0) double rating,
    @Default(0) int votesCount,
    required int durationMins,
    required String posterUrl,
    required String bannerUrl,
    required String trailerUrl,
    required String aiSummary,
    String? certificate,
    DateTime? releaseDate,
    @Default([]) List<String> cast,
    @Default([]) List<String> crew,
    @Default(false) bool isTrending,
    @Default(false) bool isFeatured,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
