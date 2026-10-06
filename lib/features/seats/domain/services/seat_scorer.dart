import 'package:showscape/features/seats/domain/models/seat_layout.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';

/// Representation of a scored block of contiguous seats
class ScoredSeatBlock {
  final List<Seat> seats;
  final SeatRow row;
  final double score; // 0.0 to 1.0
  final double viewScore;
  final double centreScore;
  final double distanceScore;
  final double aislePrefScore;
  final double togetherBonus;

  const ScoredSeatBlock({
    required this.seats,
    required this.row,
    required this.score,
    required this.viewScore,
    required this.centreScore,
    required this.distanceScore,
    required this.aislePrefScore,
    required this.togetherBonus,
  });

  /// Formatted score label e.g. "View 9.2/10"
  String get scoreLabel => 'View ${(score * 10).toStringAsFixed(1)}/10';

  /// Unique identifier of this seat block
  String get id => seats.map((s) => s.id).join('_');

  /// Seat numbers summary e.g. "D4, D5"
  String get seatNumbers => seats.map((s) => s.seatNumber).join(', ');
}

/// Pure Dart SeatScorer implementing ShowScape's personalized seat recommendation engine:
/// score = 0.35·view + 0.25·centre + 0.20·distance + 0.10·aislePref + 0.10·togetherBonus
class SeatScorer {
  static const double weightView = 0.35;
  static const double weightCentre = 0.25;
  static const double weightDistance = 0.20;
  static const double weightAislePref = 0.10;
  static const double weightTogetherBonus = 0.10;

  /// Calculates view score preferring the middle-to-rear third of rows.
  /// Normalized in [0.0, 1.0].
  static double calculateViewScore({
    required int rowIndex,
    required int totalRows,
  }) {
    if (totalRows <= 1) return 1.0;
    // p = 0.0 for front row (closest to screen), 1.0 for rear row
    final p = rowIndex / (totalRows - 1.0);

    if (p < 1.0 / 3.0) {
      // Front third: viewing angle and neck strain penalty; scales from 0.2 to 0.6
      return 0.2 + (p / (1.0 / 3.0)) * 0.4;
    } else if (p <= 0.75) {
      // Middle-to-rear third sweet spot: scales from 0.6 up to 1.0
      return 0.6 + ((p - 1.0 / 3.0) / (0.75 - 1.0 / 3.0)) * 0.4;
    } else {
      // Rearmost row: slight drop from 1.0 to 0.9
      return 1.0 - ((p - 0.75) / 0.25) * 0.1;
    }
  }

  /// Calculates centre score: centre = 1 − |col − centreCol| ÷ halfWidth
  /// Normalized in [0.0, 1.0].
  static double calculateCentreScore({
    required double col,
    required double minCol,
    required double maxCol,
  }) {
    final centreCol = (minCol + maxCol) / 2.0;
    final halfWidth = (maxCol - minCol) / 2.0;
    if (halfWidth <= 0.0) return 1.0;
    final raw = 1.0 - ((col - centreCol).abs() / halfWidth);
    return raw.clamp(0.0, 1.0);
  }

  /// Calculates distance score: distance penalises the first 3 rows.
  /// Monotonically scales: row 0 (A) -> 0.2, row 1 (B) -> 0.5, row 2 (C) -> 0.75, row 3+ -> 1.0.
  static double calculateDistanceScore({
    required int rowIndex,
  }) {
    if (rowIndex == 0) return 0.2;
    if (rowIndex == 1) return 0.5;
    if (rowIndex == 2) return 0.75;
    return 1.0;
  }

  /// Learns user's aisle preference from their past bookings: share of aisle seats.
  /// If no history exists, returns a neutral 0.5.
  static double learnAislePreference(List<Booking> pastBookings) {
    int totalSeats = 0;
    int aisleSeats = 0;

    for (final booking in pastBookings) {
      for (final ticket in booking.tickets) {
        totalSeats++;
        // Identify aisle seat: column 1, outer columns (>= 12), or ending with 1
        if (ticket.col <= 1 || ticket.col >= 12 || ticket.seatNumber.endsWith('1')) {
          aisleSeats++;
        }
      }
    }

    if (totalSeats == 0) return 0.5;
    return (aisleSeats / totalSeats).clamp(0.0, 1.0);
  }

  /// Checks if a seat in a row is an aisle seat (outer edge or next to a walkway gap).
  static bool isAisleSeat(Seat seat, SeatRow row) {
    final seats = row.seats;
    if (seats.isEmpty) return false;
    final minCol = seats.map((s) => s.col).reduce((a, b) => a < b ? a : b);
    final maxCol = seats.map((s) => s.col).reduce((a, b) => a > b ? a : b);

    // Row boundaries are aisles
    if (seat.col == minCol || seat.col == maxCol) return true;

    // Check for gangway/aisle gaps (column numbering skip > 1)
    final index = seats.indexWhere((s) => s.id == seat.id);
    if (index > 0 && (seat.col - seats[index - 1].col).abs() > 1) return true;
    if (index >= 0 && index < seats.length - 1 && (seats[index + 1].col - seat.col).abs() > 1) {
      return true;
    }

    return false;
  }

