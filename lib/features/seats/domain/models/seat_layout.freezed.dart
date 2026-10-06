// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seat_layout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Seat _$SeatFromJson(Map<String, dynamic> json) {
  return _Seat.fromJson(json);
}

/// @nodoc
mixin _$Seat {
  String get id => throw _privateConstructorUsedError;
  String get row => throw _privateConstructorUsedError;
  int get col => throw _privateConstructorUsedError;
  String get seatNumber => throw _privateConstructorUsedError;
  SeatType get type => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  SeatState get state => throw _privateConstructorUsedError;

  /// Serializes this Seat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeatCopyWith<Seat> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeatCopyWith<$Res> {
  factory $SeatCopyWith(Seat value, $Res Function(Seat) then) =
      _$SeatCopyWithImpl<$Res, Seat>;
  @useResult
  $Res call(
      {String id,
      String row,
      int col,
      String seatNumber,
      SeatType type,
      String category,
      SeatState state});
}

/// @nodoc
class _$SeatCopyWithImpl<$Res, $Val extends Seat>
    implements $SeatCopyWith<$Res> {
  _$SeatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? row = null,
    Object? col = null,
    Object? seatNumber = null,
    Object? type = null,
    Object? category = null,
    Object? state = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as String,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
      seatNumber: null == seatNumber
          ? _value.seatNumber
          : seatNumber // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SeatType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as SeatState,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeatImplCopyWith<$Res> implements $SeatCopyWith<$Res> {
  factory _$$SeatImplCopyWith(
          _$SeatImpl value, $Res Function(_$SeatImpl) then) =
      __$$SeatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String row,
      int col,
      String seatNumber,
      SeatType type,
      String category,
      SeatState state});
}

/// @nodoc
class __$$SeatImplCopyWithImpl<$Res>
    extends _$SeatCopyWithImpl<$Res, _$SeatImpl>
    implements _$$SeatImplCopyWith<$Res> {
  __$$SeatImplCopyWithImpl(_$SeatImpl _value, $Res Function(_$SeatImpl) _then)
      : super(_value, _then);

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? row = null,
    Object? col = null,
    Object? seatNumber = null,
    Object? type = null,
    Object? category = null,
    Object? state = null,
  }) {
    return _then(_$SeatImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      row: null == row
          ? _value.row
          : row // ignore: cast_nullable_to_non_nullable
              as String,
      col: null == col
          ? _value.col
          : col // ignore: cast_nullable_to_non_nullable
              as int,
      seatNumber: null == seatNumber
          ? _value.seatNumber
          : seatNumber // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SeatType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as SeatState,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeatImpl implements _Seat {
  const _$SeatImpl(
      {required this.id,
      required this.row,
      required this.col,
      required this.seatNumber,
      required this.type,
      required this.category,
      required this.state});

  factory _$SeatImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeatImplFromJson(json);

  @override
  final String id;
  @override
  final String row;
  @override
  final int col;
  @override
  final String seatNumber;
  @override
  final SeatType type;
  @override
  final String category;
  @override
  final SeatState state;

  @override
  String toString() {
    return 'Seat(id: $id, row: $row, col: $col, seatNumber: $seatNumber, type: $type, category: $category, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.row, row) || other.row == row) &&
            (identical(other.col, col) || other.col == col) &&
            (identical(other.seatNumber, seatNumber) ||
                other.seatNumber == seatNumber) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.state, state) || other.state == state));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, row, col, seatNumber, type, category, state);

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeatImplCopyWith<_$SeatImpl> get copyWith =>
      __$$SeatImplCopyWithImpl<_$SeatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeatImplToJson(
      this,
    );
  }
}

abstract class _Seat implements Seat {
  const factory _Seat(
      {required final String id,
      required final String row,
      required final int col,
      required final String seatNumber,
      required final SeatType type,
      required final String category,
      required final SeatState state}) = _$SeatImpl;

  factory _Seat.fromJson(Map<String, dynamic> json) = _$SeatImpl.fromJson;

  @override
  String get id;
  @override
  String get row;
  @override
  int get col;
  @override
  String get seatNumber;
  @override
  SeatType get type;
  @override
  String get category;
  @override
  SeatState get state;

