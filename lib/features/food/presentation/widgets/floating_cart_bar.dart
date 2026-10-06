import 'package:flutter/material.dart';
import 'package:showscape/core/widgets/price_summary_bar.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';

class FloatingCartBar extends StatelessWidget {
  final List<FnbCartItem> items;
  final VoidCallback onProceed;
  final VoidCallback? onViewDetails;

  const FloatingCartBar({
    super.key,
    required this.items,
    required this.onProceed,
    this.onViewDetails,
  });

  int get totalCount => items.fold<int>(0, (sum, i) => sum + i.quantity);
  double get totalPrice => items.fold<double>(0.0, (sum, i) => sum + i.totalPrice);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return PriceSummaryBar(
      totalAmount: totalPrice,
      label: '$totalCount ${totalCount == 1 ? 'ITEM' : 'ITEMS'} ADDED',
      buttonText: 'Add to booking',
      buttonIcon: Icons.arrow_forward_rounded,
      onButtonPressed: onProceed,
      onDetailsPressed: onViewDetails,
    );
  }
}
