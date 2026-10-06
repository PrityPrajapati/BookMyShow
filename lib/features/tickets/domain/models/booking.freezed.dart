// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Booking _$BookingFromJson(Map<String, dynamic> json) {
  return _Booking.fromJson(json);
}

/// @nodoc
mixin _$Booking {
  String get id => throw _privateConstructorUsedError;
  String get bookingNumber => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  String? get eventTitle => throw _privateConstructorUsedError;
  String? get eventPosterUrl => throw _privateConstructorUsedError;
  String get venueId => throw _privateConstructorUsedError;
  String? get venueName => throw _privateConstructorUsedError;
  String get showId => throw _privateConstructorUsedError;
  DateTime get showTime => throw _privateConstructorUsedError;
  String? get showFormat => throw _privateConstructorUsedError;
  DateTime get bookingTime => throw _privateConstructorUsedError;
  List<Ticket> get tickets => throw _privateConstructorUsedError;
  List<FnbItem> get fnbItems => throw _privateConstructorUsedError;
  ParkingLot? get parkingLot => throw _privateConstructorUsedError;
  PriceBreakdown get priceBreakdown => throw _privateConstructorUsedError;
  BookingStatus get status => throw _privateConstructorUsedError;
  String get qrCodeData => throw _privateConstructorUsedError;

  /// Serializes this Booking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingCopyWith<Booking> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingCopyWith<$Res> {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) then) =
      _$BookingCopyWithImpl<$Res, Booking>;
  @useResult
  $Res call(
      {String id,
      String bookingNumber,
      String userId,
      String eventId,
      String? eventTitle,
      String? eventPosterUrl,
      String venueId,
      String? venueName,
      String showId,
      DateTime showTime,
      String? showFormat,
      DateTime bookingTime,
      List<Ticket> tickets,
      List<FnbItem> fnbItems,
      ParkingLot? parkingLot,
      PriceBreakdown priceBreakdown,
      BookingStatus status,
      String qrCodeData});

  $ParkingLotCopyWith<$Res>? get parkingLot;
  $PriceBreakdownCopyWith<$Res> get priceBreakdown;
}

