import 'package:flutter/services.dart';
import 'package:showscape/core/utils/haptics_platform_stub.dart'
    if (dart.library.js_interop) 'package:showscape/core/utils/haptics_platform_web.dart';

/// Shared haptic feedback. Native devices use the platform vibrator.
/// Web falls back to the Vibration API when the browser supports it.
abstract final class AppHaptics {
  static bool enabled = true;

  static void selection() => _play(HapticFeedback.selectionClick, 10);

  static void light() => _play(HapticFeedback.lightImpact, 15);

  static void medium() => _play(HapticFeedback.mediumImpact, 25);

  static void heavy() => _play(HapticFeedback.heavyImpact, 40);

  static void _play(void Function() native, int webMilliseconds) {
    if (!enabled) return;
    native();
    vibratePlatform(webMilliseconds);
  }
}
