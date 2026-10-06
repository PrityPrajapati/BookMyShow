import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/event_detail/domain/models/format_info.dart';
import 'package:showscape/features/event_detail/presentation/widgets/format_explanation_sheet.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';

/// Formats row with price deltas relative to 2D at nearest cinema and info modal trigger
class FormatChipsSection extends ConsumerStatefulWidget {
  final List<Show> shows;
  final String? nearestCinemaName;
  final ValueChanged<String>? onFormatSelected;

  const FormatChipsSection({
    super.key,
    required this.shows,
    this.nearestCinemaName,
    this.onFormatSelected,
  });

  @override
  ConsumerState<FormatChipsSection> createState() => _FormatChipsSectionState();
}

class _FormatChipsSectionState extends ConsumerState<FormatChipsSection> {
  String _selectedFormatId = '2D';

  /// Calculate price delta versus 2D from real shows or fallback to format baseline
  Map<String, String> _computePriceDeltas() {
    double? basePrice2D;

    // Check if 2D shows exist
    final shows2D = widget.shows.where((s) => s.format == ShowFormat.twoD).toList();
    if (shows2D.isNotEmpty) {
      final all2DPrices = <double>[];
      for (final s in shows2D) {
        all2DPrices.addAll(s.categoryPrices.values);
      }
      if (all2DPrices.isNotEmpty) {
        all2DPrices.sort();
        basePrice2D = all2DPrices.first;
      }
    }
    basePrice2D ??= 250.0;

    final Map<String, String> labels = {};

    for (final fmt in FormatInfo.allFormats) {
      if (fmt.id == '2D') {
        labels[fmt.id] = '2D (Base)';
        continue;
      }

      // Look for matching shows of this format
      ShowFormat? targetEnum;
      switch (fmt.id) {
        case '3D':
          targetEnum = ShowFormat.threeD;
          break;
        case 'IMAX 2D':
          targetEnum = ShowFormat.imax2D;
          break;
        case 'IMAX 3D':
          targetEnum = ShowFormat.imax3D;
          break;
        case '4DX':
          targetEnum = ShowFormat.fourDX;
          break;
      }

      final fmtShows = widget.shows.where((s) => s.format == targetEnum).toList();
      if (fmtShows.isNotEmpty) {
        final prices = <double>[];
        for (final s in fmtShows) {
          prices.addAll(s.categoryPrices.values);
        }
        if (prices.isNotEmpty) {
          prices.sort();
          final minPrice = prices.first;
          final delta = (minPrice - basePrice2D).round();
          if (delta > 0) {
            labels[fmt.id] = '${fmt.id} (+₹$delta)';
          } else {
            labels[fmt.id] = '${fmt.id} (Base)';
          }
          continue;
        }
      }

      // Default curated delta
      labels[fmt.id] = '${fmt.id} (${fmt.tag})';
    }

    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labels = _computePriceDeltas();
    final cinemaName = widget.nearestCinemaName ?? 'PVR INOX: Phoenix Palladium';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          // Header with info icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.layers_outlined,
                    size: 18,
                    color: AppColors.spotlightCoral,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Experience Formats & Pricing',
                    style: AppTypography.body14(
                      color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, size: 18),
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: 'Format Guide',
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const FormatExplanationSheet(),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Nearest cinema price reference tag
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Pricing comparison at $cinemaName (Nearest)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption12(
                    color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                  ).copyWith(fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Chips Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FormatInfo.allFormats.map((fmt) {
              final isSelected = _selectedFormatId == fmt.id;
              final chipLabelText = labels[fmt.id] ?? fmt.id;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadius.pill,
                  onTap: () {
                    setState(() {
                      _selectedFormatId = fmt.id;
                    });
                    widget.onFormatSelected?.call(fmt.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [
                                AppColors.spotlightCoral,
                                AppColors.spotlightCoralDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? AppColors.midnight : AppColors.lightBackground),
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.spotlightCoral
                            : (isDark
                                ? AppColors.surfaceBorder
                                : AppColors.lightSurfaceBorder),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.spotlightCoral.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          fmt.icon,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          chipLabelText,
                          style: AppTypography.caption12(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.lavender : AppColors.textPrimaryLight),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
