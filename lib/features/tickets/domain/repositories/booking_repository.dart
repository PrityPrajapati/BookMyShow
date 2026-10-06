import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/transfer/domain/models/transfer.dart';

abstract class BookingRepository {
  /// Create new booking with tickets, FnB and price breakdown
  Future<Booking> createBooking(Booking booking);

  /// Confirm booking from booking draft and payment transaction
  Future<Booking> confirmBooking({
    required BookingDraft draft,
    required String paymentId,
    String? userId,
  });

  /// Fetch booking by id
  Future<Booking?> getBookingById(String bookingId);

  /// Fetch user bookings
  Future<List<Booking>> getUserBookings(String userId);

  /// Fetch user tickets
  Future<List<Ticket>> getUserTickets(String userId);

  /// Transfer ticket to another user via phone/email
  Future<Transfer> transferTicket({
    required String bookingId,
    required String ticketId,
    required String fromUserId,
    String? fromUserName,
    required String toUserPhone,
    String? toUserEmail,
    String? note,
  });

  /// Fetch transfer history for user
  Future<List<Transfer>> getUserTransfers(String userId);
}
