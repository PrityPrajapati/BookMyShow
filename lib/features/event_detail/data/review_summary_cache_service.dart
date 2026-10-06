import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:showscape/features/event_detail/domain/models/event_review_summary.dart';

/// Hive-backed caching service for AI review summaries:
/// Caches exactly per event per day. Key: summary_${eventId}_${yyyyMMdd}
class ReviewSummaryCacheService {
  static const String boxName = 'ai_review_summary_cache';
  Box<dynamic>? _box;

  ReviewSummaryCacheService();

  Future<Box<dynamic>> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box<dynamic>(boxName);
      return _box!;
    }
    _box = await Hive.openBox<dynamic>(boxName);
    return _box!;
  }

  /// Formats date to yyyyMMdd for daily cache partition
  String getDayKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateFormat('yyyyMMdd').format(d);
  }

  String _buildKey(String eventId, [DateTime? date]) {
    return 'summary_${eventId}_${getDayKey(date)}';
  }

  /// Retrieve summary cached for event today (or specific date)
  Future<EventReviewSummary?> getCachedSummary(
    String eventId, [
    DateTime? date,
  ]) async {
    try {
      final box = await _getBox();
      final key = _buildKey(eventId, date);
      final raw = box.get(key);
      if (raw == null) return null;

      if (raw is String) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return EventReviewSummary.fromJson(decoded);
      } else if (raw is Map) {
        return EventReviewSummary.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    } catch (e) {
      debugPrint('[ReviewSummaryCache] Error reading cache for $eventId: $e');
      return null;
    }
  }

  /// Save summary cached for event today (or specific date)
  Future<void> cacheSummary(
    EventReviewSummary summary, [
    DateTime? date,
  ]) async {
    try {
      final box = await _getBox();
      final key = _buildKey(summary.eventId, date);
      await box.put(key, jsonEncode(summary.toJson()));
    } catch (e) {
      debugPrint('[ReviewSummaryCache] Error caching summary: $e');
    }
  }

  /// Clear cached summary for a specific event (all days or today)
  Future<void> clearSummary(String eventId) async {
    try {
      final box = await _getBox();
      final prefix = 'summary_${eventId}_';
      final keysToDelete = box.keys
          .where((k) => k.toString().startsWith(prefix))
          .toList();
      for (final k in keysToDelete) {
        await box.delete(k);
      }
    } catch (e) {
      debugPrint('[ReviewSummaryCache] Error clearing cache for $eventId: $e');
    }
  }

  /// Clear all cached summaries (for debug screen)
  Future<void> clearAll() async {
    try {
      final box = await _getBox();
      await box.clear();
    } catch (e) {
      debugPrint('[ReviewSummaryCache] Error clearing all: $e');
    }
  }

  /// Check if summary is already cached for today
  Future<bool> isCachedToday(String eventId, [DateTime? date]) async {
    try {
      final box = await _getBox();
      final key = _buildKey(eventId, date);
      return box.containsKey(key);
    } catch (_) {
      return false;
    }
  }

  /// Get all event IDs that currently have a cache entry today
  Future<List<String>> getCachedEventIdsForToday([DateTime? date]) async {
    try {
      final box = await _getBox();
      final suffix = '_${getDayKey(date)}';
      final eventIds = <String>[];
      for (final key in box.keys) {
        final k = key.toString();
        if (k.startsWith('summary_') && k.endsWith(suffix)) {
          final id = k.substring('summary_'.length, k.length - suffix.length);
          eventIds.add(id);
        }
      }
      return eventIds;
    } catch (_) {
      return [];
    }
  }
}
