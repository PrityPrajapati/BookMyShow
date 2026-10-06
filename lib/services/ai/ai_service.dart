import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:showscape/core/providers/demo_mode_provider.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/repositories/repositories.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/explore/domain/models/app_mood.dart';
import 'package:showscape/features/explore/domain/models/event.dart';
import 'package:showscape/features/event_detail/domain/models/event_review_summary.dart';
import 'package:showscape/features/seats/domain/models/seat_layout.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';

// =============================================================================
// AI Message Model
// =============================================================================

enum AiMessageRole { user, assistant, system }

class AiMessage {
  final String id;
  final AiMessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isStreaming;
  final String? feedback; // 'like', 'dislike'
  final List<Event>? events;
  final List<Show>? showtimes;
  final List<Restaurant>? restaurants;
  final Map<String, dynamic>? plan;
  final List<String>? suggestedChips;

  const AiMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isStreaming = false,
    this.feedback,
    this.events,
    this.showtimes,
    this.restaurants,
    this.plan,
    this.suggestedChips,
  });

  AiMessage copyWith({
    String? id,
    AiMessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isStreaming,
    String? feedback,
    List<Event>? events,
    List<Show>? showtimes,
    List<Restaurant>? restaurants,
    Map<String, dynamic>? plan,
    List<String>? suggestedChips,
  }) {
    return AiMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
      feedback: feedback ?? this.feedback,
      events: events ?? this.events,
      showtimes: showtimes ?? this.showtimes,
      restaurants: restaurants ?? this.restaurants,
      plan: plan ?? this.plan,
      suggestedChips: suggestedChips ?? this.suggestedChips,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'feedback': feedback,
      };

  factory AiMessage.fromJson(Map<String, dynamic> json) => AiMessage(
        id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
        role: (json['role'] as String? ?? 'user') == 'assistant'
            ? AiMessageRole.assistant
            : AiMessageRole.user,
        content: json['content'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
        feedback: json['feedback'] as String?,
      );
}

// =============================================================================
// AI Service Interface
// =============================================================================

abstract class AiService {
  Stream<AiMessage> chat(List<AiMessage> history);
  Future<String> summarise(String text);
  Future<List<String>> tagMood(Event e);
}

// =============================================================================
// Rate Limiter & Cache
// =============================================================================

class AiRateLimiter {
  static const int maxRequestsPerHour = 20;
  final Map<String, List<DateTime>> _requestTimestamps = {};

  bool isAllowed(String userId) {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));

    final timestamps = _requestTimestamps[userId] ?? [];
    // Filter out requests older than 1 hour
    final recent = timestamps.where((t) => t.isAfter(oneHourAgo)).toList();
    _requestTimestamps[userId] = recent;

    if (recent.length >= maxRequestsPerHour) {
      return false;
    }

    recent.add(now);
    return true;
  }

  int remainingRequests(String userId) {
    final now = DateTime.now();
    final oneHourAgo = now.subtract(const Duration(hours: 1));
    final recent = (_requestTimestamps[userId] ?? []).where((t) => t.isAfter(oneHourAgo)).length;
    return (maxRequestsPerHour - recent).clamp(0, maxRequestsPerHour);
  }
}

class AiSummaryCache {
  final Map<String, String> _cache = {};

  String? get(String text) => _cache[text.trim()];

  void put(String text, String summary) {
    _cache[text.trim()] = summary;
  }
}

// =============================================================================
// System Instructions & Guidelines
// =============================================================================

const String scoutSystemInstruction = '''
You are Scout, the intelligent entertainment concierge for ShowScape.
Strict Rules:
1. ONLY recommend events, showtimes, seats, and restaurants returned by your tools. Never fabricate or invent data.
2. NEVER invent prices. Always show exact prices calculated with PricingEngine and actual repository figures.
3. Ask AT MOST ONE clarifying question per turn if required.
4. Detect the user's language and reply in the user's language: English, Hindi, or Hinglish (e.g. "Aaj shaam ko Kalki 2898 AD dekhne chalte hain!").
5. NEVER book without explicit user confirmation.
''';

