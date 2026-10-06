// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  EventType get type => throw _privateConstructorUsedError;
  List<String> get genres => throw _privateConstructorUsedError;
  List<String> get moodTags => throw _privateConstructorUsedError;
  List<String> get languages => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get votesCount => throw _privateConstructorUsedError;
  int get durationMins => throw _privateConstructorUsedError;
  String get posterUrl => throw _privateConstructorUsedError;
  String get bannerUrl => throw _privateConstructorUsedError;
  String get trailerUrl => throw _privateConstructorUsedError;
  String get aiSummary => throw _privateConstructorUsedError;
  String? get certificate => throw _privateConstructorUsedError;
  DateTime? get releaseDate => throw _privateConstructorUsedError;
  List<String> get cast => throw _privateConstructorUsedError;
  List<String> get crew => throw _privateConstructorUsedError;
  bool get isTrending => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      EventType type,
      List<String> genres,
      List<String> moodTags,
      List<String> languages,
      double rating,
      int votesCount,
      int durationMins,
      String posterUrl,
      String bannerUrl,
      String trailerUrl,
      String aiSummary,
      String? certificate,
      DateTime? releaseDate,
      List<String> cast,
      List<String> crew,
      bool isTrending,
      bool isFeatured});
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? genres = null,
    Object? moodTags = null,
    Object? languages = null,
    Object? rating = null,
    Object? votesCount = null,
    Object? durationMins = null,
    Object? posterUrl = null,
    Object? bannerUrl = null,
    Object? trailerUrl = null,
    Object? aiSummary = null,
    Object? certificate = freezed,
    Object? releaseDate = freezed,
    Object? cast = null,
    Object? crew = null,
    Object? isTrending = null,
    Object? isFeatured = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EventType,
      genres: null == genres
          ? _value.genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      moodTags: null == moodTags
          ? _value.moodTags
          : moodTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      languages: null == languages
          ? _value.languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      votesCount: null == votesCount
          ? _value.votesCount
          : votesCount // ignore: cast_nullable_to_non_nullable
              as int,
      durationMins: null == durationMins
          ? _value.durationMins
          : durationMins // ignore: cast_nullable_to_non_nullable
              as int,
      posterUrl: null == posterUrl
          ? _value.posterUrl
          : posterUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bannerUrl: null == bannerUrl
          ? _value.bannerUrl
          : bannerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      trailerUrl: null == trailerUrl
          ? _value.trailerUrl
          : trailerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      aiSummary: null == aiSummary
          ? _value.aiSummary
          : aiSummary // ignore: cast_nullable_to_non_nullable
              as String,
      certificate: freezed == certificate
          ? _value.certificate
          : certificate // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDate: freezed == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cast: null == cast
          ? _value.cast
          : cast // ignore: cast_nullable_to_non_nullable
              as List<String>,
      crew: null == crew
          ? _value.crew
          : crew // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(
          _$EventImpl value, $Res Function(_$EventImpl) then) =
      __$$EventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      EventType type,
      List<String> genres,
      List<String> moodTags,
      List<String> languages,
      double rating,
      int votesCount,
      int durationMins,
      String posterUrl,
      String bannerUrl,
      String trailerUrl,
      String aiSummary,
      String? certificate,
      DateTime? releaseDate,
      List<String> cast,
      List<String> crew,
      bool isTrending,
      bool isFeatured});
}

