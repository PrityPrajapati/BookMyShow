import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:showscape/features/payment/domain/models/payment_request.dart';
import 'package:showscape/features/payment/domain/models/payment_result.dart';
import 'package:showscape/features/payment/domain/services/payment_service.dart';

class RazorpayPaymentService implements PaymentService {
  final Razorpay _razorpay;
  Completer<PaymentResult>? _completer;

  // Razorpay Test Mode Key
  static const String testApiKey = 'rzp_test_showscape_demo';

  RazorpayPaymentService({Razorpay? customRazorpay})
      : _razorpay = customRazorpay ?? Razorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(
        PaymentResult.success(
          paymentId: response.paymentId ?? 'pay_${DateTime.now().millisecondsSinceEpoch}',
          signature: response.signature,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(
        PaymentResult.failure(
          code: response.code ?? -1,
          message: response.message ?? 'Payment failed or was cancelled.',
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(
        PaymentResult.success(
          paymentId: 'wallet_${response.walletName}_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
    }
  }

  @override
  Future<PaymentResult> openCheckout(PaymentRequest request) async {
    _completer = Completer<PaymentResult>();

    final options = {
      'key': testApiKey,
      'amount': request.amountInPaise,
      'name': request.name,
      'description': request.description,
      'prefill': {
        'contact': request.prefillPhone ?? '9876543210',
        'email': request.prefillEmail ?? 'guest@showscape.in',
      },
      'notes': request.notes ?? {},
      'theme': {
        'color': '#FF4D6D', // AppColors.spotlightCoral
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      return PaymentResult.failure(
        code: -1,
        message: 'Unable to launch Razorpay gateway: $e',
      );
    }

    return _completer!.future;
  }

  @override
  void dispose() {
    _razorpay.clear();
  }
}
