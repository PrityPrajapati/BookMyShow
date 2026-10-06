import 'package:flutter/material.dart';

/// Motion & Animation configuration utility
/// Respects system "Reduce Motion" setting and caps animations ≤ 350ms
abstract final class AppMotion {
  /// Maximum duration for standard UI animations (≤ 350 ms)
  static const Duration maxStandardDuration = Duration(milliseconds: 350);

  /// Quick feedback duration (e.g. tap pop, seat bounce)
  static const Duration quick = Duration(milliseconds: 180);

  /// Standard transition duration (fade, slide, shared axis)
  static const Duration standard = Duration(milliseconds: 280);

  /// Stagger interval for list items
  static const Duration staggerDelay = Duration(milliseconds: 40);

  /// Check if animations should be disabled or reduced
  static bool isReduceMotion(BuildContext context) {
    return MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  }

  /// Get effective duration respecting Reduce Motion
  static Duration duration(
    BuildContext context,
    Duration requested, {
    bool isCelebratory = false,
  }) {
    if (isReduceMotion(context)) {
      return Duration.zero;
    }
    if (isCelebratory) {
      return requested;
    }
    return requested > maxStandardDuration ? maxStandardDuration : requested;
  }
}
