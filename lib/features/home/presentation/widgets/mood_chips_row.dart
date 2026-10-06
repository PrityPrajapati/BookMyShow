import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/features/home/presentation/providers/home_providers.dart';

class MoodChipsRow extends ConsumerWidget {
  const MoodChipsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMood = ref.watch(selectedMoodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: availableMoodTags.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (moodName, emoji) = availableMoodTags[index];
          final isSelected = activeMood == moodName;

          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              if (isSelected) {
                ref.read(selectedMoodProvider.notifier).state = null;
              } else {
                ref.read(selectedMoodProvider.notifier).state = moodName;
              }
            },
            borderRadius: AppRadius.pill,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    moodName,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
