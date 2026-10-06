import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/features/showtimes/domain/models/showtime_filters.dart';

/// Filter row for format, language, and time of day (Morning <12, Afternoon 12–16, Evening 16–20, Night >20)
class ShowtimeFilterBar extends StatelessWidget {
  final ShowtimeFilters filters;
  final List<String> availableLanguages;
  final ValueChanged<ShowtimeFilters> onFiltersChanged;

  const ShowtimeFilterBar({
    super.key,
    required this.filters,
    required this.availableLanguages,
    required this.onFiltersChanged,
  });

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.spotlightCoral
                : (isDark ? AppColors.surface : AppColors.lightSurface),
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: isSelected
                  ? AppColors.spotlightCoral
                  : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Time of Day Row: Morning (<12), Afternoon (12-16), Evening (16-20), Night (>20)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildChip(
                context: context,
                label: 'All Times',
                isSelected: filters.timeOfDay == TimeOfDayCategory.all,
                onTap: () => onFiltersChanged(
                  filters.copyWith(timeOfDay: TimeOfDayCategory.all),
                ),
              ),
              _buildChip(
                context: context,
                label: 'Morning <12',
                icon: Icons.wb_sunny_outlined,
                isSelected: filters.timeOfDay == TimeOfDayCategory.morning,
                onTap: () => onFiltersChanged(
                  filters.copyWith(timeOfDay: TimeOfDayCategory.morning),
                ),
              ),
              _buildChip(
                context: context,
                label: 'Afternoon 12–16',
                icon: Icons.wb_twilight_rounded,
                isSelected: filters.timeOfDay == TimeOfDayCategory.afternoon,
                onTap: () => onFiltersChanged(
                  filters.copyWith(timeOfDay: TimeOfDayCategory.afternoon),
                ),
              ),
              _buildChip(
                context: context,
                label: 'Evening 16–20',
                icon: Icons.nights_stay_outlined,
                isSelected: filters.timeOfDay == TimeOfDayCategory.evening,
                onTap: () => onFiltersChanged(
                  filters.copyWith(timeOfDay: TimeOfDayCategory.evening),
                ),
              ),
              _buildChip(
                context: context,
                label: 'Night >20',
                icon: Icons.bedtime_rounded,
                isSelected: filters.timeOfDay == TimeOfDayCategory.night,
                onTap: () => onFiltersChanged(
                  filters.copyWith(timeOfDay: TimeOfDayCategory.night),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 2. Format & Language Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // All Formats
              _buildChip(
                context: context,
                label: 'All Formats',
                isSelected: filters.format == null,
                onTap: () => onFiltersChanged(filters.copyWith(clearFormat: true)),
              ),

              // Format chips
              ...ShowFormat.values.map((f) {
                return _buildChip(
                  context: context,
                  label: f.label,
                  isSelected: filters.format == f,
                  onTap: () {
                    final next = filters.format == f ? null : f;
                    onFiltersChanged(
                      filters.copyWith(
                        format: next,
                        clearFormat: next == null,
                      ),
                    );
                  },
                );
              }),

              // Languages
              if (availableLanguages.isNotEmpty) ...[
                const SizedBox(width: 4),
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: Colors.white24,
                ),
                ...availableLanguages.map((lang) {
                  return _buildChip(
                    context: context,
                    label: lang,
                    icon: Icons.translate_rounded,
                    isSelected: filters.language == lang,
                    onTap: () {
                      final next = filters.language == lang ? null : lang;
                      onFiltersChanged(
                        filters.copyWith(
                          language: next,
                          clearLanguage: next == null,
                        ),
                      );
                    },
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
