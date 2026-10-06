enum PaymentChannel {
  upi,
  card,
  netBanking,
  wallet,
}

class SavedPaymentMethod {
  const SavedPaymentMethod({
    required this.id,
    required this.channel,
    required this.label,
    required this.detail,
    required this.isDefault,
  });

  final String id;
  final PaymentChannel channel;
  final String label;
  final String detail;
  final bool isDefault;

  SavedPaymentMethod copyWith({
    String? id,
    PaymentChannel? channel,
    String? label,
    String? detail,
    bool? isDefault,
  }) {
    return SavedPaymentMethod(
      id: id ?? this.id,
      channel: channel ?? this.channel,
      label: label ?? this.label,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get channelLabel {
    switch (channel) {
      case PaymentChannel.upi:
        return 'UPI';
      case PaymentChannel.card:
        return 'Card';
      case PaymentChannel.netBanking:
        return 'Net banking';
      case PaymentChannel.wallet:
        return 'Wallet';
    }
  }
}
