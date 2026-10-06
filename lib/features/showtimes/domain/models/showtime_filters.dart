import 'package:showscape/features/showtimes/domain/models/show.dart';

enum TimeOfDayCategory {
  all('All Shows', null, null),
  morning('Morning (< 12 PM)', 0, 12),
  afternoon('Afternoon (12 – 4 PM)', 12, 16),
  evening('Evening (4 – 8 PM)', 16, 20),
  night('Night (> 8 PM)', 20, 24);

  final String label;
  final int? startHour;
  final int? endHour;

  const TimeOfDayCategory(this.label, this.startHour, this.endHour);

  bool matches(DateTime time) {
    if (this == TimeOfDayCategory.all) return true;
    final hour = time.hour;
    return hour >= startHour! && hour < endHour!;
  }
}

class ShowtimeFilters {
  final DateTime selectedDate;
  final ShowFormat? format;
  final String? language;
  final TimeOfDayCategory timeOfDay;

  const ShowtimeFilters({
    required this.selectedDate,
    this.format,
    this.language,
    this.timeOfDay = TimeOfDayCategory.all,
  });

  ShowtimeFilters copyWith({
    DateTime? selectedDate,
    ShowFormat? format,
    bool clearFormat = false,
    String? language,
    bool clearLanguage = false,
    TimeOfDayCategory? timeOfDay,
  }) {
    return ShowtimeFilters(
      selectedDate: selectedDate ?? this.selectedDate,
      format: clearFormat ? null : (format ?? this.format),
      language: clearLanguage ? null : (language ?? this.language),
      timeOfDay: timeOfDay ?? this.timeOfDay,
    );
  }
}
