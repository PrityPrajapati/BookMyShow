import 'package:showscape/core/models/models.dart';

/// Domain service that calculates recommendation overlap scores for the 'For You' rail
class EventRecommendationService {
  const EventRecommendationService();

  /// Calculates a personalized affinity score for an event
  double calculateScore({
    required Event event,
    required AppUser? user,
    String? moodTag,
  }) {
    double score = 0.0;

    if (user != null) {
      // 1. Genre overlap (+3.0 per matching genre)
      final genreMatches = event.genres
          .where((g) => user.favoriteGenres
              .any((ug) => ug.toLowerCase() == g.toLowerCase()))
          .length;
      score += genreMatches * 3.0;

      // 2. Language overlap (+2.0 per matching language)
      final languageMatches = event.languages
          .where((l) => user.favoriteLanguages
              .any((ul) => ul.toLowerCase() == l.toLowerCase()))
          .length;
      score += languageMatches * 2.0;

      // 3. Gold Member curation boost (+1.0)
      if (user.isGoldMember) {
        score += 1.0;
      }
    }

    // 4. Mood Tag alignment (+2.5 if matches active selected mood)
    if (moodTag != null && moodTag.trim().isNotEmpty) {
      final targetMood = moodTag.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
      final hasMoodMatch = event.moodTags.any((tag) {
        final lowerTag = tag.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
        return lowerTag == targetMood ||
            lowerTag.contains(targetMood) ||
            targetMood.contains(lowerTag);
      });

      if (hasMoodMatch) {
        score += 2.5;
      }
    }

    // 5. Rating weight (normalized up to +2.0)
    score += (event.rating / 10.0) * 2.0;

    // 6. Trend and feature boosts
    if (event.isTrending) score += 1.5;
    if (event.isFeatured) score += 1.0;

    return score;
  }

  /// Ranks all provided events for the 'For You' rail descending by recommendation score
  List<Event> rankForYou({
    required List<Event> events,
    required AppUser? user,
    String? moodTag,
  }) {
    final scoredList = events.map((event) {
      final score = calculateScore(
        event: event,
        user: user,
        moodTag: moodTag,
      );
      return MapEntry(event, score);
    }).toList();

    // Sort descending by score; if tied, sort by rating
    scoredList.sort((a, b) {
      final comp = b.value.compareTo(a.value);
      if (comp != 0) return comp;
      return b.key.rating.compareTo(a.key.rating);
    });

    return scoredList.map((entry) => entry.key).toList();
  }
}
