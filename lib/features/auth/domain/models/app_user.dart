import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? avatarUrl,
    @Default(false) bool isGoldMember,
    DateTime? goldExpiry,
    @Default([]) List<String> preferredCities,
    @Default([]) List<String> favoriteGenres,
    @Default([]) List<String> favoriteLanguages,
    DateTime? createdAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
