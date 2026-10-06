import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/features/home/domain/services/event_recommendation_service.dart';

/// Available cities in ShowScape
const supportedCities = ['Mumbai', 'Bengaluru', 'Delhi', 'Pune'];

/// Available mood tags
const availableMoodTags = [
  ('Chill', '🧊'),
  ('Laugh', '😂'),
  ('Thrill', '⚡'),
  ('Date Night', '🥂'),
  ('Family', '🍿'),
  ('Music', '🎸'),
];

/// Active selected city provider
final selectedCityProvider = StateProvider<String>((ref) => 'Mumbai');

/// Active selected mood filter (null = all)
final selectedMoodProvider = StateProvider<String?>((ref) => null);

/// Notifications badge count
final notificationCountProvider = StateProvider<int>((ref) => 3);

/// Recommendation domain service provider
final recommendationServiceProvider = Provider<EventRecommendationService>((ref) {
  return const EventRecommendationService();
});

/// 'For You' rail: personalized ranked events based on user genres, languages, and mood
final forYouEventsProvider = FutureProvider<List<Event>>((ref) async {
  final allEvents = await ref.watch(allEventsProvider.future);
  final user = await ref.watch(currentUserProvider.future);
  final mood = ref.watch(selectedMoodProvider);
  final service = ref.watch(recommendationServiceProvider);

  return service.rankForYou(
    events: allEvents,
    user: user,
    moodTag: mood,
  );
});

/// 'Now Showing' rail: movies currently playing
final nowShowingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final movies = await ref.watch(moviesProvider.future);
  final mood = ref.watch(selectedMoodProvider);

  if (mood == null) return movies;
  final target = mood.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
  return movies.where((m) {
    return m.moodTags.any((t) {
      final tag = t.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
      return tag == target || tag.contains(target) || target.contains(tag);
    });
  }).toList();
});

/// 'Events This Weekend' rail: concerts, standup comedy, etc.
final weekendEventsProvider = FutureProvider<List<Event>>((ref) async {
  final all = await ref.watch(allEventsProvider.future);
  final mood = ref.watch(selectedMoodProvider);

  final events = all.where((e) {
    return e.type == EventType.concert ||
        e.type == EventType.comedy ||
        e.type == EventType.theatre;
  }).toList();

  if (mood == null) return events;
  final target = mood.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
  return events.where((e) {
    return e.moodTags.any((t) {
      final tag = t.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_');
      return tag == target || tag.contains(target) || target.contains(tag);
    });
  }).toList();
});

/// 'Sports' rail: IPL, ISL, stadium blockbusters
final sportsEventsProvider = FutureProvider<List<Event>>((ref) async {
  final all = await ref.watch(allEventsProvider.future);
  return all.where((e) => e.type == EventType.sports).toList();
});

/// 'Dine After the Show' rail: curated restaurants in the selected city
final dineAfterShowProvider = FutureProvider<List<Restaurant>>((ref) async {
  final city = ref.watch(selectedCityProvider);
  final diningRepo = ref.watch(diningRepositoryProvider);
  final restaurants = await diningRepo.getRestaurants(city: city);

  if (restaurants.isNotEmpty) return restaurants;
  // Fallback to all restaurants if specific city has none
  return diningRepo.getRestaurants();
});
