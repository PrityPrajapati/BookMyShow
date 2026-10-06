import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';
import 'package:showscape/features/explore/presentation/providers/explore_providers.dart';

/// Horizontal scrollable category pill tabs
class CategoryTabsBar extends ConsumerWidget {
  const CategoryTabsBar({super.key});

  IconData _getIconForCategory(ExploreCategory cat) {
    switch (cat) {
      case ExploreCategory.all:
        return Icons.auto_awesome_rounded;
      case ExploreCategory.movies:
        return Icons.movie_outlined;
      case ExploreCategory.events:
        return Icons.confirmation_number_outlined;
      case ExploreCategory.sports:
        return Icons.sports_cricket_rounded;
      case ExploreCategory.comedy:
        return Icons.sentiment_very_satisfied_rounded;
      case ExploreCategory.dining:
        return Icons.restaurant_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCategory = ref.watch(
      exploreFilterNotifierProvider.select((c) => c.category),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ExploreCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = ExploreCategory.values[index];
          final isSelected = category == currentCategory;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.pill,
              onTap: () {
                ref
                    .read(exploreFilterNotifierProvider.notifier)
                    .setCategory(category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                      : (isDark
                          ? AppColors.surface
                          : AppColors.lightSurface),
                  borderRadius: AppRadius.pill,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.spotlightCoral
                        : (isDark
                            ? AppColors.surfaceBorder
                            : AppColors.lightSurfaceBorder),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.spotlightCoral.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForCategory(category),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.label,
                      style: AppTypography.chipLabel(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.lavender : AppColors.textPrimaryLight),
                      ).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
