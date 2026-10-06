import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/gold_badge.dart';
import 'package:showscape/core/widgets/showscape_image.dart';
import 'package:showscape/core/widgets/ticket_stub_card.dart';
import 'package:showscape/features/dining/presentation/providers/dining_providers.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/domain/models/ticket.dart';
import 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart';
import 'package:showscape/features/tickets/presentation/widgets/night_out_itinerary_card.dart';

/// Tickets Tab Screen with Upcoming, Past, Transferred segments,
/// TicketStubCards with countdowns, and Hive offline caching with 'Offline' chip.
class TicketsScreen extends ConsumerWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSegment = ref.watch(selectedTicketsSegmentProvider);
    final upcomingList = ref.watch(upcomingBookingsProvider);
    final pastList = ref.watch(pastBookingsProvider);
    final transferredList = ref.watch(transferredBookingsProvider);
    final bookingsAsync = ref.watch(allUserBookingsProvider);
    final isOffline = ref.watch(isOfflineModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Tickets'),
        actions: [
          // Offline mode indicator & toggle
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                ref.read(isOfflineModeProvider.notifier).state = !isOffline;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    backgroundColor: !isOffline ? AppColors.amber : AppColors.success,
                    content: Text(
                      !isOffline
                          ? 'Offline Mode ON: Using cached tickets from Hive.'
                          : 'Offline Mode OFF: Connected to live service.',
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppRadius.r20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isOffline
                      ? AppColors.amber.withValues(alpha: 0.2)
                      : (isDark ? AppColors.surfaceLight : AppColors.lightSurfaceBorder),
                  borderRadius: BorderRadius.circular(AppRadius.r20),
                  border: Border.all(
                    color: isOffline
                        ? AppColors.amber
                        : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                      size: 16,
                      color: isOffline ? AppColors.amber : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOffline ? 'Offline' : 'Online',
                      style: AppTypography.labelSmall.copyWith(
                        color: isOffline ? AppColors.amber : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Staff Gate Scanner',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push(AppRoutes.staffScanner);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segment selector tab bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadius.r16),
                border: Border.all(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
              child: Row(
                children: [
                  _buildSegmentButton(
                    context: context,
                    ref: ref,
                    title: 'Upcoming',
                    count: upcomingList.length,
                    segment: TicketsSegment.upcoming,
                    isSelected: selectedSegment == TicketsSegment.upcoming,
                  ),
                  _buildSegmentButton(
                    context: context,
                    ref: ref,
                    title: 'Past',
                    count: pastList.length,
                    segment: TicketsSegment.past,
                    isSelected: selectedSegment == TicketsSegment.past,
                  ),
                  _buildSegmentButton(
                    context: context,
                    ref: ref,
                    title: 'Transferred',
                    count: transferredList.length,
                    segment: TicketsSegment.transferred,
                    isSelected: selectedSegment == TicketsSegment.transferred,
                  ),
                ],
              ),
            ),
          ),

          // Offline banner notification if in offline mode
          if (isOffline)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.r12),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.offline_pin_rounded, color: AppColors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Mode: Cached tickets & QR codes available without internet.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Bookings list per segment
          Expanded(
            child: bookingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load tickets', style: AppTypography.headlineSmall),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(allUserBookingsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (_) {
                final currentList = ref.watch(currentSegmentBookingsProvider);
                if (currentList.isEmpty) {
                  return _buildEmptyState(context, selectedSegment);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allUserBookingsProvider);
                    await ref.read(allUserBookingsProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final booking = currentList[index];
                      final reservation = ref
                          .watch(userReservationsProvider.notifier)
                          .getReservationForBooking(booking.id);
                      if (reservation != null) {
                        return NightOutItineraryCard(
                          booking: booking,
                          reservation: reservation,
                          isOffline: isOffline,
                        );
                      }
                      return _buildBookingStubCard(context, booking, isOffline);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Segment Tab Button
  // ===========================================================================

  Widget _buildSegmentButton({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required int count,
    required TicketsSegment segment,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(selectedTicketsSegmentProvider.notifier).state = segment;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.coral : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : AppColors.coral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.coral,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Ticket Stub Card for a Booking
  // ===========================================================================

  Widget _buildBookingStubCard(
    BuildContext context,
    Booking booking,
    bool isOffline,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countdown = formatTicketCountdown(booking.showTime);
    final dateFormatted = DateFormat('EEE, d MMM • hh:mm a').format(booking.showTime);
    final isPending = booking.tickets.any((t) => t.status == TicketStatus.pendingTransfer);
    final isTransferred = booking.tickets.any((t) => t.status == TicketStatus.transferred) ||
        booking.qrCodeData.contains('TRANSFERRED');
    final isCancelled = booking.status == BookingStatus.cancelled;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/ticket/${booking.id}');
      },
      child: TicketStubCard(
        notchRadius: 14.0,
        notchPositionFraction: 0.68,
        elevation: 4.0,
        topChild: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Poster + Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Poster
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  child: ShowScapeImage(
                    imageUrl: booking.eventPosterUrl ?? '',
                    width: 70,
                    height: 98,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),

                // Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges row
                      Row(
                        children: [
                          if (booking.showFormat != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          const GoldBadge(fontSize: 8, padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2)),
                          const SizedBox(width: 6),
                          if (isPending)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                          else if (isTransferred)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'TRANSFERRED TO RAHUL',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          else if (isCancelled)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'CONFIRMED',
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

                      // Title
                      Text(
                        booking.eventTitle ?? 'Event',
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Venue
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

            const SizedBox(height: 14),

            // Date / Time & Countdown Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceLight : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.coral),
                      const SizedBox(width: 6),
                      Text(
                        dateFormatted,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Live Countdown badge (‘Starts in 2h 10m’)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, color: AppColors.amber, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          isTransferred ? 'Transferred' : countdown,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomChild: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.tickets.isNotEmpty
                      ? 'Seats: ${booking.tickets.map((t) => t.seatNumber).join(', ')}'
                      : 'Booking: ${booking.bookingNumber}',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  booking.bookingNumber,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'View QR Pass',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.coral),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Empty State
  // ===========================================================================

  Widget _buildEmptyState(BuildContext context, TicketsSegment segment) {
    String title;
    String subtitle;
    IconData icon;

    switch (segment) {
      case TicketsSegment.upcoming:
        title = 'No Upcoming Shows';
        subtitle = 'You have no active bookings. Explore the latest movies, concerts, and live sports!';
        icon = Icons.confirmation_number_outlined;
        break;
      case TicketsSegment.past:
        title = 'No Past Bookings';
        subtitle = 'Completed shows and movie history will appear here.';
        icon = Icons.history_rounded;
        break;
      case TicketsSegment.transferred:
        title = 'No Transferred Tickets';
        subtitle = 'Tickets transferred to friends or received from contacts will appear here.';
        icon = Icons.swap_horiz_rounded;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.coral, size: 48),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTypography.headlineSmall.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.explore),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Explore Events'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coral,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
