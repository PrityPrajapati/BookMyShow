/// Centralized route paths and route name constants for ShowScape
abstract final class AppRoutes {
  // Main Navigation Tabs
  static const String home = '/';
  static const String explore = '/explore';
  static const String scout = '/scout';
  static const String tickets = '/tickets';
  static const String profile = '/profile';

  // Auth & Onboarding Routes
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  // Event & Booking Flow Routes
  static const String eventDetail = '/event/:id';
  static const String showtimes = '/showtimes/:eventId';
  static const String seats = '/seats/:showId';
  static const String food = '/food/:bookingDraftId';
  static const String parking = '/parking/:venueId';
  static const String checkout = '/checkout';
  static const String paymentResult = '/payment-result';

  // Ticket & Post-Booking Routes
  static const String ticketDetail = '/ticket/:id';
  static const String transferTicket = '/transfer/:ticketId';
  static const String venueMap = '/venue-map/:venueId';
  static const String staffScanner = '/staff/scanner';

  // Dining & Membership Routes
  static const String dining = '/dining';
  static const String diningDetail = '/dining/:id';
  static const String gold = '/gold';

  // Notifications & Reminders
  static const String notifications = '/notifications';

  // Development / Design Preview / AI Debug
  static const String designPreview = '/design-preview';
  static const String aiDebug = '/debug/ai';

  // Helper Methods for Parameterized Routes
  static String eventPath(String id) => '/event/$id';
  static String showtimesPath(String eventId) => '/showtimes/$eventId';
  static String seatsPath(String showId) => '/seats/$showId';
  static String foodPath(String bookingDraftId) => '/food/$bookingDraftId';
  static String parkingPath(String venueId) => '/parking/$venueId';
  static String ticketPath(String id) => '/ticket/$id';
  static String transferPath(String ticketId) => '/transfer/$ticketId';
  static String venueMapPath(String venueId) => '/venue-map/$venueId';
  static String diningDetailPath(String id) => '/dining/$id';
}
