class PaymentResult {
  final bool isSuccess;
  final String? paymentId;
  final String? signature;
  final int? errorCode;
  final String? errorMessage;

  const PaymentResult({
    required this.isSuccess,
    this.paymentId,
    this.signature,
    this.errorCode,
    this.errorMessage,
  });

  factory PaymentResult.success({
    required String paymentId,
    String? signature,
  }) {
    return PaymentResult(
      isSuccess: true,
      paymentId: paymentId,
      signature: signature,
    );
  }

  factory PaymentResult.failure({
    required int code,
    required String message,
  }) {
    return PaymentResult(
      isSuccess: false,
      errorCode: code,
      errorMessage: message,
    );
  }
}
