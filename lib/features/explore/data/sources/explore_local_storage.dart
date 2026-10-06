import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';

/// Service for persisting Explore filters and recent searches using Hive
class ExploreLocalStorage {
  static const String boxName = 'explore_preferences';
  static const String keyLastFilters = 'last_filters';
  static const String keyRecentSearches = 'recent_searches';

  // Fallback in-memory storage for test/headless environments
  static final Map<String, dynamic> _memoryCache = {};
  static bool _hiveDisabled = false;

  Box<dynamic>? _box;

  Future<Box<dynamic>?> _getBox() async {
    if (_hiveDisabled) return null;
    if (_box != null && _box!.isOpen) return _box;

    try {
      if (Hive.isBoxOpen(boxName)) {
        _box = Hive.box<dynamic>(boxName);
        return _box;
      }
      _box = await Hive.openBox<dynamic>(boxName);
      return _box;
    } catch (e) {
      _hiveDisabled = true;
      return null;
    }
  }

  /// Save active filter criteria to Hive
  Future<void> saveFilters(ExploreFilterCriteria criteria) async {
    try {
      final jsonString = jsonEncode(criteria.toJson());
      final box = await _getBox();
      if (box != null) {
        await box.put(keyLastFilters, jsonString);
      } else {
        _memoryCache[keyLastFilters] = jsonString;
      }
    } catch (e) {
      debugPrint('Failed to save filters to Hive: $e');
    }
  }

  /// Load persisted filter criteria from Hive
  Future<ExploreFilterCriteria?> loadFilters() async {
    try {
      final box = await _getBox();
      final dynamic raw = box != null
          ? box.get(keyLastFilters)
          : _memoryCache[keyLastFilters];

      if (raw is String && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return ExploreFilterCriteria.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Failed to load filters from Hive: $e');
    }
    return null;
  }

  /// Clear persisted filters from Hive
  Future<void> clearFilters() async {
    try {
      final box = await _getBox();
      if (box != null) {
        await box.delete(keyLastFilters);
      } else {
        _memoryCache.remove(keyLastFilters);
      }
    } catch (e) {
      debugPrint('Failed to clear filters from Hive: $e');
    }
  }

  /// Save a search query to recent searches (deduped, max 10 entries)
  Future<void> saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    try {
      final current = await getRecentSearches();
      final updated = <String>[trimmed];
      for (final item in current) {
        if (item.toLowerCase() != trimmed.toLowerCase()) {
          updated.add(item);
        }
      }
      if (updated.length > 10) {
        updated.removeRange(10, updated.length);
      }

      final box = await _getBox();
      if (box != null) {
        await box.put(keyRecentSearches, updated);
      } else {
        _memoryCache[keyRecentSearches] = updated;
      }
    } catch (e) {
      debugPrint('Failed to save recent search to Hive: $e');
    }
  }

  /// Get list of recent searches
  Future<List<String>> getRecentSearches() async {
    try {
      final box = await _getBox();
      final dynamic raw = box != null
          ? box.get(keyRecentSearches)
          : _memoryCache[keyRecentSearches];

      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Failed to load recent searches from Hive: $e');
    }
    return [];
  }

  /// Remove single recent search entry
  Future<void> removeRecentSearch(String query) async {
    try {
      final current = await getRecentSearches();
      current.removeWhere((item) => item.toLowerCase() == query.trim().toLowerCase());

      final box = await _getBox();
      if (box != null) {
        await box.put(keyRecentSearches, current);
      } else {
        _memoryCache[keyRecentSearches] = current;
      }
    } catch (e) {
      debugPrint('Failed to remove recent search from Hive: $e');
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      final box = await _getBox();
      if (box != null) {
        await box.delete(keyRecentSearches);
      } else {
        _memoryCache.remove(keyRecentSearches);
      }
    } catch (e) {
      debugPrint('Failed to clear recent searches from Hive: $e');
    }
  }
}
