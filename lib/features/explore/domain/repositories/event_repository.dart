import 'package:showscape/features/explore/domain/models/event.dart';

abstract class EventRepository {
  /// Fetch all events including movies, concerts, comedy, sports, etc.
  Future<List<Event>> getAllEvents();

  /// Fetch only movies with optional language or genre filter
  Future<List<Event>> getMovies({String? language, String? genre});

  /// Fetch non-movie events (concerts, sports, comedy, theatre)
  Future<List<Event>> getEvents({EventType? type, String? search});

  /// Fetch single event by id
  Future<Event?> getEventById(String id);

  /// Fetch featured spotlight events for banners/carousels
  Future<List<Event>> getFeaturedEvents();

  /// Fetch trending movies
  Future<List<Event>> getTrendingMovies();
}