// =============================================================================
// Gemini AI Service Implementation
// =============================================================================

class GeminiAiService implements AiService {
  final EventRepository eventRepo;
  final ShowRepository showRepo;
  final SeatRepository seatRepo;
  final DiningRepository diningRepo;
  final String apiKey;
  final AiRateLimiter rateLimiter;
  final AiSummaryCache summaryCache;
  final String userId;

  GeminiAiService({
    required this.eventRepo,
    required this.showRepo,
    required this.seatRepo,
    required this.diningRepo,
    this.apiKey = '',
    AiRateLimiter? rateLimiter,
    AiSummaryCache? summaryCache,
    this.userId = 'usr_001',
  })  : rateLimiter = rateLimiter ?? AiRateLimiter(),
        summaryCache = summaryCache ?? AiSummaryCache();

  // Local Tool Implementations
  Future<List<Event>> searchEventsTool({
    String? query,
    String? city,
    String? date,
    String? category,
    double? maxPrice,
    String? mood,
  }) async {
    final all = await eventRepo.getAllEvents();
    return all.where((e) {
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!e.title.toLowerCase().contains(q) &&
            !e.genres.any((g) => g.toLowerCase().contains(q))) {
          return false;
        }
      }
      if (category != null && category.isNotEmpty) {
        if (!e.type.name.toLowerCase().contains(category.toLowerCase())) return false;
      }
      return true;
    }).take(4).toList();
  }

  Future<List<Show>> getShowtimesTool(String eventId, String? dateStr) async {
    final all = await showRepo.getShows(eventId: eventId);
    return all.take(5).toList();
  }

  Future<List<String>> recommendSeatsTool(String showId, int groupSize) async {
    final show = await showRepo.getShowById(showId);
    final layout = await seatRepo.getSeatLayoutForShow(
      showId,
      show?.seatLayoutId ?? 'layout_01',
    );
    if (layout == null) return ['E10', 'E11'];
    final allSeats = [for (final r in layout.rows) ...r.seats];
    final available = allSeats.where((s) => s.state == SeatState.available).toList();
    if (available.length >= groupSize) {
      return available.take(groupSize).map((s) => s.seatNumber).toList();
    }
    return ['E10', 'E11'];
  }

  Future<List<Restaurant>> findRestaurantsTool({
    String? nearVenueId,
    String? cuisine,
    double? budget,
    String? afterTime,
  }) async {
    final all = await diningRepo.getRestaurants();
    return all.where((r) {
      if (cuisine != null &&
          cuisine.isNotEmpty &&
          !r.cuisine.any((c) => c.toLowerCase().contains(cuisine.toLowerCase()))) {
        return false;
      }
      if (budget != null && r.costForTwo > budget) return false;
      return true;
    }).take(3).toList();
  }

  Map<String, dynamic> buildPlanTool(List<dynamic> items) {
    return {
      'title': 'Curated Night Out Plan',
      'steps': items,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  Stream<AiMessage> chat(List<AiMessage> history) async* {
    if (!rateLimiter.isAllowed(userId)) {
      yield AiMessage(
        id: 'msg_rate_limit_${DateTime.now().millisecondsSinceEpoch}',
        role: AiMessageRole.assistant,
        content: 'You’ve reached the limit of 20 requests per hour. Please wait a short while or continue browsing manually.',
        timestamp: DateTime.now(),
      );
      return;
    }

    // If API key is empty, smoothly delegate to MockAiService
    if (apiKey.isEmpty) {
      final mockService = MockAiService(
        eventRepo: eventRepo,
        showRepo: showRepo,
        seatRepo: seatRepo,
        diningRepo: diningRepo,
      );
      yield* mockService.chat(history);
      return;
    }

    // Setup Gemini model with function calling
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(scoutSystemInstruction),
        tools: [
          Tool(
            functionDeclarations: [
              FunctionDeclaration(
                'searchEvents',
                'Search movies, concerts, comedy, and theater events',
                Schema(
                  SchemaType.object,
                  properties: {
                    'query': Schema(SchemaType.string, description: 'Search term or movie title'),
                    'city': Schema(SchemaType.string, description: 'City name e.g. Mumbai'),
                    'category': Schema(SchemaType.string, description: 'Category e.g. movie, comedy'),
                    'maxPrice': Schema(SchemaType.number, description: 'Maximum ticket budget'),
                  },
                ),
              ),
              FunctionDeclaration(
                'findRestaurants',
                'Find top dining spots near a cinema or venue',
                Schema(
                  SchemaType.object,
                  properties: {
                    'cuisine': Schema(SchemaType.string, description: 'Cuisine preference'),
                    'budget': Schema(SchemaType.number, description: 'Budget for two'),
                  },
                ),
              ),
            ],
          ),
        ],
      );

      final lastUserMessage = history.lastWhere(
        (m) => m.role == AiMessageRole.user,
        orElse: () => AiMessage(
          id: 'temp',
          role: AiMessageRole.user,
          content: 'Hello',
          timestamp: DateTime.now(),
        ),
      );

      final response = await model.generateContent([
        Content.text(lastUserMessage.content),
      ]);

      final text = response.text ?? 'Here are my recommendations:';
      yield AiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        role: AiMessageRole.assistant,
        content: text,
        timestamp: DateTime.now(),
      );
    } catch (_) {
      // Graceful fallback to mock offline engine
      final mock = MockAiService(
        eventRepo: eventRepo,
        showRepo: showRepo,
        seatRepo: seatRepo,
        diningRepo: diningRepo,
      );
      yield* mock.chat(history);
    }
  }

  @override
  Future<String> summarise(String text) async {
    final cached = summaryCache.get(text);
    if (cached != null) return cached;

    if (apiKey.isEmpty) {
      final summary = EventReviewSummary.fromAiText(
        text,
        eventId: 'generic_event',
      ).toAiServiceFormat();
      summaryCache.put(text, summary);
      return summary;
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final res = await model.generateContent([
        Content.text(
          'You are ShowScape\'s AI entertainment review summarizer. '
          'Analyze the provided reviews and summarize what people say into EXACTLY 3 short bullet points '
          'and EXACTLY one line of spoiler-free verdict.\n'
          'Strict output format:\n'
          'BULLET: [first short bullet point]\n'
          'BULLET: [second short bullet point]\n'
          'BULLET: [third short bullet point]\n'
          'VERDICT: [one-line spoiler-free verdict]\n\n'
          'Reviews:\n$text',
        ),
      ]);
      final raw = res.text?.trim();
      final summary = (raw != null && raw.isNotEmpty)
          ? EventReviewSummary.fromAiText(raw, eventId: 'generic_event').toAiServiceFormat()
          : EventReviewSummary.fromAiText(text, eventId: 'generic_event').toAiServiceFormat();
      summaryCache.put(text, summary);
      return summary;
    } catch (_) {
      final fallback = EventReviewSummary.fromAiText(text, eventId: 'generic_event').toAiServiceFormat();
      summaryCache.put(text, fallback);
      return fallback;
    }
  }

  @override
  Future<List<String>> tagMood(Event e) async {
    if (apiKey.isEmpty) {
      return AppMood.deterministicMoodFallback(e);
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final res = await model.generateContent([
        Content.text(
          'Classify the event "${e.title}" (Genres: ${e.genres.join(', ')}, Type: ${e.type.name}) '
          'into 1 to 3 of the following moods only: [chill, laugh, thrill, date_night, family, music]. '
          'Respond with ONLY a comma-separated list of chosen mood keys (e.g. "thrill, date_night").',
        ),
      ]);
      final raw = res.text?.toLowerCase() ?? '';
      final parsed = raw
          .split(RegExp(r'[,;\n]'))
          .map((s) => AppMood.normalize(s))
          .where((s) => AppMood.canonicalIds.contains(s))
          .take(3)
          .toList();
      if (parsed.isNotEmpty) return parsed;
      return AppMood.deterministicMoodFallback(e);
    } catch (_) {
      return AppMood.deterministicMoodFallback(e);
    }
  }
}

