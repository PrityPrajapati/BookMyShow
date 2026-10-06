import 'package:flutter/material.dart';
import 'package:showscape/core/utils/formatters.dart';
import 'package:showscape/core/utils/motion_utils.dart';

/// Animated Number Counter with Currency Formatting
/// Animates smoothly between numeric values in ≤ 300ms
class AnimatedCurrencyCounter extends StatelessWidget {
  const AnimatedCurrencyCounter({
    required this.amount,
    super.key,
    this.style,
    this.currencySymbol = '₹',
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOutCubic,
    this.locale,
  });

  final num amount;
  final TextStyle? style;
  final String currencySymbol;
  final Duration duration;
  final Curve curve;
  final String? locale;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isReduceMotion(context)) {
      return Text(
        AppFormatters.currency(amount, locale: locale, showSymbol: currencySymbol.isNotEmpty),
        style: style,
      );
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('currency_counter_${amount.toInt()}'),
      tween: Tween<double>(begin: 0, end: amount.toDouble()),
      duration: duration > AppMotion.maxStandardDuration
          ? AppMotion.maxStandardDuration
          : duration,
      curve: curve,
      builder: (context, value, child) {
        return Text(
          AppFormatters.currency(value.round(), locale: locale, showSymbol: currencySymbol.isNotEmpty),
          style: style,
        );
      },
    );
  }
}

/// Generic animated integer counter (e.g. for ticket counts, items)
class AnimatedIntegerCounter extends StatelessWidget {
  const AnimatedIntegerCounter({
    required this.count,
    super.key,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutQuad,
  });

  final int count;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.isReduceMotion(context)) {
      return Text('$prefix$count$suffix', style: style);
    }

    return TweenAnimationBuilder<double>(
      key: ValueKey('int_counter_$count'),
      tween: Tween<double>(begin: 0, end: count.toDouble()),
      duration: duration > AppMotion.maxStandardDuration
          ? AppMotion.maxStandardDuration
          : duration,
      curve: curve,
      builder: (context, value, child) {
        return Text(
          '$prefix${value.round()}$suffix',
          style: style,
        );
      },
    );
  }
}
