class PaymentRequest {
  final double amount; // in rupees
  final String orderId;
  final String name;
  final String description;
  final String? prefillEmail;
  final String? prefillPhone;
  final Map<String, String>? notes;

  const PaymentRequest({
    required this.amount,
    required this.orderId,
    required this.name,
    required this.description,
    this.prefillEmail,
    this.prefillPhone,
    this.notes,
  });

  int get amountInPaise => (amount * 100).round();
}
