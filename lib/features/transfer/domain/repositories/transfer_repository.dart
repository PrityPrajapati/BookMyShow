import 'package:showscape/features/transfer/domain/models/transfer.dart';
import 'package:showscape/features/transfer/domain/models/transfer_recipient.dart';

class TransferResult {
  const TransferResult({
    required this.isSuccess,
    this.transfer,
    this.newQrSignature,
    this.errorMessage,
    this.shareLink,
  });

  final bool isSuccess;
  final Transfer? transfer;
  final String? newQrSignature;
  final String? errorMessage;
  final String? shareLink;

  @override
  String toString() =>
      'TransferResult(success: $isSuccess, transferId: ${transfer?.id}, error: $errorMessage)';
}

abstract class TransferRepository {
  /// Initiate ticket transfer with business rules (30m showtime lock, fraud check)
  Future<TransferResult> initiateTransfer({
    required String bookingId,
    required List<String> ticketIds,
    required String fromUserId,
    String? fromUserName,
    required TransferRecipient recipient,
    required DateTime showTime,
    String? note,
  });

  /// Recipient accepts transfer -> generates new HMAC signature and invalidates old QR
  Future<TransferResult> acceptTransfer({
    required String transferId,
    required String recipientUid,
    required String recipientName,
  });

  /// Sender cancels transfer before acceptance -> restores ticket to active
  Future<TransferResult> cancelTransfer({
    required String transferId,
    required String senderUid,
  });

  /// Retrieve a transfer by ID
  Future<Transfer?> getTransferById(String transferId);

  /// Retrieve all transfers for a booking
  Future<List<Transfer>> getTransfersForBooking(String bookingId);

  /// Retrieve transfer history for user
  Future<List<Transfer>> getUserTransfers(String userId);

  /// Check if an account is flagged for fraud
  bool isAccountFlagged(String userId);

  /// Get recipient name if ticket was transferred
  String? getRecipientNameForTicket(String ticketId);
}
