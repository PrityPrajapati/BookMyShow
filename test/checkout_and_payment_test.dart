import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/core/providers/booking_draft_provider.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_theme.dart';
import 'package:showscape/features/auth/domain/models/app_user.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:showscape/features/payment/data/services/mock_payment_service.dart';
import 'package:showscape/features/payment/domain/models/payment_request.dart';
import 'package:showscape/features/payment/presentation/screens/payment_result_screen.dart';
import 'package:showscape/features/tickets/data/repositories/mock_booking_repository.dart';

void main() {
  final regularUser = AppUser(
    id: 'user_1',
    name: 'Rahul Sharma',
    email: 'rahul@example.com',
    phone: '+919876543210',
    favoriteGenres: const ['Sci-Fi'],
    favoriteLanguages: const ['Hindi'],
    isGoldMember: false,
    createdAt: DateTime(2026, 1, 1),
  );

  final goldUser = regularUser.copyWith(isGoldMember: true);

  final testDraft = BookingDraft(
    id: 'draft_test_101',
    showId: 'show_001',
    eventId: 'movie_1',
    venueId: 'venue_1',
    eventTitle: 'Kalki 2898 AD',
    venueName: 'PVR ICON: Phoenix Palladium',
    showTime: DateTime(2026, 10, 15, 19, 30),
    seatIds: const ['A1', 'A2'],
    seatPrices: const [450.0, 450.0],
    isMovie: true,
    isGold: false,
    durationMinutes: 180,
  );

  group('MockPaymentService Tests', () {
    test('MockPaymentService processes successfully', () async {
      const service = MockPaymentService(delay: Duration(milliseconds: 50));
      const request = PaymentRequest(
        orderId: 'test_ord_1',
        amount: 500.0,
        name: 'ShowScape',
        description: 'Kalki 2898 AD Tickets',
        prefillEmail: 'rahul@example.com',
        prefillPhone: '+919876543210',
      );

      final result = await service.openCheckout(request);
      expect(result.isSuccess, isTrue);
      expect(result.paymentId, isNotEmpty);
    });
  });

  group('CheckoutScreen Widget Tests', () {
    testWidgets('renders event summary, price breakdown, and Pay button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Future.value(regularUser)),
        ],
      );

      final draftNotifier = container.read(bookingDraftProvider.notifier);
      draftNotifier.setDraft(testDraft);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const CheckoutScreen(),
          ),
        ),
      );

      await tester.pump();

      // Check event summary
      expect(find.text('Kalki 2898 AD'), findsOneWidget);
      expect(find.text('PVR ICON: Phoenix Palladium'), findsOneWidget);
      expect(find.textContaining('Seats: A1, A2'), findsOneWidget);

      // Check price breakdown items
      expect(find.text('Price Breakdown'), findsOneWidget);
      expect(find.text('Tickets'), findsOneWidget);

      // Check Gold upsell card for non-Gold user
      expect(find.textContaining('Save ₹'), findsWidgets);
      expect(find.textContaining('with Gold'), findsWidgets);

      // Pay button
      expect(find.textContaining('Pay ₹'), findsOneWidget);
      expect(find.textContaining('I agree to the Terms & Conditions'), findsOneWidget);
    });

    testWidgets('Gold user sees fee waived with GoldBadge', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Future.value(goldUser)),
        ],
      );

      final draftNotifier = container.read(bookingDraftProvider.notifier);
      draftNotifier.setDraft(testDraft.copyWith(isGold: true));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const CheckoutScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Waived with Gold'), findsWidgets);
      expect(find.text('GOLD'), findsWidgets);
    });

    testWidgets('Applying coupon SHOW100 applies discount', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Future.value(regularUser)),
        ],
      );

      final draftNotifier = container.read(bookingDraftProvider.notifier);
      draftNotifier.setDraft(testDraft);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const CheckoutScreen(),
          ),
        ),
      );

      await tester.pump();

      // Enter coupon SHOW100
      final couponField = find.byType(TextField);
      expect(couponField, findsOneWidget);
      await tester.enterText(couponField, 'SHOW100');
      await tester.tap(find.text('Apply'));
      await tester.pump();

      // Verify coupon discount appears
      expect(find.textContaining('Discount (SHOW100)'), findsOneWidget);
    });
  });

  group('PaymentResultScreen Widget Tests', () {
    testWidgets('renders success state with ticket stub and action buttons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => Future.value(regularUser)),
          bookingRepositoryProvider.overrideWithValue(MockBookingRepository()),
        ],
      );

      final draftNotifier = container.read(bookingDraftProvider.notifier);
      draftNotifier.setDraft(testDraft);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const PaymentResultScreen(isSuccess: true),
          ),
        ),
      );

      // Pump finite frames to let confirmation future resolve without hanging on lottie/ticker
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('Kalki 2898 AD'), findsOneWidget);
      expect(find.text('Add to Calendar'), findsOneWidget);
      expect(find.text('View Ticket'), findsOneWidget);
      expect(find.text('Complete Your Night'), findsOneWidget);

      // Verify flip ticket stub
      expect(find.text('Tap ticket to flip for venue map & QR pass'), findsOneWidget);
      await tester.tap(find.text('Tap ticket to flip for venue map & QR pass'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Cinema Directions'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renders failure state with retry button and hold timer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const PaymentResultScreen(
              isSuccess: false,
              errorMessage: 'Payment declined by bank.',
              autoStartHoldTimer: false,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Payment Failed'), findsOneWidget);
      expect(find.text('Payment declined by bank.'), findsOneWidget);
      expect(find.text('Retry Payment'), findsOneWidget);
      expect(find.textContaining('Seats Held For:'), findsOneWidget);

      // Clean up timer by unmounting
      await tester.pumpWidget(const SizedBox());
    });
  });
}
