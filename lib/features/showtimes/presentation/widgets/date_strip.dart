import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';

/// Horizontal 7-day date selection strip (Today, Tomorrow, Wed 2...) with Tuesday deal highlights
class DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? startDate;

  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.startDate,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = startDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    final isSelectedTuesday = selectedDate.weekday == DateTime.tuesday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 7-day Scrollable Row
        SizedBox(
          height: 88,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final day = days[index];
              final isSelected = _isSameDay(day, selectedDate);
              final isTuesday = day.weekday == DateTime.tuesday;
              final isToday = index == 0;
              final isTomorrow = index == 1;

              String dayLabel;
              if (isToday) {
                dayLabel = 'Today';
              } else if (isTomorrow) {
                dayLabel = 'Tomorrow';
              } else {
                dayLabel = DateFormat('EEE').format(day);
              }

              final dateNumber = DateFormat('d').format(day);
              final monthLabel = DateFormat('MMM').format(day).toUpperCase();

              return Semantics(
                button: true,
                selected: isSelected,
                label: '$dayLabel $dateNumber $monthLabel ${isTuesday ? "Tuesday special deal" : ""}',
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onDateSelected(day);
                  },
                  borderRadius: AppRadius.border16,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 66,
                    padding: const EdgeInsets.symmetric(vertical: 4),
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
                          : (isDark ? AppColors.surface : AppColors.lightSurface),
                      borderRadius: AppRadius.border16,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isTuesday
                                ? AppColors.marqueeAmber.withValues(alpha: 0.5)
                                : (isDark
                                    ? AppColors.surfaceBorder
                                    : AppColors.lightSurfaceBorder)),
                        width: isTuesday && !isSelected ? 1.4 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Weekday label
                        Text(
                          dayLabel,
                          style: AppTypography.caption12(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : (isTuesday
                                    ? AppColors.marqueeAmber
                                    : (isDark
                                        ? AppColors.lavenderMuted
                                        : AppColors.textSecondaryLight)),
                          ).copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Day number
                        Text(
                          dateNumber,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.lavender
                                    : AppColors.textPrimaryLight),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Month label or Tuesday Deal tag
                        if (isTuesday && !isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.marqueeAmber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '50% OFF',
                              style: AppTypography.caption12(
                                color: AppColors.marqueeAmber,
                              ).copyWith(fontSize: 8, fontWeight: FontWeight.w800),
                            ),
                          )
                        else
                          Text(
                            monthLabel,
                            style: AppTypography.caption12(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : (isDark
                                      ? AppColors.lavenderMuted
                                      : AppColors.textSecondaryLight),
                            ).copyWith(fontSize: 9, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Tuesday 50% OFF Banner (shown when a Tuesday is selected)
        if (isSelectedTuesday) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.marqueeAmber.withValues(alpha: 0.2),
                    AppColors.spotlightCoral.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: AppRadius.border12,
                border: Border.all(
                  color: AppColors.marqueeAmber.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.marqueeAmber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: Colors.black,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tuesday Blockbuster Deal: Flat 50% OFF',
                          style: AppTypography.caption12(
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Applied automatically at checkout for all Tuesday shows',
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                          ).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
