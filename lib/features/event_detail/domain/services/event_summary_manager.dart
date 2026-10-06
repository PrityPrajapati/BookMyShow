import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/features/event_detail/data/mock_reviews_data.dart';
import 'package:showscape/features/event_detail/data/review_summary_cache_service.dart';
import 'package:showscape/features/event_detail/domain/models/event_review_summary.dart';
import 'package:showscape/features/explore/data/sources/event_mood_storage.dart';
import 'package:showscape/features/explore/domain/models/app_mood.dart';
import 'package:showscape/features/explore/domain/models/event.dart';
import 'package:showscape/services/ai/ai_service.dart';

/// Central service coordinating AI Review Summaries and Event Mood Tagging
class EventSummaryManager {
  final AiService aiService;
  final ReviewSummaryCacheService cacheService;
  final EventMoodStorage moodStorage;

  EventSummaryManager({
    required this.aiService,
    required this.cacheService,
    required this.moodStorage,
  });

  /// Retrieves cached summary for [event] today, or generates via AiService.summarise and caches it
  Future<EventReviewSummary> getOrGenerateSummary(
    Event event, {
    bool forceRefresh = false,
  }) async {
    final today = DateTime.now();

    if (!forceRefresh) {
      final cached = await cacheService.getCachedSummary(event.id, today);
      if (cached != null) return cached;
    }

    // Top 20 mock reviews
    final reviews = MockReviewsData.getTop20Reviews(event);

    final reviewsPayload = [
      'Event: "${event.title}" (${event.type.name}, Genres: ${event.genres.join(', ')})',
      'Top 20 Verified User Reviews:',
      for (int i = 0; i < reviews.length; i++)
        '${i + 1}. [Rating: ${reviews[i].rating}/10] ${reviews[i].authorName}: "${reviews[i].text}"',
    ].join('\n');

    String aiOutput;
    try {
      aiOutput = await aiService.summarise(reviewsPayload);
    } catch (_) {
      aiOutput = '';
    }

    final summary = EventReviewSummary.fromAiText(
      aiOutput,
      eventId: event.id,
      event: event,
      reviews: reviews,
      timestamp: today,
    );

    // Cache per event per day in Hive
    await cacheService.cacheSummary(summary, today);
    return summary;
  }

  /// Tags event with canonical moods using AiService.tagMood and stores them in Hive
  Future<List<String>> tagAndStoreMoods(
    Event event, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final stored = await moodStorage.getStoredMoods(event.id);
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }
    }

    List<String> moods;
    try {
      moods = await aiService.tagMood(event);
    } catch (_) {
      moods = AppMood.deterministicMoodFallback(event);
    }

    // Ensure valid canonical moods only
    final canonical = moods
        .map((m) => AppMood.normalize(m))
        .where((m) => AppMood.canonicalIds.contains(m))
        .toList();

    final safeMoods = canonical.isNotEmpty
        ? canonical
        : AppMood.deterministicMoodFallback(event);

    await moodStorage.storeMoods(event.id, safeMoods);
    return safeMoods;
  }
}

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

final reviewSummaryCacheServiceProvider =
    Provider<ReviewSummaryCacheService>((ref) {
  return ReviewSummaryCacheService();
});

final eventMoodStorageProvider = Provider<EventMoodStorage>((ref) {
  return EventMoodStorage();
});

final eventSummaryManagerProvider = Provider<EventSummaryManager>((ref) {
  final ai = ref.watch(aiServiceProvider);
  final cache = ref.watch(reviewSummaryCacheServiceProvider);
  final moodStore = ref.watch(eventMoodStorageProvider);
  return EventSummaryManager(
    aiService: ai,
    cacheService: cache,
    moodStorage: moodStore,
  );
});

/// Family provider returning review summary for an event (cached per day)
final eventReviewSummaryProvider =
    FutureProvider.family<EventReviewSummary, Event>((ref, event) async {
  final manager = ref.watch(eventSummaryManagerProvider);
  return manager.getOrGenerateSummary(event);
});

/// Family provider returning canonical mood tags for an event
final eventMoodTagsProvider =
    FutureProvider.family<List<String>, Event>((ref, event) async {
  final manager = ref.watch(eventSummaryManagerProvider);
  return manager.tagAndStoreMoods(event);
});
