import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/features/explore/domain/models/app_mood.dart';
import 'package:showscape/features/explore/presentation/providers/explore_providers.dart';

/// Quick horizontal mood filter chips bar for the Explore screen
class ExploreMoodChipsBar extends ConsumerWidget {
  const ExploreMoodChipsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(exploreFilterNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: AppMood.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mood = AppMood.values[index];
          final isSelected = criteria.moods.contains(mood.id);

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              ref
                  .read(exploreFilterNotifierProvider.notifier)
                  .toggleMood(mood.id);
            },
            borderRadius: AppRadius.pill,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.spotlightCoral
                    : (isDark
                        ? AppColors.surface
                        : AppColors.lightSurfaceElevated),
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: isSelected
                      ? AppColors.spotlightCoral
                      : (isDark
                          ? AppColors.surfaceBorder
                          : AppColors.lightSurfaceBorder),
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              AppColors.spotlightCoral.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    mood.label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.lavender
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
