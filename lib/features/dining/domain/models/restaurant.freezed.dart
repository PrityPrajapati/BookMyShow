// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) {
  return _Restaurant.fromJson(json);
}

/// @nodoc
mixin _$Restaurant {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get cuisine => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  double get costForTwo => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get bannerUrl => throw _privateConstructorUsedError;
  String get openTime => throw _privateConstructorUsedError;
  String get closeTime => throw _privateConstructorUsedError;
  List<String> get amenities => throw _privateConstructorUsedError;
  bool get hasTableBooking => throw _privateConstructorUsedError;
  bool get isPureVeg => throw _privateConstructorUsedError;
  List<String> get featuredDishes => throw _privateConstructorUsedError;

  /// Serializes this Restaurant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RestaurantCopyWith<Restaurant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RestaurantCopyWith<$Res> {
  factory $RestaurantCopyWith(
          Restaurant value, $Res Function(Restaurant) then) =
      _$RestaurantCopyWithImpl<$Res, Restaurant>;
  @useResult
  $Res call(
      {String id,
      String name,
      List<String> cuisine,
      double rating,
      int reviewCount,
      double costForTwo,
      String address,
      String city,
      double distanceKm,
      String imageUrl,
      String bannerUrl,
      String openTime,
      String closeTime,
      List<String> amenities,
      bool hasTableBooking,
      bool isPureVeg,
      List<String> featuredDishes});
}

/// @nodoc
class _$RestaurantCopyWithImpl<$Res, $Val extends Restaurant>
    implements $RestaurantCopyWith<$Res> {
  _$RestaurantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? cuisine = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? costForTwo = null,
    Object? address = null,
    Object? city = null,
    Object? distanceKm = null,
    Object? imageUrl = null,
    Object? bannerUrl = null,
    Object? openTime = null,
    Object? closeTime = null,
    Object? amenities = null,
    Object? hasTableBooking = null,
    Object? isPureVeg = null,
    Object? featuredDishes = null,
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
      cuisine: null == cuisine
          ? _value.cuisine
          : cuisine // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      costForTwo: null == costForTwo
          ? _value.costForTwo
          : costForTwo // ignore: cast_nullable_to_non_nullable
              as double,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bannerUrl: null == bannerUrl
          ? _value.bannerUrl
          : bannerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      openTime: null == openTime
          ? _value.openTime
          : openTime // ignore: cast_nullable_to_non_nullable
              as String,
      closeTime: null == closeTime
          ? _value.closeTime
          : closeTime // ignore: cast_nullable_to_non_nullable
              as String,
      amenities: null == amenities
          ? _value.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasTableBooking: null == hasTableBooking
          ? _value.hasTableBooking
          : hasTableBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      isPureVeg: null == isPureVeg
          ? _value.isPureVeg
          : isPureVeg // ignore: cast_nullable_to_non_nullable
              as bool,
      featuredDishes: null == featuredDishes
          ? _value.featuredDishes
          : featuredDishes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RestaurantImplCopyWith<$Res>
    implements $RestaurantCopyWith<$Res> {
  factory _$$RestaurantImplCopyWith(
          _$RestaurantImpl value, $Res Function(_$RestaurantImpl) then) =
      __$$RestaurantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      List<String> cuisine,
      double rating,
      int reviewCount,
      double costForTwo,
      String address,
      String city,
      double distanceKm,
      String imageUrl,
      String bannerUrl,
      String openTime,
      String closeTime,
      List<String> amenities,
      bool hasTableBooking,
      bool isPureVeg,
      List<String> featuredDishes});
}

