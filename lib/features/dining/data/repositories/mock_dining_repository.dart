import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showscape/features/dining/domain/models/reservation.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/dining/domain/repositories/dining_repository.dart';

class MockDiningRepository implements DiningRepository {
  List<Restaurant>? _cachedRestaurants;
  final List<Reservation> _reservations = [];

  Future<List<Restaurant>> _loadAll() async {
    if (_cachedRestaurants != null) return _cachedRestaurants!;

    final jsonStr =
        await rootBundle.loadString('assets/mock/restaurants.json');
    final raw = jsonDecode(jsonStr) as List<dynamic>;

    _cachedRestaurants = raw
        .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cachedRestaurants!;
  }

  @override
  Future<List<Restaurant>> getRestaurants({
    String? city,
    String? cuisine,
    bool? pureVegOnly,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final restaurants = await _loadAll();

    return restaurants.where((r) {
      if (city != null && r.city.toLowerCase() != city.toLowerCase()) {
        return false;
      }
      if (cuisine != null &&
          !r.cuisine.any((c) => c.toLowerCase() == cuisine.toLowerCase())) {
        return false;
      }
      if (pureVegOnly == true && !r.isPureVeg) return false;
      return true;
    }).toList();
  }

  @override
  Future<Restaurant?> getRestaurantById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final restaurants = await _loadAll();
    try {
      return restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Reservation> createReservation(Reservation reservation) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _reservations.add(reservation);
    return reservation;
  }

  @override
  Future<List<Reservation>> getUserReservations(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _reservations.where((r) => r.userId == userId).toList();
  }

  @override
  Future<Reservation> cancelReservation(String reservationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _reservations.indexWhere((r) => r.id == reservationId);
    if (index != -1) {
      final updated = _reservations[index].copyWith(
        status: ReservationStatus.cancelled,
      );
      _reservations[index] = updated;
      return updated;
    }
    throw Exception('Reservation not found');
  }
}
