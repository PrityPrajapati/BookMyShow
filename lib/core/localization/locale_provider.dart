import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Supported Locales in ShowScape
abstract final class AppLocales {
  static const Locale english = Locale('en', 'IN');
  static const Locale hindi = Locale('hi', 'IN');

  static const List<Locale> supported = [
    english,
    hindi,
  ];

  static String getDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'en':
      default:
        return 'English (India)';
    }
  }
}

/// Provider managing active app locale (English / Hindi)
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(AppLocales.english) {
    _loadSavedLocale();
  }

  static const _boxName = 'explore_preferences';
  static const _key = 'app_locale_code';

  void _loadSavedLocale() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<dynamic>(_boxName);
        final code = box.get(_key) as String?;
        if (code == 'hi') {
          state = AppLocales.hindi;
        } else if (code == 'en') {
          state = AppLocales.english;
        }
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    state = newLocale;
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<dynamic>(_boxName);
        await box.put(_key, newLocale.languageCode);
      }
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  void toggleLanguage() {
    if (state.languageCode == 'en') {
      setLocale(AppLocales.hindi);
    } else {
      setLocale(AppLocales.english);
    }
  }
}
