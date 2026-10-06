import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/features/transfer/domain/services/fraud_rule_evaluator.dart';

void main() {
  group('FraudRuleEvaluator Unit Tests', () {
    final baseTime = DateTime(2026, 10, 2, 18, 0, 0); // 6:00 PM
    const sender = 'usr_sender_42';
    const recipient = 'usr_recipient_99';

    test('Passes valid transfer to a contact well ahead of showtime', () {
      final showtime = baseTime.add(const Duration(hours: 3)); // 9:00 PM

      final result = FraudRuleEvaluator.evaluate(
        senderId: sender,
        recipientId: recipient,
        isRecipientContact: true,
        showtime: showtime,
        pastTransfers: [],
        currentTime: baseTime,
      );

      expect(result.isFlagged, isFalse);
      expect(result.reason, isNull);
      expect(result.ruleTriggered, 'NONE');
    });

    test('Rule 1 (Showtime Lock): Blocks transfer within 30 minutes of showtime', () {
      final showtime = baseTime.add(const Duration(minutes: 25)); // 25 mins left (< 30 min buffer)

      final result = FraudRuleEvaluator.evaluate(
        senderId: sender,
        recipientId: recipient,
        isRecipientContact: true,
        showtime: showtime,
        pastTransfers: [],
        currentTime: baseTime,
      );

      expect(result.isFlagged, isTrue);
      expect(result.ruleTriggered, 'SHOWTIME_30M_LOCK');
      expect(result.reason, contains('30 minutes of showtime'));
    });

    test('Rule 2 (Burst Velocity Limit): Blocks transfer if >= 5 transfers in last 10 minutes', () {
      final showtime = baseTime.add(const Duration(hours: 2));

      // 5 transfers in the last 5 minutes
      final pastTransfers = List.generate(
        5,
        (i) => TransferAuditRecord(
          transferId: 'tr_$i',
          senderId: sender,
          recipientId: 'rec_$i',
          timestamp: baseTime.subtract(Duration(minutes: i + 1)),
          isContact: true,
        ),
      );

      final result = FraudRuleEvaluator.evaluate(
        senderId: sender,
        recipientId: recipient,
        isRecipientContact: true,
        showtime: showtime,
        pastTransfers: pastTransfers,
        currentTime: baseTime,
      );

      expect(result.isFlagged, isTrue);
      expect(result.ruleTriggered, 'BURST_VELOCITY_LIMIT');
      expect(result.reason, contains('Velocity limit exceeded'));
    });

    test('Rule 3 (24h Non-Contact Limit): Blocks when >20 transfers to non-contacts in 24h', () {
      final showtime = baseTime.add(const Duration(hours: 4));

      // 20 non-contact transfers in last 12 hours
      final pastTransfers = List.generate(
        20,
        (i) => TransferAuditRecord(
          transferId: 'tr_bulk_$i',
          senderId: sender,
          recipientId: 'random_stranger_$i',
          timestamp: baseTime.subtract(Duration(minutes: 20 * (i + 1))), // spread across hours
          isContact: false,
        ),
      );

      // 21st non-contact transfer
      final result = FraudRuleEvaluator.evaluate(
        senderId: sender,
        recipientId: 'another_non_contact_user',
        isRecipientContact: false,
        showtime: showtime,
        pastTransfers: pastTransfers,
        currentTime: baseTime,
      );

      expect(result.isFlagged, isTrue);
      expect(result.ruleTriggered, 'MAX_24H_NON_CONTACT_LIMIT');
      expect(result.reason, contains('exceeded maximum 20 non-contact ticket transfers'));
    });

    test('Allows transfer to verified contact even if 20 non-contact transfers were made', () {
      final showtime = baseTime.add(const Duration(hours: 4));

      final pastTransfers = List.generate(
        20,
        (i) => TransferAuditRecord(
          transferId: 'tr_bulk_$i',
          senderId: sender,
          recipientId: 'random_stranger_$i',
          timestamp: baseTime.subtract(Duration(minutes: 20 * (i + 1))),
          isContact: false,
        ),
      );

      // Transfer to an actual known contact is permitted
      final result = FraudRuleEvaluator.evaluate(
        senderId: sender,
        recipientId: 'friend_contact',
        isRecipientContact: true,
        showtime: showtime,
        pastTransfers: pastTransfers,
        currentTime: baseTime,
      );

      expect(result.isFlagged, isFalse);
    });
  });
}
