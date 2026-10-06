import 'package:showscape/features/seats/domain/models/seat_layout.dart';

abstract class SeatRepository {
  /// Fetch seat layout by layout id
  Future<SeatLayout?> getSeatLayoutById(String layoutId);

  /// Fetch seat layout for a specific show
  Future<SeatLayout?> getSeatLayoutForShow(String showId, String seatLayoutId);

  /// Toggle or update a seat's selection state
  Future<SeatLayout> updateSeatState(
    String layoutId,
    String seatId,
    SeatState newState,
  );
}
