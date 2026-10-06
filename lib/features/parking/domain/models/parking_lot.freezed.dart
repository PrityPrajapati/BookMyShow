// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parking_lot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ParkingLot _$ParkingLotFromJson(Map<String, dynamic> json) {
  return _ParkingLot.fromJson(json);
}

/// @nodoc
mixin _$ParkingLot {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  VehicleType get vehicleType => throw _privateConstructorUsedError;
  int get capacity => throw _privateConstructorUsedError;
  int get available => throw _privateConstructorUsedError;
  double get hourlyRate => throw _privateConstructorUsedError;
  double get flatRate => throw _privateConstructorUsedError;
  bool get isCovered => throw _privateConstructorUsedError;
  bool get hasValet => throw _privateConstructorUsedError;

  /// Serializes this ParkingLot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParkingLot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParkingLotCopyWith<ParkingLot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParkingLotCopyWith<$Res> {
  factory $ParkingLotCopyWith(
          ParkingLot value, $Res Function(ParkingLot) then) =
      _$ParkingLotCopyWithImpl<$Res, ParkingLot>;
  @useResult
  $Res call(
      {String id,
      String name,
      VehicleType vehicleType,
      int capacity,
      int available,
      double hourlyRate,
      double flatRate,
      bool isCovered,
      bool hasValet});
}

/// @nodoc
class _$ParkingLotCopyWithImpl<$Res, $Val extends ParkingLot>
    implements $ParkingLotCopyWith<$Res> {
  _$ParkingLotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParkingLot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? vehicleType = null,
    Object? capacity = null,
    Object? available = null,
    Object? hourlyRate = null,
    Object? flatRate = null,
    Object? isCovered = null,
    Object? hasValet = null,
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
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as VehicleType,
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      hourlyRate: null == hourlyRate
          ? _value.hourlyRate
          : hourlyRate // ignore: cast_nullable_to_non_nullable
              as double,
      flatRate: null == flatRate
          ? _value.flatRate
          : flatRate // ignore: cast_nullable_to_non_nullable
              as double,
      isCovered: null == isCovered
          ? _value.isCovered
          : isCovered // ignore: cast_nullable_to_non_nullable
              as bool,
      hasValet: null == hasValet
          ? _value.hasValet
          : hasValet // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ParkingLotImplCopyWith<$Res>
    implements $ParkingLotCopyWith<$Res> {
  factory _$$ParkingLotImplCopyWith(
          _$ParkingLotImpl value, $Res Function(_$ParkingLotImpl) then) =
      __$$ParkingLotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      VehicleType vehicleType,
      int capacity,
      int available,
      double hourlyRate,
      double flatRate,
      bool isCovered,
      bool hasValet});
}

/// @nodoc
class __$$ParkingLotImplCopyWithImpl<$Res>
    extends _$ParkingLotCopyWithImpl<$Res, _$ParkingLotImpl>
    implements _$$ParkingLotImplCopyWith<$Res> {
  __$$ParkingLotImplCopyWithImpl(
      _$ParkingLotImpl _value, $Res Function(_$ParkingLotImpl) _then)
      : super(_value, _then);

  /// Create a copy of ParkingLot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? vehicleType = null,
    Object? capacity = null,
    Object? available = null,
    Object? hourlyRate = null,
    Object? flatRate = null,
    Object? isCovered = null,
    Object? hasValet = null,
  }) {
    return _then(_$ParkingLotImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleType: null == vehicleType
          ? _value.vehicleType
          : vehicleType // ignore: cast_nullable_to_non_nullable
              as VehicleType,
      capacity: null == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      hourlyRate: null == hourlyRate
          ? _value.hourlyRate
          : hourlyRate // ignore: cast_nullable_to_non_nullable
              as double,
      flatRate: null == flatRate
          ? _value.flatRate
          : flatRate // ignore: cast_nullable_to_non_nullable
              as double,
      isCovered: null == isCovered
          ? _value.isCovered
          : isCovered // ignore: cast_nullable_to_non_nullable
              as bool,
      hasValet: null == hasValet
          ? _value.hasValet
          : hasValet // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ParkingLotImpl implements _ParkingLot {
  const _$ParkingLotImpl(
      {required this.id,
      required this.name,
      required this.vehicleType,
      required this.capacity,
      required this.available,
      required this.hourlyRate,
      required this.flatRate,
      this.isCovered = false,
      this.hasValet = false});

  factory _$ParkingLotImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParkingLotImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final VehicleType vehicleType;
  @override
  final int capacity;
  @override
  final int available;
  @override
  final double hourlyRate;
  @override
  final double flatRate;
  @override
  @JsonKey()
  final bool isCovered;
  @override
  @JsonKey()
  final bool hasValet;

  @override
  String toString() {
    return 'ParkingLot(id: $id, name: $name, vehicleType: $vehicleType, capacity: $capacity, available: $available, hourlyRate: $hourlyRate, flatRate: $flatRate, isCovered: $isCovered, hasValet: $hasValet)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParkingLotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.vehicleType, vehicleType) ||
                other.vehicleType == vehicleType) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.hourlyRate, hourlyRate) ||
                other.hourlyRate == hourlyRate) &&
            (identical(other.flatRate, flatRate) ||
                other.flatRate == flatRate) &&
            (identical(other.isCovered, isCovered) ||
                other.isCovered == isCovered) &&
            (identical(other.hasValet, hasValet) ||
                other.hasValet == hasValet));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, vehicleType, capacity,
      available, hourlyRate, flatRate, isCovered, hasValet);

  /// Create a copy of ParkingLot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParkingLotImplCopyWith<_$ParkingLotImpl> get copyWith =>
      __$$ParkingLotImplCopyWithImpl<_$ParkingLotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParkingLotImplToJson(
      this,
    );
  }
}

abstract class _ParkingLot implements ParkingLot {
  const factory _ParkingLot(
      {required final String id,
      required final String name,
      required final VehicleType vehicleType,
      required final int capacity,
      required final int available,
      required final double hourlyRate,
      required final double flatRate,
      final bool isCovered,
      final bool hasValet}) = _$ParkingLotImpl;

  factory _ParkingLot.fromJson(Map<String, dynamic> json) =
      _$ParkingLotImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  VehicleType get vehicleType;
  @override
  int get capacity;
  @override
  int get available;
  @override
  double get hourlyRate;
  @override
  double get flatRate;
  @override
  bool get isCovered;
  @override
  bool get hasValet;

  /// Create a copy of ParkingLot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParkingLotImplCopyWith<_$ParkingLotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
