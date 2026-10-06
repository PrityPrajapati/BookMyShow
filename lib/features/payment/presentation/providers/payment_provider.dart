import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/providers/demo_mode_provider.dart';
import 'package:showscape/features/payment/data/services/mock_payment_service.dart';
import 'package:showscape/features/payment/data/services/razorpay_payment_service.dart';
import 'package:showscape/features/payment/domain/services/payment_service.dart';

final isDemoModeProvider = StateProvider<bool>((ref) => true);

final paymentServiceProvider = Provider<PaymentService>((ref) {
  final isLegacyDemo = ref.watch(isDemoModeProvider);
  final demo = ref.watch(demoModeProvider);
  if (kIsWeb || isLegacyDemo || (demo.isDemoActive && demo.useMockPayment)) {
    return const MockPaymentService();
  }
  final service = RazorpayPaymentService();
  ref.onDispose(() => service.dispose());
  return service;
});
