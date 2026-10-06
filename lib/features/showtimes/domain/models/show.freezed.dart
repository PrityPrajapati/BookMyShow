// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'show.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Show _$ShowFromJson(Map<String, dynamic> json) {
  return _Show.fromJson(json);
}

/// @nodoc
mixin _$Show {
  String get id => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String get venueId => throw _privateConstructorUsedError;
  String get screenId => throw _privateConstructorUsedError;
  String get screenName => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  ShowFormat get format => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  Map<String, double> get categoryPrices => throw _privateConstructorUsedError;
  double get occupancyPct => throw _privateConstructorUsedError;
  bool get isPresale => throw _privateConstructorUsedError;
  String get seatLayoutId => throw _privateConstructorUsedError;

  /// Serializes this Show to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Show
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShowCopyWith<Show> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShowCopyWith<$Res> {
  factory $ShowCopyWith(Show value, $Res Function(Show) then) =
      _$ShowCopyWithImpl<$Res, Show>;
  @useResult
  $Res call(
      {String id,
      String eventId,
      String venueId,
      String screenId,
      String screenName,
      DateTime startTime,
      DateTime? endTime,
      ShowFormat format,
      String language,
      Map<String, double> categoryPrices,
      double occupancyPct,
      bool isPresale,
      String seatLayoutId});
}

/// @nodoc
class _$ShowCopyWithImpl<$Res, $Val extends Show>
    implements $ShowCopyWith<$Res> {
  _$ShowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Show
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? venueId = null,
    Object? screenId = null,
    Object? screenName = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? format = null,
    Object? language = null,
    Object? categoryPrices = null,
    Object? occupancyPct = null,
    Object? isPresale = null,
    Object? seatLayoutId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      screenId: null == screenId
          ? _value.screenId
          : screenId // ignore: cast_nullable_to_non_nullable
              as String,
      screenName: null == screenName
          ? _value.screenName
          : screenName // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as ShowFormat,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      categoryPrices: null == categoryPrices
          ? _value.categoryPrices
          : categoryPrices // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      occupancyPct: null == occupancyPct
          ? _value.occupancyPct
          : occupancyPct // ignore: cast_nullable_to_non_nullable
              as double,
      isPresale: null == isPresale
          ? _value.isPresale
          : isPresale // ignore: cast_nullable_to_non_nullable
              as bool,
      seatLayoutId: null == seatLayoutId
          ? _value.seatLayoutId
          : seatLayoutId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShowImplCopyWith<$Res> implements $ShowCopyWith<$Res> {
  factory _$$ShowImplCopyWith(
          _$ShowImpl value, $Res Function(_$ShowImpl) then) =
      __$$ShowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String eventId,
      String venueId,
      String screenId,
      String screenName,
      DateTime startTime,
      DateTime? endTime,
      ShowFormat format,
      String language,
      Map<String, double> categoryPrices,
      double occupancyPct,
      bool isPresale,
      String seatLayoutId});
}

