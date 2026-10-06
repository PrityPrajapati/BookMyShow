import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/core/router/app_router.dart';
import 'package:showscape/core/router/auth_state.dart';
import 'package:showscape/core/router/placeholder_screens.dart'
    hide TicketsScreen, TicketDetailScreen, ProfileScreen, DiningScreen, DiningDetailScreen, GoldScreen, ScoutScreen;
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/router/scaffold_with_nav_bar.dart';
import 'package:showscape/features/dining/presentation/screens/dining_detail_screen.dart';
import 'package:showscape/features/dining/presentation/screens/dining_screen.dart';
import 'package:showscape/features/gold/presentation/screens/gold_screen.dart';
import 'package:showscape/features/profile/presentation/screens/profile_screen.dart';
import 'package:showscape/features/scout_ai/presentation/screens/scout_screen.dart';
import 'package:showscape/features/tickets/presentation/screens/ticket_detail_screen.dart';
import 'package:showscape/features/tickets/presentation/screens/tickets_screen.dart';
import 'package:showscape/main.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_router_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });
  testWidgets('Renders ShowScapeApp with 5 navigation tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShowScapeApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Home Screen initially rendered
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ScaffoldWithNavBar), findsOneWidget);

    // Verify 5 tab labels and Scout AI center button
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Scout AI'), findsOneWidget);
    expect(find.text('Tickets'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Switching bottom tabs switches shell branch', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShowScapeApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap Explore tab (index 1)
    await tester.tap(find.byKey(const Key('nav_tab_1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ExploreScreen), findsOneWidget);

    // Tap Scout AI center button (Index 2)
    await tester.tap(find.byKey(const Key('nav_tab_scout')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ScoutScreen), findsOneWidget);

    // Tap Tickets tab (index 3)
    await tester.tap(find.byKey(const Key('nav_tab_3')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TicketsScreen), findsOneWidget);

    // Tap Profile tab (index 4)
    await tester.tap(find.byKey(const Key('nav_tab_4')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ProfileScreen), findsOneWidget);

    // Tap Home tab back (index 0)
    await tester.tap(find.byKey(const Key('nav_tab_0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Redirect guard redirects unauthenticated user to /onboarding', (WidgetTester tester) async {
    final unauthNotifier = AuthNotifier()..logout();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => unauthNotifier),
        ],
        child: const ShowScapeApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Should redirect to OnboardingScreen
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Welcome to ShowScape'), findsOneWidget);

    // Logging in should redirect back to Home
    unauthNotifier.login();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Navigates through auxiliary routes correctly', (WidgetTester tester) async {
    final container = ProviderContainer();
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Navigate to Event Detail
    router.go(AppRoutes.eventPath('evt_dune_2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(EventDetailScreen), findsOneWidget);

    // Navigate to Showtimes
    router.go(AppRoutes.showtimesPath('evt_dune_2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ShowtimesScreen), findsOneWidget);

    // Navigate to Seats
    router.go(AppRoutes.seatsPath('show_imax_730'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SeatsScreen), findsOneWidget);

    // Navigate to Food
    router.go(AppRoutes.foodPath('draft_99342'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(FoodScreen), findsOneWidget);

    // Navigate to Parking
    router.go(AppRoutes.parkingPath('venue_pvr_palladium'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ParkingScreen), findsOneWidget);

    // Navigate to Checkout
    router.go(AppRoutes.checkout);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CheckoutScreen), findsOneWidget);

    // Navigate to Payment Result
    router.go(AppRoutes.paymentResult);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PaymentResultScreen), findsOneWidget);

    // Navigate to Ticket Detail
    router.go(AppRoutes.ticketPath('TICK-98234-IN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TicketDetailScreen), findsOneWidget);
    expect(find.text('TICK-98234-IN'), findsOneWidget);

    // Navigate to Transfer
    router.go(AppRoutes.transferPath('TICK-98234-IN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TransferTicketScreen), findsOneWidget);

    // Navigate to Venue Map
    router.go(AppRoutes.venueMapPath('venue_pvr_palladium'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(VenueMapScreen), findsOneWidget);

    // Navigate to Dining
    router.go(AppRoutes.dining);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(DiningScreen), findsOneWidget);

    // Navigate to Dining Detail
    router.go(AppRoutes.diningDetailPath('dine_aer_rooftop'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(DiningDetailScreen), findsOneWidget);

    // Navigate to Gold
    router.go(AppRoutes.gold);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GoldScreen), findsOneWidget);
  });
}
