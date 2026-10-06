// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fnb_combo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FnbCombo _$FnbComboFromJson(Map<String, dynamic> json) {
  return _FnbCombo.fromJson(json);
}

/// @nodoc
mixin _$FnbCombo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  List<FnbItem> get items => throw _privateConstructorUsedError;
  double get comboPrice => throw _privateConstructorUsedError;
  double? get originalPrice => throw _privateConstructorUsedError;
  double get savings => throw _privateConstructorUsedError;

  /// Serializes this FnbCombo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FnbCombo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FnbComboCopyWith<FnbCombo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FnbComboCopyWith<$Res> {
  factory $FnbComboCopyWith(FnbCombo value, $Res Function(FnbCombo) then) =
      _$FnbComboCopyWithImpl<$Res, FnbCombo>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String imageUrl,
      List<FnbItem> items,
      double comboPrice,
      double? originalPrice,
      double savings});
}

/// @nodoc
class _$FnbComboCopyWithImpl<$Res, $Val extends FnbCombo>
    implements $FnbComboCopyWith<$Res> {
  _$FnbComboCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FnbCombo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? items = null,
    Object? comboPrice = null,
    Object? originalPrice = freezed,
    Object? savings = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<FnbItem>,
      comboPrice: null == comboPrice
          ? _value.comboPrice
          : comboPrice // ignore: cast_nullable_to_non_nullable
              as double,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      savings: null == savings
          ? _value.savings
          : savings // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FnbComboImplCopyWith<$Res>
    implements $FnbComboCopyWith<$Res> {
  factory _$$FnbComboImplCopyWith(
          _$FnbComboImpl value, $Res Function(_$FnbComboImpl) then) =
      __$$FnbComboImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String imageUrl,
      List<FnbItem> items,
      double comboPrice,
      double? originalPrice,
      double savings});
}

/// @nodoc
class __$$FnbComboImplCopyWithImpl<$Res>
    extends _$FnbComboCopyWithImpl<$Res, _$FnbComboImpl>
    implements _$$FnbComboImplCopyWith<$Res> {
  __$$FnbComboImplCopyWithImpl(
      _$FnbComboImpl _value, $Res Function(_$FnbComboImpl) _then)
      : super(_value, _then);

  /// Create a copy of FnbCombo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? items = null,
    Object? comboPrice = null,
    Object? originalPrice = freezed,
    Object? savings = null,
  }) {
    return _then(_$FnbComboImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<FnbItem>,
      comboPrice: null == comboPrice
          ? _value.comboPrice
          : comboPrice // ignore: cast_nullable_to_non_nullable
              as double,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      savings: null == savings
          ? _value.savings
          : savings // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FnbComboImpl extends _FnbCombo {
  const _$FnbComboImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.imageUrl,
      final List<FnbItem> items = const [],
      required this.comboPrice,
      this.originalPrice,
      this.savings = 0.0})
      : _items = items,
        super._();

  factory _$FnbComboImpl.fromJson(Map<String, dynamic> json) =>
      _$$FnbComboImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String imageUrl;
  final List<FnbItem> _items;
  @override
  @JsonKey()
  List<FnbItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double comboPrice;
  @override
  final double? originalPrice;
  @override
  @JsonKey()
  final double savings;

  @override
  String toString() {
    return 'FnbCombo(id: $id, name: $name, description: $description, imageUrl: $imageUrl, items: $items, comboPrice: $comboPrice, originalPrice: $originalPrice, savings: $savings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FnbComboImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.comboPrice, comboPrice) ||
                other.comboPrice == comboPrice) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.savings, savings) || other.savings == savings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      imageUrl,
      const DeepCollectionEquality().hash(_items),
      comboPrice,
      originalPrice,
      savings);

  /// Create a copy of FnbCombo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FnbComboImplCopyWith<_$FnbComboImpl> get copyWith =>
      __$$FnbComboImplCopyWithImpl<_$FnbComboImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FnbComboImplToJson(
      this,
    );
  }
}

abstract class _FnbCombo extends FnbCombo {
  const factory _FnbCombo(
      {required final String id,
      required final String name,
      required final String description,
      required final String imageUrl,
      final List<FnbItem> items,
      required final double comboPrice,
      final double? originalPrice,
      final double savings}) = _$FnbComboImpl;
  const _FnbCombo._() : super._();

  factory _FnbCombo.fromJson(Map<String, dynamic> json) =
      _$FnbComboImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  List<FnbItem> get items;
  @override
  double get comboPrice;
  @override
  double? get originalPrice;
  @override
  double get savings;

  /// Create a copy of FnbCombo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FnbComboImplCopyWith<_$FnbComboImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
