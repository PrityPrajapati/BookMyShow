// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  bool get isGoldMember => throw _privateConstructorUsedError;
  DateTime? get goldExpiry => throw _privateConstructorUsedError;
  List<String> get preferredCities => throw _privateConstructorUsedError;
  List<String> get favoriteGenres => throw _privateConstructorUsedError;
  List<String> get favoriteLanguages => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      String phone,
      String? avatarUrl,
      bool isGoldMember,
      DateTime? goldExpiry,
      List<String> preferredCities,
      List<String> favoriteGenres,
      List<String> favoriteLanguages,
      DateTime? createdAt});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? avatarUrl = freezed,
    Object? isGoldMember = null,
    Object? goldExpiry = freezed,
    Object? preferredCities = null,
    Object? favoriteGenres = null,
    Object? favoriteLanguages = null,
    Object? createdAt = freezed,
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
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isGoldMember: null == isGoldMember
          ? _value.isGoldMember
          : isGoldMember // ignore: cast_nullable_to_non_nullable
              as bool,
      goldExpiry: freezed == goldExpiry
          ? _value.goldExpiry
          : goldExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      preferredCities: null == preferredCities
          ? _value.preferredCities
          : preferredCities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteGenres: null == favoriteGenres
          ? _value.favoriteGenres
          : favoriteGenres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteLanguages: null == favoriteLanguages
          ? _value.favoriteLanguages
          : favoriteLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String email,
      String phone,
      String? avatarUrl,
      bool isGoldMember,
      DateTime? goldExpiry,
      List<String> preferredCities,
      List<String> favoriteGenres,
      List<String> favoriteLanguages,
      DateTime? createdAt});
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = null,
    Object? phone = null,
    Object? avatarUrl = freezed,
    Object? isGoldMember = null,
    Object? goldExpiry = freezed,
    Object? preferredCities = null,
    Object? favoriteGenres = null,
    Object? favoriteLanguages = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$AppUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isGoldMember: null == isGoldMember
          ? _value.isGoldMember
          : isGoldMember // ignore: cast_nullable_to_non_nullable
              as bool,
      goldExpiry: freezed == goldExpiry
          ? _value.goldExpiry
          : goldExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      preferredCities: null == preferredCities
          ? _value._preferredCities
          : preferredCities // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteGenres: null == favoriteGenres
          ? _value._favoriteGenres
          : favoriteGenres // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteLanguages: null == favoriteLanguages
          ? _value._favoriteLanguages
          : favoriteLanguages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl implements _AppUser {
  const _$AppUserImpl(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone,
      this.avatarUrl,
      this.isGoldMember = false,
      this.goldExpiry,
      final List<String> preferredCities = const [],
      final List<String> favoriteGenres = const [],
      final List<String> favoriteLanguages = const [],
      this.createdAt})
      : _preferredCities = preferredCities,
        _favoriteGenres = favoriteGenres,
        _favoriteLanguages = favoriteLanguages;

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String email;
  @override
  final String phone;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final bool isGoldMember;
  @override
  final DateTime? goldExpiry;
  final List<String> _preferredCities;
  @override
  @JsonKey()
  List<String> get preferredCities {
    if (_preferredCities is EqualUnmodifiableListView) return _preferredCities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredCities);
  }

  final List<String> _favoriteGenres;
  @override
  @JsonKey()
  List<String> get favoriteGenres {
    if (_favoriteGenres is EqualUnmodifiableListView) return _favoriteGenres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteGenres);
  }

  final List<String> _favoriteLanguages;
  @override
  @JsonKey()
  List<String> get favoriteLanguages {
    if (_favoriteLanguages is EqualUnmodifiableListView)
      return _favoriteLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteLanguages);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AppUser(id: $id, name: $name, email: $email, phone: $phone, avatarUrl: $avatarUrl, isGoldMember: $isGoldMember, goldExpiry: $goldExpiry, preferredCities: $preferredCities, favoriteGenres: $favoriteGenres, favoriteLanguages: $favoriteLanguages, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.isGoldMember, isGoldMember) ||
                other.isGoldMember == isGoldMember) &&
            (identical(other.goldExpiry, goldExpiry) ||
                other.goldExpiry == goldExpiry) &&
            const DeepCollectionEquality()
                .equals(other._preferredCities, _preferredCities) &&
            const DeepCollectionEquality()
                .equals(other._favoriteGenres, _favoriteGenres) &&
            const DeepCollectionEquality()
                .equals(other._favoriteLanguages, _favoriteLanguages) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      email,
      phone,
      avatarUrl,
      isGoldMember,
      goldExpiry,
      const DeepCollectionEquality().hash(_preferredCities),
      const DeepCollectionEquality().hash(_favoriteGenres),
      const DeepCollectionEquality().hash(_favoriteLanguages),
      createdAt);

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser implements AppUser {
  const factory _AppUser(
      {required final String id,
      required final String name,
      required final String email,
      required final String phone,
      final String? avatarUrl,
      final bool isGoldMember,
      final DateTime? goldExpiry,
      final List<String> preferredCities,
      final List<String> favoriteGenres,
      final List<String> favoriteLanguages,
      final DateTime? createdAt}) = _$AppUserImpl;

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get email;
  @override
  String get phone;
  @override
  String? get avatarUrl;
  @override
  bool get isGoldMember;
  @override
  DateTime? get goldExpiry;
  @override
  List<String> get preferredCities;
  @override
  List<String> get favoriteGenres;
  @override
  List<String> get favoriteLanguages;
  @override
  DateTime? get createdAt;

  /// Create a copy of AppUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
