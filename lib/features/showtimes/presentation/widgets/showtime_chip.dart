import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/features/showtimes/presentation/widgets/mini_seat_map_preview_sheet.dart';

/// Showtime Chip colored by occupancy percentage with Tuesday deal ribbon and Gold presale lock
class ShowtimeChip extends StatelessWidget {
  final Show show;
  final String cinemaName;
  final bool isUserGold;
  final bool isTuesday;

  const ShowtimeChip({
    super.key,
    required this.show,
    required this.cinemaName,
    this.isUserGold = false,
    this.isTuesday = false,
  });

  void _openMiniPreview(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MiniSeatMapPreviewSheet(
        show: show,
        cinemaName: cinemaName,
      ),
    );
  }

  void _handleTap(BuildContext context, bool isSoldOut, bool isLockedPresale) {
    if (isSoldOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This show is sold out. Please select another showtime.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (isLockedPresale) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.dark
              ? AppColors.surface
              : AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.border20),
          title: const Row(
            children: [
              Icon(Icons.lock_rounded, color: AppColors.marqueeAmber, size: 24),
              SizedBox(width: 8),
              Text('Gold Presale Window'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Presale shows are bookable exclusively by ShowScape Gold users until public booking commences.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.marqueeAmber.withValues(alpha: 0.12),
                  borderRadius: AppRadius.border12,
                  border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: AppColors.marqueeAmber),
                    SizedBox(width: 6),
                    Text(
                      'Opens for everyone in 1d 14h',
                      style: TextStyle(
                        color: AppColors.marqueeAmber,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.notifications_active_outlined, size: 14),
              label: const Text('Notify me'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alert saved! We will notify you when public sale opens in 1d 14h.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.marqueeAmber,
                foregroundColor: AppColors.midnight,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.gold);
              },
              child: const Text('Upgrade to Gold', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    context.push(AppRoutes.seatsPath(show.id));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = DateFormat('h:mm a').format(show.startTime);

    // Normalize occupancy
    final normalizedOccupancy = show.occupancyPct > 1.0
        ? show.occupancyPct / 100.0
        : show.occupancyPct;

    final isSoldOut = normalizedOccupancy >= 1.0;
    final isAlmostFull = normalizedOccupancy > 0.80 && !isSoldOut;
    final isFillingFast = normalizedOccupancy >= 0.50 && normalizedOccupancy <= 0.80;

    final isLockedPresale = show.isPresale && !isUserGold;

    // Occupancy color scheme
    Color occupancyColor;
    String statusText;
    if (isSoldOut) {
      occupancyColor = Colors.grey;
      statusText = 'Sold out';
    } else if (isAlmostFull) {
      occupancyColor = AppColors.spotlightCoral;
      statusText = 'Almost full';
    } else if (isFillingFast) {
      occupancyColor = AppColors.marqueeAmber;
      statusText = 'Filling fast';
    } else {
      occupancyColor = AppColors.success;
      statusText = 'Available';
    }

    // Minimum price
    double? minPrice;
    if (show.categoryPrices.isNotEmpty) {
      minPrice = show.categoryPrices.values.reduce(min);
    }

    final cardBg = isSoldOut
        ? (isDark ? Colors.white10 : Colors.black12)
        : (isDark ? AppColors.surface : AppColors.lightSurface);

    return Semantics(
      button: true,
      enabled: !isSoldOut,
      label: 'Showtime $timeStr, ${show.format}, $statusText${minPrice != null ? ', starting at ₹${minPrice.toInt()}' : ''}${show.isPresale ? ', Gold Presale' : ''}',
      child: InkWell(
        onTap: () => _handleTap(context, isSoldOut, isLockedPresale),
        onLongPress: () => _openMiniPreview(context),
        borderRadius: AppRadius.border12,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 100, minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: AppRadius.border12,
              border: Border.all(
                color: isSoldOut
                    ? Colors.transparent
                    : occupancyColor.withValues(alpha: isDark ? 0.7 : 0.9),
                width: 1.2,
              ),
              boxShadow: !isSoldOut
                  ? [
                      BoxShadow(
                        color: occupancyColor.withValues(alpha: isDark ? 0.12 : 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Showtime (e.g. 10:30 AM)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: isSoldOut
                            ? (isDark ? Colors.white38 : Colors.black38)
                            : (isDark ? AppColors.lavender : AppColors.textPrimaryLight),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    if (isLockedPresale) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.lock_rounded,
                        size: 13,
                        color: AppColors.marqueeAmber,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),

                // 2. Format & Language Pill
                Text(
                  '${show.format.label} • ${show.language}',
                  style: AppTypography.caption12(
                    color: isSoldOut
                        ? (isDark ? Colors.white24 : Colors.black26)
                        : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                  ).copyWith(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // 3. Occupancy Status dot + text or Presale Countdown
                if (isLockedPresale)
                  const Text(
                    'Opens in 1d 14h',
                    style: TextStyle(
                      color: AppColors.marqueeAmber,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: occupancyColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: occupancyColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                // 4. Starting price (if present)
                if (minPrice != null && !isSoldOut) ...[
                  const SizedBox(height: 2),
                  Text(
                    '₹${minPrice.toInt()}',
                    style: AppTypography.caption12(
                      color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                    ).copyWith(fontSize: 9),
                  ),
                ],
              ],
            ),
          ),

          // Tuesday 50% OFF ribbon at top-right
          if (isTuesday && !isSoldOut)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.marqueeAmber, AppColors.spotlightCoral],
                  ),
                  borderRadius: AppRadius.pill,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.marqueeAmber.withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Text(
                  '50% OFF',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
