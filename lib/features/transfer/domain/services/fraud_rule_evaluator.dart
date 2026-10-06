/// Result of a fraud check evaluation
class FraudCheckResult {
  final bool isFlagged;
  final String? reason;
  final String ruleTriggered;

  const FraudCheckResult.passed()
      : isFlagged = false,
        reason = null,
        ruleTriggered = 'NONE';

  const FraudCheckResult.blocked({
    required this.reason,
    required this.ruleTriggered,
  }) : isFlagged = true;
}

/// Simulated transfer record for fraud evaluation
class TransferAuditRecord {
  final String transferId;
  final String senderId;
  final String recipientId;
  final DateTime timestamp;
  final bool isContact;

  const TransferAuditRecord({
    required this.transferId,
    required this.senderId,
    required this.recipientId,
    required this.timestamp,
    required this.isContact,
  });
}

/// Pure Dart Fraud Rule Evaluator
class FraudRuleEvaluator {
  static const int maxTransfers24hNonContact = 20;
  static const int maxTransfers10mBurst = 5;
  static const Duration showtimeTransferLockBuffer = Duration(minutes: 30);

  /// Evaluate transfer request against security and fraud detection rules
  static FraudCheckResult evaluate({
    required String senderId,
    required String recipientId,
    required bool isRecipientContact,
    required DateTime showtime,
    required List<TransferAuditRecord> pastTransfers,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();

    // Rule 1: Showtime Lock (transfers blocked within 30m of showtime)
    final timeUntilShow = showtime.difference(now);
    if (timeUntilShow <= showtimeTransferLockBuffer) {
      return const FraudCheckResult.blocked(
        reason: 'Ticket transfer is locked within 30 minutes of showtime.',
        ruleTriggered: 'SHOWTIME_30M_LOCK',
      );
    }

    // Rule 2: Burst Rate Limit (max 5 transfers within 10 minutes)
    final tenMinutesAgo = now.subtract(const Duration(minutes: 10));
    final burstTransfers = pastTransfers
        .where((t) => t.senderId == senderId && t.timestamp.isAfter(tenMinutesAgo))
        .length;
    if (burstTransfers >= maxTransfers10mBurst) {
      return const FraudCheckResult.blocked(
        reason: 'Velocity limit exceeded: too many transfer attempts in 10 minutes.',
        ruleTriggered: 'BURST_VELOCITY_LIMIT',
      );
    }

    // Rule 3: 24h Non-Contact Transfer Limit (>20 transfers to non-contacts in 24h)
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    final nonContactTransfers24h = pastTransfers
        .where((t) =>
            t.senderId == senderId &&
            !t.isContact &&
            t.timestamp.isAfter(twentyFourHoursAgo))
        .length;

    if (!isRecipientContact && nonContactTransfers24h >= maxTransfers24hNonContact) {
      return const FraudCheckResult.blocked(
        reason:
            'Account flagged: exceeded maximum 20 non-contact ticket transfers in 24 hours.',
        ruleTriggered: 'MAX_24H_NON_CONTACT_LIMIT',
      );
    }

    return const FraudCheckResult.passed();
  }
}
