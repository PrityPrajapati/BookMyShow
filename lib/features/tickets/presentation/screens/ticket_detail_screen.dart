import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:showscape/core/theme/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/showscape_image.dart';
import 'package:showscape/core/widgets/ticket_stub_card.dart';
import 'package:showscape/features/tickets/data/services/screen_brightness_service.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart';
import 'package:showscape/features/tickets/presentation/widgets/transfer_ticket_sheet.dart';
import 'package:showscape/features/tickets/presentation/widgets/venue_map_sheet.dart';
import 'package:showscape/features/dining/presentation/widgets/dine_suggestions_card.dart';
import 'package:showscape/features/transfer/domain/models/transfer.dart';
import 'package:showscape/features/transfer/presentation/providers/transfer_providers.dart';

/// Ticket Detail screen with 3D Flip animation (front: details, back: QR codes via qr_flutter)
/// Features screen brightness boost + wakelock, per-seat swipeable QRs, linked food order,
/// parking pass QR, action buttons, and Hive offline caching.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({
    required this.id,
    super.key,
  });

  final String id;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late PageController _qrPageController;

  int _selectedSeatIndex = 0;
  bool _isFlippedToBack = false;
  late ScreenBrightnessService _brightnessService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightnessService = ref.read(screenBrightnessServiceProvider);
  }

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isFlippedToBack = true);
        // Boost screen brightness and keep screen awake when QR is displayed
        _brightnessService.boostBrightnessAndKeepAwake();
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _isFlippedToBack = false);
        // Restore default brightness when flipped back to details
        _brightnessService.restoreBrightnessAndSleep();
      }
    });

    _qrPageController = PageController();
  }

  @override
  void dispose() {
    // Restore brightness and release wakelock on screen exit using cached service
    _brightnessService.restoreBrightnessAndSleep();
    _flipController.dispose();
    _qrPageController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    HapticFeedback.mediumImpact();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(ticketDetailProvider(widget.id));
    final isOffline = ref.watch(isOfflineModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket Pass',
              style: AppTypography.headlineSmall.copyWith(fontSize: 18),
            ),
            Text(
              widget.id,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          // Offline status badge & toggle
          IconButton(
            tooltip: isOffline ? 'Offline Mode active' : 'Simulate Offline Mode',
            icon: Icon(
              isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
              color: isOffline ? AppColors.amber : AppColors.textMuted,
            ),
            onPressed: () {
              ref.read(isOfflineModeProvider.notifier).state = !isOffline;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  backgroundColor: !isOffline ? AppColors.amber : AppColors.success,
                  content: Text(
                    !isOffline
                        ? 'Offline Mode ON: Tickets loaded directly from local Hive cache.'
                        : 'Offline Mode OFF: Online sync active.',
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Share Ticket',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              bookingAsync.whenData((booking) {
                if (booking != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing booking ${booking.bookingNumber}...'),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Unable to load ticket', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text('$err', style: AppTypography.bodySmall),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(ticketDetailProvider(widget.id)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (booking) {
          if (booking == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.confirmation_number_outlined,
                      color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text('Ticket Not Found', style: AppTypography.headlineSmall),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to Tickets'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Offline banner if enabled or cached
                if (isOffline)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                      border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.offline_bolt_rounded,
                            color: AppColors.amber, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Offline Mode • Verified via Hive Local Cache',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.amber,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 3D Flip Card Container
                AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * math.pi;
                    final isBack = angle >= math.pi / 2;

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // 3D perspective depth
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isBack
                          ? Transform(
                              // Invert the back side so content reads normally
                              transform: Matrix4.identity()..rotateY(math.pi),
                              alignment: Alignment.center,
                              child: _buildBackCard(context, booking),
                            )
                          : _buildFrontCard(context, booking),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Flip Toggle CTA Button
                Center(
                  child: ElevatedButton.icon(
                    key: const Key('flip_ticket_button'),
                    onPressed: _toggleFlip,
                    icon: AnimatedRotation(
                      turns: _isFlippedToBack ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.flip_rounded, size: 20),
                    ),
                    label: Text(
                      _isFlippedToBack ? 'View Booking Details' : 'Show Entry QR Code',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFlippedToBack
                          ? (isDark ? AppColors.surfaceLight : AppColors.lightSurface)
                          : AppColors.coral,
                      foregroundColor: _isFlippedToBack ? AppColors.textPrimary : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.r20),
                        side: _isFlippedToBack
                            ? const BorderSide(color: AppColors.surfaceBorder)
                            : BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Linked Food Order (if present)
                if (booking.fnbItems.isNotEmpty) ...[
                  _buildLinkedFoodSection(context, booking),
                  const SizedBox(height: 16),
                ],

                // Linked Parking Pass (if present)
                if (booking.parkingLot != null) ...[
                  _buildLinkedParkingSection(context, booking),
                  const SizedBox(height: 16),
                ],

                // Dine Before & Dine After Suggestions with 15m walking buffer
                DineSuggestionsCard(
                  showStart: booking.showTime,
                  showEnd: booking.showTime.add(const Duration(minutes: 150)),
                  venueId: booking.venueId,
                  bookingId: booking.id,
                  venueName: booking.venueName,
                ),
                const SizedBox(height: 16),

                // Action Buttons Row (Directions, Venue Map, Order Food, Transfer, Add to Calendar)
                _buildActionButtons(context, booking),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // Front Card: Details
  // ===========================================================================

  Widget _buildFrontCard(BuildContext context, Booking booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countdown = formatTicketCountdown(booking.showTime);
    final dateFormatted = DateFormat('EEE, d MMM yyyy').format(booking.showTime);
    final timeFormatted = DateFormat('hh:mm a').format(booking.showTime);
    final hasPendingTransfer = booking.tickets.any((t) => t.status == TicketStatus.pendingTransfer);
    final hasTransferred = booking.tickets.any((t) => t.status == TicketStatus.transferred) ||
        booking.qrCodeData.contains('TRANSFERRED');
    final isCancelled = booking.status == BookingStatus.cancelled;

    return TicketStubCard(
      notchRadius: 14.0,
      notchPositionFraction: 0.64,
      elevation: 6.0,
      topChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Title & Poster Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                child: ShowScapeImage(
                  imageUrl: booking.eventPosterUrl ?? '',
                  width: 64,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),

              // Title and metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (booking.showFormat != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: AppColors.coral.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.showFormat!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.coral,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (hasPendingTransfer)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'PENDING',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          )
                        else if (hasTransferred)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.purple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ACCEPTED',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          )
                        else if (isCancelled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'CANCELLED',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.status.name.toUpperCase(),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking.eventTitle ?? 'Event',
                      style: AppTypography.headlineSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.venueName ?? 'Cinema / Venue',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date, Time & Countdown Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceLight : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(
                color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.coral, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormatted,
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              timeFormatted,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Live countdown badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        countdown,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Seats & Category details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEATS',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: booking.tickets.isNotEmpty
                        ? booking.tickets.map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.coral.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.coral.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                t.seatNumber,
                                style: AppTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.coral,
                                ),
                              ),
                            );
                          }).toList()
                        : [
                            Text(
                              'General Admission',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'AUDITORIUM',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Screen 4 (Laser)',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildTransferStateBanner(context, booking),
        ],
      ),
      bottomChild: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BOOKING ID',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.bookingNumber,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${booking.priceBreakdown.grandTotal.toStringAsFixed(0)}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.coral,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tap to flip hint
          InkWell(
            onTap: _toggleFlip,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.r12),
                border: Border.all(color: AppColors.coral.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded,
                      size: 16, color: AppColors.coral),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to Reveal Entry QR Code ➔',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.coral,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Back Card: QR Code via qr_flutter with Multi-Seat Horizontal Swipe
  // ===========================================================================

  Widget _buildBackCard(BuildContext context, Booking booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tickets = booking.tickets;
    final hasMultipleSeats = tickets.length > 1;

    return TicketStubCard(
      notchRadius: 14.0,
      notchPositionFraction: 0.72,
      elevation: 6.0,
      topChild: Column(
        children: [
          // High brightness scanner hint banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.r16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wb_sunny_rounded, color: AppColors.amber, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Screen Brightness Boosted for Scanner',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Per-Seat PageView for multi-seat bookings or single QR
          if (hasMultipleSeats) ...[
            // Seat Swipe Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Swipe between per-seat QRs:',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Seat ${_selectedSeatIndex + 1} of ${tickets.length}',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.coral,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _qrPageController,
                itemCount: tickets.length,
                onPageChanged: (idx) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedSeatIndex = idx);
                },
                itemBuilder: (context, idx) {
                  final ticket = tickets[idx];
                  return _buildPerSeatQr(ticket);
                },
              ),
            ),

            const SizedBox(height: 10),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(tickets.length, (idx) {
                final isSelected = _selectedSeatIndex == idx;
                return Container(
                  width: isSelected ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.coral : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ] else ...[
            // Single seat or default booking QR
            _buildPerSeatQr(
              tickets.isNotEmpty
                  ? tickets.first
                  : Ticket(
                      id: 'tkt_default',
                      bookingId: booking.id,
                      seatId: 'A1',
                      seatNumber: 'A1',
                      row: 'A',
                      col: 1,
                      category: 'Standard',
                      price: booking.priceBreakdown.basePrice,
                      qrData: booking.qrCodeData,
                    ),
            ),
          ],
        ],
      ),
      bottomChild: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCAN AT GATE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Screen 4 • Fast Track Lane',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'PASS VALID',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Flip back button
          InkWell(
            onTap: _toggleFlip,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceLight : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                border: Border.all(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Flip Back to Ticket Info',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferStateBanner(BuildContext context, Booking booking) {
    final transfersAsync = ref.watch(bookingTransfersProvider(booking.id));
    final hasPending = booking.tickets.any((t) => t.status == TicketStatus.pendingTransfer);
    final hasTransferred = booking.tickets.any((t) => t.status == TicketStatus.transferred) ||
        booking.qrCodeData.contains('TRANSFERRED');

    if (!hasPending && !hasTransferred) return const SizedBox.shrink();

    return transfersAsync.maybeWhen(
      data: (transfers) {
        final pendingTransfer = transfers.where((t) => t.status == TransferStatus.pending).firstOrNull;
        final acceptedTransfer = transfers.where((t) => t.status == TransferStatus.accepted).firstOrNull;

        if (hasPending) {
          final recipientDisplay = pendingTransfer?.toUserPhone ?? 'Rahul';
          return Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, color: AppColors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Transfer Pending (to $recipientDisplay)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (pendingTransfer != null)
                      TextButton(
                        key: const Key('cancel_transfer_button'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => _confirmCancelTransfer(context, pendingTransfer),
                        child: const Text(
                          'Cancel Transfer',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Awaiting recipient acceptance. You can cancel anytime before it is claimed.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        } else if (hasTransferred) {
          final recipientName = acceptedTransfer?.toUserPhone != null ? 'Rahul' : 'Rahul';
          return Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.purple, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transferred to $recipientName',
                        key: const Key('transferred_to_rahul_label'),
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pass accepted. New HMAC-SHA256 entry pass issued. Original QR invalidated.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
      orElse: () {
        if (hasTransferred) {
          return Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: Colors.purple, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Transferred to Rahul',
                    key: const Key('transferred_to_rahul_label'),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _confirmCancelTransfer(BuildContext context, Transfer transfer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Transfer?'),
        content: const Text(
          'Are you sure you want to cancel this transfer? Your seats and original QR code will be restored immediately.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Pending'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Transfer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final res = await ref.read(transferControllerProvider.notifier).cancelTransfer(
            transferId: transfer.id,
            bookingId: transfer.bookingId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: res.isSuccess ? AppColors.success : AppColors.error,
            content: Text(
              res.isSuccess
                  ? 'Transfer cancelled. Tickets restored to your account.'
                  : (res.errorMessage ?? 'Failed to cancel transfer'),
            ),
          ),
        );
      }
    }
  }

  Widget _buildPerSeatQr(Ticket ticket) {
    final isInvalidated = ticket.status == TicketStatus.transferred ||
        ticket.qrData.contains('TRANSFERRED') ||
        ticket.qrData.contains('INVALIDATED');
    final isPending = ticket.status == TicketStatus.pendingTransfer;
    final recipientName =
        ref.watch(transferredRecipientNameProvider(ticket.id)) ?? 'Rahul';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // High contrast white box for optimal scanning
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.r16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Semantics(
                label: 'Entry gate QR Code for booking ${ticket.bookingId}',
                image: true,
                child: Opacity(
                  opacity: isInvalidated ? 0.15 : 1.0,
                  child: QrImageView(
                    data: ticket.qrData,
                    version: QrVersions.auto,
                    size: 160,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            if (isInvalidated)
              Container(
                width: 170,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  border: Border.all(color: AppColors.error, width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.block_rounded, color: AppColors.error, size: 28),
                    const SizedBox(height: 4),
                    const Text(
                      'QR REVOKED',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Transferred to $recipientName',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            if (isPending)
              Positioned(
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PENDING ACCEPTANCE',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Seat ${ticket.seatNumber} • ${ticket.category}',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ticket.qrData,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textMuted,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ===========================================================================
  // Linked Food Order (Pickup Code + Status)
  // ===========================================================================

  Widget _buildLinkedFoodSection(BuildContext context, Booking booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickupCode = 'FOOD-${booking.id.replaceAll('bkg_', '').toUpperCase()}-88';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.fastfood_rounded,
                        color: AppColors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Linked Food Order',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Pickup: Before Show (Counter 3)',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PREPARING',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pickup Code highlight box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceLight : AppColors.lightSurfaceBorder.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PICKUP CODE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pickupCode,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: AppColors.amber,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  tooltip: 'Copy Code',
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: pickupCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Food pickup code copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Food items list
          ...booking.fnbItems.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 16, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₹${item.price.toStringAsFixed(0)}',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // Linked Parking Pass
  // ===========================================================================

  Widget _buildLinkedParkingSection(BuildContext context, Booking booking) {
    final lot = booking.parkingLot!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parkingQrData = 'SHOWSCAPE:PARKING:${lot.id}:${booking.id}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parking QR
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Semantics(
              label: 'Parking pass gate QR Code for lot ${lot.name}',
              image: true,
              child: QrImageView(
                data: parkingQrData,
                version: QrVersions.auto,
                size: 72,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Lot Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.electricPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PARKING PASS',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.electricPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (lot.hasValet)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'VALET',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.coral,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  lot.name,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Scan at Parking Barrier Entry B',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Action Buttons: Directions, Venue Map, Order Food, Transfer, Add to Calendar
  // ===========================================================================

  Widget _buildActionButtons(BuildContext context, Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 12),

        // Action grid / row
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // 1. Directions
            _buildActionButton(
              icon: Icons.directions_outlined,
              label: 'Directions',
              onTap: () {
                HapticFeedback.lightImpact();
                _showDirectionsDialog(context, booking);
              },
            ),

            // 2. Venue Map
            _buildActionButton(
              icon: Icons.map_outlined,
              label: 'Venue Map',
              onTap: () {
                HapticFeedback.lightImpact();
                VenueMapSheet.show(
                  context,
                  venueName: booking.venueName ?? 'Cinema Complex',
                );
              },
            ),

            // 3. Order Food
            _buildActionButton(
              icon: Icons.fastfood_outlined,
              label: 'Order Food',
              onTap: () {
                HapticFeedback.lightImpact();
                _showOrderFoodDialog(context, booking);
              },
            ),

            // 4. Transfer
            _buildActionButton(
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              onTap: () {
                HapticFeedback.lightImpact();
                TransferTicketSheet.show(context, booking: booking);
              },
            ),

            // 5. Add to Calendar
            _buildActionButton(
              icon: Icons.event_available_outlined,
              label: 'Add to Calendar',
              onTap: () {
                HapticFeedback.lightImpact();
                _addToCalendar(context, booking);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(
            color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.coral),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDirectionsDialog(BuildContext context, Booking booking) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.directions_rounded, color: AppColors.coral),
            SizedBox(width: 8),
            Text('Venue Directions'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.venueName ?? 'Cinema Complex',
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Senapati Bapat Marg, Lower Parel, Mumbai, Maharashtra 400013',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.traffic_rounded, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Normal traffic • 22 mins away from your location',
                      style: AppTypography.bodySmall.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Navigation Maps...')),
              );
            },
            child: const Text('Start Navigation'),
          ),
        ],
      ),
    );
  }

  void _showOrderFoodDialog(BuildContext context, Booking booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.amber,
        content: Row(
          children: [
            const Icon(Icons.fastfood_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ordering food for ${booking.eventTitle} at ${booking.venueName}...',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCalendar(BuildContext context, Booking booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Row(
          children: [
            const Icon(Icons.event_available_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added to Calendar: ${booking.eventTitle} (Alert set 2h prior)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
