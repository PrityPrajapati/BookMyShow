import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/checkout/domain/models/price_breakdown.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/tickets/domain/repositories/booking_repository.dart';
import 'package:showscape/features/transfer/domain/models/transfer.dart';

class MockBookingRepository implements BookingRepository {
  List<Booking>? _cachedBookings;
  final List<Transfer> _transfers = [];

  Future<List<Booking>> _loadAll() async {
    if (_cachedBookings != null) return _cachedBookings!;

    final jsonStr = await rootBundle.loadString('assets/mock/bookings.json');
    final raw = jsonDecode(jsonStr) as List<dynamic>;

    _cachedBookings =
        raw.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
    return _cachedBookings!;
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _loadAll();
    _cachedBookings!.insert(0, booking);
    return booking;
  }

  @override
  Future<Booking> confirmBooking({
    required BookingDraft draft,
    required String paymentId,
    String? userId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _loadAll();

    final bookingId = 'bkg_${DateTime.now().millisecondsSinceEpoch}';
    final actualUserId = userId ?? 'usr_current';
    final now = DateTime.now();

    // Create tickets: one per seat
    final tickets = <Ticket>[];
    for (int i = 0; i < draft.seatIds.length; i++) {
      final seatCode = draft.seatIds[i];
      final seatPrice = i < draft.seatPrices.length ? draft.seatPrices[i] : 250.0;
      final parts = seatCode.split('-');
      final row = parts.isNotEmpty ? parts.first : 'A';
      final col = parts.length > 1 ? (int.tryParse(parts.last) ?? (i + 1)) : (i + 1);

      tickets.add(
        Ticket(
          id: 'tkt_${bookingId}_${i + 1}',
          bookingId: bookingId,
          seatId: seatCode,
          seatNumber: seatCode,
          row: row,
          col: col,
          category: 'Standard',
          price: seatPrice,
          qrData: 'SHOWSCAPE:$bookingId:${i + 1}:$seatCode',
          status: TicketStatus.active,
        ),
      );
    }

    final pricing = draft.priceBreakdown;
    final priceBreakdown = PriceBreakdown(
      basePrice: pricing.ticketSubtotal,
      convenienceFee: pricing.convenienceFee,
      gst: pricing.gstOnFee,
      fnbTotal: pricing.fnbTotal,
      parkingTotal: pricing.parking,
      discount: pricing.discountAmount,
      grandTotal: pricing.grandTotal,
    );

    final List<FnbItem> fnbList = [];
    for (final cartItem in draft.fnbItems) {
      if (cartItem.item != null) {
        fnbList.add(cartItem.item!);
      }
    }

    final booking = Booking(
      id: bookingId,
      bookingNumber: 'SS-${now.millisecondsSinceEpoch.toString().substring(5)}',
      userId: actualUserId,
      eventId: draft.eventId ?? 'ev_001',
      eventTitle: draft.eventTitle ?? 'Dune: Part Two',
      venueId: draft.venueId ?? 'ven_001',
      venueName: draft.venueName ?? 'PVR INOX: Phoenix Palladium',
      showId: draft.showId,
      showTime: draft.showTime ?? now.add(const Duration(hours: 3)),
      showFormat: 'IMAX 2D',
      bookingTime: now,
      tickets: tickets,
      fnbItems: fnbList,
      parkingLot: draft.parking?.lot,
      priceBreakdown: priceBreakdown,
      status: BookingStatus.confirmed,
      qrCodeData: 'SHOWSCAPE_BOOKING:$bookingId',
    );

    _cachedBookings!.insert(0, booking);
    return booking;
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final bookings = await _loadAll();
    try {
      return bookings.firstWhere((b) => b.id == bookingId || b.bookingNumber == bookingId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final bookings = await _loadAll();
    return bookings
        .where((b) =>
            b.userId == userId ||
            userId.isEmpty ||
            userId == 'usr_001' ||
            userId == 'usr_current' ||
            b.userId == 'usr_001' ||
            b.userId == 'usr_current')
        .toList();
  }

  @override
  Future<List<Ticket>> getUserTickets(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final bookings = await _loadAll();
    final userBookings = bookings.where((b) => b.userId == userId);

    final List<Ticket> allTickets = [];
    for (final b in userBookings) {
      allTickets.addAll(b.tickets);
    }
    return allTickets;
  }

  @override
  Future<Transfer> transferTicket({
    required String bookingId,
    required String ticketId,
    required String fromUserId,
    String? fromUserName,
    required String toUserPhone,
    String? toUserEmail,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _loadAll();

    // Mark the ticket as transferred inside the booking
    final bookingIndex = _cachedBookings!.indexWhere((b) => b.id == bookingId);
    if (bookingIndex != -1) {
      final booking = _cachedBookings![bookingIndex];
      final updatedTickets = booking.tickets.map((t) {
        if (t.id == ticketId) {
          return t.copyWith(status: TicketStatus.transferred);
        }
        return t;
      }).toList();
      _cachedBookings![bookingIndex] =
          booking.copyWith(tickets: updatedTickets);
    }

    final transfer = Transfer(
      id: 'trf_${DateTime.now().millisecondsSinceEpoch}',
      bookingId: bookingId,
      ticketId: ticketId,
      fromUserId: fromUserId,
      fromUserName: fromUserName ?? 'You',
      toUserPhone: toUserPhone,
      toUserEmail: toUserEmail,
      status: TransferStatus.accepted,
      initiatedAt: DateTime.now(),
      completedAt: DateTime.now(),
      note: note,
    );

    _transfers.insert(0, transfer);
    return transfer;
  }

  @override
  Future<List<Transfer>> getUserTransfers(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _transfers.where((t) => t.fromUserId == userId).toList();
  }
}
