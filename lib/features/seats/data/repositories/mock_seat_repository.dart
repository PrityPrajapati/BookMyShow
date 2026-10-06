import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showscape/features/seats/domain/models/seat_layout.dart';
import 'package:showscape/features/seats/domain/repositories/seat_repository.dart';

class MockSeatRepository implements SeatRepository {
  static Map<String, SeatLayout>? _cachedLayouts;

  Future<Map<String, SeatLayout>> _loadAll() async {
    if (_cachedLayouts != null) return _cachedLayouts!;

    final jsonStr =
        await rootBundle.loadString('assets/mock/seat_layouts.json');
    final raw = jsonDecode(jsonStr) as List<dynamic>;

    final map = <String, SeatLayout>{};
    for (final item in raw) {
      final layout = SeatLayout.fromJson(item as Map<String, dynamic>);
      map[layout.id] = layout;
    }

    _cachedLayouts = map;
    return _cachedLayouts!;
  }

  @override
  Future<SeatLayout?> getSeatLayoutById(String layoutId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final layouts = await _loadAll();
    return layouts[layoutId];
  }

  @override
  Future<SeatLayout?> getSeatLayoutForShow(
      String showId, String seatLayoutId) async {
    return getSeatLayoutById(seatLayoutId);
  }

  @override
  Future<SeatLayout> updateSeatState(
    String layoutId,
    String seatId,
    SeatState newState,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final layouts = await _loadAll();
    final existing = layouts[layoutId];
    if (existing == null) throw Exception('Layout not found: $layoutId');

    final updatedRows = existing.rows.map((row) {
      final updatedSeats = row.seats.map((seat) {
        if (seat.id == seatId) {
          return seat.copyWith(state: newState);
        }
        return seat;
      }).toList();
      return row.copyWith(seats: updatedSeats);
    }).toList();

    final updatedLayout = existing.copyWith(rows: updatedRows);
    _cachedLayouts![layoutId] = updatedLayout;
    return updatedLayout;
  }
}
