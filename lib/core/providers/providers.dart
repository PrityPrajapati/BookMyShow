import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/core/repositories/repositories.dart';
export 'booking_draft_provider.dart';
export 'package:showscape/features/dining/presentation/providers/dining_providers.dart'
    show userReservationsProvider, UserReservationsNotifier;
export 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart'
    show allUserBookingsProvider;

// =============================================================================
// Repository Providers
// =============================================================================

/// Global singleton providers for abstract repositories with mock instances
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository();
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository();
});

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  return MockVenueRepository();
});

final showRepositoryProvider = Provider<ShowRepository>((ref) {
  return MockShowRepository();
});

final seatRepositoryProvider = Provider<SeatRepository>((ref) {
  return MockSeatRepository();
});

final fnbRepositoryProvider = Provider<FnbRepository>((ref) {
  return MockFnbRepository();
});

final diningRepositoryProvider = Provider<DiningRepository>((ref) {
  return MockDiningRepository();
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return MockBookingRepository();
});

// =============================================================================
// User & Auth Providers
// =============================================================================

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getCurrentUser();
});

// =============================================================================
// Event & Movie Providers
// =============================================================================

/// All events across movies, concerts, sports, comedy, theatre
final allEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getAllEvents();
});

/// Filtered movies
final moviesProvider = FutureProvider<List<Event>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getMovies();
});

/// Trending movies on homepage
final trendingMoviesProvider = FutureProvider<List<Event>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getTrendingMovies();
});

/// Featured spotlight events for carousels
final featuredEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getFeaturedEvents();
});

/// Event detail by id
final eventDetailProvider =
    FutureProvider.family<Event?, String>((ref, id) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventById(id);
});

/// Events filtered by EventType
final eventsByTypeProvider =
    FutureProvider.family<List<Event>, EventType>((ref, type) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvents(type: type);
});

// =============================================================================
// Venue Providers
// =============================================================================

final venuesProvider = FutureProvider<List<Venue>>((ref) async {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getVenues();
});

final cinemasProvider = FutureProvider<List<Venue>>((ref) async {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getCinemas();
});

final stadiumsProvider = FutureProvider<List<Venue>>((ref) async {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getStadiums();
});

final venueDetailProvider =
    FutureProvider.family<Venue?, String>((ref, id) async {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getVenueById(id);
});

final venueParkingLotsProvider =
    FutureProvider.family<List<ParkingLot>, String>((ref, venueId) async {
  final repo = ref.watch(venueRepositoryProvider);
  return repo.getParkingLots(venueId);
});

// =============================================================================
// Show & Showtime Providers
// =============================================================================

final showsForEventProvider =
    FutureProvider.family<List<Show>, String>((ref, eventId) async {
  final repo = ref.watch(showRepositoryProvider);
  return repo.getShows(eventId: eventId);
});

final availableDatesForEventProvider =
    FutureProvider.family<List<DateTime>, String>((ref, eventId) async {
  final repo = ref.watch(showRepositoryProvider);
  return repo.getAvailableDatesForEvent(eventId);
});

final showDetailProvider =
    FutureProvider.family<Show?, String>((ref, showId) async {
  final repo = ref.watch(showRepositoryProvider);
  return repo.getShowById(showId);
});

// =============================================================================
// Seat Layout Providers
// =============================================================================

final seatLayoutProvider =
    FutureProvider.family<SeatLayout?, String>((ref, layoutId) async {
  final repo = ref.watch(seatRepositoryProvider);
  return repo.getSeatLayoutById(layoutId);
});

// =============================================================================
// Food & Beverage Providers
// =============================================================================

final fnbItemsProvider = FutureProvider<List<FnbItem>>((ref) async {
  final repo = ref.watch(fnbRepositoryProvider);
  return repo.getMenuItems();
});

final fnbCombosProvider = FutureProvider<List<FnbCombo>>((ref) async {
  final repo = ref.watch(fnbRepositoryProvider);
  return repo.getCombos();
});

// =============================================================================
// Dining & Restaurant Providers
// =============================================================================

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repo = ref.watch(diningRepositoryProvider);
  return repo.getRestaurants();
});

final restaurantDetailProvider =
    FutureProvider.family<Restaurant?, String>((ref, id) async {
  final repo = ref.watch(diningRepositoryProvider);
  return repo.getRestaurantById(id);
});

// =============================================================================
// Booking & Ticket Providers
// =============================================================================

final userBookingsProvider =
    FutureProvider.family<List<Booking>, String>((ref, userId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getUserBookings(userId);
});

final userTicketsProvider =
    FutureProvider.family<List<Ticket>, String>((ref, userId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getUserTickets(userId);
});

final bookingDetailProvider =
    FutureProvider.family<Booking?, String>((ref, bookingId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingById(bookingId);
});
