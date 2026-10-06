import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed storage service for event mood tags (chill, laugh, thrill, date_night, family, music)
class EventMoodStorage {
  static const String boxName = 'event_mood_tags_cache';
  Box<dynamic>? _box;

  EventMoodStorage();

  Future<Box<dynamic>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<dynamic>(boxName);
      return _box!;
    }
    _box = await Hive.openBox<dynamic>(boxName);
    return _box!;
  }

  /// Get stored canonical moods for an event, or null if not yet tagged
  Future<List<String>?> getStoredMoods(String eventId) async {
    try {
      final box = await _getBox();
      final raw = box.get('moods_$eventId');
      if (raw == null) return null;
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return null;
    } catch (e) {
      debugPrint('[EventMoodStorage] Error reading moods for $eventId: $e');
      return null;
    }
  }

  /// Store canonical moods for an event
  Future<void> storeMoods(String eventId, List<String> moods) async {
    try {
      final box = await _getBox();
      await box.put('moods_$eventId', moods);
    } catch (e) {
      debugPrint('[EventMoodStorage] Error saving moods for $eventId: $e');
    }
  }

  /// Store batch canonical moods in one operation
  Future<void> storeBatch(Map<String, List<String>> map) async {
    try {
      final box = await _getBox();
      final entries = {
        for (final entry in map.entries) 'moods_${entry.key}': entry.value,
      };
      await box.putAll(entries);
    } catch (e) {
      debugPrint('[EventMoodStorage] Error batch saving moods: $e');
    }
  }

  /// Retrieve all stored mood mappings
  Future<Map<String, List<String>>> getAllStoredMoods() async {
    try {
      final box = await _getBox();
      final map = <String, List<String>>{};
      for (final key in box.keys) {
        final k = key.toString();
        if (k.startsWith('moods_')) {
          final eventId = k.substring('moods_'.length);
          final raw = box.get(k);
          if (raw is List) {
            map[eventId] = raw.map((e) => e.toString()).toList();
          }
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// Clear moods for specific event
  Future<void> clearMoods(String eventId) async {
    try {
      final box = await _getBox();
      await box.delete('moods_$eventId');
    } catch (_) {}
  }

  /// Clear all stored moods (for debug screen)
  Future<void> clearAll() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (_) {}
  }
}
