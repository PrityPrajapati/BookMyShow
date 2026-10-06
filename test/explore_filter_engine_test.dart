import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';
import 'package:showscape/features/explore/domain/services/explore_filter_engine.dart';

void main() {
  const engine = ExploreFilterEngine();

  group('ExploreFilterEngine - Levenshtein Distance & Typo Tolerance', () {
    test('levenshteinDistance computes accurate edit distance', () {
      expect(engine.levenshteinDistance('', ''), equals(0));
      expect(engine.levenshteinDistance('pushpa', 'pushpa'), equals(0));
      expect(engine.levenshteinDistance('Pushpa', 'pushpa'), equals(0)); // case-insensitive

      // 1 edit
      expect(engine.levenshteinDistance('pushpa', 'puspa'), equals(1)); // deletion
      expect(engine.levenshteinDistance('pushpa', 'pushpaa'), equals(1)); // insertion
      expect(engine.levenshteinDistance('pushpa', 'pashpa'), equals(1)); // substitution

      // 2 edits
      expect(engine.levenshteinDistance('pushpa', 'puzpa'), equals(2)); // 'sh' -> 'z'
      expect(engine.levenshteinDistance('arijit', 'arjit'), equals(1));
      expect(engine.levenshteinDistance('coldplay', 'coldplay'), equals(0));
      expect(engine.levenshteinDistance('interstellar', 'interstelar'), equals(1));

      // > 2 edits
      expect(engine.levenshteinDistance('pushpa', 'pzzzz'), greaterThan(2));
    });

    test('typoMatch returns true for exact, substring, and <= 2 edit distances', () {
      expect(engine.typoMatch('push', 'Pushpa 2: The Rule'), isTrue);
      expect(engine.typoMatch('puzpa', 'Pushpa 2: The Rule'), isTrue); // distance 2
      expect(engine.typoMatch('arjit', 'Arijit Singh Live'), isTrue); // distance 1
      expect(engine.typoMatch('criket', 'IPL Cricket: MI vs CSK'), isTrue); // 'criket' vs 'Cricket' distance 1
      expect(engine.typoMatch('coldplay', 'Coldplay: Music of the Spheres'), isTrue);

      // Distant query should not match
      expect(engine.typoMatch('batman', 'Pushpa 2: The Rule'), isFalse);
      expect(engine.typoMatch('xyz123', 'Arijit Singh'), isFalse);
    });

    test('typoMatch handles multi-word queries with typos', () {
      expect(engine.typoMatch('puzpa rule', 'Pushpa 2: The Rule'), isTrue);
      expect(engine.typoMatch('arjit live', 'Arijit Singh Live'), isTrue);
      expect(engine.typoMatch('coldplay sphere', 'Coldplay: Music of the Spheres'), isTrue);
      expect(engine.typoMatch('superman avengers', 'Pushpa 2: The Rule'), isFalse);
    });
  });

  group('ExploreFilterEngine - Event Filtering', () {
    final sampleMovie = Event(
      id: 'mov_001',
      title: 'Pushpa 2: The Rule',
      description: 'Action thriller',
      type: EventType.movie,
      genres: ['Action', 'Thriller'],
      languages: ['Telugu', 'Hindi'],
      rating: 4.8,
      votesCount: 42000,
      durationMins: 195,
      posterUrl: 'https://images.unsplash.com/photo-pushpa',
      bannerUrl: 'https://images.unsplash.com/photo-pushpa-b',
      trailerUrl: 'https://youtube.com',
      aiSummary: 'Iconic mass action drama',
      certificate: 'UA 16+',
      releaseDate: DateTime(2026, 10, 1),
    );

    final sampleConcert = Event(
      id: 'evt_001',
      title: 'Arijit Singh Live in Concert',
      description: 'Soulful musical evening',
      type: EventType.concert,
      genres: ['Music', 'Bollywood'],
      languages: ['Hindi'],
      rating: 4.9,
      votesCount: 88000,
      durationMins: 180,
      posterUrl: 'https://images.unsplash.com/photo-arijit',
      bannerUrl: 'https://images.unsplash.com/photo-arijit-b',
      trailerUrl: 'https://youtube.com',
      aiSummary: 'Arijit live performing romantic melodies',
      certificate: 'U',
      releaseDate: DateTime(2026, 10, 3),
    );

    final sampleShows = [
      Show(
        id: 'sh_01',
        eventId: 'mov_001',
        venueId: 'ven_01',
        screenId: 'scr_01',
        screenName: 'Screen 1',
        startTime: DateTime(2026, 10, 1, 14, 0),
        format: ShowFormat.imax2D,
        categoryPrices: {'Standard': 300.0, 'Prime': 600.0},
        seatLayoutId: 'l1',
      ),
      Show(
        id: 'sh_02',
        eventId: 'evt_001',
        venueId: 'ven_02',
        screenId: 'scr_02',
        screenName: 'Arena A',
        startTime: DateTime(2026, 10, 3, 19, 0),
        format: ShowFormat.twoD,
        categoryPrices: {'Silver': 1500.0, 'VIP': 5000.0},
        seatLayoutId: 'l2',
      ),
    ];

    test('filters by category', () {
      const criteriaMovies = ExploreFilterCriteria(category: ExploreCategory.movies);
      final filteredMovies = engine.filterAndSortEvents([sampleMovie, sampleConcert], criteriaMovies);
      expect(filteredMovies.length, equals(1));
      expect(filteredMovies.first.id, equals('mov_001'));

      const criteriaEvents = ExploreFilterCriteria(category: ExploreCategory.events);
      final filteredEvents = engine.filterAndSortEvents([sampleMovie, sampleConcert], criteriaEvents);
      expect(filteredEvents.length, equals(1));
      expect(filteredEvents.first.id, equals('evt_001'));
    });

    test('filters by language and genre', () {
      const criteriaTelugu = ExploreFilterCriteria(languages: {'Telugu'});
      expect(engine.matchesEvent(sampleMovie, criteriaTelugu), isTrue);
      expect(engine.matchesEvent(sampleConcert, criteriaTelugu), isFalse);

      const criteriaMusic = ExploreFilterCriteria(genres: {'Music'});
      expect(engine.matchesEvent(sampleMovie, criteriaMusic), isFalse);
      expect(engine.matchesEvent(sampleConcert, criteriaMusic), isTrue);
    });

    test('filters by price range (₹0–₹10,000)', () {
      // sampleMovie has prices 300 and 600
      const criteriaAffordable = ExploreFilterCriteria(minPrice: 100, maxPrice: 400);
      expect(
        engine.matchesEvent(sampleMovie, criteriaAffordable, eventShows: [sampleShows[0]]),
        isTrue,
      );

      const criteriaExpensiveOnly = ExploreFilterCriteria(minPrice: 1000, maxPrice: 8000);
      expect(
        engine.matchesEvent(sampleMovie, criteriaExpensiveOnly, eventShows: [sampleShows[0]]),
        isFalse,
      );
      expect(
        engine.matchesEvent(sampleConcert, criteriaExpensiveOnly, eventShows: [sampleShows[1]]),
        isTrue,
      );
    });

    test('filters by selected calendar day', () {
      final oct1 = DateTime(2026, 10, 1);
      final oct3 = DateTime(2026, 10, 3);
      final oct5 = DateTime(2026, 10, 5);

      final criteriaOct1 = ExploreFilterCriteria(selectedDate: oct1);
      expect(
        engine.matchesEvent(sampleMovie, criteriaOct1, eventShows: [sampleShows[0]]),
        isTrue,
      );
      expect(
        engine.matchesEvent(sampleConcert, criteriaOct1, eventShows: [sampleShows[1]]),
        isFalse,
      );

      final criteriaOct3 = ExploreFilterCriteria(selectedDate: oct3);
      expect(
        engine.matchesEvent(sampleConcert, criteriaOct3, eventShows: [sampleShows[1]]),
        isTrue,
      );

      final criteriaOct5 = ExploreFilterCriteria(selectedDate: oct5);
      expect(
        engine.matchesEvent(sampleMovie, criteriaOct5, eventShows: [sampleShows[0]]),
        isFalse,
      );
    });

    test('filters by format and age rating', () {
      const criteriaImax = ExploreFilterCriteria(formats: {'IMAX 2D'});
      expect(
        engine.matchesEvent(sampleMovie, criteriaImax, eventShows: [sampleShows[0]]),
        isTrue,
      );
      expect(
        engine.matchesEvent(sampleConcert, criteriaImax, eventShows: [sampleShows[1]]),
        isFalse,
      );

      const criteriaU = ExploreFilterCriteria(ageRatings: {'U'});
      expect(engine.matchesEvent(sampleMovie, criteriaU), isFalse);
      expect(engine.matchesEvent(sampleConcert, criteriaU), isTrue);
    });

    test('sorts by Popularity and Price', () {
      final events = [sampleMovie, sampleConcert];

      // Popularity (sampleConcert has 88000 votes * 4.9 rating vs sampleMovie 42000 * 4.8)
      final sortedByPop = engine.sortEvents(events, ExploreSortBy.popularity);
      expect(sortedByPop.first.id, equals('evt_001'));

      // Price low to high
      final showsByEvent = {
        'mov_001': [sampleShows[0]],
        'evt_001': [sampleShows[1]],
      };
      final sortedByPrice = engine.sortEvents(
        events,
        ExploreSortBy.priceAsc,
        showsByEvent: showsByEvent,
      );
      expect(sortedByPrice.first.id, equals('mov_001')); // 300 < 1500
    });
  });

  group('ExploreFilterEngine - Restaurant Filtering', () {
    const restaurant1 = Restaurant(
      id: 'rest_01',
      name: 'Bastian Bandra',
      cuisine: ['Seafood', 'Asian'],
      rating: 4.7,
      costForTwo: 3500.0,
      address: 'Linking Road, Bandra West',
      city: 'Mumbai',
      distanceKm: 3.2,
      imageUrl: 'https://images.unsplash.com/photo-bastian',
      bannerUrl: 'https://images.unsplash.com/photo-bastian-b',
      openTime: '12:00 PM',
      closeTime: '01:00 AM',
    );

    const restaurant2 = Restaurant(
      id: 'rest_02',
      name: 'Toit Brewpub',
      cuisine: ['Brewery', 'Finger Food'],
      rating: 4.8,
      costForTwo: 1800.0,
      address: 'Indiranagar',
      city: 'Bengaluru',
      distanceKm: 8.5,
      imageUrl: 'https://images.unsplash.com/photo-toit',
      bannerUrl: 'https://images.unsplash.com/photo-toit-b',
      openTime: '11:30 AM',
      closeTime: '11:30 PM',
    );

    test('filters restaurants by query, price, and distance', () {
      const criteriaSearch = ExploreFilterCriteria(
        category: ExploreCategory.dining,
        searchQuery: 'bastion', // Typo for Bastian
      );
      expect(engine.matchesRestaurant(restaurant1, criteriaSearch), isTrue);
      expect(engine.matchesRestaurant(restaurant2, criteriaSearch), isFalse);

      const criteriaDistance = ExploreFilterCriteria(
        category: ExploreCategory.dining,
        maxDistanceKm: 5.0,
      );
      expect(engine.matchesRestaurant(restaurant1, criteriaDistance), isTrue); // 3.2 km <= 5 km
      expect(engine.matchesRestaurant(restaurant2, criteriaDistance), isFalse); // 8.5 km > 5 km
    });
  });
}
