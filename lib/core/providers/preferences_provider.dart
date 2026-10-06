import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/core/utils/app_haptics.dart';

const String appPreferencesBox = 'app_preferences';

String? readPreference(String key) {
  if (!Hive.isBoxOpen(appPreferencesBox)) return null;
  final value = Hive.box<dynamic>(appPreferencesBox).get(key);
  return value is String ? value : null;
}

void writePreference(String key, String value) {
  if (!Hive.isBoxOpen(appPreferencesBox)) return;
  Hive.box<dynamic>(appPreferencesBox).put(key, value);
}

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return readPreference('themeMode') == 'light' ? ThemeMode.light : ThemeMode.dark;
});

final hapticsEnabledProvider = StateProvider<bool>((ref) {
  final enabled = readPreference('haptics') != 'off';
  AppHaptics.enabled = enabled;
  return enabled;
});

void setHapticsEnabled(WidgetRef ref, bool enabled) {
  AppHaptics.enabled = enabled;
  ref.read(hapticsEnabledProvider.notifier).state = enabled;
  writePreference('haptics', enabled ? 'on' : 'off');
  if (enabled) AppHaptics.selection();
}

void setThemeMode(WidgetRef ref, ThemeMode mode) {
  ref.read(themeModeProvider.notifier).state = mode;
  writePreference('themeMode', mode == ThemeMode.light ? 'light' : 'dark');
  AppHaptics.selection();
}
