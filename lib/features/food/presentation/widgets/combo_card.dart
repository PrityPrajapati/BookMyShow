import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/food/domain/models/fnb_combo.dart';
import 'package:showscape/features/food/presentation/widgets/indian_diet_badge.dart';

class ComboCard extends StatelessWidget {
  final FnbCombo combo;
  final int quantity;
  final bool isRecommended;
  final bool isPickedForYou;
  final int recommendedSeatCount;
  final VoidCallback onAdd;
  final ValueChanged<int> onQuantityChanged;

  const ComboCard({
    super.key,
    required this.combo,
    this.quantity = 0,
    this.isRecommended = false,
    this.isPickedForYou = false,
    this.recommendedSeatCount = 4,
    required this.onAdd,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final itemsSum = combo.items.fold<double>(
      0.0,
      (sum, item) => sum + item.price,
    );
    final originalPrice = (combo.originalPrice != null && combo.originalPrice! > combo.comboPrice)
        ? combo.originalPrice!
        : (itemsSum > combo.comboPrice ? itemsSum : combo.comboPrice);

    final savings = originalPrice > combo.comboPrice ? (originalPrice - combo.comboPrice) : 0.0;
    final savingsPct = originalPrice > 0 ? ((savings / originalPrice) * 100).round() : 0;

    final isAllVeg = combo.items.isEmpty || combo.items.every((item) => item.isVeg);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: (isPickedForYou || isRecommended)
              ? AppColors.marqueeAmber.withValues(alpha: 0.8)
              : AppColors.surfaceBorder,
          width: (isPickedForYou || isRecommended) ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (isPickedForYou || isRecommended)
            BoxShadow(
              color: AppColors.marqueeAmber.withValues(alpha: 0.22),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Hero Image with overlays
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: combo.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Icon(
                      Icons.fastfood_rounded,
                      size: 48,
                      color: AppColors.lavenderMuted,
                    ),
                  ),
                ),
              ),

              // Gradient Overlay at bottom of image
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Picked for you / Recommended for X Badge
              if (isPickedForYou || isRecommended)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.marqueeAmber, AppColors.spotlightCoral],
                      ),
                      borderRadius: AppRadius.pill,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.marqueeAmber.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPickedForYou ? 'Picked for you' : 'Recommended for $recommendedSeatCount',
                          style: AppTypography.caption12(color: Colors.black).copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Veg / Non-veg marker on top-right
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IndianDietBadge(isVeg: isAllVeg, size: 14),
                ),
              ),

              // Savings green badge on image bottom-left: 'Save ₹120 (23%)'
              if (savings > 0)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'Save ₹${savings.toInt()} ($savingsPct%)',
                      style: AppTypography.caption12(color: Colors.white).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  combo.name,
                  style: AppTypography.heading20().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.vertical8,

                // Items included
                if (combo.items.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: AppRadius.border12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: combo.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IndianDietBadge(isVeg: item.isVeg, size: 10),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: AppTypography.caption12(color: AppColors.lavenderMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  AppSpacing.vertical12,
                ] else if (combo.description.isNotEmpty) ...[
                  Text(
                    combo.description,
                    style: AppTypography.body14(color: AppColors.lavenderMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vertical12,
                ],

                // Price Row and Quantity Stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Prices
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${combo.comboPrice.toInt()}',
                          style: AppTypography.heading24(color: AppColors.lavender),
                        ),
                        if (savings > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '₹${originalPrice.toInt()}',
                            style: AppTypography.body14(color: AppColors.lavenderMuted).copyWith(
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.lavenderMuted,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Add or Quantity Stepper
                    if (quantity == 0)
                      SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: onAdd,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.spotlightCoral.withOpacity(0.12),
                            foregroundColor: AppColors.spotlightCoral,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.border12,
                              side: const BorderSide(
                                color: AppColors.spotlightCoral,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'ADD',
                                style: AppTypography.buttonLabel(color: AppColors.spotlightCoral).copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.spotlightCoral,
                          borderRadius: AppRadius.border12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              constraints: const BoxConstraints(minWidth: 36),
                              onPressed: () => onQuantityChanged(quantity - 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '$quantity',
                                style: AppTypography.body16(color: Colors.white, fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16, color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              constraints: const BoxConstraints(minWidth: 36),
                              onPressed: () => onQuantityChanged(quantity + 1),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