// =============================================================================
// Mock AI Service with Scripted Multi-Turn Responses & Local Tools
// =============================================================================

class MockAiService implements AiService {
  final EventRepository eventRepo;
  final ShowRepository showRepo;
  final SeatRepository seatRepo;
  final DiningRepository diningRepo;
  final AiSummaryCache summaryCache;

  MockAiService({
    required this.eventRepo,
    required this.showRepo,
    required this.seatRepo,
    required this.diningRepo,
    AiSummaryCache? summaryCache,
  }) : summaryCache = summaryCache ?? AiSummaryCache();

  @override
  Stream<AiMessage> chat(List<AiMessage> history) async* {
    final lastMessage = history.lastWhere(
      (m) => m.role == AiMessageRole.user,
      orElse: () => AiMessage(
        id: 'mock_user',
        role: AiMessageRole.user,
        content: 'Hi',
        timestamp: DateTime.now(),
      ),
    );

    final q = lastMessage.content.toLowerCase();

    // Check language: Hindi / Hinglish vs English
    final isHindi = q.contains('karo') ||
        q.contains('batao') ||
        q.contains('aaj') ||
        q.contains('shaam') ||
        q.contains('dikhao') ||
        q.contains('chahiye') ||
        q.contains('hai');

    List<Event>? matchedEvents;
    List<Show>? matchedShowtimes;
    List<Restaurant>? matchedRestaurants;
    Map<String, dynamic>? matchedPlan;
    List<String>? suggestions;
    String fullContent = '';

    if (q.contains('comedy') || q.contains('haso') || q.contains('standup')) {
      final all = await eventRepo.getAllEvents();
      matchedEvents = all.where((e) => e.type == EventType.comedy || e.genres.contains('Comedy')).toList();
      if (matchedEvents.isEmpty) matchedEvents = all.take(2).toList();

      fullContent = isHindi
          ? 'Haan bilkul! Yeh rahe aapke liye top stand-up comedy shows aaj shaam ke liye. Inme se kaunsa pasand aaya?'
          : 'Here are the funniest live stand-up comedy shows performing near you tonight. Would you like to reserve seats?';

      suggestions = ['Showtimes for Zakir Khan', 'Front row seats', 'Dinner nearby'];
    } else if (q.contains('dinner') || q.contains('restaurant') || q.contains('food') || q.contains('khana')) {
      final all = await diningRepo.getRestaurants();
      matchedRestaurants = all.take(2).toList();

      fullContent = isHindi
          ? 'Mast dining spots mil gaye! In restaurants par ShowScape ticket ke saath Flat 20% off bhi milega.'
          : 'I found fabulous dining spots right next to the venue with exclusive 20% off after the show:';

      suggestions = ['Reserve table at AER', 'Show me menu', 'Book Dune show'];
    } else if (q.contains('plan') ||
        q.contains('night out') ||
        q.contains('combo') ||
        q.contains('date') ||
        q.contains('bandra') ||
        q.contains('funny')) {
      double targetBudget = 2500.0;
      final budgetMatch = RegExp(
        r'(?:under|below|within|budget(?:\s*of)?)\s*(?:₹|rs\.?|inr)?\s*(\d+(?:,\d+)?)',
        caseSensitive: false,
      ).firstMatch(q);
      if (budgetMatch != null) {
        final parsed = double.tryParse(budgetMatch.group(1)!.replaceAll(',', ''));
        if (parsed != null && parsed > 0) {
          targetBudget = parsed;
        }
      }

      final isImpossible = targetBudget < 1500.0;

      final shows = [
        {
          'id': 'show_comedy_01',
          'showId': 'show_comedy_bandra_01',
          'eventId': 'event_comedy_01',
          'type': 'show',
          'time': '7:00 PM',
          'title': 'Rahul Subramanian: Who Are You? (Live)',
          'subtitle': 'Bal Gandharva Rang Mandir, Bandra West',
          'imageUrl':
              'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=500',
          'price': 998.0,
          'unitPrice': 499.0,
          'seats': ['D-4', 'D-5'],
          'venueId': 'venue_bandra_01',
        },
        {
          'id': 'show_comedy_02',
          'showId': 'show_comedy_bandra_02',
          'eventId': 'event_comedy_02',
          'type': 'show',
          'time': '7:30 PM',
          'title': 'Biswa Kalyan Rath: Live & Raw Stand-Up',
          'subtitle': 'St. Andrews Auditorium, Bandra West',
          'imageUrl':
              'https://images.unsplash.com/photo-1514306191717-452ec28c7814?w=500',
          'price': 1198.0,
          'unitPrice': 599.0,
          'seats': ['C-12', 'C-13'],
          'venueId': 'venue_bandra_02',
        },
        {
          'id': 'show_comedy_03',
          'showId': 'show_comedy_bandra_03',
          'eventId': 'event_comedy_03',
          'type': 'show',
          'time': '6:30 PM',
          'title': 'Bandra Comedy Club: Improv All-Stars',
          'subtitle': 'Suburban Comedy Lounge, Pali Hill, Bandra',
          'imageUrl':
              'https://images.unsplash.com/photo-1507676184212-d03ab07a01bf?w=500',
          'price': 798.0,
          'unitPrice': 399.0,
          'seats': ['B-7', 'B-8'],
          'venueId': 'venue_bandra_03',
        },
      ];

      final restaurants = [
        {
          'id': 'dine_01',
          'restaurantId': 'dine_bastian_bandra',
          'type': 'dinner',
          'time': '9:30 PM',
          'title': 'Bastian Bandra',
          'subtitle': 'Seafood & Asian Tapas • Flat 20% off after show',
          'imageUrl':
              'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
          'price': 1050.0,
        },
        {
          'id': 'dine_02',
          'restaurantId': 'dine_daily_bandra',
          'type': 'dinner',
          'time': '9:30 PM',
          'title': 'The Daily All Day, Bandra',
          'subtitle': 'Craft Kitchen & Cocktails • Reserved VIP booth',
          'imageUrl':
              'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
          'price': 920.0,
        },
        {
          'id': 'dine_03',
          'restaurantId': 'dine_candies_bandra',
          'type': 'dinner',
          'time': '9:15 PM',
          'title': 'Candies, Pali Hill Bandra',
          'subtitle': 'Charming European Villa Café & Gourmet Desserts',
          'imageUrl':
              'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500',
          'price': 650.0,
        },
      ];

      final parking = {
        'id': 'park_01',
        'type': 'parking',
        'time': '6:45 PM',
        'title': 'Reserved Valet & 4-Wheeler Parking',
        'subtitle': 'Basement P1 (Guaranteed spot under venue)',
        'imageUrl':
            'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=500',
        'price': 150.0,
      };

      matchedPlan = {
        'id': 'plan_bandra_datenight_01',
        'title': 'Date Night Saturday in Bandra',
        'targetBudget': targetBudget,
        'isImpossibleBudget': isImpossible,
        'hasParking': true,
        'currentShowIndex': 0,
        'currentRestaurantIndex': 0,
        'shows': shows,
        'restaurants': restaurants,
        'parking': parking,
      };

      if (isImpossible) {
        fullContent = isHindi
            ? 'Bandra mein 2 stand-up comedy tickets, dinner aur parking ₹${targetBudget.toInt()} ke budget mein possible nahi hai (entry ₹399/seat se shuru hoti hai). Lekin maine aapke liye sabse affordable package banaya hai ₹1,598 mein:'
            : 'A full Saturday date night in Bandra with 2 live comedy tickets, dinner, and parking isn\'t feasible under ₹${targetBudget.toInt()} (passes start at ₹399/ticket and parking is ₹150). However, I’ve tailored the closest, most value-packed option at ₹1,598:';
      } else {
        fullContent = isHindi
            ? 'Aapke liye Saturday Date Night plan Bandra mein ready hai! 7:00 PM stand-up comedy show, 9:30 PM Bastian mein dinner aur reserved valet parking—PricingEngine se calculated aur aapke ₹${targetBudget.toInt()} budget ke andar:'
            : 'Here is your curated Date Night plan for this Saturday near Bandra! Featuring front-row laughs at Rahul Subramanian’s live stand-up, post-show Asian tapas at Bastian, and reserved basement valet parking—all calculated with ShowScape’s PricingEngine and under your ₹${targetBudget.toInt()} budget:';
      }

      suggestions = [
        'Swap show',
        'Swap restaurant',
        'Remove parking',
        'Book this plan',
      ];
    } else if (q.contains('seat') || q.contains('showtime') || q.contains('book')) {
      final shows = await showRepo.getShows();
      matchedShowtimes = shows.take(3).toList();

      fullContent = isHindi
          ? 'Aapke liye available prime showtimes mil gaye hain. Seat chunne ke liye showtime chip par tap karein:'
          : 'Here are the upcoming showtimes with best seat views. Tap any showtime chip below to view the interactive seat map:';

      suggestions = ['Book 2 Tickets', 'Gold presale access', 'Dine before'];
    } else {
      // Default discovery
      final all = await eventRepo.getAllEvents();
      matchedEvents = all.take(3).toList();

      fullContent = isHindi
          ? 'Namaste Alex! Aaj ke sabse trending movies aur events yeh rahe. Kisme interested hain aap?'
          : 'Hey Alex! Here are the hottest trending movies and live experiences in Mumbai today:';

      suggestions = ['Night Out Plan', 'Comedy Shows', 'Dinner near Bandra'];
    }

    // Stream the content token by token to simulate real AI streaming
    final words = fullContent.split(' ');
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
    String currentText = '';

    for (int i = 0; i < words.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      currentText += (i == 0 ? '' : ' ') + words[i];

      yield AiMessage(
        id: messageId,
        role: AiMessageRole.assistant,
        content: currentText,
        timestamp: DateTime.now(),
        isStreaming: i < words.length - 1,
        events: i == words.length - 1 ? matchedEvents : null,
        showtimes: i == words.length - 1 ? matchedShowtimes : null,
        restaurants: i == words.length - 1 ? matchedRestaurants : null,
        plan: i == words.length - 1 ? matchedPlan : null,
        suggestedChips: i == words.length - 1 ? suggestions : null,
      );
    }
  }

