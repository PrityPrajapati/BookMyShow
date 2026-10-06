import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:showscape/core/theme/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/transfer/domain/services/transfer_security_service.dart';

/// Gate staff scanner screen using mobile_scanner that validates entry passes
/// and HMAC-SHA256 signatures for tickets, transferred passes, and revoking invalidated QRs.
class StaffScannerScreen extends StatefulWidget {
  const StaffScannerScreen({super.key});

  @override
  State<StaffScannerScreen> createState() => _StaffScannerScreenState();
}

class _StaffScannerScreenState extends State<StaffScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _handleScannedCode(rawValue);
  }

  void _handleScannedCode(String qrData) {
    setState(() {
      _isProcessing = true;
    });

    // Validate using cryptographically secure HMAC verification
    final result = TransferSecurityService.validateQrPayload(qrData);

    if (result.isValid) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }

    _showValidationSheet(result, qrData);
  }

  void _showValidationSheet(QrValidationResult result, String qrData) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isSuccess = result.isValid;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: isSuccess ? AppColors.success : AppColors.error,
                  width: 2.5,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon Header
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isSuccess ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
                    color: isSuccess ? AppColors.success : AppColors.error,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                isSuccess ? 'PASS VERIFIED & VALID' : 'ENTRY REJECTED',
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? AppColors.success : AppColors.error,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                isSuccess
                    ? 'Cryptographic HMAC signature verified. Seat entry approved.'
                    : (result.errorReason ?? 'Invalid pass presented.'),
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // Pass Details Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceLight
                      : AppColors.lightSurfaceBorder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                ),
                child: Column(
                  children: [
                    _buildResultRow('Booking ID', result.bookingId ?? 'N/A'),
                    _buildResultRow('Seat / Pass', result.seatId ?? 'General'),
                    _buildResultRow('Ticket Holder', result.holderUid ?? 'N/A'),
                    if (result.expiry != null)
                      _buildResultRow(
                        'Pass Expiry',
                        DateFormat('hh:mm a, d MMM').format(result.expiry!),
                      ),
                    _buildResultRow(
                      'Security Version',
                      result.version == 2
                          ? 'HMAC-SHA256 (v2)'
                          : result.version == 1
                              ? 'Legacy Pass (v1)'
                              : 'Invalidated (v0)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Scan Next CTA
              ElevatedButton.icon(
                key: const Key('scan_next_button'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isProcessing = false;
                  });
                },
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(
                  isSuccess ? 'Admit & Scan Next' : 'Dismiss & Scan Next',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSuccess ? AppColors.success : AppColors.coral,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Dialog allowing gate staff to manually test any QR code string (for testing/simulators)
  Future<void> _showManualQrInputDialog() async {
    final textController = TextEditingController();

    // Default test samples
    final validHmac = TransferSecurityService.createSignedQrPayload(
      bookingId: 'bkg_1001',
      seatId: 'Seat E4',
      holderUid: 'usr_rahul_99',
      expiry: DateTime.now().add(const Duration(hours: 6)),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Test QR Payload'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter or pick a simulated QR code string to validate HMAC integrity:',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 3,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: const InputDecoration(
                  hintText: 'Paste QR string...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ActionChip(
                    label: const Text('Valid HMAC (Rahul)'),
                    onPressed: () => textController.text = validHmac,
                  ),
                  ActionChip(
                    label: const Text('Invalidated (Old Pass)'),
                    onPressed: () => textController.text =
                        'SHOWSCAPE:INVALIDATED:TRANSFERRED_TO_Rahul',
                  ),
                  ActionChip(
                    label: const Text('Tampered Payload'),
                    onPressed: () => textController.text =
                        'SHOWSCAPE:v2:bkg_1001:Seat_E4:usr_rahul:1772450000:fake_signature_abc123',
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              key: const Key('submit_test_qr_button'),
              onPressed: () => Navigator.of(ctx).pop(textController.text.trim()),
              child: const Text('Validate'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      _handleScannedCode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gate Staff Scanner', style: TextStyle(fontSize: 18)),
            Text(
              'ShowScape Entry Validation • HMAC-SHA256',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          // Torch toggle
          IconButton(
            tooltip: 'Toggle Flashlight',
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isTorchOn ? AppColors.amber : Colors.white,
            ),
            onPressed: () {
              _cameraController.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
          // Camera switch
          IconButton(
            tooltip: 'Switch Camera',
            icon: const Icon(Icons.flip_camera_ios_rounded),
            onPressed: () => _cameraController.switchCamera(),
          ),
          // Test QR Manual Input
          IconButton(
            key: const Key('manual_qr_test_button'),
            tooltip: 'Simulate / Test QR Code',
            icon: const Icon(Icons.keyboard_alt_outlined),
            onPressed: _showManualQrInputDialog,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. MobileScanner Viewfinder
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off_rounded,
                          color: AppColors.coral, size: 54),
                      const SizedBox(height: 12),
                      const Text(
                        'Camera Unavailable',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Testing in simulator or web? Use the manual QR input button above to test verification.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showManualQrInputDialog,
                        icon: const Icon(Icons.edit_note_rounded),
                        label: const Text('Test QR Code Manually'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 2. Reticle Overlay Frame
          IgnorePointer(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing
                      ? AppColors.amber
                      : AppColors.coral.withValues(alpha: 0.8),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (_isProcessing ? AppColors.amber : AppColors.coral)
                        .withValues(alpha: 0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Guidance Hint
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(AppRadius.r16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.coral, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Align patron QR code within the frame.\nSigned HMAC and transfer status will verify automatically.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _showManualQrInputDialog,
                    child: const Text('Test QR', style: TextStyle(color: AppColors.coral)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