/// @nodoc
class __$$ShowImplCopyWithImpl<$Res>
    extends _$ShowCopyWithImpl<$Res, _$ShowImpl>
    implements _$$ShowImplCopyWith<$Res> {
  __$$ShowImplCopyWithImpl(_$ShowImpl _value, $Res Function(_$ShowImpl) _then)
      : super(_value, _then);

  /// Create a copy of Show
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? eventId = null,
    Object? venueId = null,
    Object? screenId = null,
    Object? screenName = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? format = null,
    Object? language = null,
    Object? categoryPrices = null,
    Object? occupancyPct = null,
    Object? isPresale = null,
    Object? seatLayoutId = null,
  }) {
    return _then(_$ShowImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      screenId: null == screenId
          ? _value.screenId
          : screenId // ignore: cast_nullable_to_non_nullable
              as String,
      screenName: null == screenName
          ? _value.screenName
          : screenName // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as ShowFormat,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      categoryPrices: null == categoryPrices
          ? _value._categoryPrices
          : categoryPrices // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      occupancyPct: null == occupancyPct
          ? _value.occupancyPct
          : occupancyPct // ignore: cast_nullable_to_non_nullable
              as double,
      isPresale: null == isPresale
          ? _value.isPresale
          : isPresale // ignore: cast_nullable_to_non_nullable
              as bool,
      seatLayoutId: null == seatLayoutId
          ? _value.seatLayoutId
          : seatLayoutId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShowImpl implements _Show {
  const _$ShowImpl(
      {required this.id,
      required this.eventId,
      required this.venueId,
      required this.screenId,
      required this.screenName,
      required this.startTime,
      this.endTime,
      required this.format,
      this.language = 'Hindi',
      required final Map<String, double> categoryPrices,
      this.occupancyPct = 0.0,
      this.isPresale = false,
      required this.seatLayoutId})
      : _categoryPrices = categoryPrices;

  factory _$ShowImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShowImplFromJson(json);

  @override
  final String id;
  @override
  final String eventId;
  @override
  final String venueId;
  @override
  final String screenId;
  @override
  final String screenName;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final ShowFormat format;
  @override
  @JsonKey()
  final String language;
  final Map<String, double> _categoryPrices;
  @override
  Map<String, double> get categoryPrices {
    if (_categoryPrices is EqualUnmodifiableMapView) return _categoryPrices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_categoryPrices);
  }

  @override
  @JsonKey()
  final double occupancyPct;
  @override
  @JsonKey()
  final bool isPresale;
  @override
  final String seatLayoutId;

  @override
  String toString() {
    return 'Show(id: $id, eventId: $eventId, venueId: $venueId, screenId: $screenId, screenName: $screenName, startTime: $startTime, endTime: $endTime, format: $format, language: $language, categoryPrices: $categoryPrices, occupancyPct: $occupancyPct, isPresale: $isPresale, seatLayoutId: $seatLayoutId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.screenId, screenId) ||
                other.screenId == screenId) &&
            (identical(other.screenName, screenName) ||
                other.screenName == screenName) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.language, language) ||
                other.language == language) &&
            const DeepCollectionEquality()
                .equals(other._categoryPrices, _categoryPrices) &&
            (identical(other.occupancyPct, occupancyPct) ||
                other.occupancyPct == occupancyPct) &&
            (identical(other.isPresale, isPresale) ||
                other.isPresale == isPresale) &&
            (identical(other.seatLayoutId, seatLayoutId) ||
                other.seatLayoutId == seatLayoutId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      eventId,
      venueId,
      screenId,
      screenName,
      startTime,
      endTime,
      format,
      language,
      const DeepCollectionEquality().hash(_categoryPrices),
      occupancyPct,
      isPresale,
      seatLayoutId);

  /// Create a copy of Show
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShowImplCopyWith<_$ShowImpl> get copyWith =>
      __$$ShowImplCopyWithImpl<_$ShowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShowImplToJson(
      this,
    );
  }
}

abstract class _Show implements Show {
  const factory _Show(
      {required final String id,
      required final String eventId,
      required final String venueId,
      required final String screenId,
      required final String screenName,
      required final DateTime startTime,
      final DateTime? endTime,
      required final ShowFormat format,
      final String language,
      required final Map<String, double> categoryPrices,
      final double occupancyPct,
      final bool isPresale,
      required final String seatLayoutId}) = _$ShowImpl;

  factory _Show.fromJson(Map<String, dynamic> json) = _$ShowImpl.fromJson;

  @override
  String get id;
  @override
  String get eventId;
  @override
  String get venueId;
  @override
  String get screenId;
  @override
  String get screenName;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  ShowFormat get format;
  @override
  String get language;
  @override
  Map<String, double> get categoryPrices;
  @override
  double get occupancyPct;
  @override
  bool get isPresale;
  @override
  String get seatLayoutId;

  /// Create a copy of Show
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShowImplCopyWith<_$ShowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
