import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/features/showtimes/domain/repositories/show_repository.dart';

class MockShowRepository implements ShowRepository {
  static List<Show>? _cachedShows;

  Future<List<Show>> _loadAll() async {
    if (_cachedShows != null) return _cachedShows!;

    final jsonStr = await rootBundle.loadString('assets/mock/shows.json');
    final raw = jsonDecode(jsonStr) as List<dynamic>;
    final baseDate = DateTime(2026, 10, 1);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = today.difference(baseDate).inDays;

    _cachedShows = raw.map((e) {
      final s = Show.fromJson(e as Map<String, dynamic>);
      if (diffDays == 0) return s;
      return s.copyWith(
        startTime: s.startTime.add(Duration(days: diffDays)),
        endTime: s.endTime?.add(Duration(days: diffDays)),
      );
    }).toList();
    return _cachedShows!;
  }

  @override
  Future<List<Show>> getShows({
    String? eventId,
    String? venueId,
    DateTime? date,
    ShowFormat? format,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final shows = await _loadAll();

    return shows.where((s) {
      if (eventId != null && s.eventId != eventId) return false;
      if (venueId != null && s.venueId != venueId) return false;
      if (format != null && s.format != format) return false;
      if (date != null) {
        final matchesDate = s.startTime.year == date.year &&
            s.startTime.month == date.month &&
            s.startTime.day == date.day;
        if (!matchesDate) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<Show?> getShowById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final shows = await _loadAll();
    try {
      return shows.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DateTime>> getAvailableDatesForEvent(String eventId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final shows = await _loadAll();
    final eventShows = shows.where((s) => s.eventId == eventId);

    final Set<String> seen = {};
    final List<DateTime> dates = [];

    for (final s in eventShows) {
      final key = '${s.startTime.year}-${s.startTime.month}-${s.startTime.day}';
      if (!seen.contains(key)) {
        seen.add(key);
        dates.add(DateTime(s.startTime.year, s.startTime.month, s.startTime.day));
      }
    }

    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }
}
