import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/animated_number_counter.dart';

/// Reusable compact running total bar used across Seats, Food, and Checkout screens.
class PriceSummaryBar extends StatelessWidget {
  final double totalAmount;
  final String label;
  final String? subtitle;
  final String buttonText;
  final IconData? buttonIcon;
  final VoidCallback onButtonPressed;
  final VoidCallback? onDetailsPressed;
  final bool isLoading;
  final bool isButtonEnabled;

  const PriceSummaryBar({
    super.key,
    required this.totalAmount,
    this.label = 'TOTAL PAYABLE',
    this.subtitle,
    required this.buttonText,
    this.buttonIcon = Icons.arrow_forward_rounded,
    required this.onButtonPressed,
    this.onDetailsPressed,
    this.isLoading = false,
    this.isButtonEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: AppRadius.border28,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.94),
              borderRadius: AppRadius.border28,
              border: Border.all(
                color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Price & breakdown trigger
                Expanded(
                  child: GestureDetector(
                    onTap: onDetailsPressed,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              label,
                              style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (onDetailsPressed != null) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: AppColors.spotlightCoral,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        AnimatedCurrencyCounter(
                          amount: totalAmount,
                          style: AppTypography.heading20(color: AppColors.lavender).copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Primary CTA button
                ElevatedButton(
                  onPressed: isButtonEnabled && !isLoading ? onButtonPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.spotlightCoral,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceElevated,
                    disabledForegroundColor: AppColors.lavenderMuted,
                    elevation: 0,
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.border20,
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              buttonText,
                              style: AppTypography.buttonLabel(color: Colors.white).copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (buttonIcon != null) ...[
                              const SizedBox(width: 6),
                              Icon(buttonIcon, size: 16),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
