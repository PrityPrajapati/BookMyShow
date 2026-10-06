import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';

part 'venue.freezed.dart';
part 'venue.g.dart';

enum VenueType {
  @JsonValue('cinema')
  cinema,
  @JsonValue('stadium')
  stadium,
}

@freezed
class GeoLocation with _$GeoLocation {
  const factory GeoLocation({
    required double latitude,
    required double longitude,
    String? formattedAddress,
  }) = _GeoLocation;

  factory GeoLocation.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationFromJson(json);
}

@freezed
class Venue with _$Venue {
  const factory Venue({
    required String id,
    required String name,
    required VenueType type,
    required String address,
    required String city,
    required String state,
    required GeoLocation geo,
    @Default([]) List<String> amenities,
    @Default([]) List<ParkingLot> parkingLots,
    String? imageUrl,
    @Default(0.0) double rating,
    @Default(0) int totalScreens,
  }) = _Venue;

  factory Venue.fromJson(Map<String, dynamic> json) => _$VenueFromJson(json);
}
