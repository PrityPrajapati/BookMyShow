import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/primary_button.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

/// Sticky bottom navigation bar with starting price label and primary 'Book tickets' button
class StickyBookingBar extends StatelessWidget {
  final Event event;
  final double startingPrice;
  final VoidCallback onBookPressed;

  const StickyBookingBar({
    super.key,
    required this.event,
    required this.startingPrice,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Starting price & subtitle
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'from ',
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      currencyFormatter.format(startingPrice),
                      style: AppTypography.heading20(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      ).copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  event.type == EventType.movie
                      ? 'In standard & premium formats'
                      : (event.type == EventType.sports
                          ? 'Per ticket (Includes taxes)'
                          : 'Early bird & VIP available'),
                  style: AppTypography.caption12(
                    color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Primary Book Tickets Button
          PrimaryButton(
            text: 'Book tickets',
            width: 160,
            icon: const Icon(
              Icons.confirmation_number_outlined,
              size: 18,
              color: Colors.white,
            ),
            onPressed: onBookPressed,
          ),
        ],
      ),
    );
  }
}
