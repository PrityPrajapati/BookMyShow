import 'dart:async';
import 'package:showscape/features/payment/domain/models/payment_request.dart';
import 'package:showscape/features/payment/domain/models/payment_result.dart';
import 'package:showscape/features/payment/domain/services/payment_service.dart';

/// Mock payment service that simulates payment gateway processing with 1.5s delay
class MockPaymentService implements PaymentService {
  final bool shouldSucceed;
  final Duration delay;

  const MockPaymentService({
    this.shouldSucceed = true,
    this.delay = const Duration(milliseconds: 1500),
  });

  @override
  Future<PaymentResult> openCheckout(PaymentRequest request) async {
    // Simulate gateway roundtrip: default 1.5 seconds delay
    await Future<void>.delayed(delay);

    if (shouldSucceed) {
      final mockPaymentId =
          'pay_mock_${DateTime.now().millisecondsSinceEpoch}_${request.orderId}';
      return PaymentResult.success(
        paymentId: mockPaymentId,
        signature: 'sig_mock_verified',
      );
    } else {
      return PaymentResult.failure(
        code: 400,
        message: 'Payment declined by bank or user cancelled simulation.',
      );
    }
  }

  @override
  void dispose() {}
}
