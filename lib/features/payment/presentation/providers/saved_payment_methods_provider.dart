import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/features/payment/domain/models/saved_payment_method.dart';

class SavedPaymentMethodsNotifier extends Notifier<List<SavedPaymentMethod>> {
  @override
  List<SavedPaymentMethod> build() {
    return const <SavedPaymentMethod>[
      SavedPaymentMethod(
        id: 'pm_upi',
        channel: PaymentChannel.upi,
        label: 'UPI',
        detail: 'prity@oksbi',
        isDefault: true,
      ),
      SavedPaymentMethod(
        id: 'pm_card',
        channel: PaymentChannel.card,
        label: 'Visa',
        detail: '•••• 4242',
        isDefault: false,
      ),
    ];
  }

  void addMethod(SavedPaymentMethod method) {
    final cleared = method.isDefault
        ? state.map((item) => item.copyWith(isDefault: false)).toList()
        : List<SavedPaymentMethod>.from(state);
    state = <SavedPaymentMethod>[...cleared, method];
  }

  void removeMethod(String id) {
    final remaining = state.where((item) => item.id != id).toList();
    if (remaining.isEmpty) {
      state = remaining;
      return;
    }
    final hasDefault = remaining.any((item) => item.isDefault);
    if (!hasDefault) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }
    state = remaining;
  }

  void makeDefault(String id) {
    state = state
        .map((item) => item.copyWith(isDefault: item.id == id))
        .toList();
  }

  void replaceAll(List<SavedPaymentMethod> methods) {
    state = methods;
  }

  void seedDemoMethods() {
    state = build();
  }
}

final savedPaymentMethodsProvider =
    NotifierProvider<SavedPaymentMethodsNotifier, List<SavedPaymentMethod>>(
  SavedPaymentMethodsNotifier.new,
);