/// @nodoc
class __$$EventImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$EventImpl>
    implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(
      _$EventImpl _value, $Res Function(_$EventImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? type = null,
    Object? genres = null,
    Object? moodTags = null,
    Object? languages = null,
    Object? rating = null,
    Object? votesCount = null,
    Object? durationMins = null,
    Object? posterUrl = null,
    Object? bannerUrl = null,
    Object? trailerUrl = null,
    Object? aiSummary = null,
    Object? certificate = freezed,
    Object? releaseDate = freezed,
    Object? cast = null,
    Object? crew = null,
    Object? isTrending = null,
    Object? isFeatured = null,
  }) {
    return _then(_$EventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EventType,
      genres: null == genres
          ? _value._genres
          : genres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      moodTags: null == moodTags
          ? _value._moodTags
          : moodTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      languages: null == languages
          ? _value._languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      votesCount: null == votesCount
          ? _value.votesCount
          : votesCount // ignore: cast_nullable_to_non_nullable
              as int,
      durationMins: null == durationMins
          ? _value.durationMins
          : durationMins // ignore: cast_nullable_to_non_nullable
              as int,
      posterUrl: null == posterUrl
          ? _value.posterUrl
          : posterUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bannerUrl: null == bannerUrl
          ? _value.bannerUrl
          : bannerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      trailerUrl: null == trailerUrl
          ? _value.trailerUrl
          : trailerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      aiSummary: null == aiSummary
          ? _value.aiSummary
          : aiSummary // ignore: cast_nullable_to_non_nullable
              as String,
      certificate: freezed == certificate
          ? _value.certificate
          : certificate // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDate: freezed == releaseDate
          ? _value.releaseDate
          : releaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cast: null == cast
          ? _value._cast
          : cast // ignore: cast_nullable_to_non_nullable
              as List<String>,
      crew: null == crew
          ? _value._crew
          : crew // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isTrending: null == isTrending
          ? _value.isTrending
          : isTrending // ignore: cast_nullable_to_non_nullable
              as bool,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl implements _Event {
  const _$EventImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.type,
      final List<String> genres = const [],
      final List<String> moodTags = const [],
      final List<String> languages = const [],
      this.rating = 0.0,
      this.votesCount = 0,
      required this.durationMins,
      required this.posterUrl,
      required this.bannerUrl,
      required this.trailerUrl,
      required this.aiSummary,
      this.certificate,
      this.releaseDate,
      final List<String> cast = const [],
      final List<String> crew = const [],
      this.isTrending = false,
      this.isFeatured = false})
      : _genres = genres,
        _moodTags = moodTags,
        _languages = languages,
        _cast = cast,
        _crew = crew;

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final EventType type;
  final List<String> _genres;
  @override
  @JsonKey()
  List<String> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  final List<String> _moodTags;
  @override
  @JsonKey()
  List<String> get moodTags {
    if (_moodTags is EqualUnmodifiableListView) return _moodTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moodTags);
  }

  final List<String> _languages;
  @override
  @JsonKey()
  List<String> get languages {
    if (_languages is EqualUnmodifiableListView) return _languages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_languages);
  }

  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int votesCount;
  @override
  final int durationMins;
  @override
  final String posterUrl;
  @override
  final String bannerUrl;
  @override
  final String trailerUrl;
  @override
  final String aiSummary;
  @override
  final String? certificate;
  @override
  final DateTime? releaseDate;
  final List<String> _cast;
  @override
  @JsonKey()
  List<String> get cast {
    if (_cast is EqualUnmodifiableListView) return _cast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cast);
  }

  final List<String> _crew;
  @override
  @JsonKey()
  List<String> get crew {
    if (_crew is EqualUnmodifiableListView) return _crew;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_crew);
  }

  @override
  @JsonKey()
  final bool isTrending;
  @override
  @JsonKey()
  final bool isFeatured;

  @override
  String toString() {
    return 'Event(id: $id, title: $title, description: $description, type: $type, genres: $genres, moodTags: $moodTags, languages: $languages, rating: $rating, votesCount: $votesCount, durationMins: $durationMins, posterUrl: $posterUrl, bannerUrl: $bannerUrl, trailerUrl: $trailerUrl, aiSummary: $aiSummary, certificate: $certificate, releaseDate: $releaseDate, cast: $cast, crew: $crew, isTrending: $isTrending, isFeatured: $isFeatured)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            const DeepCollectionEquality().equals(other._moodTags, _moodTags) &&
            const DeepCollectionEquality()
                .equals(other._languages, _languages) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.votesCount, votesCount) ||
                other.votesCount == votesCount) &&
            (identical(other.durationMins, durationMins) ||
                other.durationMins == durationMins) &&
            (identical(other.posterUrl, posterUrl) ||
                other.posterUrl == posterUrl) &&
            (identical(other.bannerUrl, bannerUrl) ||
                other.bannerUrl == bannerUrl) &&
            (identical(other.trailerUrl, trailerUrl) ||
                other.trailerUrl == trailerUrl) &&
            (identical(other.aiSummary, aiSummary) ||
                other.aiSummary == aiSummary) &&
            (identical(other.certificate, certificate) ||
                other.certificate == certificate) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
            const DeepCollectionEquality().equals(other._crew, _crew) &&
            (identical(other.isTrending, isTrending) ||
                other.isTrending == isTrending) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        type,
        const DeepCollectionEquality().hash(_genres),
        const DeepCollectionEquality().hash(_moodTags),
        const DeepCollectionEquality().hash(_languages),
        rating,
        votesCount,
        durationMins,
        posterUrl,
        bannerUrl,
        trailerUrl,
        aiSummary,
        certificate,
        releaseDate,
        const DeepCollectionEquality().hash(_cast),
        const DeepCollectionEquality().hash(_crew),
        isTrending,
        isFeatured
      ]);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventImplToJson(
      this,
    );
  }
}

abstract class _Event implements Event {
  const factory _Event(
      {required final String id,
      required final String title,
      required final String description,
      required final EventType type,
      final List<String> genres,
      final List<String> moodTags,
      final List<String> languages,
      final double rating,
      final int votesCount,
      required final int durationMins,
      required final String posterUrl,
      required final String bannerUrl,
      required final String trailerUrl,
      required final String aiSummary,
      final String? certificate,
      final DateTime? releaseDate,
      final List<String> cast,
      final List<String> crew,
      final bool isTrending,
      final bool isFeatured}) = _$EventImpl;

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  EventType get type;
  @override
  List<String> get genres;
  @override
  List<String> get moodTags;
  @override
  List<String> get languages;
  @override
  double get rating;
  @override
  int get votesCount;
  @override
  int get durationMins;
  @override
  String get posterUrl;
  @override
  String get bannerUrl;
  @override
  String get trailerUrl;
  @override
  String get aiSummary;
  @override
  String? get certificate;
  @override
  DateTime? get releaseDate;
  @override
  List<String> get cast;
  @override
  List<String> get crew;
  @override
  bool get isTrending;
  @override
  bool get isFeatured;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
