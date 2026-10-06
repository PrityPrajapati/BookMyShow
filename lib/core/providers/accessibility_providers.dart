import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider for 'Large text & simple mode' accessibility setting
final simpleModeProvider = StateNotifierProvider<SimpleModeNotifier, bool>((ref) {
  return SimpleModeNotifier();
});

class SimpleModeNotifier extends StateNotifier<bool> {
  SimpleModeNotifier() : super(false) {
    _loadSavedState();
  }

  static const _boxName = 'explore_preferences';
  static const _key = 'large_text_simple_mode_enabled';

  void _loadSavedState() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<dynamic>(_boxName);
        state = box.get(_key, defaultValue: false) as bool;
      }
    } catch (_) {}
  }

  Future<void> toggle() async {
    state = !state;
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<dynamic>(_boxName);
        await box.put(_key, state);
      }
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<dynamic>(_boxName);
        await box.put(_key, enabled);
      }
    } catch (_) {}
  }
}
