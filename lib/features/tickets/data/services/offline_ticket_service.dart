import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';

/// Service responsible for offline caching of bookings, tickets, and QR payloads in Hive
class OfflineTicketService {
  static const String boxName = 'offline_tickets_box';

  Box<dynamic>? _box;

  Future<Box<dynamic>?> _getBox() async {
    try {
      if (_box != null && _box!.isOpen) {
        return _box!;
      }
      if (!Hive.isBoxOpen(boxName)) {
        _box = await Hive.openBox<dynamic>(boxName);
      } else {
        _box = Hive.box<dynamic>(boxName);
      }
      return _box;
    } catch (e) {
      debugPrint('OfflineTicketService: Hive is not initialized or box could not be opened: $e');
      return null;
    }
  }

  /// Cache a list of bookings in Hive
  Future<void> cacheBookings(List<Booking> bookings) async {
    try {
      final box = await _getBox();
      if (box == null) return;

      for (final booking in bookings) {
        final jsonMap = booking.toJson();
        await box.put(booking.id, jsonEncode(jsonMap));

        // Also store QR code payload explicitly for fast offline scanner retrieval
        await box.put('qr_${booking.id}', booking.qrCodeData);
        for (final ticket in booking.tickets) {
          await box.put('qr_ticket_${ticket.id}', ticket.qrData);
        }
      }
      // Save all booking IDs list
      final ids = bookings.map((b) => b.id).toList();
      await box.put('all_booking_ids', ids);
    } catch (e) {
      debugPrint('Error caching bookings to Hive: $e');
    }
  }

  /// Cache a single booking
  Future<void> cacheBooking(Booking booking) async {
    try {
      final box = await _getBox();
      if (box == null) return;

      final jsonMap = booking.toJson();
      await box.put(booking.id, jsonEncode(jsonMap));
      await box.put('qr_${booking.id}', booking.qrCodeData);
      for (final ticket in booking.tickets) {
        await box.put('qr_ticket_${ticket.id}', ticket.qrData);
      }

      final ids = List<String>.from(box.get('all_booking_ids', defaultValue: <String>[]) as List);
      if (!ids.contains(booking.id)) {
        ids.insert(0, booking.id);
        await box.put('all_booking_ids', ids);
      }
    } catch (e) {
      debugPrint('Error caching single booking to Hive: $e');
    }
  }

  /// Retrieve all cached bookings from Hive
  Future<List<Booking>> getCachedBookings() async {
    try {
      final box = await _getBox();
      if (box == null) return [];

      final ids = List<String>.from(box.get('all_booking_ids', defaultValue: <String>[]) as List);
      final List<Booking> result = [];

      for (final id in ids) {
        final raw = box.get(id);
        if (raw != null) {
          final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
          result.add(Booking.fromJson(map));
        }
      }
      return result;
    } catch (e) {
      debugPrint('Error loading cached bookings from Hive: $e');
      return [];
    }
  }

  /// Retrieve a specific cached booking by ID
  Future<Booking?> getCachedBooking(String bookingId) async {
    try {
      final box = await _getBox();
      if (box == null) return null;

      final raw = box.get(bookingId);
      if (raw != null) {
        final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
        return Booking.fromJson(map);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading cached booking $bookingId from Hive: $e');
      return null;
    }
  }

  /// Check if a booking is cached in Hive
  Future<bool> hasCachedBooking(String bookingId) async {
    try {
      final box = await _getBox();
      if (box == null) return false;
      return box.containsKey(bookingId);
    } catch (_) {
      return false;
    }
  }
}