  /// Computes the aisle preference match score for a block of seats.
  static double calculateAisleScore({
    required List<Seat> seats,
    required SeatRow row,
    required double userAislePreference,
  }) {
    final hasAisle = seats.any((s) => isAisleSeat(s, row));
    if (hasAisle) {
      return userAislePreference;
    } else {
      return 1.0 - userAislePreference;
    }
  }

  /// Calculates togetherBonus: togetherBonus = 1 if the group fits contiguously, else 0.
  static double calculateTogetherBonus({
    required List<Seat> seats,
    required int requestedGroupSize,
  }) {
    if (seats.length != requestedGroupSize) return 0.0;
    if (seats.isEmpty) return 0.0;

    // All seats must be available
    if (!seats.every((s) => s.state == SeatState.available)) return 0.0;

    // Must be in the exact same row
    final rowLabel = seats.first.row;
    if (!seats.every((s) => s.row == rowLabel)) return 0.0;

    // Must be contiguous by column
    for (int i = 0; i < seats.length - 1; i++) {
      if (seats[i + 1].col != seats[i].col + 1) {
        return 0.0;
      }
    }

    return 1.0;
  }

  /// Computes the composite weighted score:
  /// score = 0.35·view + 0.25·centre + 0.20·distance + 0.10·aislePref + 0.10·togetherBonus
  static double calculateCompositeScore({
    required double view,
    required double centre,
    required double distance,
    required double aislePref,
    required double togetherBonus,
  }) {
    final composite = (weightView * view) +
        (weightCentre * centre) +
        (weightDistance * distance) +
        (weightAislePref * aislePref) +
        (weightTogetherBonus * togetherBonus);
    return composite.clamp(0.0, 1.0);
  }

  /// Scores a specific candidate block of seats.
  static ScoredSeatBlock scoreBlock({
    required List<Seat> seats,
    required SeatRow row,
    required int rowIndex,
    required int totalRows,
    required int requestedGroupSize,
    double userAislePreference = 0.5,
  }) {
    final minCol = row.seats.map((s) => s.col).reduce((a, b) => a < b ? a : b).toDouble();
    final maxCol = row.seats.map((s) => s.col).reduce((a, b) => a > b ? a : b).toDouble();

    final blockAvgCol = seats.fold<double>(0.0, (acc, s) => acc + s.col) / seats.length;

    final viewScore = calculateViewScore(rowIndex: rowIndex, totalRows: totalRows);
    final centreScore = calculateCentreScore(col: blockAvgCol, minCol: minCol, maxCol: maxCol);
    final distanceScore = calculateDistanceScore(rowIndex: rowIndex);
    final aislePrefScore = calculateAisleScore(
      seats: seats,
      row: row,
      userAislePreference: userAislePreference,
    );
    final togetherBonus = calculateTogetherBonus(
      seats: seats,
      requestedGroupSize: requestedGroupSize,
    );

    final composite = calculateCompositeScore(
      view: viewScore,
      centre: centreScore,
      distance: distanceScore,
      aislePref: aislePrefScore,
      togetherBonus: togetherBonus,
    );

    return ScoredSeatBlock(
      seats: seats,
      row: row,
      score: composite,
      viewScore: viewScore,
      centreScore: centreScore,
      distanceScore: distanceScore,
      aislePrefScore: aislePrefScore,
      togetherBonus: togetherBonus,
    );
  }

  /// Finds and returns the top 3 best non-overlapping blocks of seats of size [groupSize].
  static List<ScoredSeatBlock> findTopBlocks({
    required SeatLayout layout,
    required int groupSize,
    double userAislePreference = 0.5,
    int limit = 3,
  }) {
    if (groupSize <= 0 || layout.rows.isEmpty) return [];

    final candidateBlocks = <ScoredSeatBlock>[];
    final totalRows = layout.rows.length;

    for (int rIdx = 0; rIdx < totalRows; rIdx++) {
      final row = layout.rows[rIdx];
      final availableSeats = row.seats.where((s) => s.state == SeatState.available).toList();
      if (availableSeats.length < groupSize) continue;

      // Find all contiguous windows of size `groupSize`
      for (int i = 0; i <= availableSeats.length - groupSize; i++) {
        final window = availableSeats.sublist(i, i + groupSize);

        // Check contiguous by column
        bool isContiguous = true;
        for (int j = 0; j < groupSize - 1; j++) {
          if (window[j + 1].col != window[j].col + 1) {
            isContiguous = false;
            break;
          }
        }

        if (isContiguous) {
          final scored = scoreBlock(
            seats: window,
            row: row,
            rowIndex: rIdx,
            totalRows: totalRows,
            requestedGroupSize: groupSize,
            userAislePreference: userAislePreference,
          );
          candidateBlocks.add(scored);
        }
      }
    }

    // Sort descending by composite score
    candidateBlocks.sort((a, b) => b.score.compareTo(a.score));

    // Filter to top non-overlapping blocks
    final topBlocks = <ScoredSeatBlock>[];
    final usedSeatIds = <String>{};

    for (final candidate in candidateBlocks) {
      final hasOverlap = candidate.seats.any((s) => usedSeatIds.contains(s.id));
      if (!hasOverlap) {
        topBlocks.add(candidate);
        usedSeatIds.addAll(candidate.seats.map((s) => s.id));
        if (topBlocks.length >= limit) break;
      }
    }

    return topBlocks;
  }
}
