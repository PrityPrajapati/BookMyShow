import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:showscape/features/event_detail/data/mock_reviews_data.dart';
import 'package:showscape/features/event_detail/data/review_summary_cache_service.dart';
import 'package:showscape/features/event_detail/domain/models/event_review_summary.dart';
import 'package:showscape/features/event_detail/domain/services/event_summary_manager.dart';
import 'package:showscape/features/explore/data/sources/event_mood_storage.dart';
import 'package:showscape/features/explore/domain/models/app_mood.dart';
import 'package:showscape/features/explore/domain/models/event.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';
import 'package:showscape/features/explore/domain/services/explore_filter_engine.dart';
import 'package:showscape/services/ai/ai_service.dart';
import 'package:showscape/core/repositories/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late MockAiService mockAiService;
  late ReviewSummaryCacheService cacheService;
  late EventMoodStorage moodStorage;
  late EventSummaryManager summaryManager;

  final testMovie = Event(
    id: 'test_mov_01',
    title: 'Interstellar Odyssey',
    description: 'An epic sci-fi adventure across space and time.',
    type: EventType.movie,
    genres: ['Sci-Fi', 'Action', 'Thriller'],
    durationMins: 165,
    posterUrl: 'https://example.com/poster.jpg',
    bannerUrl: 'https://example.com/banner.jpg',
    trailerUrl: 'https://example.com/trailer',
    aiSummary: 'A monumental sci-fi spectacle with brilliant VFX.',
    cast: ['Matthew Cooper', 'Anne Hathaway'],
  );

  final testComedy = Event(
    id: 'test_com_01',
    title: 'Zakir Khan Live',
    description: 'Tathastu special live stand-up tour.',
    type: EventType.comedy,
    genres: ['Comedy', 'Stand-up'],
    durationMins: 90,
    posterUrl: 'https://example.com/poster.jpg',
    bannerUrl: 'https://example.com/banner.jpg',
    trailerUrl: 'https://example.com/trailer',
    aiSummary: 'Relatable storytelling that keeps the crowd laughing.',
    cast: ['Zakir Khan'],
  );

  final testConcert = Event(
    id: 'test_con_01',
    title: 'Coldplay Music of the Spheres',
    description: 'Live stadium concert in Mumbai.',
    type: EventType.concert,
    genres: ['Music', 'Rock', 'Pop'],
    durationMins: 140,
    posterUrl: 'https://example.com/poster.jpg',
    bannerUrl: 'https://example.com/banner.jpg',
    trailerUrl: 'https://example.com/trailer',
    aiSummary: 'A visual and sonic explosion of joy.',
    cast: ['Chris Martin'],
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('showscape_ai_test_');
    Hive.init(tempDir.path);

    mockAiService = MockAiService(
      eventRepo: MockEventRepository(),
      showRepo: MockShowRepository(),
      seatRepo: MockSeatRepository(),
      diningRepo: MockDiningRepository(),
    );

    cacheService = ReviewSummaryCacheService();
    moodStorage = EventMoodStorage();
    summaryManager = EventSummaryManager(
      aiService: mockAiService,
      cacheService: cacheService,
      moodStorage: moodStorage,
    );
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('1. Top 20 Mock Reviews & Payload Generation', () {
    test('MockReviewsData generates exactly 20 reviews per event', () {
      final reviews = MockReviewsData.getTop20Reviews(testMovie);
      expect(reviews.length, equals(20));
      for (final r in reviews) {
        expect(r.eventId, equals(testMovie.id));
        expect(r.authorName, isNotEmpty);
        expect(r.text, isNotEmpty);
        expect(r.rating, greaterThanOrEqualTo(1.0));
        expect(r.rating, lessThanOrEqualTo(10.0));
      }
    });

    test('Different event types produce contextualized mock reviews', () {
      final comedyReviews = MockReviewsData.getTop20Reviews(testComedy);
      final concertReviews = MockReviewsData.getTop20Reviews(testConcert);

      expect(comedyReviews.length, equals(20));
      expect(concertReviews.length, equals(20));

      final hasComedyKeyword = comedyReviews.any((r) =>
          r.text.toLowerCase().contains('laugh') ||
          r.text.toLowerCase().contains('punchline') ||
          r.text.toLowerCase().contains('humor'));
      expect(hasComedyKeyword, isTrue);

      final hasConcertKeyword = concertReviews.any((r) =>
          r.text.toLowerCase().contains('vocal') ||
          r.text.toLowerCase().contains('sound') ||
          r.text.toLowerCase().contains('acoustic') ||
          r.text.toLowerCase().contains('stadium'));
      expect(hasConcertKeyword, isTrue);
    });
  });

  group('2. AiService.summarise & Format Contract', () {
    test('AiService.summarise returns 3 bullets and 1 verdict format', () async {
      final reviews = MockReviewsData.getTop20Reviews(testMovie);
      final rawText = reviews.take(5).map((r) => '${r.authorName}: ${r.text}').join('\n');

      final aiOutput = await mockAiService.summarise(rawText);
      expect(aiOutput, contains('BULLET:'));
      expect(aiOutput, contains('VERDICT:'));

      final summary = EventReviewSummary.fromAiText(
        aiOutput,
        eventId: testMovie.id,
        event: testMovie,
      );

      expect(summary.bullets.length, equals(3));
      expect(summary.verdict, isNotEmpty);
      expect(summary.verdict.contains('\n'), isFalse); // Exactly one line
    });

    test('Deterministic fallback triggers when AI text is missing or invalid', () {
      final reviews = MockReviewsData.getTop20Reviews(testMovie);
      final fallback = EventReviewSummary.fromAiText(
        'Some unparseable junk text',
        eventId: testMovie.id,
        event: testMovie,
        reviews: reviews,
      );

      expect(fallback.bullets.length, equals(3));
      expect(fallback.verdict, isNotEmpty);
      expect(fallback.bullets[0], isNotEmpty);
      expect(fallback.bullets[1], isNotEmpty);
      expect(fallback.bullets[2], isNotEmpty);
    });

    test('Deterministic fallback incorporates top review highlight', () {
      final reviews = MockReviewsData.getTop20Reviews(testMovie);
      final fallback = EventReviewSummary.deterministicFallback(
        eventId: testMovie.id,
        event: testMovie,
        reviews: reviews,
      );

      expect(fallback.bullets.length, equals(3));
      // First bullet should reflect Matthew Cooper or lead performance
      expect(fallback.bullets[0].toLowerCase(), contains('matthew cooper'));
      expect(fallback.verdict, isNotEmpty);
    });
  });

  group('3. Canonical Moods (chill, laugh, thrill, date_night, family, music)', () {
    test('Canonical set contains exactly the 6 required moods', () {
      expect(
        AppMood.canonicalIds,
        equals(['chill', 'laugh', 'thrill', 'date_night', 'family', 'music']),
      );
    });

    test('AppMood.normalize handles spaces, hyphens, and casing', () {
      expect(AppMood.normalize('Date Night'), equals('date_night'));
      expect(AppMood.normalize('date_night'), equals('date_night'));
      expect(AppMood.normalize('DATE-NIGHT'), equals('date_night'));
      expect(AppMood.normalize('Chill'), equals('chill'));
    });

    test('Deterministic mood fallback maps genres accurately to canonical moods', () {
      final comedyMoods = AppMood.deterministicMoodFallback(testComedy);
      expect(comedyMoods, contains('laugh'));
      for (final m in comedyMoods) {
        expect(AppMood.canonicalIds, contains(m));
      }

      final concertMoods = AppMood.deterministicMoodFallback(testConcert);
      expect(concertMoods, contains('music'));
      for (final m in concertMoods) {
        expect(AppMood.canonicalIds, contains(m));
      }

      final movieMoods = AppMood.deterministicMoodFallback(testMovie);
      expect(movieMoods, contains('thrill'));
      for (final m in movieMoods) {
        expect(AppMood.canonicalIds, contains(m));
      }
    });

    test('AiService.tagMood returns a valid subset of canonical moods', () async {
      final moods = await mockAiService.tagMood(testMovie);
      expect(moods, isNotEmpty);
      for (final m in moods) {
        expect(AppMood.canonicalIds, contains(m));
      }
    });
  });

  group('4. Daily Hive Caching per Event per Day', () {
    test('ReviewSummaryCacheService generates yyyyMMdd daily partition key', () {
      final now = DateTime(2026, 10, 2);
      final key = cacheService.getDayKey(now);
      expect(key, equals('20261002'));
    });

    test('Caches review summary in Hive and retrieves on cache hit', () async {
      final now = DateTime(2026, 10, 2);
      final summary = EventReviewSummary(
        eventId: testMovie.id,
        bullets: [
          'Visually revolutionary sci-fi masterpiece.',
          'Matthew Cooper gives a career-best performance.',
          'Immersive sound design that shakes the theatre.',
        ],
        verdict: 'A landmark cinema achievement best seen on the largest screen.',
        cachedAt: now,
      );

      await cacheService.cacheSummary(summary, now);

      final isCached = await cacheService.isCachedToday(testMovie.id, now);
      expect(isCached, isTrue);

      final retrieved = await cacheService.getCachedSummary(testMovie.id, now);
      expect(retrieved, isNotNull);
      expect(retrieved!.eventId, equals(testMovie.id));
      expect(retrieved.bullets, equals(summary.bullets));
      expect(retrieved.verdict, equals(summary.verdict));
    });

    test('EventSummaryManager uses cache on subsequent calls and regenerates on forceRefresh', () async {
      final s1 = await summaryManager.getOrGenerateSummary(testMovie);
      expect(s1.bullets.length, equals(3));

      // Second call returns cached without recalculating
      final s2 = await summaryManager.getOrGenerateSummary(testMovie);
      expect(s2.bullets, equals(s1.bullets));

      // Force refresh regenerates
      final s3 = await summaryManager.getOrGenerateSummary(testMovie, forceRefresh: true);
      expect(s3.bullets.length, equals(3));
    });
  });

  group('5. Explore Filter Engine with Canonical Moods', () {
    const engine = ExploreFilterEngine();

    test('Filters events matching selected canonical mood', () {
      final taggedComedy = testComedy.copyWith(moodTags: ['laugh', 'chill']);
      final taggedMovie = testMovie.copyWith(moodTags: ['thrill']);

      final comedyCriteria = const ExploreFilterCriteria(moods: {'laugh'});
      expect(engine.matchesEvent(taggedComedy, comedyCriteria), isTrue);
      expect(engine.matchesEvent(taggedMovie, comedyCriteria), isFalse);

      final thrillCriteria = const ExploreFilterCriteria(moods: {'thrill'});
      expect(engine.matchesEvent(taggedMovie, thrillCriteria), isTrue);
      expect(engine.matchesEvent(taggedComedy, thrillCriteria), isFalse);
    });

    test('Matches normalized mood strings seamlessly (Date Night vs date_night)', () {
      final romanticEvent = testMovie.copyWith(
        genres: ['Romance', 'Drama'],
        moodTags: ['date_night'],
      );

      final criteriaWithDisplay = const ExploreFilterCriteria(moods: {'Date Night'});
      final criteriaWithId = const ExploreFilterCriteria(moods: {'date_night'});

      expect(engine.matchesEvent(romanticEvent, criteriaWithDisplay), isTrue);
      expect(engine.matchesEvent(romanticEvent, criteriaWithId), isTrue);
    });
  });
}
