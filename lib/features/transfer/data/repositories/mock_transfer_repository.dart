import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:showscape/features/tickets/data/services/offline_ticket_service.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/transfer/domain/models/transfer.dart';
import 'package:showscape/features/transfer/domain/models/transfer_recipient.dart';
import 'package:showscape/features/transfer/domain/repositories/transfer_repository.dart';
import 'package:showscape/features/transfer/domain/services/transfer_security_service.dart';

/// Simulated transfer record tracking non-contact transfers for fraud detection
class _TransferAuditRecord {
  const _TransferAuditRecord({
    required this.userId,
    required this.timestamp,
    required this.isContact,
  });

  final String userId;
  final DateTime timestamp;
  final bool isContact;
}

/// Mock / Cloud Function simulated implementation of TransferRepository
class MockTransferRepository implements TransferRepository {
  MockTransferRepository({OfflineTicketService? offlineTicketService})
      : _offlineService = offlineTicketService;

  final OfflineTicketService? _offlineService;
  final List<Transfer> _transfers = [];
  final List<_TransferAuditRecord> _auditLog = [];
  final Set<String> _flaggedAccounts = {};

  // Store in-memory modifications to bookings and tickets
  final Map<String, List<Ticket>> _bookingTicketsOverride = {};
  final Map<String, String> _transferredToNames = {};

  @override
  bool isAccountFlagged(String userId) => _flaggedAccounts.contains(userId);

  /// Helper to get the transferred recipient name for a ticket
  @override
  String? getRecipientNameForTicket(String ticketId) => _transferredToNames[ticketId];

