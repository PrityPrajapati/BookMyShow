import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/core/providers/booking_draft_provider.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_theme.dart';
import 'package:showscape/features/auth/domain/models/app_user.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/checkout/presentation/screens/checkout_screen.dart';

void main() {
  group('Checkout Breakdown with Gold Member Widget Tests', () {
    final goldUser = AppUser(
      id: 'gold_user_007',
      name: 'Aditi Roy',
      email: 'aditi@showscape.io',
      phone: '+919876543210',
      favoriteGenres: const ['Action', 'Sci-Fi'],
      favoriteLanguages: const ['Hindi', 'English'],
      isGoldMember: true,
      goldExpiry: DateTime.now().add(const Duration(days: 300)),
      createdAt: DateTime(2026, 1, 1),
    );

    final goldDraft = BookingDraft(
      id: 'draft_gold_101',
      showId: 'show_imax_01',
      eventId: 'movie_dune_2',
      venueId: 'venue_phoenix_01',
      eventTitle: 'Dune: Part Two',
      venueName: 'PVR INOX IMAX Lower Parel',
      showTime: DateTime(2026, 10, 10, 19, 0),
      seatIds: const ['E12', 'E13'],
      seatPrices: const [550.0, 550.0],
      isMovie: true,
      isGold: true,
      durationMinutes: 166,
    );

    testWidgets('Gold user receives ₹0 convenience fee and GoldBadge indicator', (tester) async {
      tester.view.physicalSize = const Size(500, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Future.value(goldUser)),
        ],
      );

      final draftNotifier = container.read(bookingDraftProvider.notifier);
      draftNotifier.setDraft(goldDraft);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const CheckoutScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify event details
      expect(find.text('Dune: Part Two'), findsOneWidget);
      expect(find.text('PVR INOX IMAX Lower Parel'), findsOneWidget);

      // Verify Price Breakdown card
      expect(find.text('Price Breakdown'), findsOneWidget);
      expect(find.text('Tickets'), findsOneWidget);

      // Verify Gold fee waiver is active
      expect(find.text('Waived with Gold'), findsWidgets);
      expect(find.text('GOLD'), findsWidgets);

      // Verify Pay button displays ₹1,100 (tickets only, convenience fee ₹0)
      expect(find.textContaining('1,100'), findsWidgets);
    });
  });
}