/// @nodoc
class _$BookingCopyWithImpl<$Res, $Val extends Booking>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingNumber = null,
    Object? userId = null,
    Object? eventId = null,
    Object? eventTitle = freezed,
    Object? eventPosterUrl = freezed,
    Object? venueId = null,
    Object? venueName = freezed,
    Object? showId = null,
    Object? showTime = null,
    Object? showFormat = freezed,
    Object? bookingTime = null,
    Object? tickets = null,
    Object? fnbItems = null,
    Object? parkingLot = freezed,
    Object? priceBreakdown = null,
    Object? status = null,
    Object? qrCodeData = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bookingNumber: null == bookingNumber
          ? _value.bookingNumber
          : bookingNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      eventTitle: freezed == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      eventPosterUrl: freezed == eventPosterUrl
          ? _value.eventPosterUrl
          : eventPosterUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      venueName: freezed == venueName
          ? _value.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String?,
      showId: null == showId
          ? _value.showId
          : showId // ignore: cast_nullable_to_non_nullable
              as String,
      showTime: null == showTime
          ? _value.showTime
          : showTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      showFormat: freezed == showFormat
          ? _value.showFormat
          : showFormat // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingTime: null == bookingTime
          ? _value.bookingTime
          : bookingTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tickets: null == tickets
          ? _value.tickets
          : tickets // ignore: cast_nullable_to_non_nullable
              as List<Ticket>,
      fnbItems: null == fnbItems
          ? _value.fnbItems
          : fnbItems // ignore: cast_nullable_to_non_nullable
              as List<FnbItem>,
      parkingLot: freezed == parkingLot
          ? _value.parkingLot
          : parkingLot // ignore: cast_nullable_to_non_nullable
              as ParkingLot?,
      priceBreakdown: null == priceBreakdown
          ? _value.priceBreakdown
          : priceBreakdown // ignore: cast_nullable_to_non_nullable
              as PriceBreakdown,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      qrCodeData: null == qrCodeData
          ? _value.qrCodeData
          : qrCodeData // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ParkingLotCopyWith<$Res>? get parkingLot {
    if (_value.parkingLot == null) {
      return null;
    }

    return $ParkingLotCopyWith<$Res>(_value.parkingLot!, (value) {
      return _then(_value.copyWith(parkingLot: value) as $Val);
    });
  }

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PriceBreakdownCopyWith<$Res> get priceBreakdown {
    return $PriceBreakdownCopyWith<$Res>(_value.priceBreakdown, (value) {
      return _then(_value.copyWith(priceBreakdown: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingImplCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$$BookingImplCopyWith(
          _$BookingImpl value, $Res Function(_$BookingImpl) then) =
      __$$BookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String bookingNumber,
      String userId,
      String eventId,
      String? eventTitle,
      String? eventPosterUrl,
      String venueId,
      String? venueName,
      String showId,
      DateTime showTime,
      String? showFormat,
      DateTime bookingTime,
      List<Ticket> tickets,
      List<FnbItem> fnbItems,
      ParkingLot? parkingLot,
      PriceBreakdown priceBreakdown,
      BookingStatus status,
      String qrCodeData});

  @override
  $ParkingLotCopyWith<$Res>? get parkingLot;
  @override
  $PriceBreakdownCopyWith<$Res> get priceBreakdown;
}

/// @nodoc
class __$$BookingImplCopyWithImpl<$Res>
    extends _$BookingCopyWithImpl<$Res, _$BookingImpl>
    implements _$$BookingImplCopyWith<$Res> {
  __$$BookingImplCopyWithImpl(
      _$BookingImpl _value, $Res Function(_$BookingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookingNumber = null,
    Object? userId = null,
    Object? eventId = null,
    Object? eventTitle = freezed,
    Object? eventPosterUrl = freezed,
    Object? venueId = null,
    Object? venueName = freezed,
    Object? showId = null,
    Object? showTime = null,
    Object? showFormat = freezed,
    Object? bookingTime = null,
    Object? tickets = null,
    Object? fnbItems = null,
    Object? parkingLot = freezed,
    Object? priceBreakdown = null,
    Object? status = null,
    Object? qrCodeData = null,
  }) {
    return _then(_$BookingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      bookingNumber: null == bookingNumber
          ? _value.bookingNumber
          : bookingNumber // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      eventTitle: freezed == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      eventPosterUrl: freezed == eventPosterUrl
          ? _value.eventPosterUrl
          : eventPosterUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      venueName: freezed == venueName
          ? _value.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String?,
      showId: null == showId
          ? _value.showId
          : showId // ignore: cast_nullable_to_non_nullable
              as String,
      showTime: null == showTime
          ? _value.showTime
          : showTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      showFormat: freezed == showFormat
          ? _value.showFormat
          : showFormat // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingTime: null == bookingTime
          ? _value.bookingTime
          : bookingTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tickets: null == tickets
          ? _value._tickets
          : tickets // ignore: cast_nullable_to_non_nullable
              as List<Ticket>,
      fnbItems: null == fnbItems
          ? _value._fnbItems
          : fnbItems // ignore: cast_nullable_to_non_nullable
              as List<FnbItem>,
      parkingLot: freezed == parkingLot
          ? _value.parkingLot
          : parkingLot // ignore: cast_nullable_to_non_nullable
              as ParkingLot?,
      priceBreakdown: null == priceBreakdown
          ? _value.priceBreakdown
          : priceBreakdown // ignore: cast_nullable_to_non_nullable
              as PriceBreakdown,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      qrCodeData: null == qrCodeData
          ? _value.qrCodeData
          : qrCodeData // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingImpl implements _Booking {
  const _$BookingImpl(
      {required this.id,
      required this.bookingNumber,
      required this.userId,
      required this.eventId,
      this.eventTitle,
      this.eventPosterUrl,
      required this.venueId,
      this.venueName,
      required this.showId,
      required this.showTime,
      this.showFormat,
      required this.bookingTime,
      final List<Ticket> tickets = const [],
      final List<FnbItem> fnbItems = const [],
      this.parkingLot,
      required this.priceBreakdown,
      this.status = BookingStatus.confirmed,
      required this.qrCodeData})
      : _tickets = tickets,
        _fnbItems = fnbItems;

  factory _$BookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingImplFromJson(json);

  @override
  final String id;
  @override
  final String bookingNumber;
  @override
  final String userId;
  @override
  final String eventId;
  @override
  final String? eventTitle;
  @override
  final String? eventPosterUrl;
  @override
  final String venueId;
  @override
  final String? venueName;
  @override
  final String showId;
  @override
  final DateTime showTime;
  @override
  final String? showFormat;
  @override
  final DateTime bookingTime;
  final List<Ticket> _tickets;
  @override
  @JsonKey()
  List<Ticket> get tickets {
    if (_tickets is EqualUnmodifiableListView) return _tickets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tickets);
  }

  final List<FnbItem> _fnbItems;
  @override
  @JsonKey()
  List<FnbItem> get fnbItems {
    if (_fnbItems is EqualUnmodifiableListView) return _fnbItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fnbItems);
  }

  @override
  final ParkingLot? parkingLot;
  @override
  final PriceBreakdown priceBreakdown;
  @override
  @JsonKey()
  final BookingStatus status;
  @override
  final String qrCodeData;

  @override
  String toString() {
    return 'Booking(id: $id, bookingNumber: $bookingNumber, userId: $userId, eventId: $eventId, eventTitle: $eventTitle, eventPosterUrl: $eventPosterUrl, venueId: $venueId, venueName: $venueName, showId: $showId, showTime: $showTime, showFormat: $showFormat, bookingTime: $bookingTime, tickets: $tickets, fnbItems: $fnbItems, parkingLot: $parkingLot, priceBreakdown: $priceBreakdown, status: $status, qrCodeData: $qrCodeData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookingNumber, bookingNumber) ||
                other.bookingNumber == bookingNumber) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.eventTitle, eventTitle) ||
                other.eventTitle == eventTitle) &&
            (identical(other.eventPosterUrl, eventPosterUrl) ||
                other.eventPosterUrl == eventPosterUrl) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.venueName, venueName) ||
                other.venueName == venueName) &&
            (identical(other.showId, showId) || other.showId == showId) &&
            (identical(other.showTime, showTime) ||
                other.showTime == showTime) &&
            (identical(other.showFormat, showFormat) ||
                other.showFormat == showFormat) &&
            (identical(other.bookingTime, bookingTime) ||
                other.bookingTime == bookingTime) &&
            const DeepCollectionEquality().equals(other._tickets, _tickets) &&
            const DeepCollectionEquality().equals(other._fnbItems, _fnbItems) &&
            (identical(other.parkingLot, parkingLot) ||
                other.parkingLot == parkingLot) &&
            (identical(other.priceBreakdown, priceBreakdown) ||
                other.priceBreakdown == priceBreakdown) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.qrCodeData, qrCodeData) ||
                other.qrCodeData == qrCodeData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      bookingNumber,
      userId,
      eventId,
      eventTitle,
      eventPosterUrl,
      venueId,
      venueName,
      showId,
      showTime,
      showFormat,
      bookingTime,
      const DeepCollectionEquality().hash(_tickets),
      const DeepCollectionEquality().hash(_fnbItems),
      parkingLot,
      priceBreakdown,
      status,
      qrCodeData);

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      __$$BookingImplCopyWithImpl<_$BookingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingImplToJson(
      this,
    );
  }
}

