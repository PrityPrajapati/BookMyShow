import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/features/explore/data/sources/explore_local_storage.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';
import 'package:showscape/features/explore/domain/services/explore_filter_engine.dart';

/// Layout view mode for Explore screen results
enum ExploreViewMode { grid, list }

/// Provider for local storage service
final exploreLocalStorageProvider = Provider<ExploreLocalStorage>((ref) {
  return ExploreLocalStorage();
});

/// Provider for pure Dart filter engine
final exploreFilterEngineProvider = Provider<ExploreFilterEngine>((ref) {
  return const ExploreFilterEngine();
});

/// Provider for calendar format (collapsible between week and month)
final calendarFormatProvider = StateProvider<CalendarFormat>((ref) {
  return CalendarFormat.week;
});

/// Provider for view mode (Grid vs List toggle)
final exploreViewModeProvider = StateProvider<ExploreViewMode>((ref) {
  return ExploreViewMode.grid;
});

/// Provider for all shows loaded from repository
final allShowsListProvider = FutureProvider<List<Show>>((ref) async {
  final repo = ref.watch(showRepositoryProvider);
  return repo.getShows();
});

/// Provider for mapping venueId -> Venue for fast lookup and distance calculations
final venuesMapProvider = FutureProvider<Map<String, Venue>>((ref) async {
  final repo = ref.watch(venueRepositoryProvider);
  final venues = await repo.getVenues();
  return {for (final v in venues) v.id: v};
});

/// Provider mapping normalized date (year, month, day) to set of eventIds having shows that day
final calendarEventDatesProvider = FutureProvider<Map<DateTime, Set<String>>>((ref) async {
  final shows = await ref.watch(allShowsListProvider.future);
  final Map<DateTime, Set<String>> dateMap = {};

  for (final show in shows) {
    final day = DateTime(show.startTime.year, show.startTime.month, show.startTime.day);
    dateMap.putIfAbsent(day, () => <String>{}).add(show.eventId);
  }

  return dateMap;
});

/// Notifier for recent searches backed by Hive
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  final ExploreLocalStorage _storage;

  RecentSearchesNotifier(this._storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final list = await _storage.getRecentSearches();
    state = list;
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    await _storage.saveRecentSearch(query);
    state = await _storage.getRecentSearches();
  }

  Future<void> removeSearch(String query) async {
    await _storage.removeRecentSearch(query);
    state = await _storage.getRecentSearches();
  }

  Future<void> clearAll() async {
    await _storage.clearRecentSearches();
    state = [];
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  final storage = ref.watch(exploreLocalStorageProvider);
  return RecentSearchesNotifier(storage);
});

/// State notifier managing active filter criteria with automatic Hive persistence
class ExploreFilterNotifier extends StateNotifier<ExploreFilterCriteria> {
  final ExploreLocalStorage _storage;

  ExploreFilterNotifier(this._storage) : super(const ExploreFilterCriteria()) {
    _loadPersistedFilters();
  }

  Future<void> _loadPersistedFilters() async {
    final saved = await _storage.loadFilters();
    if (saved != null) {
      state = saved;
    }
  }

  void _persistState() {
    _storage.saveFilters(state);
  }

  void setCategory(ExploreCategory category) {
    state = state.copyWith(category: category);
    _persistState();
  }

  void setSelectedDate(DateTime? date) {
    if (date == null) {
      state = state.copyWith(clearSelectedDate: true);
    } else {
      // Toggle off if tapping already selected date
      if (state.selectedDate != null &&
          state.selectedDate!.year == date.year &&
          state.selectedDate!.month == date.month &&
          state.selectedDate!.day == date.day) {
        state = state.copyWith(clearSelectedDate: true);
      } else {
        state = state.copyWith(
          selectedDate: DateTime(date.year, date.month, date.day),
        );
      }
    }
    _persistState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _persistState();
  }

  void setSortBy(ExploreSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _persistState();
  }

