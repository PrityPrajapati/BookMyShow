import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_typography.dart';

/// Occupancy indicator legend: Available (<50%), Filling fast (50-80%), Almost full (>80%), Sold out (100%)
class OccupancyLegend extends StatelessWidget {
  const OccupancyLegend({super.key});

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.caption12(
            color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
          ).copyWith(fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildLegendItem(
                color: AppColors.success,
                label: 'Available (<50%)',
                context: context,
              ),
              _buildLegendItem(
                color: AppColors.marqueeAmber,
                label: 'Filling fast (50–80%)',
                context: context,
              ),
              _buildLegendItem(
                color: AppColors.spotlightCoral,
                label: 'Almost full (>80%)',
                context: context,
              ),
              _buildLegendItem(
                color: Colors.grey,
                label: 'Sold out (100%)',
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