abstract class _Booking implements Booking {
  const factory _Booking(
      {required final String id,
      required final String bookingNumber,
      required final String userId,
      required final String eventId,
      final String? eventTitle,
      final String? eventPosterUrl,
      required final String venueId,
      final String? venueName,
      required final String showId,
      required final DateTime showTime,
      final String? showFormat,
      required final DateTime bookingTime,
      final List<Ticket> tickets,
      final List<FnbItem> fnbItems,
      final ParkingLot? parkingLot,
      required final PriceBreakdown priceBreakdown,
      final BookingStatus status,
      required final String qrCodeData}) = _$BookingImpl;

  factory _Booking.fromJson(Map<String, dynamic> json) = _$BookingImpl.fromJson;

  @override
  String get id;
  @override
  String get bookingNumber;
  @override
  String get userId;
  @override
  String get eventId;
  @override
  String? get eventTitle;
  @override
  String? get eventPosterUrl;
  @override
  String get venueId;
  @override
  String? get venueName;
  @override
  String get showId;
  @override
  DateTime get showTime;
  @override
  String? get showFormat;
  @override
  DateTime get bookingTime;
  @override
  List<Ticket> get tickets;
  @override
  List<FnbItem> get fnbItems;
  @override
  ParkingLot? get parkingLot;
  @override
  PriceBreakdown get priceBreakdown;
  @override
  BookingStatus get status;
  @override
  String get qrCodeData;

  /// Create a copy of Booking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingImplCopyWith<_$BookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
