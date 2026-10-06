import 'package:showscape/features/seats/domain/models/seat_layout.dart';

/// Helper model for seat selection business logic: contiguous auto-selection & orphan seat prevention
class SeatSelectionState {
  final Map<String, Seat> selectedSeats; // seatId -> Seat
  final Map<String, double> seatPrices; // seatId -> price
  final int maxSeats;

  const SeatSelectionState({
    this.selectedSeats = const {},
    this.seatPrices = const {},
    this.maxSeats = 10,
  });

  int get count => selectedSeats.length;

  double get totalPrice {
    double total = 0.0;
    for (final seat in selectedSeats.values) {
      total += seatPrices[seat.id] ?? 250.0;
    }
    return total;
  }

  List<String> get selectedSeatCodes {
    final list = selectedSeats.values.map((s) => s.seatNumber).toList();
    list.sort();
    return list;
  }

  SeatSelectionState copyWith({
    Map<String, Seat>? selectedSeats,
    Map<String, double>? seatPrices,
  }) {
    return SeatSelectionState(
      selectedSeats: selectedSeats ?? this.selectedSeats,
      seatPrices: seatPrices ?? this.seatPrices,
      maxSeats: maxSeats,
    );
  }

  /// Automatically picks a contiguous best block of available seats closest to the center
  static Map<String, Seat> findBestContiguousBlock(SeatLayout layout, int count) {
    if (count <= 0) return {};

    // Sort rows from back to front (audiophile sweet spot is 60-80% back)
    final rows = List<SeatRow>.from(layout.rows);

    List<Seat>? bestBlock;
    double bestDistanceScore = double.infinity;

    for (final row in rows) {
      final availableSeats = row.seats.where((s) => s.state == SeatState.available).toList();
      if (availableSeats.length < count) continue;

      // Find all contiguous windows of length `count`
      for (int i = 0; i <= availableSeats.length - count; i++) {
        final candidate = availableSeats.sublist(i, i + count);

        // Check if contiguous by column index
        bool isContiguous = true;
        for (int j = 0; j < count - 1; j++) {
          if (candidate[j + 1].col != candidate[j].col + 1) {
            isContiguous = false;
            break;
          }
        }

        if (isContiguous) {
          // Calculate center offset score
          final rowMidCol = row.seats.length / 2.0;
          final candidateMidCol = (candidate.first.col + candidate.last.col) / 2.0;
          final distFromCenter = (candidateMidCol - rowMidCol).abs();

          // Prefer premium categories and central alignment
          final categoryBonus = row.category.toLowerCase().contains('recliner')
              ? -50
              : (row.category.toLowerCase().contains('prime') ? -25 : 0);

          final score = distFromCenter + categoryBonus;
          if (score < bestDistanceScore) {
            bestDistanceScore = score;
            bestBlock = candidate;
          }
        }
      }
    }

    if (bestBlock != null) {
      final map = <String, Seat>{};
      for (final s in bestBlock) {
        map[s.id] = s;
      }
      return map;
    }

    // Fallback: If no single row has a strictly contiguous block of `count`,
    // pick the closest available seats in the best row so the user always receives a selection
    for (final row in rows) {
      final availableSeats = row.seats.where((s) => s.state == SeatState.available).toList();
      if (availableSeats.length >= count) {
        final map = <String, Seat>{};
        for (final s in availableSeats.take(count)) {
          map[s.id] = s;
        }
        return map;
      }
    }

    return {};
  }

  /// Orphan seat rule: Checks if selecting/unselecting leaves a single isolated available seat
  static String? checkOrphanSeatRule({
    required SeatLayout layout,
    required Seat targetSeat,
    required bool willSelect,
    required Map<String, Seat> currentSelection,
  }) {
    // Find the row of the seat
    SeatRow? targetRow;
    for (final r in layout.rows) {
      if (r.rowLabel == targetSeat.row) {
        targetRow = r;
        break;
      }
    }
    if (targetRow == null) return null;

    final updatedSelection = Map<String, Seat>.from(currentSelection);
    if (willSelect) {
      updatedSelection[targetSeat.id] = targetSeat;
    } else {
      updatedSelection.remove(targetSeat.id);
    }

    final seats = targetRow.seats;
    final n = seats.length;

    // Check every seat in the row
    for (int i = 0; i < n; i++) {
      final s = seats[i];

      // A seat is 'free' if it is available and not in our selection
      final isSeatFree = s.state == SeatState.available && !updatedSelection.containsKey(s.id);
      if (!isSeatFree) continue;

      // Check left neighbor
      final isLeftOccupied = (i == 0) ||
          seats[i - 1].state != SeatState.available ||
          updatedSelection.containsKey(seats[i - 1].id);

      // Check right neighbor
      final isRightOccupied = (i == n - 1) ||
          seats[i + 1].state != SeatState.available ||
          updatedSelection.containsKey(seats[i + 1].id);

      // If both left and right neighbors are occupied/blocked/wall, this is a single orphan seat!
      if (isLeftOccupied && isRightOccupied) {
        return 'Please avoid leaving a single empty seat (${s.seatNumber}) alone.';
      }
    }

    return null;
  }
}
