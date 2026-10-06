import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/explore/domain/models/app_mood.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';
import 'package:showscape/features/explore/presentation/providers/explore_providers.dart';

/// Removable chips row displaying all currently active filter criteria with 'Clear all'
class ActiveFilterChips extends ConsumerWidget {
  const ActiveFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(exploreFilterNotifierProvider);
    final notifier = ref.read(exploreFilterNotifierProvider.notifier);

    final chips = <Widget>[];

    // 1. Calendar Selected Date
    if (criteria.selectedDate != null) {
      final dateStr = DateFormat('EEE, d MMM').format(criteria.selectedDate!);
      chips.add(
        _FilterChipItem(
          label: '📅 $dateStr',
          onRemove: () => notifier.removeFilter('date'),
        ),
      );
    }

    // 2. Custom Date Range
    if (criteria.startDate != null || criteria.endDate != null) {
      final start = criteria.startDate != null
          ? DateFormat('d MMM').format(criteria.startDate!)
          : 'Any';
      final end = criteria.endDate != null
          ? DateFormat('d MMM').format(criteria.endDate!)
          : 'Any';
      chips.add(
        _FilterChipItem(
          label: '$start – $end',
          onRemove: () => notifier.removeFilter('dateRange'),
        ),
      );
    }

    // 3. Languages
    for (final lang in criteria.languages) {
      chips.add(
        _FilterChipItem(
          label: lang,
          onRemove: () => notifier.removeFilter('language', lang),
        ),
      );
    }

    // 4. Genres
    for (final genre in criteria.genres) {
      chips.add(
        _FilterChipItem(
          label: genre,
          onRemove: () => notifier.removeFilter('genre', genre),
        ),
      );
    }

    // 4b. Moods
    for (final moodId in criteria.moods) {
      final appMood = AppMood.tryFrom(moodId);
      final label = appMood != null ? '${appMood.emoji} ${appMood.label}' : moodId;
      chips.add(
        _FilterChipItem(
          label: label,
          onRemove: () => notifier.removeFilter('mood', moodId),
        ),
      );
    }

    // 5. Price Range
    if (criteria.minPrice > 0 || criteria.maxPrice < 10000) {
      final minStr = '₹${criteria.minPrice.toInt()}';
      final maxStr = '₹${criteria.maxPrice.toInt()}';
      chips.add(
        _FilterChipItem(
          label: '$minStr – $maxStr',
          onRemove: () => notifier.removeFilter('price'),
        ),
      );
    }

    // 6. Max Distance
    if (criteria.maxDistanceKm != null) {
      chips.add(
        _FilterChipItem(
          label: 'Within ${criteria.maxDistanceKm!.toInt()} km',
          onRemove: () => notifier.removeFilter('distance'),
        ),
      );
    }

    // 7. Formats
    for (final fmt in criteria.formats) {
      chips.add(
        _FilterChipItem(
          label: fmt,
          onRemove: () => notifier.removeFilter('format', fmt),
        ),
      );
    }

    // 8. Age Ratings
    for (final age in criteria.ageRatings) {
      chips.add(
        _FilterChipItem(
          label: age,
          onRemove: () => notifier.removeFilter('ageRating', age),
        ),
      );
    }

    // 9. Sort (if not relevance)
    if (criteria.sortBy != ExploreSortBy.relevance) {
      chips.add(
        _FilterChipItem(
          label: criteria.sortBy.label,
          onRemove: () => notifier.removeFilter('sort'),
        ),
      );
    }

    // 10. Search query
    if (criteria.searchQuery.trim().isNotEmpty) {
      chips.add(
        _FilterChipItem(
          label: '"${criteria.searchQuery.trim()}"',
          onRemove: () => notifier.removeFilter('query'),
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Clear all button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: AppRadius.pill,
              onTap: () => notifier.clearAllFilters(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                  border: Border.all(
                    color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: AppColors.spotlightCoral,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clear all',
                      style: AppTypography.caption12(
                        color: AppColors.spotlightCoral,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // All active filter chips
          ...chips.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: c,
              )),
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChipItem({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: AppColors.spotlightCoral.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.caption12(
              color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.black12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 12,
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
