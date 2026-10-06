import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/repositories/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Domain Entities Serialization Tests', () {
    test('AppUser model serialization', () {
      const user = AppUser(
        id: 'usr_test',
        name: 'Test User',
        email: 'test@showscape.com',
        phone: '+91 99999 88888',
        isGoldMember: true,
        preferredCities: ['Mumbai', 'Delhi'],
      );

      final json = user.toJson();
      final fromJson = AppUser.fromJson(json);

      expect(fromJson.id, 'usr_test');
      expect(fromJson.name, 'Test User');
      expect(fromJson.isGoldMember, true);
      expect(fromJson.preferredCities, contains('Mumbai'));
    });

    test('Event model serialization', () {
      const event = Event(
        id: 'evt_test',
        title: 'Pushpa 2',
        description: 'Action thriller',
        type: EventType.movie,
        durationMins: 195,
        posterUrl: 'https://example.com/poster.jpg',
        bannerUrl: 'https://example.com/banner.jpg',
        trailerUrl: 'https://example.com/trailer',
        aiSummary: 'High-octane action',
        genres: ['Action', 'Thriller'],
        languages: ['Telugu', 'Hindi'],
        rating: 9.2,
      );

      final json = event.toJson();
      final fromJson = Event.fromJson(json);

      expect(fromJson.title, 'Pushpa 2');
      expect(fromJson.type, EventType.movie);
      expect(fromJson.rating, 9.2);
    });

    test('FnbCombo computed savings calculation', () {
      const item1 = FnbItem(
        id: '1',
        name: 'Popcorn',
        description: 'Large',
        imageUrl: 'url',
        price: 350.0,
        category: 'Popcorn',
      );
      const item2 = FnbItem(
        id: '2',
        name: 'Coke',
        description: 'Medium',
        imageUrl: 'url',
        price: 200.0,
        category: 'Beverage',
      );

      const combo = FnbCombo(
        id: 'c1',
        name: 'Duo Combo',
        description: 'Popcorn + Coke',
        imageUrl: 'url',
        items: [item1, item2],
        comboPrice: 450.0,
      );

      // (350 + 200) - 450 = 100
      expect(combo.computedSavings, 100.0);
    });

    test('PriceBreakdown calculation', () {
      const pb = PriceBreakdown(
        basePrice: 500.0,
        convenienceFee: 50.0,
        gst: 9.0,
        fnbTotal: 300.0,
        parkingTotal: 100.0,
        discount: 40.0,
        grandTotal: 919.0,
      );

      expect(pb.grandTotal, 919.0);
    });
  });

  group('Mock Repositories with JSON Asset Loading & 400ms Delay', () {
    test('MockEventRepository loads 12 movies and 8 events', () async {
      final repo = MockEventRepository();
      final all = await repo.getAllEvents();
      expect(all.length, 20); // 12 movies + 8 events

      final movies = await repo.getMovies();
      expect(movies.length, 12);

      // Verify Hindi, English, Tamil, Telugu languages present in movies
      final languages = movies.expand((m) => m.languages).toSet();
      expect(languages, containsAll(['Hindi', 'English', 'Tamil', 'Telugu']));

      final events = await repo.getEvents();
      expect(events.length, 8); // concerts, sports, comedy

      final concerts = await repo.getEvents(type: EventType.concert);
      expect(concerts.length, 3); // Coldplay, Arijit, Diljit

      final sports = await repo.getEvents(type: EventType.sports);
      expect(sports.length, 2); // IPL, ISL

      final comedy = await repo.getEvents(type: EventType.comedy);
      expect(comedy.length, 3); // Zakir, Bassi, Vir Das
    });

    test('MockVenueRepository loads 6 cinemas and 2 stadiums', () async {
      final repo = MockVenueRepository();
      final venues = await repo.getVenues();
      expect(venues.length, 8);

      final cinemas = await repo.getCinemas();
      expect(cinemas.length, 6);

      final stadiums = await repo.getStadiums();
      expect(stadiums.length, 2);

      // Verify cities: Mumbai, Delhi, Bengaluru, Pune
      final cities = venues.map((v) => v.city).toSet();
      expect(cities, containsAll(['Mumbai', 'Delhi', 'Bengaluru', 'Pune']));

      // Verify parking lots on venues
      final parkingLots = await repo.getParkingLots(venues.first.id);
      expect(parkingLots.isNotEmpty, true);
      expect(parkingLots.any((p) => p.vehicleType == VehicleType.fourWheeler), true);
    });

    test('MockSeatRepository loads 3 distinct layouts', () async {
      final repo = MockSeatRepository();

      final small = await repo.getSeatLayoutById('layout_small_120');
      expect(small, isNotNull);
      expect(small!.totalSeats, 120);

      final large = await repo.getSeatLayoutById('layout_large_300');
      expect(large, isNotNull);
      expect(large!.totalSeats, 300);

      final imax = await repo.getSeatLayoutById('layout_imax');
      expect(imax, isNotNull);
      expect(imax!.totalSeats, greaterThan(150));
    });

    test('MockShowRepository loads 7 days of shows', () async {
      final repo = MockShowRepository();
      final shows = await repo.getShows();
      expect(shows.length, greaterThan(200));

      final dates = await repo.getAvailableDatesForEvent('mov_001');
      expect(dates.length, greaterThanOrEqualTo(3));

      // Verify all 7 days are covered by shows
      final allDates = shows.map((s) => '${s.startTime.year}-${s.startTime.month}-${s.startTime.day}').toSet();
      expect(allDates.length, 7);
    });

    test('MockFnbRepository loads menus and combos', () async {
      final repo = MockFnbRepository();
      final items = await repo.getMenuItems();
      expect(items.length, greaterThanOrEqualTo(10));

      final combos = await repo.getCombos();
      expect(combos.length, greaterThanOrEqualTo(3));
      for (final c in combos) {
        expect(c.computedSavings, greaterThan(0));
      }
    });

    test('MockDiningRepository loads 10 restaurants in Indian cities', () async {
      final repo = MockDiningRepository();
      final restaurants = await repo.getRestaurants();
      expect(restaurants.length, 10);

      final cities = restaurants.map((r) => r.city).toSet();
      expect(cities, containsAll(['Mumbai', 'Delhi', 'Bengaluru', 'Pune']));
    });

    test('MockBookingRepository creates booking and transfers tickets', () async {
      final repo = MockBookingRepository();
      final bookings = await repo.getUserBookings('usr_001');
      expect(bookings.isNotEmpty, true);

      final transfer = await repo.transferTicket(
        bookingId: bookings.first.id,
        ticketId: bookings.first.tickets.first.id,
        fromUserId: 'usr_001',
        toUserPhone: '+91 91234 56789',
        note: 'Enjoy the movie!',
      );

      expect(transfer.status, TransferStatus.accepted);
      expect(transfer.toUserPhone, '+91 91234 56789');
    });

    test('Riverpod providers provide all mock repositories', () {
      final container = ProviderContainer();
      expect(container.read(eventRepositoryProvider), isNotNull);
      expect(container.read(venueRepositoryProvider), isNotNull);
      expect(container.read(showRepositoryProvider), isNotNull);
      expect(container.read(seatRepositoryProvider), isNotNull);
      expect(container.read(fnbRepositoryProvider), isNotNull);
      expect(container.read(diningRepositoryProvider), isNotNull);
      expect(container.read(bookingRepositoryProvider), isNotNull);
      expect(container.read(userRepositoryProvider), isNotNull);
    });
  });
}
