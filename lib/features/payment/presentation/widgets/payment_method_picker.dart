import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_palette.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/utils/app_haptics.dart';
import 'package:showscape/features/payment/domain/models/saved_payment_method.dart';
import 'package:showscape/features/payment/presentation/providers/saved_payment_methods_provider.dart';

class PaymentMethodPicker extends ConsumerWidget {
  const PaymentMethodPicker({
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final String? selectedId;
  final ValueChanged<SavedPaymentMethod> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final methods = ref.watch(savedPaymentMethodsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.border20,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay with',
            style: AppTypography.heading18(color: palette.text),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a saved method or add UPI, card, net banking, or a wallet.',
            style: AppTypography.body14(color: palette.textMuted),
          ),
          const SizedBox(height: 12),
          if (methods.isEmpty)
            Text(
              'No saved methods yet.',
              style: AppTypography.body14(color: palette.textMuted),
            )
          else
            ...methods.map((method) {
              final selected = method.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: selected
                      ? AppColors.spotlightCoral.withValues(alpha: 0.12)
                      : palette.surfaceElevated,
                  borderRadius: AppRadius.border12,
                  child: InkWell(
                    borderRadius: AppRadius.border12,
                    onTap: () {
                      AppHaptics.selection();
                      onSelected(method);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Icon(_iconFor(method.channel), color: AppColors.spotlightCoral),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.label,
                                  style: AppTypography.body14(
                                    color: palette.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${method.channelLabel} · ${method.detail}',
                                  style: AppTypography.caption12(color: palette.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (method.isDefault)
                            Text(
                              'Default',
                              style: AppTypography.caption12(color: AppColors.marqueeAmber),
                            ),
                          const SizedBox(width: 8),
                          Icon(
                            selected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: selected ? AppColors.spotlightCoral : palette.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showAddSheet(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add payment method'),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(PaymentChannel channel) {
    switch (channel) {
      case PaymentChannel.upi:
        return Icons.account_balance_rounded;
      case PaymentChannel.card:
        return Icons.credit_card_rounded;
      case PaymentChannel.netBanking:
        return Icons.account_balance_rounded;
      case PaymentChannel.wallet:
        return Icons.account_balance_wallet_rounded;
    }
  }
}

Future<void> showAddPaymentMethodSheet(BuildContext context, WidgetRef ref) {
  return _showAddSheet(context, ref);
}

Future<void> _showAddSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: _AddPaymentMethodSheet(parentRef: ref),
      );
    },
  );
}

class _AddPaymentMethodSheet extends StatefulWidget {
  const _AddPaymentMethodSheet({required this.parentRef});

  final WidgetRef parentRef;

  @override
  State<_AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<_AddPaymentMethodSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _detailController = TextEditingController();
  PaymentChannel _channel = PaymentChannel.upi;

  @override
  void dispose() {
    _detailController.dispose();
    super.dispose();
  }

  String get _detailLabel {
    switch (_channel) {
      case PaymentChannel.upi:
        return 'UPI ID';
      case PaymentChannel.card:
        return 'Card ending';
      case PaymentChannel.netBanking:
        return 'Bank name';
      case PaymentChannel.wallet:
        return 'Wallet number';
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    AppHaptics.medium();
    final detail = _detailController.text.trim();
    final method = SavedPaymentMethod(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      channel: _channel,
      label: _labelFor(_channel, detail),
      detail: detail,
      isDefault: widget.parentRef.read(savedPaymentMethodsProvider).isEmpty,
    );
    widget.parentRef.read(savedPaymentMethodsProvider.notifier).addMethod(method);
    Navigator.of(context).pop();
  }

  String _labelFor(PaymentChannel channel, String detail) {
    switch (channel) {
      case PaymentChannel.upi:
        return 'UPI';
      case PaymentChannel.card:
        return 'Card';
      case PaymentChannel.netBanking:
        return detail;
      case PaymentChannel.wallet:
        return 'Wallet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Material(
      color: palette.surface,
      borderRadius: AppRadius.sheetTop20,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add a payment method', style: AppTypography.heading20(color: palette.text)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaymentChannel.values.map((channel) {
                  final selected = channel == _channel;
                  return ChoiceChip(
                    label: Text(_channelName(channel)),
                    selected: selected,
                    onSelected: (_) {
                      AppHaptics.selection();
                      setState(() => _channel = channel);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailController,
                decoration: InputDecoration(labelText: _detailLabel),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Enter a valid $_detailLabel';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _channelName(PaymentChannel channel) {
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
