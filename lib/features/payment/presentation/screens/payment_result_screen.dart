import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/primary_button.dart';
import 'package:showscape/core/widgets/secondary_button.dart';
import 'package:showscape/core/widgets/ticket_stub_card.dart';
import 'package:showscape/core/widgets/confetti_celebration.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/dining/presentation/widgets/dine_suggestions_card.dart';

class PaymentResultScreen extends ConsumerStatefulWidget {
  final bool isSuccess;
  final String? errorMessage;
  final bool autoStartHoldTimer;

  const PaymentResultScreen({
    super.key,
    this.isSuccess = true,
    this.errorMessage,
    this.autoStartHoldTimer = true,
  });

  @override
  ConsumerState<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends ConsumerState<PaymentResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _showBackSide = false;

  // 8-minute seat hold timer for retry flow
  Timer? _holdCountdownTimer;
  int _holdSecondsRemaining = 8 * 60; // 480 seconds

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    )..addListener(() {
        if (_flipAnimation.value >= 0.5 && !_showBackSide) {
          setState(() => _showBackSide = true);
        } else if (_flipAnimation.value < 0.5 && _showBackSide) {
          setState(() => _showBackSide = false);
        }
      });

    if (!widget.isSuccess && widget.autoStartHoldTimer) {
      _startHoldTimer();
    }
  }

  void _startHoldTimer() {
    _holdCountdownTimer?.cancel();
    _holdCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_holdSecondsRemaining > 0) {
        setState(() => _holdSecondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _holdCountdownTimer?.cancel();
    super.dispose();
  }

  void _toggleFlip() {
    HapticFeedback.lightImpact();
    if (_flipController.isCompleted) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  void _addToCalendar(BookingDraft draft) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Added to calendar: ${draft.eventTitle ?? 'Movie'} on Sat, 3 Oct',
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimer(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);

    if (!widget.isSuccess) {
      return _buildFailureView(context, draft);
    }

    final restaurantsAsync = ref.watch(restaurantsProvider);

    final bookingId = 'SS-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.lavender),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          children: [
            // Lottie Success / Confetti Animation
            SizedBox(
              height: 110,
              child: Center(
                child: Lottie.network(
                  'https://assets2.lottiefiles.com/packages/lf20_jbrwutsd.json',
                  repeat: false,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 48,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
            ),

            Text(
              'Booking Confirmed!',
              style: AppTypography.heading24().copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.vertical4,
            Text(
              'Booking ID: $bookingId',
              style: AppTypography.caption12(color: AppColors.marqueeAmber).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            AppSpacing.vertical4,
            Text(
              'Tickets sent to your registered email & phone',
              style: AppTypography.body14(color: AppColors.lavenderMuted).copyWith(fontSize: 12),
            ),

            AppSpacing.vertical20,

            // Flippable 3D Ticket Stub Preview
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleFlip,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final angle = _flipAnimation.value * pi;
                  final isUnder = _flipAnimation.value > 0.5;

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isUnder
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(pi),
                            alignment: Alignment.center,
                            child: _buildTicketBack(draft, bookingId),
                          )
                        : _buildTicketFront(draft, bookingId),
                  );
                },
              ),
            ),

            AppSpacing.vertical8,

            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleFlip,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flip_rounded, size: 14, color: AppColors.lavenderMuted),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Tap ticket to flip for venue map & QR pass',
                      style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.vertical24,

            // Action Buttons: 'Add to calendar' and 'View ticket'
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Add to Calendar',
                    icon: const Icon(Icons.event_available_rounded, size: 18),
                    onPressed: () => _addToCalendar(draft),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'View Ticket',
                    icon: const Icon(Icons.confirmation_number_rounded, size: 18),
                    onPressed: () => context.push(AppRoutes.ticketPath(bookingId)),
                  ),
                ),
              ],
            ),

            AppSpacing.vertical24,

            // Dine Before & Dine After Suggestions aligned with showtime + 15m walking buffer
            DineSuggestionsCard(
              showStart: draft.showTime ?? DateTime.now().add(const Duration(hours: 3)),
              showEnd: (draft.showTime ?? DateTime.now().add(const Duration(hours: 3))).add(const Duration(minutes: 150)),
              venueId: draft.venueId ?? 'venue_01',
              bookingId: bookingId,
              venueName: draft.venueName,
            ),

            AppSpacing.vertical24,

            // 'Complete your night' Section with Nearby Restaurants
            _buildCompleteYourNightSection(restaurantsAsync),
          ],
        ),
      ),
      const Positioned.fill(
        child: IgnorePointer(
          child: ConfettiCelebration(),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildTicketFront(BookingDraft draft, String bookingId) {
    return TicketStubCard(
      topChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CINEMA PASS',
                style: AppTypography.caption12(color: AppColors.spotlightCoral).copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'IMAX 2D',
                  style: AppTypography.caption12(color: AppColors.spotlightCoral).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vertical8,
          Text(
            draft.eventTitle ?? 'Dune: Part Two',
            style: AppTypography.heading20().copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.vertical4,
          Text(
            draft.venueName ?? 'PVR INOX: Phoenix Palladium • Audi 3',
            style: AppTypography.body14(color: AppColors.lavenderMuted).copyWith(
              fontSize: 12,
            ),
          ),
          AppSpacing.vertical12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DATE & TIME', style: AppTypography.caption12(color: AppColors.lavenderMuted)),
                    Text(
                      draft.showTime != null
                          ? DateFormat('EEE, d MMM • hh:mm a').format(draft.showTime!)
                          : 'Sat, 3 Oct • 07:30 PM',
                      style: AppTypography.body14(color: AppColors.lavender).copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SEATS', style: AppTypography.caption12(color: AppColors.lavenderMuted)),
                  Text(
                    draft.seatIds.isNotEmpty ? draft.seatIds.join(', ') : 'E-5, E-6',
                    style: AppTypography.body14(color: AppColors.marqueeAmber).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      bottomChild: Column(
        children: [
          Center(
            child: QrImageView(
              data: 'SHOWSCAPE:$bookingId',
              version: QrVersions.auto,
              size: 100.0,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.lavender,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.lavender,
              ),
            ),
          ),
          AppSpacing.vertical8,
          Text(
            bookingId,
            style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
              letterSpacing: 2.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketBack(BookingDraft draft, String bookingId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.spotlightCoral.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ENTRY PASS & AMENITIES',
                style: AppTypography.heading20().copyWith(
                  fontSize: 14,
                  color: AppColors.spotlightCoral,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.qr_code_2_rounded, color: AppColors.spotlightCoral),
            ],
          ),
          const Divider(color: AppColors.surfaceBorder, height: 20),

          // Venue & Entrance
          Text(
            'Cinema Directions',
            style: AppTypography.caption12(color: AppColors.lavenderMuted),
          ),
          Text(
            'Level 4, High Street Phoenix, Lower Parel',
            style: AppTypography.body14(color: AppColors.lavender).copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.vertical12,

          // Parking Pass info if booked
          if (draft.parking != null) ...[
            Text(
              'Reserved Smart Parking',
              style: AppTypography.caption12(color: AppColors.lavenderMuted),
            ),
            Text(
              '${draft.parking!.lot.name} • Plate: ${draft.parking!.vehicleNumber}',
              style: AppTypography.body14(color: AppColors.marqueeAmber).copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vertical12,
          ],

          // Food pickup code if booked
          if (draft.fnbItems.isNotEmpty) ...[
            Text(
              'Food Concession Pickup',
              style: AppTypography.caption12(color: AppColors.lavenderMuted),
            ),
            Text(
              'Pickup at Counter #2 • ${draft.pickupTiming == PickupTiming.beforeShow ? 'Before Show' : 'At Interval'}',
              style: AppTypography.body14(color: AppColors.success).copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.vertical12,
          ],

          // QR Code verification
          Center(
            child: QrImageView(
              data: 'SHOWSCAPE_VERIFY:$bookingId',
              version: QrVersions.auto,
              size: 110.0,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.lavender,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.lavender,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteYourNightSection(AsyncValue<List<dynamic>> restaurantsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Your Night',
                    style: AppTypography.heading20().copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Popular dining & cocktail bars within 500m',
                    style: AppTypography.caption12(color: AppColors.lavenderMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => context.push(AppRoutes.dining),
              child: Text(
                'Explore All',
                style: AppTypography.buttonLabel(color: AppColors.spotlightCoral).copyWith(
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.vertical12,

        // Restaurant cards rail
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildRestaurantCard(
                name: 'Bastian - At The Top',
                cuisine: 'Asian Seafood • Rooftop Lounge',
                rating: 4.8,
                distance: '150m walk',
                offer: '15% off with cinema ticket',
                imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500',
              ),
              _buildRestaurantCard(
                name: 'The Bombay Canteen',
                cuisine: 'Modern Indian • Craft Cocktails',
                rating: 4.9,
                distance: '300m walk',
                offer: 'Complimentary dessert',
                imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
              ),
              _buildRestaurantCard(
                name: 'Smoke House Deli',
                cuisine: 'European Comfort Food • Wine Bar',
                rating: 4.7,
                distance: 'Inside Mall • Level 3',
                offer: '10% off bill',
                imageUrl: 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=500',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard({
    required String name,
    required String cuisine,
    required double rating,
    required String distance,
    required String offer,
    required String imageUrl,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border16,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 85,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surfaceElevated),
              errorWidget: (_, __, ___) => Container(
                color: AppColors.surfaceElevated,
                child: const Icon(Icons.restaurant_rounded, color: AppColors.lavenderMuted),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTypography.heading20().copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: AppColors.marqueeAmber),
                        const SizedBox(width: 2),
                        Text(
                          '$rating',
                          style: AppTypography.caption12(color: AppColors.marqueeAmber).copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  cuisine,
                  style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vertical4,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    offer,
                    style: AppTypography.caption12(color: AppColors.success).copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureView(BuildContext context, BookingDraft draft) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.lavender),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ),
            AppSpacing.vertical20,
            Text(
              'Payment Failed',
              style: AppTypography.heading24().copyWith(fontWeight: FontWeight.w700),
            ),
            AppSpacing.vertical8,
            Text(
              widget.errorMessage ?? 'Payment was cancelled or rejected by your banking provider.',
              textAlign: TextAlign.center,
              style: AppTypography.body14(color: AppColors.lavenderMuted),
            ),
            AppSpacing.vertical24,

            // Active Seat Hold Countdown Timer Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.border16,
                border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_top_rounded, color: AppColors.marqueeAmber, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Seats Held For: ${_formatTimer(_holdSecondsRemaining)}',
                          style: AppTypography.heading20().copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.marqueeAmber,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vertical8,
                  Text(
                    'Your selected seats (${draft.seatIds.join(', ')}) are reserved for 8 minutes. You will not lose them if you retry now.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption12(color: AppColors.lavenderMuted),
                  ),
                ],
              ),
            ),

            AppSpacing.vertical32,

            PrimaryButton(
              text: 'Retry Payment',
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
            AppSpacing.vertical12,
            SecondaryButton(
              text: 'Choose Another Payment Method',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
