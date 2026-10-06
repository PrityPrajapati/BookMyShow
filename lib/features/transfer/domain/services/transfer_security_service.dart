import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Validation result returned when verifying a gate entry QR code
class QrValidationResult {
  const QrValidationResult({
    required this.isValid,
    this.isExpired = false,
    this.bookingId,
    this.seatId,
    this.holderUid,
    this.expiry,
    this.signature,
    this.errorReason,
    this.version = 1,
  });

  final bool isValid;
  final bool isExpired;
  final String? bookingId;
  final String? seatId;
  final String? holderUid;
  final DateTime? expiry;
  final String? signature;
  final String? errorReason;
  final int version;

  @override
  String toString() =>
      'QrValidationResult(valid: $isValid, expired: $isExpired, booking: $bookingId, seat: $seatId, holder: $holderUid, error: $errorReason)';
}

/// Service providing cryptographically secure HMAC signatures for tickets and gate validation
class TransferSecurityService {
  static const String defaultSecret = 'SHOWSCAPE_SECURE_GATE_KEY_2026';

  /// Generate HMAC-SHA256 signature for (bookingId + seatId + holderUid + expiry)
  static String generateHmacSignature({
    required String bookingId,
    required String seatId,
    required String holderUid,
    required int expiryEpochSeconds,
    String secretKey = defaultSecret,
  }) {
    final payload = '$bookingId:$seatId:$holderUid:$expiryEpochSeconds';
    final keyBytes = utf8.encode(secretKey);
    final payloadBytes = utf8.encode(payload);

    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(payloadBytes);
    return digest.toString();
  }

  /// Creates a signed QR payload containing metadata and HMAC signature
  static String createSignedQrPayload({
    required String bookingId,
    required String seatId,
    required String holderUid,
    required DateTime expiry,
    String secretKey = defaultSecret,
  }) {
    final expiryEpoch = expiry.millisecondsSinceEpoch ~/ 1000;
    final signature = generateHmacSignature(
      bookingId: bookingId,
      seatId: seatId,
      holderUid: holderUid,
      expiryEpochSeconds: expiryEpoch,
      secretKey: secretKey,
    );

    // Format: SHOWSCAPE:v2:<bookingId>:<seatId>:<holderUid>:<expiryEpoch>:<signature>
    return 'SHOWSCAPE:v2:$bookingId:$seatId:$holderUid:$expiryEpoch:$signature';
  }

  /// Validates a QR code string against HMAC signature and expiration
  static QrValidationResult validateQrPayload(
    String qrData, {
    String secretKey = defaultSecret,
    DateTime? currentTime,
  }) {
    final nowEpoch = (currentTime ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;

    // 1. HMAC v2 format validation
    if (qrData.startsWith('SHOWSCAPE:v2:')) {
      final parts = qrData.split(':');
      if (parts.length < 7) {
        return const QrValidationResult(
          isValid: false,
          errorReason: 'Malformed QR payload format (expected 7 components)',
          version: 2,
        );
      }

      final bookingId = parts[2];
      final seatId = parts[3];
      final holderUid = parts[4];
      final expiryEpoch = int.tryParse(parts[5]);
      final receivedSignature = parts[6];

      if (expiryEpoch == null) {
        return const QrValidationResult(
          isValid: false,
          errorReason: 'Invalid expiration timestamp in QR payload',
          version: 2,
        );
      }

      final expectedSignature = generateHmacSignature(
        bookingId: bookingId,
        seatId: seatId,
        holderUid: holderUid,
        expiryEpochSeconds: expiryEpoch,
        secretKey: secretKey,
      );

      if (expectedSignature != receivedSignature) {
        return QrValidationResult(
          isValid: false,
          bookingId: bookingId,
          seatId: seatId,
          holderUid: holderUid,
          errorReason: 'Tampered QR: Cryptographic signature mismatch',
          version: 2,
        );
      }

      final isExpired = nowEpoch > expiryEpoch;
      if (isExpired) {
        return QrValidationResult(
          isValid: false,
          isExpired: true,
          bookingId: bookingId,
          seatId: seatId,
          holderUid: holderUid,
          expiry: DateTime.fromMillisecondsSinceEpoch(expiryEpoch * 1000),
          errorReason: 'Pass has expired',
          version: 2,
        );
      }

      return QrValidationResult(
        isValid: true,
        bookingId: bookingId,
        seatId: seatId,
        holderUid: holderUid,
        expiry: DateTime.fromMillisecondsSinceEpoch(expiryEpoch * 1000),
        signature: receivedSignature,
        version: 2,
      );
    }

    // 2. Check for invalidated / revoked pass
    if (qrData.startsWith('SHOWSCAPE:INVALIDATED:')) {
      final reason = qrData.replaceFirst('SHOWSCAPE:INVALIDATED:', '');
      return QrValidationResult(
        isValid: false,
        errorReason: 'Ticket is invalid: $reason',
        version: 0,
      );
    }

    // 3. Legacy / v1 verification fallback
    if (qrData.startsWith('SHOWSCAPE:')) {
      final parts = qrData.split(':');
      final bookingId = parts.length > 1 ? parts[1] : 'unknown';
      final seatId = parts.length > 2 ? parts[2] : 'unknown';

      return QrValidationResult(
        isValid: true,
        bookingId: bookingId,
        seatId: seatId,
        holderUid: 'legacy_holder',
        version: 1,
      );
    }

    return const QrValidationResult(
      isValid: false,
      errorReason: 'Unknown QR code format: Not a verified ShowScape pass',
      version: 0,
    );
  }
}
