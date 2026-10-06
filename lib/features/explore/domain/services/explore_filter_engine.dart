import 'dart:math' as math;
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/explore/domain/models/event.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/features/venue_map/domain/models/venue.dart';

/// Pure Dart filtering, sorting, and typo-tolerant search engine for Explore
class ExploreFilterEngine {
  const ExploreFilterEngine();

  // ---------------------------------------------------------------------------
  // Levenshtein Distance & Typo Tolerance
  // ---------------------------------------------------------------------------

  /// Calculates the Levenshtein edit distance between two strings.
  /// Space-optimized O(min(|s|, |t|)) dynamic programming implementation.
  int levenshteinDistance(String s, String t) {
    final sLower = s.trim().toLowerCase();
    final tLower = t.trim().toLowerCase();

    if (sLower == tLower) return 0;
    if (sLower.isEmpty) return tLower.length;
    if (tLower.isEmpty) return sLower.length;

    // Use shorter string for inner loop to save memory
    final String str1 = sLower.length < tLower.length ? sLower : tLower;
    final String str2 = sLower.length < tLower.length ? tLower : sLower;

    List<int> previousRow = List<int>.generate(str1.length + 1, (i) => i);
    List<int> currentRow = List<int>.filled(str1.length + 1, 0);

    for (int i = 0; i < str2.length; i++) {
      currentRow[0] = i + 1;
      final char2 = str2.codeUnitAt(i);

      for (int j = 0; j < str1.length; j++) {
        final char1 = str1.codeUnitAt(j);
        final cost = (char1 == char2) ? 0 : 1;

        currentRow[j + 1] = [
          currentRow[j] + 1, // Insertion
          previousRow[j + 1] + 1, // Deletion
          previousRow[j] + cost, // Substitution
        ].reduce(math.min);
      }

      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[str1.length];
  }

  /// Checks if [query] matches [target] either by substring or by Levenshtein distance <= [maxDistance].
  bool typoMatch(String query, String target, {int maxDistance = 2}) {
    final q = query.trim().toLowerCase();
    final t = target.trim().toLowerCase();

    if (q.isEmpty) return true;
    if (t.isEmpty) return false;

    // Direct containment is an instant match
    if (t.contains(q)) return true;

    // If query itself has distance <= maxDistance to target
    if (levenshteinDistance(q, t) <= maxDistance) return true;

    // Tokenize target into words
    final targetWords = t
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    // Check individual query against target words
    final queryWords = q
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (queryWords.isEmpty) return false;

    // Single-word query: check against any target word
    if (queryWords.length == 1) {
      final singleQ = queryWords.first;
      for (final word in targetWords) {
        if (word.contains(singleQ) || singleQ.contains(word)) return true;
        // Don't apply edit distance on words shorter than 3 unless length is very close
        if (singleQ.length >= 3 && (singleQ.length - word.length).abs() <= 2) {
          if (levenshteinDistance(singleQ, word) <= maxDistance) return true;
        }
      }
      return false;
    }

    // Multi-word query: check that every query word matches some target word
    for (final qWord in queryWords) {
      bool matched = false;
      for (final tWord in targetWords) {
        if (tWord.contains(qWord) || qWord.contains(tWord)) {
          matched = true;
          break;
        }
        if (qWord.length >= 3 && (qWord.length - tWord.length).abs() <= 2) {
          if (levenshteinDistance(qWord, tWord) <= maxDistance) {
            matched = true;
            break;
          }
        }
      }
      if (!matched) return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Distance Calculation (Haversine Formula)
  // ---------------------------------------------------------------------------

  /// Returns Haversine distance in kilometers between two geo coordinates
  double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) *
            math.cos(lat2 * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  // ---------------------------------------------------------------------------
  // Event Filtering Logic
  // ---------------------------------------------------------------------------

  /// Checks if [event] satisfies the given [criteria]
  bool matchesEvent(
    Event event,
    ExploreFilterCriteria criteria, {
    List<Show>? eventShows,
    Map<String, Venue>? venueMap,
    double? userLat,
    double? userLng,
  }) {
    // 1. Category check
    switch (criteria.category) {
      case ExploreCategory.all:
        break; // matches any event
      case ExploreCategory.movies:
        if (event.type != EventType.movie) return false;
        break;
      case ExploreCategory.events:
        if (event.type != EventType.concert && event.type != EventType.theatre) {
          return false;
        }
        break;
      case ExploreCategory.sports:
        if (event.type != EventType.sports) return false;
        break;
      case ExploreCategory.comedy:
        if (event.type != EventType.comedy) return false;
        break;
      case ExploreCategory.dining:
        // Handled in restaurant filter, events do not match dining category
        return false;
    }

    // 2. Search Query with Typo-tolerance
    if (criteria.searchQuery.trim().isNotEmpty) {
      final q = criteria.searchQuery.trim();
      final titleMatch = typoMatch(q, event.title);
      final genreMatch = event.genres.any((g) => typoMatch(q, g));
      final castMatch = event.cast.any((c) => typoMatch(q, c));
      final summaryMatch = typoMatch(q, event.aiSummary);
      final langMatch = event.languages.any((l) => typoMatch(q, l));

      if (!titleMatch &&
          !genreMatch &&
          !castMatch &&
          !summaryMatch &&
          !langMatch) {
        return false;
      }
    }

    // 3. Languages
    if (criteria.languages.isNotEmpty) {
      final hasMatchingLang = event.languages.any(
        (l) => criteria.languages.any(
          (filterL) => filterL.toLowerCase() == l.toLowerCase(),
        ),
      );
      if (!hasMatchingLang) return false;
    }

    // 4. Genres
    if (criteria.genres.isNotEmpty) {
      final hasMatchingGenre = event.genres.any(
        (g) => criteria.genres.any(
          (filterG) => filterG.toLowerCase() == g.toLowerCase(),
        ),
      );
      if (!hasMatchingGenre) return false;
    }

    // 4b. Mood Tags
    if (criteria.moods.isNotEmpty) {
      final hasMatchingMood = event.moodTags.any((t) {
        final normTag = t.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
        return criteria.moods.any((m) {
          final normCriteria = m.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
          return normTag == normCriteria ||
              normTag.contains(normCriteria) ||
              normCriteria.contains(normTag);
        });
      });
      if (!hasMatchingMood) return false;
    }

    // 5. Age Ratings (Certificate)
    if (criteria.ageRatings.isNotEmpty) {
      final cert = event.certificate ?? 'UA';
      final hasRating = criteria.ageRatings.any(
        (r) => r.trim().toLowerCase() == cert.trim().toLowerCase(),
      );
      if (!hasRating) return false;
    }

    // 6. Selected Calendar Day
    if (criteria.selectedDate != null) {
      final targetDate = criteria.selectedDate!;
      if (eventShows != null && eventShows.isNotEmpty) {
        final hasShowOnDay = eventShows.any((s) =>
            s.startTime.year == targetDate.year &&
            s.startTime.month == targetDate.month &&
            s.startTime.day == targetDate.day);
        if (!hasShowOnDay) return false;
      }
    }

    // 7. Date Range
    if (criteria.startDate != null || criteria.endDate != null) {
      final start = criteria.startDate ?? DateTime(2000);
      final end = criteria.endDate != null
          ? DateTime(
              criteria.endDate!.year,
              criteria.endDate!.month,
              criteria.endDate!.day,
              23,
              59,
              59,
            )
          : DateTime(2099);

      if (eventShows != null && eventShows.isNotEmpty) {
        final hasShowInRange = eventShows.any(
          (s) =>
              s.startTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
              s.startTime.isBefore(end.add(const Duration(seconds: 1))),
        );
        if (!hasShowInRange) return false;
      } else if (event.releaseDate != null) {
        final rel = event.releaseDate!;
        if (rel.isBefore(start) || rel.isAfter(end)) return false;
      }
    }

    // 8. Formats
    if (criteria.formats.isNotEmpty && eventShows != null && eventShows.isNotEmpty) {
      final normalizedCriteriaFormats = criteria.formats
          .map((f) => f.replaceAll(' ', '').toUpperCase())
          .toSet();

      final hasMatchingFormat = eventShows.any((s) {
        final showFmt = s.format.name.replaceAll(' ', '').toUpperCase();
        final showLabel = s.format.label.replaceAll(' ', '').toUpperCase();
        return normalizedCriteriaFormats.contains(showFmt) ||
            normalizedCriteriaFormats.contains(showLabel);
      });
      if (!hasMatchingFormat) return false;
    }

    // 9. Price Range (₹0 - ₹10,000)
    final minRequested = criteria.minPrice;
    final maxRequested = criteria.maxPrice;

    if (minRequested > 0 || maxRequested < 10000) {
      if (eventShows != null && eventShows.isNotEmpty) {
        // Collect all prices across available shows
        final prices = <double>[];
        for (final s in eventShows) {
          prices.addAll(s.categoryPrices.values);
        }
        if (prices.isNotEmpty) {
          final minShowPrice = prices.reduce(math.min);
          final maxShowPrice = prices.reduce(math.max);
          // If the event's cheapest ticket is more expensive than maxRequested,
          // or its most expensive ticket is cheaper than minRequested
          if (minShowPrice > maxRequested || maxShowPrice < minRequested) {
            return false;
          }
        }
      }
    }

    // 10. Distance Filter
    if (criteria.maxDistanceKm != null &&
        userLat != null &&
        userLng != null &&
        venueMap != null &&
        eventShows != null &&
        eventShows.isNotEmpty) {
      bool withinDistance = false;
      for (final s in eventShows) {
        final venue = venueMap[s.venueId];
        if (venue != null) {
          final dist = calculateDistanceKm(
            userLat,
            userLng,
            venue.geo.latitude,
            venue.geo.longitude,
          );
          if (dist <= criteria.maxDistanceKm!) {
            withinDistance = true;
            break;
          }
        }
      }
      if (!withinDistance) return false;
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Restaurant Filtering Logic
  // ---------------------------------------------------------------------------

  /// Checks if [restaurant] satisfies the given [criteria]
  bool matchesRestaurant(
    Restaurant restaurant,
    ExploreFilterCriteria criteria, {
    double? userLat,
    double? userLng,
  }) {
    // Only match when category is 'all' or 'dining'
    if (criteria.category != ExploreCategory.all &&
        criteria.category != ExploreCategory.dining) {
      return false;
    }

    // 1. Search Query
    if (criteria.searchQuery.trim().isNotEmpty) {
      final q = criteria.searchQuery.trim();
      final nameMatch = typoMatch(q, restaurant.name);
      final cuisineMatch = restaurant.cuisine.any((c) => typoMatch(q, c));
      final dishMatch = restaurant.featuredDishes.any((d) => typoMatch(q, d));
      final cityMatch = typoMatch(q, restaurant.city);

      if (!nameMatch && !cuisineMatch && !dishMatch && !cityMatch) {
        return false;
      }
    }

    // 2. Price Range (using costForTwo or costForOne)
    final approxCost = restaurant.costForTwo / 2;
    if (approxCost < criteria.minPrice || approxCost > criteria.maxPrice) {
      return false;
    }

    // 3. Distance
    if (criteria.maxDistanceKm != null) {
      if (restaurant.distanceKm > criteria.maxDistanceKm!) {
        return false;
      }
    }

    return true;
  }

  // ---------------------------------------------------------------------------
  // Filtering & Sorting Orchestration
  // ---------------------------------------------------------------------------

  /// Filters and sorts a list of events according to [criteria]
  List<Event> filterAndSortEvents(
    List<Event> events,
    ExploreFilterCriteria criteria, {
    List<Show>? allShows,
    Map<String, Venue>? venueMap,
    double? userLat,
    double? userLng,
  }) {
    // Pre-group shows by eventId for fast lookup
    final Map<String, List<Show>> showsByEvent = {};
    if (allShows != null) {
      for (final s in allShows) {
        showsByEvent.putIfAbsent(s.eventId, () => []).add(s);
      }
    }

    // Filter
    final filtered = events.where((e) {
      final eventShows = showsByEvent[e.id];
      return matchesEvent(
        e,
        criteria,
        eventShows: eventShows,
        venueMap: venueMap,
        userLat: userLat,
        userLng: userLng,
      );
    }).toList();

    // Sort
    return sortEvents(
      filtered,
      criteria.sortBy,
      showsByEvent: showsByEvent,
      venueMap: venueMap,
      userLat: userLat,
      userLng: userLng,
      searchQuery: criteria.searchQuery,
    );
  }

  /// Sorts events according to [sortBy]
  List<Event> sortEvents(
    List<Event> list,
    ExploreSortBy sortBy, {
    Map<String, List<Show>>? showsByEvent,
    Map<String, Venue>? venueMap,
    double? userLat,
    double? userLng,
    String? searchQuery,
  }) {
    final sorted = List<Event>.from(list);

    switch (sortBy) {
      case ExploreSortBy.relevance:
        sorted.sort((a, b) {
          // If search query is present, rank exact/closer matches higher
          if (searchQuery != null && searchQuery.trim().isNotEmpty) {
            final aDist = levenshteinDistance(searchQuery, a.title);
            final bDist = levenshteinDistance(searchQuery, b.title);
            if (aDist != bDist) return aDist.compareTo(bDist);
          }
          // Featured events first
          if (a.isFeatured != b.isFeatured) {
            return a.isFeatured ? -1 : 1;
          }
          // Trending events next
          if (a.isTrending != b.isTrending) {
            return a.isTrending ? -1 : 1;
          }
          // Highest rating
          return b.rating.compareTo(a.rating);
        });
        break;

      case ExploreSortBy.popularity:
        sorted.sort((a, b) {
          final scoreA = a.rating * a.votesCount;
          final scoreB = b.rating * b.votesCount;
          return scoreB.compareTo(scoreA);
        });
        break;

      case ExploreSortBy.priceAsc:
        sorted.sort((a, b) {
          final priceA = _getMinPriceForEvent(a.id, showsByEvent);
          final priceB = _getMinPriceForEvent(b.id, showsByEvent);
          return priceA.compareTo(priceB);
        });
        break;

      case ExploreSortBy.date:
        sorted.sort((a, b) {
          final dateA = _getEarliestDateForEvent(a, showsByEvent);
          final dateB = _getEarliestDateForEvent(b, showsByEvent);
          return dateA.compareTo(dateB);
        });
        break;

      case ExploreSortBy.distance:
        sorted.sort((a, b) {
          final distA = _getMinDistanceForEvent(
            a.id,
            showsByEvent,
            venueMap,
            userLat,
            userLng,
          );
          final distB = _getMinDistanceForEvent(
            b.id,
            showsByEvent,
            venueMap,
            userLat,
            userLng,
          );
          return distA.compareTo(distB);
        });
        break;
    }

    return sorted;
  }

  /// Filters and sorts a list of restaurants
  List<Restaurant> filterAndSortRestaurants(
    List<Restaurant> restaurants,
    ExploreFilterCriteria criteria, {
    double? userLat,
    double? userLng,
  }) {
    final filtered = restaurants
        .where((r) => matchesRestaurant(
              r,
              criteria,
              userLat: userLat,
              userLng: userLng,
            ))
        .toList();

    switch (criteria.sortBy) {
      case ExploreSortBy.relevance:
      case ExploreSortBy.popularity:
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ExploreSortBy.priceAsc:
        filtered.sort((a, b) => a.costForTwo.compareTo(b.costForTwo));
        break;
      case ExploreSortBy.distance:
        filtered.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case ExploreSortBy.date:
        // No show dates for restaurants, fallback to rating
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return filtered;
  }

  // ---------------------------------------------------------------------------
  // Helper Extractor Functions
  // ---------------------------------------------------------------------------

  double _getMinPriceForEvent(
    String eventId,
    Map<String, List<Show>>? showsByEvent,
  ) {
    final shows = showsByEvent?[eventId];
    if (shows == null || shows.isEmpty) return 250.0;
    final prices = <double>[];
    for (final s in shows) {
      prices.addAll(s.categoryPrices.values);
    }
    if (prices.isEmpty) return 250.0;
    return prices.reduce(math.min);
  }

  DateTime _getEarliestDateForEvent(
    Event event,
    Map<String, List<Show>>? showsByEvent,
  ) {
    final shows = showsByEvent?[event.id];
    if (shows != null && shows.isNotEmpty) {
      return shows.map((s) => s.startTime).reduce(
            (a, b) => a.isBefore(b) ? a : b,
          );
    }
    return event.releaseDate ?? DateTime(2026, 10, 1);
  }

  double _getMinDistanceForEvent(
    String eventId,
    Map<String, List<Show>>? showsByEvent,
    Map<String, Venue>? venueMap,
    double? userLat,
    double? userLng,
  ) {
    if (userLat == null || userLng == null || venueMap == null) return 999.0;
    final shows = showsByEvent?[eventId];
    if (shows == null || shows.isEmpty) return 999.0;

    double minD = 999.0;
    for (final s in shows) {
      final venue = venueMap[s.venueId];
      if (venue != null) {
        final d = calculateDistanceKm(
          userLat,
          userLng,
          venue.geo.latitude,
          venue.geo.longitude,
        );
        if (d < minD) minD = d;
      }
    }
    return minD;
  }
}
