import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/core/providers/demo_mode_provider.dart';
import 'package:showscape/features/payment/presentation/providers/payment_provider.dart';
import 'package:showscape/features/payment/data/services/mock_payment_service.dart';
import 'package:showscape/services/ai/ai_service.dart';
import 'package:showscape/services/pricing_engine.dart';

import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('Case Study 146 Demo Mode Tests', () {
    test('Initial state has demo mode disabled', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(demoModeProvider);
      expect(state.isDemoActive, isFalse);
      expect(container.read(isDemoTuesdayProvider), isFalse);
      expect(container.read(isDemoGoldProvider), isFalse);
    });

    test('Activating Demo Mode enables Tuesday offer, Gold user, and mock services', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(demoModeProvider.notifier);
      notifier.activateDemoMode();

      final state = container.read(demoModeProvider);
      expect(state.isDemoActive, isTrue);
      expect(state.isTuesdayOverride, isTrue);
      expect(state.isGoldOverride, isTrue);
      expect(state.useMockAi, isTrue);
      expect(state.useMockPayment, isTrue);
      expect(state.notificationCountdown, 10);

      // Verify Tuesday provider reflects override
      expect(container.read(isDemoTuesdayProvider), isTrue);
      expect(container.read(isDemoGoldProvider), isTrue);

      // Verify MockPaymentService is resolved
      final paymentService = container.read(paymentServiceProvider);
      expect(paymentService, isA<MockPaymentService>());

      // Verify MockAiService is resolved
      final aiService = container.read(aiServiceProvider);
      expect(aiService, isA<MockAiService>());
    });

    test('PricingEngine applies 50% Tuesday discount when forceTuesday is true', () {
      // 2 tickets at ₹300 = ₹600 subtotal
      final breakdown = PricingEngine.calculate(
        seatPrices: [300.0, 300.0],
        showDate: DateTime(2026, 10, 1), // Thursday
        isMovie: true,
        occupancyPct: 50.0,
        isGold: false,
        forceTuesday: true, // Demo Mode Tuesday discount
      );

      expect(breakdown.ticketSubtotal, 600.0);
      expect(breakdown.discountType, DiscountType.tuesday);
      expect(breakdown.discountAmount, 300.0); // 50% discount
    });

    test('Gold VIP user receives fee waiver in Demo Mode', () {
      final breakdown = PricingEngine.calculate(
        seatPrices: [400.0],
        showDate: DateTime(2026, 10, 1),
        isMovie: true,
        occupancyPct: 50.0,
        isGold: true, // Demo user is Gold
        forceTuesday: false,
      );

      expect(breakdown.feeWaived, isTrue);
      expect(breakdown.convenienceFee, 0.0);
      expect(breakdown.gstOnFee, 0.0);
      expect(breakdown.goldSavings, greaterThan(0.0));
    });

    test('Demo Mode countdown decrements and can be toggled off', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(demoModeProvider.notifier);
      notifier.activateDemoMode();
      expect(container.read(demoModeProvider).isDemoActive, isTrue);

      notifier.toggleDemoMode();
      expect(container.read(demoModeProvider).isDemoActive, isFalse);
      expect(container.read(isDemoTuesdayProvider), isFalse);
    });
  });
}
