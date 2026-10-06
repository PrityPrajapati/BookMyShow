import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/features/venue_map/domain/models/venue.dart';
import 'package:showscape/features/venue_map/domain/repositories/venue_repository.dart';

class MockVenueRepository implements VenueRepository {
  static List<Venue>? _cachedVenues;

  Future<List<Venue>> _loadAll() async {
    if (_cachedVenues != null) return _cachedVenues!;

    final jsonStr = await rootBundle.loadString('assets/mock/venues.json');
    final raw = jsonDecode(jsonStr) as List<dynamic>;
    _cachedVenues = raw
        .map((e) => Venue.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedVenues!;
  }

  @override
  Future<List<Venue>> getVenues({String? city, VenueType? type}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final venues = await _loadAll();
    return venues.where((v) {
      if (city != null && v.city.toLowerCase() != city.toLowerCase()) {
        return false;
      }
      if (type != null && v.type != type) return false;
      return true;
    }).toList();
  }

  @override
  Future<Venue?> getVenueById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final venues = await _loadAll();
    try {
      return venues.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Venue>> getCinemas({String? city}) async {
    return getVenues(city: city, type: VenueType.cinema);
  }

  @override
  Future<List<Venue>> getStadiums({String? city}) async {
    return getVenues(city: city, type: VenueType.stadium);
  }

  @override
  Future<List<ParkingLot>> getParkingLots(String venueId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final venue = await getVenueById(venueId);
    return venue?.parkingLots ?? [];
  }
}
