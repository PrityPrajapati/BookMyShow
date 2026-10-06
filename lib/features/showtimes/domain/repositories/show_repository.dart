import 'package:showscape/features/showtimes/domain/models/show.dart';

abstract class ShowRepository {
  /// Fetch shows matching filters (eventId, venueId, date)
  Future<List<Show>> getShows({
    String? eventId,
    String? venueId,
    DateTime? date,
    ShowFormat? format,
  });

  /// Fetch single show by id
  Future<Show?> getShowById(String id);

  /// Fetch available distinct dates for an event
  Future<List<DateTime>> getAvailableDatesForEvent(String eventId);
}
