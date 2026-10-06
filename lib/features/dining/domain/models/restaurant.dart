import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant.freezed.dart';
part 'restaurant.g.dart';

@freezed
class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String id,
    required String name,
    @Default([]) List<String> cuisine,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    required double costForTwo,
    required String address,
    required String city,
    @Default(1.0) double distanceKm,
    required String imageUrl,
    required String bannerUrl,
    required String openTime,
    required String closeTime,
    @Default([]) List<String> amenities,
    @Default(true) bool hasTableBooking,
    @Default(false) bool isPureVeg,
    @Default([]) List<String> featuredDishes,
  }) = _Restaurant;

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);
}