  @override
  Future<String> summarise(String text) async {
    final cached = summaryCache.get(text);
    if (cached != null) return cached;

    await Future<void>.delayed(const Duration(milliseconds: 250));
    final summary = EventReviewSummary.fromAiText(
      text,
      eventId: 'mock_event',
    ).toAiServiceFormat();
    summaryCache.put(text, summary);
    return summary;
  }

  @override
  Future<List<String>> tagMood(Event e) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return AppMood.deterministicMoodFallback(e);
  }
}

// =============================================================================
// Riverpod Providers for AI Service
// =============================================================================

final aiRateLimiterProvider = Provider<AiRateLimiter>((ref) => AiRateLimiter());
final aiSummaryCacheProvider = Provider<AiSummaryCache>((ref) => AiSummaryCache());

final aiServiceProvider = Provider<AiService>((ref) {
  final eventRepo = ref.watch(eventRepositoryProvider);
  final showRepo = ref.watch(showRepositoryProvider);
  final seatRepo = ref.watch(seatRepositoryProvider);
  final diningRepo = ref.watch(diningRepositoryProvider);
  final limiter = ref.watch(aiRateLimiterProvider);
  final cache = ref.watch(aiSummaryCacheProvider);
  final demo = ref.watch(demoModeProvider);

  if (demo.isDemoActive && demo.useMockAi) {
    return MockAiService(
      eventRepo: eventRepo,
      showRepo: showRepo,
      seatRepo: seatRepo,
      diningRepo: diningRepo,
      summaryCache: cache,
    );
  }

  // Return GeminiAiService (which automatically falls back to MockAiService when offline or no API key)
  return GeminiAiService(
    eventRepo: eventRepo,
    showRepo: showRepo,
    seatRepo: seatRepo,
    diningRepo: diningRepo,
    rateLimiter: limiter,
    summaryCache: cache,
  );
});