  void setPriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
    _persistState();
  }

  void setMaxDistance(double? km) {
    if (km == null) {
      state = state.copyWith(clearMaxDistance: true);
    } else {
      state = state.copyWith(maxDistanceKm: km);
    }
    _persistState();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      state = state.copyWith(clearDateRange: true);
    } else {
      state = state.copyWith(startDate: start, endDate: end);
    }
    _persistState();
  }

  void toggleLanguage(String language) {
    final current = Set<String>.from(state.languages);
    if (current.contains(language)) {
      current.remove(language);
    } else {
      current.add(language);
    }
    state = state.copyWith(languages: current);
    _persistState();
  }

  void toggleGenre(String genre) {
    final current = Set<String>.from(state.genres);
    if (current.contains(genre)) {
      current.remove(genre);
    } else {
      current.add(genre);
    }
    state = state.copyWith(genres: current);
    _persistState();
  }

  void toggleMood(String mood) {
    final current = Set<String>.from(state.moods);
    if (current.contains(mood)) {
      current.remove(mood);
    } else {
      current.add(mood);
    }
    state = state.copyWith(moods: current);
    _persistState();
  }

  void toggleFormat(String format) {
    final current = Set<String>.from(state.formats);
    if (current.contains(format)) {
      current.remove(format);
    } else {
      current.add(format);
    }
    state = state.copyWith(formats: current);
    _persistState();
  }

  void toggleAgeRating(String rating) {
    final current = Set<String>.from(state.ageRatings);
    if (current.contains(rating)) {
      current.remove(rating);
    } else {
      current.add(rating);
    }
    state = state.copyWith(ageRatings: current);
    _persistState();
  }

  void applyCriteria(ExploreFilterCriteria newCriteria) {
    state = newCriteria;
    _persistState();
  }

  void removeFilter(String type, [String? value]) {
    switch (type) {
      case 'date':
        state = state.copyWith(clearSelectedDate: true);
        break;
      case 'dateRange':
        state = state.copyWith(clearDateRange: true);
        break;
      case 'language':
        if (value != null) {
          final updated = Set<String>.from(state.languages)..remove(value);
          state = state.copyWith(languages: updated);
        }
        break;
      case 'genre':
        if (value != null) {
          final updated = Set<String>.from(state.genres)..remove(value);
          state = state.copyWith(genres: updated);
        }
        break;
      case 'mood':
        if (value != null) {
          final updated = Set<String>.from(state.moods)..remove(value);
          state = state.copyWith(moods: updated);
        }
        break;
      case 'format':
        if (value != null) {
          final updated = Set<String>.from(state.formats)..remove(value);
          state = state.copyWith(formats: updated);
        }
        break;
      case 'ageRating':
        if (value != null) {
          final updated = Set<String>.from(state.ageRatings)..remove(value);
          state = state.copyWith(ageRatings: updated);
        }
        break;
      case 'price':
        state = state.copyWith(minPrice: 0.0, maxPrice: 10000.0);
        break;
      case 'distance':
        state = state.copyWith(clearMaxDistance: true);
        break;
      case 'sort':
        state = state.copyWith(sortBy: ExploreSortBy.relevance);
        break;
      case 'query':
        state = state.copyWith(searchQuery: '');
        break;
    }
    _persistState();
  }

  void clearAllFilters() {
    state = ExploreFilterCriteria(
      category: state.category, // Keep currently selected category tab
    );
    _storage.clearFilters();
  }
}

final exploreFilterNotifierProvider =
    StateNotifierProvider<ExploreFilterNotifier, ExploreFilterCriteria>((ref) {
  final storage = ref.watch(exploreLocalStorageProvider);
  return ExploreFilterNotifier(storage);
});

/// Filtered Events Provider
final filteredExploreEventsProvider = FutureProvider<List<Event>>((ref) async {
  final criteria = ref.watch(exploreFilterNotifierProvider);
  final engine = ref.watch(exploreFilterEngineProvider);
  final allEvents = await ref.watch(allEventsProvider.future);
  final allShows = await ref.watch(allShowsListProvider.future);
  final venueMap = await ref.watch(venuesMapProvider.future);

  // Default coordinate center (Mumbai / Bandra)
  const double userLat = 19.0760;
  const double userLng = 72.8777;

  return engine.filterAndSortEvents(
    allEvents,
    criteria,
    allShows: allShows,
    venueMap: venueMap,
    userLat: userLat,
    userLng: userLng,
  );
});

/// Filtered Restaurants Provider (for Dining and All categories)
final filteredExploreRestaurantsProvider =
    FutureProvider<List<Restaurant>>((ref) async {
  final criteria = ref.watch(exploreFilterNotifierProvider);
  final engine = ref.watch(exploreFilterEngineProvider);
  final allRestaurants = await ref.watch(restaurantsProvider.future);

  return engine.filterAndSortRestaurants(
    allRestaurants,
    criteria,
  );
});
