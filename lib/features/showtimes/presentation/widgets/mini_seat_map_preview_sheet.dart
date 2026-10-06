import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/primary_button.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';

/// Mini seat map preview modal showing seat occupancy grid and pricing tiers
class MiniSeatMapPreviewSheet extends StatelessWidget {
  final Show show;
  final String cinemaName;

  const MiniSeatMapPreviewSheet({
    super.key,
    required this.show,
    required this.cinemaName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('h:mm a').format(show.startTime);
    final dateStr = DateFormat('EEE, d MMM').format(show.startTime);

    // Normalize occupancy
    final normalizedOccupancy = show.occupancyPct > 1.0
        ? show.occupancyPct / 100.0
        : show.occupancyPct;
    final pctInt = (normalizedOccupancy * 100).toInt();

    Color statusColor;
    String statusLabel;
    if (normalizedOccupancy >= 1.0) {
      statusColor = Colors.grey;
      statusLabel = 'Sold out';
    } else if (normalizedOccupancy > 0.80) {
      statusColor = AppColors.spotlightCoral;
      statusLabel = 'Almost full';
    } else if (normalizedOccupancy >= 0.50) {
      statusColor = AppColors.marqueeAmber;
      statusLabel = 'Filling fast';
    } else {
      statusColor = AppColors.success;
      statusLabel = 'Available';
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnight : AppColors.lightBackground,
        borderRadius: AppRadius.sheetTop28,
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),

          // Header: Cinema & Show details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cinemaName,
                      style: AppTypography.heading20(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      ).copyWith(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${show.screenName} • $dateStr at $timeStr',
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      show.format.label,
                      style: AppTypography.caption12(
                        color: AppColors.spotlightCoral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Occupancy Status Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              borderRadius: AppRadius.border16,
              border: Border.all(
                color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$statusLabel ($pctInt% Occupied)',
                              style: AppTypography.body14(
                                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mini Seat Map Preview',
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Simulated Screen Curve Indicator
                Center(
                  child: Container(
                    height: 4,
                    width: 180,
                    decoration: BoxDecoration(
                      color: AppColors.spotlightCoral.withValues(alpha: 0.6),
                      borderRadius: AppRadius.pill,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'SCREEN THIS WAY',
                    style: AppTypography.caption12(
                      color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                    ).copyWith(fontSize: 8, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 12),

                // Simulated Mini Seat Grid (8 rows x 16 cols)
                Center(
                  child: SizedBox(
                    width: 260,
                    child: Column(
                      children: List.generate(6, (r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(14, (c) {
                              if (c == 3 || c == 11) {
                                return const SizedBox(width: 10); // Aisle
                              }
                              // Deterministic pseudo-random seed based on row/col and occupancy
                              final isBooked = ((r * 14 + c) * 37) % 100 < pctInt;
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 10,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? (isDark ? Colors.white24 : Colors.black26)
                                      : AppColors.success.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category Prices Chips
          if (show.categoryPrices.isNotEmpty) ...[
            Text(
              'Pricing Tiers',
              style: AppTypography.body14(
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: show.categoryPrices.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    borderRadius: AppRadius.border12,
                    border: Border.all(
                      color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key,
                        style: AppTypography.caption12(
                          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: AppTypography.caption12(
                          color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Primary CTA Button
          PrimaryButton(
            text: normalizedOccupancy >= 1.0 ? 'Show Sold Out' : 'Select Seats',
            icon: const Icon(Icons.event_seat_rounded, size: 18),
            onPressed: normalizedOccupancy >= 1.0
                ? null
                : () {
                    Navigator.of(context).pop();
                    context.push(AppRoutes.seatsPath(show.id));
                  },
          ),
        ],
      ),
    );
  }
}
