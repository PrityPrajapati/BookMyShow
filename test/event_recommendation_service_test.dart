import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/features/home/domain/services/event_recommendation_service.dart';

void main() {
  group('EventRecommendationService Unit Tests', () {
    const service = EventRecommendationService();

    const testUser = AppUser(
      id: 'u1',
      name: 'Test Fan',
      email: 'fan@showscape.com',
      phone: '+91 99999 88888',
      favoriteGenres: ['Sci-Fi', 'Action'],
      favoriteLanguages: ['Hindi', 'English'],
      isGoldMember: true,
    );

    const sciFiActionMovie = Event(
      id: 'e1',
      title: 'Interstellar Hindi Dub',
      description: 'Sci fi epic',
      type: EventType.movie,
      genres: ['Sci-Fi', 'Action'], // 2 matches -> +6.0
      languages: ['Hindi'], // 1 match -> +2.0
      moodTags: ['Mind-Bending', 'Thrill'],
      rating: 9.5, // 9.5/10*2 -> +1.9
      durationMins: 169,
      posterUrl: 'url1',
      bannerUrl: 'banner1',
      trailerUrl: 'trailer1',
      aiSummary: 'Summary',
      isTrending: true, // +1.5
    );

    const romanticDramaMovie = Event(
      id: 'e2',
      title: 'Pure Romance Drama',
      description: 'Romantic drama',
      type: EventType.movie,
      genres: ['Romance', 'Drama'], // 0 matches -> 0
      languages: ['Tamil'], // 0 matches -> 0
      moodTags: ['Romantic', 'Date Night'],
      rating: 7.0, // 7/10*2 -> +1.4
      durationMins: 120,
      posterUrl: 'url2',
      bannerUrl: 'banner2',
      trailerUrl: 'trailer2',
      aiSummary: 'Summary',
    );

    test('Scores events with higher genre and language overlap higher', () {
      final scoreHigh = service.calculateScore(
        event: sciFiActionMovie,
        user: testUser,
      );

      final scoreLow = service.calculateScore(
        event: romanticDramaMovie,
        user: testUser,
      );

      expect(scoreHigh, greaterThan(scoreLow));
      // scoreHigh should have genre (+6), language (+2), gold (+1), rating (+1.9), trending (+1.5) = 12.4
      expect(scoreHigh, greaterThan(10.0));
      // scoreLow should only have rating (+1.4) + gold (+1) = 2.4
      expect(scoreLow, lessThan(4.0));
    });

    test('Mood tag boost gives extra score when mood matches', () {
      final withoutMood = service.calculateScore(
        event: sciFiActionMovie,
        user: testUser,
        moodTag: null,
      );

      final withMatchingMood = service.calculateScore(
        event: sciFiActionMovie,
        user: testUser,
        moodTag: 'Thrill',
      );

      expect(withMatchingMood, equals(withoutMood + 2.5));
    });

    test('rankForYou orders items by descending affinity score', () {
      final ranked = service.rankForYou(
        events: [romanticDramaMovie, sciFiActionMovie],
        user: testUser,
      );

      expect(ranked.first.id, 'e1');
      expect(ranked.last.id, 'e2');
    });

    test('Gracefully handles null user', () {
      final score = service.calculateScore(
        event: sciFiActionMovie,
        user: null,
      );

      // Null user should not crash and still consider rating and trending
      expect(score, greaterThan(0.0));
    });
  });
}