/// @nodoc
class __$$RestaurantImplCopyWithImpl<$Res>
    extends _$RestaurantCopyWithImpl<$Res, _$RestaurantImpl>
    implements _$$RestaurantImplCopyWith<$Res> {
  __$$RestaurantImplCopyWithImpl(
      _$RestaurantImpl _value, $Res Function(_$RestaurantImpl) _then)
      : super(_value, _then);

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? cuisine = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? costForTwo = null,
    Object? address = null,
    Object? city = null,
    Object? distanceKm = null,
    Object? imageUrl = null,
    Object? bannerUrl = null,
    Object? openTime = null,
    Object? closeTime = null,
    Object? amenities = null,
    Object? hasTableBooking = null,
    Object? isPureVeg = null,
    Object? featuredDishes = null,
  }) {
    return _then(_$RestaurantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      cuisine: null == cuisine
          ? _value._cuisine
          : cuisine // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      reviewCount: null == reviewCount
          ? _value.reviewCount
          : reviewCount // ignore: cast_nullable_to_non_nullable
              as int,
      costForTwo: null == costForTwo
          ? _value.costForTwo
          : costForTwo // ignore: cast_nullable_to_non_nullable
              as double,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bannerUrl: null == bannerUrl
          ? _value.bannerUrl
          : bannerUrl // ignore: cast_nullable_to_non_nullable
              as String,
      openTime: null == openTime
          ? _value.openTime
          : openTime // ignore: cast_nullable_to_non_nullable
              as String,
      closeTime: null == closeTime
          ? _value.closeTime
          : closeTime // ignore: cast_nullable_to_non_nullable
              as String,
      amenities: null == amenities
          ? _value._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      hasTableBooking: null == hasTableBooking
          ? _value.hasTableBooking
          : hasTableBooking // ignore: cast_nullable_to_non_nullable
              as bool,
      isPureVeg: null == isPureVeg
          ? _value.isPureVeg
          : isPureVeg // ignore: cast_nullable_to_non_nullable
              as bool,
      featuredDishes: null == featuredDishes
          ? _value._featuredDishes
          : featuredDishes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RestaurantImpl implements _Restaurant {
  const _$RestaurantImpl(
      {required this.id,
      required this.name,
      final List<String> cuisine = const [],
      this.rating = 0.0,
      this.reviewCount = 0,
      required this.costForTwo,
      required this.address,
      required this.city,
      this.distanceKm = 1.0,
      required this.imageUrl,
      required this.bannerUrl,
      required this.openTime,
      required this.closeTime,
      final List<String> amenities = const [],
      this.hasTableBooking = true,
      this.isPureVeg = false,
      final List<String> featuredDishes = const []})
      : _cuisine = cuisine,
        _amenities = amenities,
        _featuredDishes = featuredDishes;

  factory _$RestaurantImpl.fromJson(Map<String, dynamic> json) =>
      _$$RestaurantImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<String> _cuisine;
  @override
  @JsonKey()
  List<String> get cuisine {
    if (_cuisine is EqualUnmodifiableListView) return _cuisine;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cuisine);
  }

  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int reviewCount;
  @override
  final double costForTwo;
  @override
  final String address;
  @override
  final String city;
  @override
  @JsonKey()
  final double distanceKm;
  @override
  final String imageUrl;
  @override
  final String bannerUrl;
  @override
  final String openTime;
  @override
  final String closeTime;
  final List<String> _amenities;
  @override
  @JsonKey()
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  @override
  @JsonKey()
  final bool hasTableBooking;
  @override
  @JsonKey()
  final bool isPureVeg;
  final List<String> _featuredDishes;
  @override
  @JsonKey()
  List<String> get featuredDishes {
    if (_featuredDishes is EqualUnmodifiableListView) return _featuredDishes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_featuredDishes);
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, cuisine: $cuisine, rating: $rating, reviewCount: $reviewCount, costForTwo: $costForTwo, address: $address, city: $city, distanceKm: $distanceKm, imageUrl: $imageUrl, bannerUrl: $bannerUrl, openTime: $openTime, closeTime: $closeTime, amenities: $amenities, hasTableBooking: $hasTableBooking, isPureVeg: $isPureVeg, featuredDishes: $featuredDishes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RestaurantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._cuisine, _cuisine) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.costForTwo, costForTwo) ||
                other.costForTwo == costForTwo) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.bannerUrl, bannerUrl) ||
                other.bannerUrl == bannerUrl) &&
            (identical(other.openTime, openTime) ||
                other.openTime == openTime) &&
            (identical(other.closeTime, closeTime) ||
                other.closeTime == closeTime) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            (identical(other.hasTableBooking, hasTableBooking) ||
                other.hasTableBooking == hasTableBooking) &&
            (identical(other.isPureVeg, isPureVeg) ||
                other.isPureVeg == isPureVeg) &&
            const DeepCollectionEquality()
                .equals(other._featuredDishes, _featuredDishes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      const DeepCollectionEquality().hash(_cuisine),
      rating,
      reviewCount,
      costForTwo,
      address,
      city,
      distanceKm,
      imageUrl,
      bannerUrl,
      openTime,
      closeTime,
      const DeepCollectionEquality().hash(_amenities),
      hasTableBooking,
      isPureVeg,
      const DeepCollectionEquality().hash(_featuredDishes));

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RestaurantImplCopyWith<_$RestaurantImpl> get copyWith =>
      __$$RestaurantImplCopyWithImpl<_$RestaurantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RestaurantImplToJson(
      this,
    );
  }
}

abstract class _Restaurant implements Restaurant {
  const factory _Restaurant(
      {required final String id,
      required final String name,
      final List<String> cuisine,
      final double rating,
      final int reviewCount,
      required final double costForTwo,
      required final String address,
      required final String city,
      final double distanceKm,
      required final String imageUrl,
      required final String bannerUrl,
      required final String openTime,
      required final String closeTime,
      final List<String> amenities,
      final bool hasTableBooking,
      final bool isPureVeg,
      final List<String> featuredDishes}) = _$RestaurantImpl;

  factory _Restaurant.fromJson(Map<String, dynamic> json) =
      _$RestaurantImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<String> get cuisine;
  @override
  double get rating;
  @override
  int get reviewCount;
  @override
  double get costForTwo;
  @override
  String get address;
  @override
  String get city;
  @override
  double get distanceKm;
  @override
  String get imageUrl;
  @override
  String get bannerUrl;
  @override
  String get openTime;
  @override
  String get closeTime;
  @override
  List<String> get amenities;
  @override
  bool get hasTableBooking;
  @override
  bool get isPureVeg;
  @override
  List<String> get featuredDishes;

  /// Create a copy of Restaurant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RestaurantImplCopyWith<_$RestaurantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
