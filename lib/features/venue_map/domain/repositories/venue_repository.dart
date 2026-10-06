import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/features/venue_map/domain/models/venue.dart';

abstract class VenueRepository {
  /// Fetch all venues with optional city or type filter
  Future<List<Venue>> getVenues({String? city, VenueType? type});

  /// Fetch single venue by id
  Future<Venue?> getVenueById(String id);

  /// Fetch cinemas only
  Future<List<Venue>> getCinemas({String? city});

  /// Fetch stadiums only
  Future<List<Venue>> getStadiums({String? city});

  /// Fetch parking lots for a specific venue
  Future<List<ParkingLot>> getParkingLots(String venueId);
}