  @override
  Future<TransferResult> initiateTransfer({
    required String bookingId,
    required List<String> ticketIds,
    required String fromUserId,
    String? fromUserName,
    required TransferRecipient recipient,
    required DateTime showTime,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // 1. Check if user account has been flagged for fraud
    if (_flaggedAccounts.contains(fromUserId)) {
      return const TransferResult(
        isSuccess: false,
        errorMessage:
            'Account flagged for unusual transfer activity. Transfers are blocked.',
      );
    }

    // 2. Lock transfers 30 minutes before showtime rule
    final now = DateTime.now();
    final difference = showTime.difference(now);
    if (difference.inMinutes <= 30) {
      return const TransferResult(
        isSuccess: false,
        errorMessage: 'Transfers are locked within 30 minutes of showtime.',
      );
    }

    // 3. Fraud Detection Rule: more than 20 transfers in 24h to non-contacts
    final oneDayAgo = now.subtract(const Duration(hours: 24));
    final recentNonContactTransfers = _auditLog
        .where((record) =>
            record.userId == fromUserId &&
            !record.isContact &&
            record.timestamp.isAfter(oneDayAgo))
        .length;

    if (!recipient.isContact && recentNonContactTransfers >= 20) {
      _flaggedAccounts.add(fromUserId);
      return const TransferResult(
        isSuccess: false,
        errorMessage:
            'Transfer limit exceeded (max 20 transfers in 24h to non-contacts). Account flagged for security review.',
      );
    }

    // Record audit log
    for (int i = 0; i < ticketIds.length; i++) {
      _auditLog.add(
        _TransferAuditRecord(
          userId: fromUserId,
          timestamp: now,
          isContact: recipient.isContact,
        ),
      );
    }

    final transferId = 'trf_${DateTime.now().millisecondsSinceEpoch}';
    final primaryTicketId = ticketIds.isNotEmpty ? ticketIds.first : 'tkt_unknown';

    // 4. Emulate Cloud Function transferTicket: mark ticket as pendingTransfer
    for (final ticketId in ticketIds) {
      _transferredToNames[ticketId] = recipient.name;
    }

    final transfer = Transfer(
      id: transferId,
      bookingId: bookingId,
      ticketId: primaryTicketId,
      fromUserId: fromUserId,
      fromUserName: fromUserName ?? 'You',
      toUserPhone: recipient.phoneNumber,
      toUserEmail: recipient.email,
      status: TransferStatus.pending,
      initiatedAt: now,
      note: note,
    );

    _transfers.insert(0, transfer);

    // Update ticket status in offline cache & memory
    final service = _offlineService;
    if (service != null) {
      try {
        final cachedBooking = await service.getCachedBooking(bookingId);
        if (cachedBooking != null) {
          final updatedTickets = cachedBooking.tickets.map((t) {
            if (ticketIds.contains(t.id)) {
              return t.copyWith(status: TicketStatus.pendingTransfer);
            }
            return t;
          }).toList();
          _bookingTicketsOverride[bookingId] = updatedTickets;
          await service.cacheBooking(
            cachedBooking.copyWith(tickets: updatedTickets),
          );
        }
      } catch (_) {
        // Safe fallback when Hive is uninitialized (e.g. unit tests)
      }
    }

    // 5. Send FCM push notification simulation to recipient
    _sendSimulatedFcmNotification(
      recipient: recipient,
      senderName: fromUserName ?? 'Your friend',
      ticketCount: ticketIds.length,
      transferId: transferId,
    );

    final shareLink = 'https://showscape.app/transfer/claim?id=$transferId';

    return TransferResult(
      isSuccess: true,
      transfer: transfer,
      shareLink: shareLink,
    );
  }

  @override
  Future<TransferResult> acceptTransfer({
    required String transferId,
    required String recipientUid,
    required String recipientName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index == -1) {
      return const TransferResult(
        isSuccess: false,
        errorMessage: 'Transfer request not found.',
      );
    }

    final existing = _transfers[index];
    if (existing.status != TransferStatus.pending) {
      return TransferResult(
        isSuccess: false,
        errorMessage: 'Transfer is no longer pending (status: ${existing.status.name}).',
      );
    }

    final now = DateTime.now();

    // 1. Issue new QR signature (HMAC of bookingId+seatId+holderUid+expiry)
    final expiry = now.add(const Duration(days: 3));
    final newHmacQr = TransferSecurityService.createSignedQrPayload(
      bookingId: existing.bookingId,
      seatId: existing.ticketId,
      holderUid: recipientUid,
      expiry: expiry,
    );

    // 2. Mark original ticket transferred and invalidate old QR code
    final updatedTransfer = existing.copyWith(
      status: TransferStatus.accepted,
      completedAt: now,
    );
    _transfers[index] = updatedTransfer;
    _transferredToNames[existing.ticketId] = recipientName;

    // Invalidate old QR code in offline cache & memory
    final service2 = _offlineService;
    if (service2 != null) {
      try {
        final cachedBooking = await service2.getCachedBooking(existing.bookingId);
        if (cachedBooking != null) {
          final updatedTickets = cachedBooking.tickets.map((t) {
            if (t.id == existing.ticketId) {
              return t.copyWith(
                status: TicketStatus.transferred,
                qrData: 'SHOWSCAPE:INVALIDATED:TRANSFERRED_TO_$recipientName',
              );
            }
            return t;
          }).toList();
          _bookingTicketsOverride[existing.bookingId] = updatedTickets;
          await service2.cacheBooking(
            cachedBooking.copyWith(tickets: updatedTickets),
          );
        }
      } catch (_) {
        // Safe fallback when Hive is uninitialized
      }
    }

    debugPrint(
      '[Cloud Function] Transfer $transferId ACCEPTED by $recipientName ($recipientUid). Issued new HMAC signature: $newHmacQr',
    );

    return TransferResult(
      isSuccess: true,
      transfer: updatedTransfer,
      newQrSignature: newHmacQr,
    );
  }

  @override
  Future<TransferResult> cancelTransfer({
    required String transferId,
    required String senderUid,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final index = _transfers.indexWhere((t) => t.id == transferId);
    if (index == -1) {
      return const TransferResult(
        isSuccess: false,
        errorMessage: 'Transfer not found.',
      );
    }

    final existing = _transfers[index];
    if (existing.status != TransferStatus.pending) {
      return TransferResult(
        isSuccess: false,
        errorMessage: 'Cannot cancel a transfer with status: ${existing.status.name}',
      );
    }

    // Revert ticket back to active state
    final updatedTransfer = existing.copyWith(
      status: TransferStatus.cancelled,
      completedAt: DateTime.now(),
    );
    _transfers[index] = updatedTransfer;
    _transferredToNames.remove(existing.ticketId);

    final service3 = _offlineService;
    if (service3 != null) {
      try {
        final cachedBooking = await service3.getCachedBooking(existing.bookingId);
        if (cachedBooking != null) {
          final updatedTickets = cachedBooking.tickets.map((t) {
            if (t.id == existing.ticketId) {
              return t.copyWith(status: TicketStatus.active);
            }
            return t;
          }).toList();
          _bookingTicketsOverride[existing.bookingId] = updatedTickets;
          await service3.cacheBooking(
            cachedBooking.copyWith(tickets: updatedTickets),
          );
        }
      } catch (_) {
        // Safe fallback when Hive is uninitialized
      }
    }

    return TransferResult(
      isSuccess: true,
      transfer: updatedTransfer,
    );
  }

  @override
  Future<Transfer?> getTransferById(String transferId) async {
    try {
      return _transfers.firstWhere((t) => t.id == transferId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Transfer>> getTransfersForBooking(String bookingId) async {
    return _transfers.where((t) => t.bookingId == bookingId).toList();
  }

  @override
  Future<List<Transfer>> getUserTransfers(String userId) async {
    return _transfers.where((t) => t.fromUserId == userId).toList();
  }

  void _sendSimulatedFcmNotification({
    required TransferRecipient recipient,
    required String senderName,
    required int ticketCount,
    required String transferId,
  }) {
    debugPrint(
      '🔔 [FCM Cloud Function] Push notification dispatched to ${recipient.phoneNumber}: '
      '"$senderName sent you $ticketCount ticket(s). Tap to view and accept your entry pass."',
    );
  }
}
