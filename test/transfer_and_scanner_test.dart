import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/features/checkout/domain/models/price_breakdown.dart';
import 'package:showscape/features/scanner/presentation/screens/staff_scanner_screen.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/tickets/presentation/widgets/transfer_ticket_sheet.dart';
import 'package:showscape/features/transfer/data/repositories/mock_transfer_repository.dart';
import 'package:showscape/features/transfer/domain/models/transfer_recipient.dart';
import 'package:showscape/features/transfer/domain/services/transfer_security_service.dart';

void main() {
  group('TransferSecurityService HMAC Tests', () {
    test('generateHmacSignature produces consistent sha256 hex string', () {
      final sig1 = TransferSecurityService.generateHmacSignature(
        bookingId: 'bkg_test_1',
        seatId: 'A1',
        holderUid: 'usr_user_1',
        expiryEpochSeconds: 1772450000,
      );
      final sig2 = TransferSecurityService.generateHmacSignature(
        bookingId: 'bkg_test_1',
        seatId: 'A1',
        holderUid: 'usr_user_1',
        expiryEpochSeconds: 1772450000,
      );
      expect(sig1, isNotEmpty);
      expect(sig1, equals(sig2));
      expect(sig1.length, equals(64)); // SHA-256 hex length
    });

    test('validateQrPayload approves legitimate HMAC QR payload', () {
      final expiry = DateTime.now().add(const Duration(hours: 24));
      final qrString = TransferSecurityService.createSignedQrPayload(
        bookingId: 'bkg_123',
        seatId: 'Seat_E4',
        holderUid: 'usr_rahul',
        expiry: expiry,
      );

      final result = TransferSecurityService.validateQrPayload(qrString);
      expect(result.isValid, isTrue);
      expect(result.bookingId, equals('bkg_123'));
      expect(result.seatId, equals('Seat_E4'));
      expect(result.holderUid, equals('usr_rahul'));
      expect(result.isExpired, isFalse);
    });

    test('validateQrPayload rejects tampered signature', () {
      final expiry = DateTime.now().add(const Duration(hours: 24));
      final expiryEpoch = expiry.millisecondsSinceEpoch ~/ 1000;
      final tamperedQr =
          'SHOWSCAPE:v2:bkg_123:Seat_E4:usr_rahul:$expiryEpoch:deadbeef1234567890abcdef';

      final result = TransferSecurityService.validateQrPayload(tamperedQr);
      expect(result.isValid, isFalse);
      expect(result.errorReason, contains('Tampered QR'));
    });

    test('validateQrPayload rejects expired passes', () {
      final pastExpiry = DateTime.now().subtract(const Duration(hours: 2));
      final qrString = TransferSecurityService.createSignedQrPayload(
        bookingId: 'bkg_123',
        seatId: 'Seat_E4',
        holderUid: 'usr_rahul',
        expiry: pastExpiry,
      );

      final result = TransferSecurityService.validateQrPayload(qrString);
      expect(result.isValid, isFalse);
      expect(result.isExpired, isTrue);
      expect(result.errorReason, contains('expired'));
    });

    test('validateQrPayload rejects invalidated transferred passes', () {
      const invalidatedQr = 'SHOWSCAPE:INVALIDATED:TRANSFERRED_TO_Rahul';
      final result = TransferSecurityService.validateQrPayload(invalidatedQr);
      expect(result.isValid, isFalse);
      expect(result.errorReason, contains('Ticket is invalid'));
    });
  });

  group('MockTransferRepository Business Rules', () {
    late MockTransferRepository repo;

    setUp(() {
      repo = MockTransferRepository();
    });

    test('Lock transfers within 30 minutes of showtime rule', () async {
      // Show is in 15 minutes (< 30m)
      final nearShowTime = DateTime.now().add(const Duration(minutes: 15));

      final result = await repo.initiateTransfer(
        bookingId: 'bkg_lock_test',
        ticketIds: ['tkt_1'],
        fromUserId: 'usr_sender_1',
        recipient: const TransferRecipient(
          name: 'Rahul',
          phoneNumber: '+91 98765 00000',
        ),
        showTime: nearShowTime,
      );

      expect(result.isSuccess, isFalse);
      expect(result.errorMessage, contains('locked within 30 minutes'));
    });

    test('Allows transfers when more than 30 minutes before showtime', () async {
      final farShowTime = DateTime.now().add(const Duration(hours: 5));

      final result = await repo.initiateTransfer(
        bookingId: 'bkg_ok_test',
        ticketIds: ['tkt_1'],
        fromUserId: 'usr_sender_2',
        recipient: const TransferRecipient(
          name: 'Rahul',
          phoneNumber: '+91 98765 00000',
          isContact: true,
        ),
        showTime: farShowTime,
      );

      expect(result.isSuccess, isTrue);
      expect(result.transfer?.status.name, equals('pending'));
      expect(result.shareLink, isNotNull);
    });

    test('Sender can cancel before acceptance and restores active state', () async {
      final farShowTime = DateTime.now().add(const Duration(hours: 5));

      final initResult = await repo.initiateTransfer(
        bookingId: 'bkg_cancel_test',
        ticketIds: ['tkt_cancel_1'],
        fromUserId: 'usr_sender_3',
        recipient: const TransferRecipient(
          name: 'Rahul',
          phoneNumber: '+91 98765 00000',
        ),
        showTime: farShowTime,
      );

      expect(initResult.isSuccess, isTrue);
      final transferId = initResult.transfer!.id;

      // Cancel transfer
      final cancelResult = await repo.cancelTransfer(
        transferId: transferId,
        senderUid: 'usr_sender_3',
      );

      expect(cancelResult.isSuccess, isTrue);
      expect(cancelResult.transfer?.status.name, equals('cancelled'));
    });

    test('Accept transfer issues HMAC signature and completes transfer', () async {
      final farShowTime = DateTime.now().add(const Duration(hours: 5));

      final initResult = await repo.initiateTransfer(
        bookingId: 'bkg_accept_test',
        ticketIds: ['tkt_acc_1'],
        fromUserId: 'usr_sender_4',
        recipient: const TransferRecipient(
          name: 'Rahul Sharma',
          phoneNumber: '+91 98765 00000',
        ),
        showTime: farShowTime,
      );

      expect(initResult.isSuccess, isTrue);
      final transferId = initResult.transfer!.id;

      // Recipient accepts
      final acceptResult = await repo.acceptTransfer(
        transferId: transferId,
        recipientUid: 'usr_rahul_uid',
        recipientName: 'Rahul Sharma',
      );

      expect(acceptResult.isSuccess, isTrue);
      expect(acceptResult.newQrSignature, isNotNull);
      expect(acceptResult.newQrSignature, startsWith('SHOWSCAPE:v2:bkg_accept_test'));
      expect(acceptResult.transfer?.status.name, equals('accepted'));

      // Validate new HMAC signature
      final validation =
          TransferSecurityService.validateQrPayload(acceptResult.newQrSignature!);
      expect(validation.isValid, isTrue);
      expect(validation.holderUid, equals('usr_rahul_uid'));
    });

    test('Fraud Rule: >20 transfers in 24h to non-contacts flags account and blocks transfers', () async {
      final farShowTime = DateTime.now().add(const Duration(hours: 10));
      const senderId = 'usr_fraud_tester';

      // Perform 20 non-contact transfers
      for (int i = 0; i < 20; i++) {
        final res = await repo.initiateTransfer(
          bookingId: 'bkg_batch_$i',
          ticketIds: ['tkt_$i'],
          fromUserId: senderId,
          recipient: TransferRecipient(
            name: 'Stranger $i',
            phoneNumber: '+91 90000 ${10000 + i}',
            isContact: false,
          ),
          showTime: farShowTime,
        );
        expect(res.isSuccess, isTrue, reason: 'Transfer $i should succeed');
      }

      // The 21st transfer to a non-contact should trigger the fraud rule and flag the account
      final blockedResult = await repo.initiateTransfer(
        bookingId: 'bkg_batch_21',
        ticketIds: ['tkt_21'],
        fromUserId: senderId,
        recipient: const TransferRecipient(
          name: 'Stranger 21',
          phoneNumber: '+91 90000 99999',
          isContact: false,
        ),
        showTime: farShowTime,
      );

      expect(blockedResult.isSuccess, isFalse);
      expect(blockedResult.errorMessage, contains('Transfer limit exceeded'));
      expect(repo.isAccountFlagged(senderId), isTrue);

      // Subsequent transfers are blocked
      final blockedSubsequent = await repo.initiateTransfer(
        bookingId: 'bkg_batch_22',
        ticketIds: ['tkt_22'],
        fromUserId: senderId,
        recipient: const TransferRecipient(
          name: 'Friend',
          phoneNumber: '+91 90000 88888',
          isContact: true,
        ),
        showTime: farShowTime,
      );
      expect(blockedSubsequent.isSuccess, isFalse);
      expect(blockedSubsequent.errorMessage, contains('Account flagged'));
    });
  });

  group('Transfer & Scanner Widget Tests', () {
    testWidgets('StaffScannerScreen validates test QR code payload via manual input', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: StaffScannerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap manual QR test button in AppBar
      final testButton = find.byKey(const Key('manual_qr_test_button'));
      expect(testButton, findsOneWidget);
      await tester.tap(testButton);
      await tester.pumpAndSettle();

      // Alert dialog should open
      expect(find.text('Test QR Payload'), findsOneWidget);

      // Select 'Valid HMAC (Rahul)' action chip
      final hmacChip = find.text('Valid HMAC (Rahul)');
      expect(hmacChip, findsOneWidget);
      await tester.tap(hmacChip);
      await tester.pumpAndSettle();

      // Tap 'Validate' button
      final validateButton = find.byKey(const Key('submit_test_qr_button'));
      await tester.tap(validateButton);
      await tester.pumpAndSettle();

      // Validation sheet should display 'PASS VERIFIED & VALID'
      expect(find.text('PASS VERIFIED & VALID'), findsOneWidget);
      expect(find.text('Admit & Scan Next'), findsOneWidget);

      // Tap 'Admit & Scan Next' to dismiss
      await tester.tap(find.byKey(const Key('scan_next_button')));
      await tester.pumpAndSettle();

      expect(find.text('PASS VERIFIED & VALID'), findsNothing);
    });

    testWidgets('TransferTicketSheet allows seat selection and stepping to recipient', (tester) async {
      final sampleBooking = Booking(
        id: 'bkg_widget_demo',
        bookingNumber: 'BKG-9922',
        userId: 'usr_001',
        eventId: 'evt_movie_1',
        venueId: 'ven_1',
        showId: 'show_1',
        eventTitle: 'Interstellar (IMAX)',
        venueName: 'PVR ICON IMAX, Lower Parel',
        showTime: DateTime.now().add(const Duration(hours: 4)),
        bookingTime: DateTime.now(),
        tickets: const [
          Ticket(
            id: 'tkt_w_1',
            bookingId: 'bkg_widget_demo',
            seatId: 'E4',
            seatNumber: 'E4',
            row: 'E',
            col: 4,
            category: 'VIP Recliner',
            price: 550,
            qrData: 'SHOWSCAPE:bkg_widget_demo:E4',
          ),
          Ticket(
            id: 'tkt_w_2',
            bookingId: 'bkg_widget_demo',
            seatId: 'E5',
            seatNumber: 'E5',
            row: 'E',
            col: 5,
            category: 'VIP Recliner',
            price: 550,
            qrData: 'SHOWSCAPE:bkg_widget_demo:E5',
          ),
        ],
        priceBreakdown: const PriceBreakdown(
          basePrice: 1100,
          convenienceFee: 60,
          gst: 10.8,
          grandTotal: 1170.8,
        ),
        qrCodeData: 'SHOWSCAPE:bkg_widget_demo',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => TransferTicketSheet.show(
                    context,
                    booking: sampleBooking,
                  ),
                  child: const Text('Open Transfer Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Transfer Sheet'));
      await tester.pumpAndSettle();

      // Step 1: Select seats
      expect(find.text('Select Seats'), findsOneWidget);
      expect(find.text('Seat E4'), findsOneWidget);
      expect(find.text('Seat E5'), findsOneWidget);

      // Advance to Step 2
      final nextButton = find.byKey(const Key('next_transfer_step_cta'));
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 2: Choose Recipient
      expect(find.text('Choose Recipient'), findsOneWidget);
      expect(find.text('Contacts'), findsOneWidget);
      expect(find.text('Rahul Sharma'), findsOneWidget);

      // Advance to Step 3
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Step 3: Confirmation Sheet
      expect(find.text('Confirmation'), findsOneWidget);
      expect(find.text('TRANSFER SUMMARY'), findsOneWidget);
      expect(find.text('Transfers Lock 30m Before Showtime'), findsOneWidget);
      expect(find.byKey(const Key('confirm_transfer_cta')), findsOneWidget);
    });
  });
}
