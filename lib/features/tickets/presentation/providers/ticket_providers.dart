import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/features/tickets/data/services/offline_ticket_service.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';

enum TicketsSegment {
  upcoming,
  past,
  transferred,
}

/// Offline ticket service provider
final offlineTicketServiceProvider = Provider<OfflineTicketService>((ref) {
  return OfflineTicketService();
});

/// Simulation / detection of offline state
final isOfflineModeProvider = StateProvider<bool>((ref) => false);

/// Selected tab segment: Upcoming, Past, Transferred
final selectedTicketsSegmentProvider =
    StateProvider<TicketsSegment>((ref) => TicketsSegment.upcoming);

/// Format showtime into live countdown string e.g. "Starts in 2h 10m"
String formatTicketCountdown(DateTime showTime, {DateTime? currentTime}) {
  final now = currentTime ?? DateTime.now();
  final difference = showTime.difference(now);

  if (difference.isNegative) {
    final elapsedMinutes = difference.inMinutes.abs();
    if (elapsedMinutes < 180) {
      if (elapsedMinutes < 60) {
        return 'Started ${elapsedMinutes}m ago';
      }
      final hours = elapsedMinutes ~/ 60;
      final mins = elapsedMinutes % 60;
      return 'Started ${hours}h ${mins}m ago';
    }
    return 'Completed';
  }

  final totalMinutes = difference.inMinutes;
  if (totalMinutes < 60) {
    if (totalMinutes == 0) return 'Starting now';
    return 'Starts in ${totalMinutes}m';
  }

  final hours = difference.inHours;
  final minutes = totalMinutes % 60;
  if (hours < 24) {
    if (minutes == 0) return 'Starts in ${hours}h';
    return 'Starts in ${hours}h ${minutes}m';
  }

  final days = difference.inDays;
  if (days == 1) {
    return 'Starts tomorrow (${DateFormat('hh:mm a').format(showTime)})';
  }
  return 'Starts in $days days';
}

/// All user bookings with automatic Hive offline caching and fallback
final allUserBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final isOffline = ref.watch(isOfflineModeProvider);
  final offlineService = ref.watch(offlineTicketServiceProvider);
  final repo = ref.watch(bookingRepositoryProvider);
  final user = await ref.watch(currentUserProvider.future);
  final userId = user?.id ?? 'usr_001';

  if (isOffline) {
    final cached = await offlineService.getCachedBookings();
    if (cached.isNotEmpty) {
      return cached;
    }
  }

  try {
    final bookings = await repo.getUserBookings(userId);
    // Cache fresh bookings to Hive
    await offlineService.cacheBookings(bookings);
    return bookings;
  } catch (e) {
    // Fallback to cached bookings if network/repo fails
    final cached = await offlineService.getCachedBookings();
    if (cached.isNotEmpty) return cached;
    rethrow;
  }
});

/// Bookings grouped by segment
final upcomingBookingsProvider = Provider<List<Booking>>((ref) {
  final bookingsAsync = ref.watch(allUserBookingsProvider);
  return bookingsAsync.maybeWhen(
    data: (bookings) {
      final now = DateTime.now().subtract(const Duration(hours: 3));
      return bookings.where((b) {
        final hasActiveTicket = b.tickets.any((t) => t.status == TicketStatus.active);
        return (b.showTime.isAfter(now) || b.tickets.isEmpty || hasActiveTicket) &&
            b.status != BookingStatus.cancelled &&
            b.status != BookingStatus.expired &&
            !b.tickets.every((t) => t.status == TicketStatus.transferred);
      }).toList()
        ..sort((a, b) => a.showTime.compareTo(b.showTime));
    },
    orElse: () => [],
  );
});

final pastBookingsProvider = Provider<List<Booking>>((ref) {
  final bookingsAsync = ref.watch(allUserBookingsProvider);
  return bookingsAsync.maybeWhen(
    data: (bookings) {
      final now = DateTime.now().subtract(const Duration(hours: 3));
      return bookings.where((b) {
        final isPastTime = b.showTime.isBefore(now);
        final allUsedOrCancelled = b.tickets.isNotEmpty &&
            b.tickets.every((t) =>
                t.status == TicketStatus.used ||
                t.status == TicketStatus.cancelled);
        return (isPastTime || allUsedOrCancelled) &&
            !b.tickets.every((t) => t.status == TicketStatus.transferred);
      }).toList()
        ..sort((a, b) => b.showTime.compareTo(a.showTime));
    },
    orElse: () => [],
  );
});

final transferredBookingsProvider = Provider<List<Booking>>((ref) {
  final bookingsAsync = ref.watch(allUserBookingsProvider);
  return bookingsAsync.maybeWhen(
    data: (bookings) {
      return bookings.where((b) {
        return b.tickets.any((t) =>
                t.status == TicketStatus.transferred ||
                t.status == TicketStatus.pendingTransfer) ||
            b.qrCodeData.contains('TRANSFERRED');
      }).toList()
        ..sort((a, b) => b.showTime.compareTo(a.showTime));
    },
    orElse: () => [],
  );
});

/// Bookings for the currently selected segment
final currentSegmentBookingsProvider = Provider<List<Booking>>((ref) {
  final segment = ref.watch(selectedTicketsSegmentProvider);
  switch (segment) {
    case TicketsSegment.upcoming:
      return ref.watch(upcomingBookingsProvider);
    case TicketsSegment.past:
      return ref.watch(pastBookingsProvider);
    case TicketsSegment.transferred:
      return ref.watch(transferredBookingsProvider);
  }
});

/// Single booking detail with offline caching fallback
final ticketDetailProvider =
    FutureProvider.family<Booking?, String>((ref, bookingId) async {
  final isOffline = ref.watch(isOfflineModeProvider);
  final offlineService = ref.watch(offlineTicketServiceProvider);
  final repo = ref.watch(bookingRepositoryProvider);

  if (isOffline) {
    final cached = await offlineService.getCachedBooking(bookingId);
    if (cached != null) return cached;
  }

  try {
    final booking = await repo.getBookingById(bookingId);
    if (booking != null) {
      await offlineService.cacheBooking(booking);
      return booking;
    }
  } catch (_) {}

  // Fallback to Hive cache
  try {
    return await offlineService.getCachedBooking(bookingId);
  } catch (_) {
    return null;
  }
});
