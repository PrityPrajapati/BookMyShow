import 'package:showscape/features/dining/domain/models/reservation.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';

abstract class DiningRepository {
  /// Fetch restaurants with optional city or cuisine filter
  Future<List<Restaurant>> getRestaurants({
    String? city,
    String? cuisine,
    bool? pureVegOnly,
  });

  /// Fetch single restaurant by id
  Future<Restaurant?> getRestaurantById(String id);

  /// Create table reservation
  Future<Reservation> createReservation(Reservation reservation);

  /// Fetch user reservations
  Future<List<Reservation>> getUserReservations(String userId);

  /// Cancel reservation
  Future<Reservation> cancelReservation(String reservationId);
}
