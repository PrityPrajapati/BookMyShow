import 'package:showscape/features/payment/domain/models/payment_request.dart';
import 'package:showscape/features/payment/domain/models/payment_result.dart';

abstract class PaymentService {
  Future<PaymentResult> openCheckout(PaymentRequest request);
  void dispose();
}
