import 'package:intl/intl.dart';

/// App-wide formatting helper supporting en_IN and hi_IN
abstract final class AppFormatters {
  /// Format currency with rupee symbol (e.g. ₹1,250)
  static String currency(
    num amount, {
    String? locale,
    int decimalDigits = 0,
    bool showSymbol = true,
  }) {
    final effectiveLocale = locale ?? 'en_IN';
    final formatter = NumberFormat.currency(
      locale: effectiveLocale,
      symbol: showSymbol ? '₹' : '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount).trim();
  }

  /// Format date (e.g. "2 Oct 2026", "2 अक्टू 2026")
  static String date(
    DateTime date, {
    String? locale,
    String pattern = 'd MMM y',
  }) {
    final effectiveLocale = locale ?? 'en_IN';
    return DateFormat(pattern, effectiveLocale).format(date);
  }

  /// Format time (e.g. "7:30 PM", "7:30 अपराह्न")
  static String time(
    DateTime date, {
    String? locale,
  }) {
    final effectiveLocale = locale ?? 'en_IN';
    return DateFormat.jm(effectiveLocale).format(date);
  }

  /// Format date and time combined
  static String dateTime(
    DateTime date, {
    String? locale,
  }) {
    final effectiveLocale = locale ?? 'en_IN';
    return '${DateFormat('d MMM', effectiveLocale).format(date)}, ${DateFormat.jm(effectiveLocale).format(date)}';
  }
}
