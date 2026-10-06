import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showscape/features/explore/domain/models/app_mood.dart';
import 'package:showscape/features/explore/domain/models/event.dart';
import 'package:showscape/features/explore/domain/repositories/event_repository.dart';

class MockEventRepository implements EventRepository {
  static List<Event>? _cachedEvents;

  static void clearCache() {
    _cachedEvents = null;
  }

  static void updateCachedMoods(String eventId, List<String> moods) {
    if (_cachedEvents != null) {
      final index = _cachedEvents!.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _cachedEvents![index] = _cachedEvents![index].copyWith(moodTags: moods);
      }
    }
  }

  Future<List<Event>> _loadAll() async {
    if (_cachedEvents != null) return _cachedEvents!;

    final moviesJsonStr =
        await rootBundle.loadString('assets/mock/movies.json');
    final eventsJsonStr =
        await rootBundle.loadString('assets/mock/events.json');

    final moviesRaw = jsonDecode(moviesJsonStr) as List<dynamic>;
    final eventsRaw = jsonDecode(eventsJsonStr) as List<dynamic>;

    final movies = moviesRaw
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
    final events = eventsRaw
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();

    final allRaw = [...movies, ...events];
    final enriched = <Event>[];

    for (final e in allRaw) {
      enriched.add(e.copyWith(moodTags: AppMood.deterministicMoodFallback(e)));
    }

    _cachedEvents = enriched;
    return _cachedEvents!;
  }

  @override
  Future<List<Event>> getAllEvents() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = await _loadAll();
    return List.unmodifiable(all);
  }

  @override
  Future<List<Event>> getMovies({String? language, String? genre}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = await _loadAll();
    return all.where((e) {
      if (e.type != EventType.movie) return false;
      if (language != null && !e.languages.contains(language)) return false;
      if (genre != null && !e.genres.contains(genre)) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<Event>> getEvents({EventType? type, String? search}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = await _loadAll();
    return all.where((e) {
      if (type != null) {
        if (e.type != type) return false;
      } else {
        if (e.type == EventType.movie) return false;
      }
      if (search != null && search.isNotEmpty) {
        final query = search.toLowerCase();
        final matchTitle = e.title.toLowerCase().contains(query);
        final matchCast =
            e.cast.any((c) => c.toLowerCase().contains(query));
        final matchGenre =
            e.genres.any((g) => g.toLowerCase().contains(query));
        if (!matchTitle && !matchCast && !matchGenre) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<Event?> getEventById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = await _loadAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Event>> getFeaturedEvents() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = await _loadAll();
    return all.where((e) => e.isFeatured).toList();
  }

  @override
  Future<List<Event>> getTrendingMovies() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final all = await _loadAll();
    return all
        .where((e) => e.type == EventType.movie && e.isTrending)
        .toList();
  }
}
