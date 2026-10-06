import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/explore/presentation/providers/explore_providers.dart';

/// Collapsible TableCalendar widget supporting Week and Month views
/// with coral dot markers on days containing shows/events
class CollapsibleCalendar extends ConsumerStatefulWidget {
  const CollapsibleCalendar({super.key});

  @override
  ConsumerState<CollapsibleCalendar> createState() => _CollapsibleCalendarState();
}

class _CollapsibleCalendarState extends ConsumerState<CollapsibleCalendar> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    // Default focused day matching the mock data shows period (Oct 2026)
    _focusedDay = DateTime(2026, 10, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calendarFormat = ref.watch(calendarFormatProvider);
    final selectedDate = ref.watch(
      exploreFilterNotifierProvider.select((c) => c.selectedDate),
    );
    final eventDatesAsync = ref.watch(calendarEventDatesProvider);

    final eventDatesMap = eventDatesAsync.valueOrNull ?? {};

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row with collapse/expand toggle button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: AppColors.spotlightCoral,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      calendarFormat == CalendarFormat.week
                          ? 'This Week\'s Shows'
                          : 'Monthly Schedule',
                      style: AppTypography.body14(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (selectedDate != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(exploreFilterNotifierProvider.notifier)
                              .setSelectedDate(null);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Clear',
                                style: AppTypography.caption12(
                                  color: AppColors.spotlightCoral,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.close_rounded,
                                size: 12,
                                color: AppColors.spotlightCoral,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Format Toggle Button (Week <-> Month)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    final next = calendarFormat == CalendarFormat.week
                        ? CalendarFormat.month
                        : CalendarFormat.week;
                    ref.read(calendarFormatProvider.notifier).state = next;
                  },
                  icon: Icon(
                    calendarFormat == CalendarFormat.week
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 18,
                    color: AppColors.spotlightCoral,
                  ),
                  label: Text(
                    calendarFormat == CalendarFormat.week ? 'Expand' : 'Collapse',
                    style: AppTypography.caption12(
                      color: AppColors.spotlightCoral,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TableCalendar
          TableCalendar<String>(
            firstDay: DateTime.utc(2026, 1, 1),
            lastDay: DateTime.utc(2027, 12, 31),
            focusedDay: _focusedDay,
            currentDay: DateTime.utc(2026, 10, 1),
            calendarFormat: calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: calendarFormat == CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTypography.body14(
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                size: 20,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                size: 20,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: AppTypography.caption12(
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: AppTypography.caption12(
                color: AppColors.spotlightCoral.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            selectedDayPredicate: (day) {
              if (selectedDate == null) return false;
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              ref
                  .read(exploreFilterNotifierProvider.notifier)
                  .setSelectedDate(selectedDay);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              final normalized = DateTime(day.year, day.month, day.day);
              final eventsSet = eventDatesMap[normalized];
              return eventsSet != null ? eventsSet.toList() : const [];
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              isTodayHighlighted: true,
              todayDecoration: BoxDecoration(
                border: Border.all(color: AppColors.spotlightCoral, width: 1.5),
                shape: BoxShape.circle,
              ),
              todayTextStyle: AppTypography.caption12(
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.spotlightCoral, AppColors.spotlightCoralDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66FF4D6D),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              selectedTextStyle: AppTypography.caption12(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
              defaultTextStyle: AppTypography.caption12(
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
              ),
              weekendTextStyle: AppTypography.caption12(
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              // Coral dot markers for days with events
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return const SizedBox.shrink();

                final isDaySelected = selectedDate != null && isSameDay(selectedDate, day);

                return Positioned(
                  bottom: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      events.length > 3 ? 3 : events.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDaySelected
                              ? Colors.white
                              : AppColors.spotlightCoral,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.spotlightCoral.withValues(alpha: 0.6),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