  /// Create a copy of Seat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeatImplCopyWith<_$SeatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SeatRow _$SeatRowFromJson(Map<String, dynamic> json) {
  return _SeatRow.fromJson(json);
}

/// @nodoc
mixin _$SeatRow {
  String get rowLabel => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  List<Seat> get seats => throw _privateConstructorUsedError;

  /// Serializes this SeatRow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeatRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeatRowCopyWith<SeatRow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeatRowCopyWith<$Res> {
  factory $SeatRowCopyWith(SeatRow value, $Res Function(SeatRow) then) =
      _$SeatRowCopyWithImpl<$Res, SeatRow>;
  @useResult
  $Res call({String rowLabel, String category, double price, List<Seat> seats});
}

/// @nodoc
class _$SeatRowCopyWithImpl<$Res, $Val extends SeatRow>
    implements $SeatRowCopyWith<$Res> {
  _$SeatRowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeatRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rowLabel = null,
    Object? category = null,
    Object? price = null,
    Object? seats = null,
  }) {
    return _then(_value.copyWith(
      rowLabel: null == rowLabel
          ? _value.rowLabel
          : rowLabel // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      seats: null == seats
          ? _value.seats
          : seats // ignore: cast_nullable_to_non_nullable
              as List<Seat>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeatRowImplCopyWith<$Res> implements $SeatRowCopyWith<$Res> {
  factory _$$SeatRowImplCopyWith(
          _$SeatRowImpl value, $Res Function(_$SeatRowImpl) then) =
      __$$SeatRowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rowLabel, String category, double price, List<Seat> seats});
}

/// @nodoc
class __$$SeatRowImplCopyWithImpl<$Res>
    extends _$SeatRowCopyWithImpl<$Res, _$SeatRowImpl>
    implements _$$SeatRowImplCopyWith<$Res> {
  __$$SeatRowImplCopyWithImpl(
      _$SeatRowImpl _value, $Res Function(_$SeatRowImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeatRow
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rowLabel = null,
    Object? category = null,
    Object? price = null,
    Object? seats = null,
  }) {
    return _then(_$SeatRowImpl(
      rowLabel: null == rowLabel
          ? _value.rowLabel
          : rowLabel // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      seats: null == seats
          ? _value._seats
          : seats // ignore: cast_nullable_to_non_nullable
              as List<Seat>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeatRowImpl implements _SeatRow {
  const _$SeatRowImpl(
      {required this.rowLabel,
      required this.category,
      required this.price,
      required final List<Seat> seats})
      : _seats = seats;

  factory _$SeatRowImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeatRowImplFromJson(json);

  @override
  final String rowLabel;
  @override
  final String category;
  @override
  final double price;
  final List<Seat> _seats;
  @override
  List<Seat> get seats {
    if (_seats is EqualUnmodifiableListView) return _seats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seats);
  }

  @override
  String toString() {
    return 'SeatRow(rowLabel: $rowLabel, category: $category, price: $price, seats: $seats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeatRowImpl &&
            (identical(other.rowLabel, rowLabel) ||
                other.rowLabel == rowLabel) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.price, price) || other.price == price) &&
            const DeepCollectionEquality().equals(other._seats, _seats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rowLabel, category, price,
      const DeepCollectionEquality().hash(_seats));

  /// Create a copy of SeatRow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeatRowImplCopyWith<_$SeatRowImpl> get copyWith =>
      __$$SeatRowImplCopyWithImpl<_$SeatRowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeatRowImplToJson(
      this,
    );
  }
}

abstract class _SeatRow implements SeatRow {
  const factory _SeatRow(
      {required final String rowLabel,
      required final String category,
      required final double price,
      required final List<Seat> seats}) = _$SeatRowImpl;

  factory _SeatRow.fromJson(Map<String, dynamic> json) = _$SeatRowImpl.fromJson;

  @override
  String get rowLabel;
  @override
  String get category;
  @override
  double get price;
  @override
  List<Seat> get seats;

  /// Create a copy of SeatRow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeatRowImplCopyWith<_$SeatRowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SeatLayout _$SeatLayoutFromJson(Map<String, dynamic> json) {
  return _SeatLayout.fromJson(json);
}

/// @nodoc
mixin _$SeatLayout {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get screenType => throw _privateConstructorUsedError;
  int get totalSeats => throw _privateConstructorUsedError;
  List<SeatRow> get rows => throw _privateConstructorUsedError;

  /// Serializes this SeatLayout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeatLayout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeatLayoutCopyWith<SeatLayout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeatLayoutCopyWith<$Res> {
  factory $SeatLayoutCopyWith(
          SeatLayout value, $Res Function(SeatLayout) then) =
      _$SeatLayoutCopyWithImpl<$Res, SeatLayout>;
  @useResult
  $Res call(
      {String id,
      String name,
      String screenType,
      int totalSeats,
      List<SeatRow> rows});
}

/// @nodoc
class _$SeatLayoutCopyWithImpl<$Res, $Val extends SeatLayout>
    implements $SeatLayoutCopyWith<$Res> {
  _$SeatLayoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeatLayout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? screenType = null,
    Object? totalSeats = null,
    Object? rows = null,
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
      screenType: null == screenType
          ? _value.screenType
          : screenType // ignore: cast_nullable_to_non_nullable
              as String,
      totalSeats: null == totalSeats
          ? _value.totalSeats
          : totalSeats // ignore: cast_nullable_to_non_nullable
              as int,
      rows: null == rows
          ? _value.rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<SeatRow>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeatLayoutImplCopyWith<$Res>
    implements $SeatLayoutCopyWith<$Res> {
  factory _$$SeatLayoutImplCopyWith(
          _$SeatLayoutImpl value, $Res Function(_$SeatLayoutImpl) then) =
      __$$SeatLayoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String screenType,
      int totalSeats,
      List<SeatRow> rows});
}

/// @nodoc
class __$$SeatLayoutImplCopyWithImpl<$Res>
    extends _$SeatLayoutCopyWithImpl<$Res, _$SeatLayoutImpl>
    implements _$$SeatLayoutImplCopyWith<$Res> {
  __$$SeatLayoutImplCopyWithImpl(
      _$SeatLayoutImpl _value, $Res Function(_$SeatLayoutImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeatLayout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? screenType = null,
    Object? totalSeats = null,
    Object? rows = null,
  }) {
    return _then(_$SeatLayoutImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      screenType: null == screenType
          ? _value.screenType
          : screenType // ignore: cast_nullable_to_non_nullable
              as String,
      totalSeats: null == totalSeats
          ? _value.totalSeats
          : totalSeats // ignore: cast_nullable_to_non_nullable
              as int,
      rows: null == rows
          ? _value._rows
          : rows // ignore: cast_nullable_to_non_nullable
              as List<SeatRow>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeatLayoutImpl implements _SeatLayout {
  const _$SeatLayoutImpl(
      {required this.id,
      required this.name,
      required this.screenType,
      required this.totalSeats,
      required final List<SeatRow> rows})
      : _rows = rows;

  factory _$SeatLayoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeatLayoutImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String screenType;
  @override
  final int totalSeats;
  final List<SeatRow> _rows;
  @override
  List<SeatRow> get rows {
    if (_rows is EqualUnmodifiableListView) return _rows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rows);
  }

  @override
  String toString() {
    return 'SeatLayout(id: $id, name: $name, screenType: $screenType, totalSeats: $totalSeats, rows: $rows)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeatLayoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.screenType, screenType) ||
                other.screenType == screenType) &&
            (identical(other.totalSeats, totalSeats) ||
                other.totalSeats == totalSeats) &&
            const DeepCollectionEquality().equals(other._rows, _rows));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, screenType, totalSeats,
      const DeepCollectionEquality().hash(_rows));

  /// Create a copy of SeatLayout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeatLayoutImplCopyWith<_$SeatLayoutImpl> get copyWith =>
      __$$SeatLayoutImplCopyWithImpl<_$SeatLayoutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeatLayoutImplToJson(
      this,
    );
  }
}

abstract class _SeatLayout implements SeatLayout {
  const factory _SeatLayout(
      {required final String id,
      required final String name,
      required final String screenType,
      required final int totalSeats,
      required final List<SeatRow> rows}) = _$SeatLayoutImpl;

  factory _SeatLayout.fromJson(Map<String, dynamic> json) =
      _$SeatLayoutImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get screenType;
  @override
  int get totalSeats;
  @override
  List<SeatRow> get rows;

  /// Create a copy of SeatLayout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeatLayoutImplCopyWith<_$SeatLayoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
