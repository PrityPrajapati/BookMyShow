import 'package:showscape/features/event_detail/domain/models/mock_review.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

/// The 6 canonical moods required across ShowScape
enum AppMood {
  chill('chill', 'Chill', '🧊'),
  laugh('laugh', 'Laugh', '😂'),
  thrill('thrill', 'Thrill', '⚡'),
  dateNight('date_night', 'Date Night', '🥂'),
  family('family', 'Family', '🍿'),
  music('music', 'Music', '🎸');

  final String id;
  final String label;
  final String emoji;

  const AppMood(this.id, this.label, this.emoji);

  static const List<String> canonicalIds = [
    'chill',
    'laugh',
    'thrill',
    'date_night',
    'family',
    'music',
  ];

  static AppMood? tryFrom(String? value) {
    if (value == null) return null;
    final normalized = normalize(value);
    for (final mood in AppMood.values) {
      if (mood.id == normalized || mood.label.toLowerCase() == value.toLowerCase()) {
        return mood;
      }
    }
    return null;
  }

  /// Normalizes any variation (e.g. 'Date Night', 'date_night', 'Date-Night') to canonical id
  static String normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-]+'), '_');
  }

  /// Deterministic fallback mapping: event genre/type + top review keywords -> canonical moods
  static List<String> deterministicMoodFallback(
    Event event, {
    List<MockReview>? reviews,
  }) {
    final genres = event.genres.map((g) => g.toLowerCase().trim()).toSet();
    final type = event.type;
    final resultMoods = <String>{};

    // 1. Genre & Type deterministic mapping
    if (type == EventType.comedy ||
        genres.contains('comedy') ||
        genres.contains('stand-up') ||
        genres.contains('standup')) {
      resultMoods.add(AppMood.laugh.id);
      resultMoods.add(AppMood.chill.id);
    }

    if (type == EventType.concert ||
        genres.contains('music') ||
        genres.contains('concert') ||
        genres.contains('rock') ||
        genres.contains('pop') ||
        genres.contains('classical') ||
        genres.contains('edm')) {
      resultMoods.add(AppMood.music.id);
    }

    if (genres.contains('action') ||
        genres.contains('thriller') ||
        genres.contains('sci-fi') ||
        genres.contains('crime') ||
        genres.contains('horror') ||
        genres.contains('mystery') ||
        genres.contains('adventure') ||
        type == EventType.sports) {
      resultMoods.add(AppMood.thrill.id);
    }

    if (genres.contains('romance') ||
        genres.contains('drama') ||
        genres.contains('romantic')) {
      resultMoods.add(AppMood.dateNight.id);
    }

    if (genres.contains('animation') ||
        genres.contains('family') ||
        genres.contains('children') ||
        genres.contains('fantasy')) {
      resultMoods.add(AppMood.family.id);
      resultMoods.add(AppMood.laugh.id);
    }

    // 2. Top Review Sentiment Fallback (if provided)
    if (reviews != null && reviews.isNotEmpty) {
      final topReviewText = reviews.first.text.toLowerCase();
      if (topReviewText.contains('laugh') ||
          topReviewText.contains('hilarious') ||
          topReviewText.contains('funny') ||
          topReviewText.contains('stitches')) {
        resultMoods.add(AppMood.laugh.id);
      }
      if (topReviewText.contains('thrill') ||
          topReviewText.contains('goosebumps') ||
          topReviewText.contains('adrenaline') ||
          topReviewText.contains('edge of seat')) {
        resultMoods.add(AppMood.thrill.id);
      }
      if (topReviewText.contains('date') ||
          topReviewText.contains('heartfelt') ||
          topReviewText.contains('chemistry') ||
          topReviewText.contains('romantic')) {
        resultMoods.add(AppMood.dateNight.id);
      }
      if (topReviewText.contains('wholesome') ||
          topReviewText.contains('kids') ||
          topReviewText.contains('family')) {
        resultMoods.add(AppMood.family.id);
      }
      if (topReviewText.contains('music') ||
          topReviewText.contains('soundtrack') ||
          topReviewText.contains('acoustic') ||
          topReviewText.contains('vocals') ||
          topReviewText.contains('score')) {
        resultMoods.add(AppMood.music.id);
      }
      if (topReviewText.contains('chill') ||
          topReviewText.contains('relaxing') ||
          topReviewText.contains('unwind') ||
          topReviewText.contains('peaceful')) {
        resultMoods.add(AppMood.chill.id);
      }
    }

    // If still empty, fall back to chill or thrill based on type
    if (resultMoods.isEmpty) {
      resultMoods.add(type == EventType.movie ? AppMood.thrill.id : AppMood.chill.id);
    }

    // Retain only canonical moods and cap at 3 for clean display
    return resultMoods
        .where((m) => canonicalIds.contains(m))
        .take(3)
        .toList();
  }
}
