import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/food/presentation/widgets/indian_diet_badge.dart';

class FnbItemCard extends StatelessWidget {
  final FnbItem item;
  final int cartQuantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final ValueChanged<int> onQuantityChanged;

  const FnbItemCard({
    super.key,
    required this.item,
    this.cartQuantity = 0,
    required this.onTap,
    required this.onAdd,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Dietary badge, title, desc, price, customizable tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IndianDietBadge(isVeg: item.isVeg, size: 14),
                    const SizedBox(width: 8),
                    if (item.rating > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.marqueeAmber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: AppColors.marqueeAmber),
                            const SizedBox(width: 2),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: AppTypography.caption12(color: AppColors.marqueeAmber).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                AppSpacing.vertical8,

                Text(
                  item.name,
                  style: AppTypography.heading20().copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vertical4,

                Text(
                  '₹${item.price.toInt()}',
                  style: AppTypography.heading20(color: AppColors.lavender).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppSpacing.vertical4,

                Text(
                  item.description,
                  style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vertical8,

                // Customizable tag
                Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 12,
                      color: AppColors.spotlightCoral,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Customisable',
                      style: AppTypography.caption12(color: AppColors.spotlightCoral).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Right: Image with Add / Stepper button placed partially over the bottom
          SizedBox(
            width: 110,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.border12,
                      child: SizedBox(
                        width: 110,
                        height: 95,
                        child: CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.surfaceElevated),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceElevated,
                            child: const Icon(Icons.fastfood_rounded, color: AppColors.lavenderMuted),
                          ),
                        ),
                      ),
                    ),

                    // Add Button / Stepper
                    Positioned(
                      bottom: -14,
                      child: cartQuantity == 0
                          ? SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: onAdd,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.spotlightCoral,
                                  elevation: 3,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.r12),
                                    side: const BorderSide(color: AppColors.spotlightCoral, width: 1.2),
                                  ),
                                ),
                                child: Text(
                                  'ADD',
                                  style: AppTypography.buttonLabel(color: AppColors.spotlightCoral).copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.spotlightCoral,
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28),
                                    onPressed: () => onQuantityChanged(cartQuantity - 1),
                                  ),
                                  Text(
                                    '$cartQuantity',
                                    style: AppTypography.caption12(color: Colors.white).copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 14, color: Colors.white),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28),
                                    onPressed: () => onQuantityChanged(cartQuantity + 1),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
