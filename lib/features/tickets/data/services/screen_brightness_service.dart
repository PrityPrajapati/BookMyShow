import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Service managing high brightness and screen awake states during QR display
class ScreenBrightnessService {
  bool _isMaxBrightnessActive = false;

  bool get isMaxBrightnessActive => _isMaxBrightnessActive;

  /// Elevate screen brightness to maximum and keep screen awake
  Future<void> boostBrightnessAndKeepAwake() async {
    try {
      _isMaxBrightnessActive = true;
      if (!kIsWeb) {
        await ScreenBrightness().setApplicationScreenBrightness(1.0);
      }
      await WakelockPlus.enable();
    } catch (e) {
      debugPrint('ScreenBrightnessService.boostBrightnessAndKeepAwake error: $e');
    }
  }

  /// Restore default screen brightness and allow screen to sleep
  Future<void> restoreBrightnessAndSleep() async {
    try {
      _isMaxBrightnessActive = false;
      if (!kIsWeb) {
        await ScreenBrightness().resetApplicationScreenBrightness();
      }
      await WakelockPlus.disable();
    } catch (e) {
      debugPrint('ScreenBrightnessService.restoreBrightnessAndSleep error: $e');
    }
  }
}

final screenBrightnessServiceProvider = Provider<ScreenBrightnessService>((ref) {
  final service = ScreenBrightnessService();
  ref.onDispose(() {
    service.restoreBrightnessAndSleep();
  });
  return service;
});
