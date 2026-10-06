import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/features/dining/domain/models/reservation.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart';

/// Night Out Itinerary Card grouping a Show booking with its linked Dining Table Reservation
class NightOutItineraryCard extends StatelessWidget {
  final Booking booking;
  final Reservation reservation;
  final bool isOffline;

  const NightOutItineraryCard({
    super.key,
    required this.booking,
    required this.reservation,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final countdown = formatTicketCountdown(booking.showTime);
    final isBeforeShow = reservation.specialRequests?.contains('DINE BEFORE') ?? true;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: AppColors.marqueeAmber.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.marqueeAmber.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Night Out Golden Header Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.marqueeAmber.withValues(alpha: 0.25),
                  AppColors.spotlightCoral.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.marqueeAmber, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'NIGHT OUT ITINERARY',
                  style: TextStyle(
                    color: AppColors.marqueeAmber,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.success, width: 0.8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.success, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'CONFIRMED',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Timeline representation
                if (booking.parkingLot != null) ...[
                  // Parking step
                  _buildTimelineItem(
                    context: context,
                    isDark: isDark,
                    icon: Icons.local_parking_rounded,
                    iconColor: Colors.blueAccent,
                    time: DateFormat('h:mm a').format(
                      booking.showTime.subtract(const Duration(minutes: 15)),
                    ),
                    title: 'Reserved Parking at ${booking.parkingLot!.name}',
                    subtitle:
                        'Guaranteed 4-Wheeler Slot Reserved',
                    isFirst: true,
                  ),
                  _buildWalkingConnector(isDark, text: 'Direct entrance to venue'),
                  // Show step
                  _buildTimelineItem(
                    context: context,
                    isDark: isDark,
                    icon: Icons.theater_comedy_rounded,
                    iconColor: AppColors.lavender,
                    time: DateFormat('h:mm a').format(booking.showTime),
                    title: booking.eventTitle ?? 'Live Show',
                    subtitle:
                        '${booking.venueName ?? "Cinema"} • ${booking.tickets.length} Seats (${booking.tickets.map((t) => t.seatNumber).join(", ")})',
                    isFirst: false,
                  ),
                  _buildWalkingConnector(isDark, text: '15 min walk buffer'),
                  // Dinner step
                  _buildTimelineItem(
                    context: context,
                    isDark: isDark,
                    icon: Icons.restaurant_rounded,
                    iconColor: AppColors.spotlightCoral,
                    time: reservation.timeSlot,
                    title: 'Dinner at ${reservation.restaurantName ?? "Restaurant"}',
                    subtitle:
                        'Party of ${reservation.partySize} guests • 20% off with ticket',
                    isFirst: false,
                  ),
                ] else ...[
                  _buildTimelineItem(
                    context: context,
                    isDark: isDark,
                    icon: isBeforeShow
                        ? Icons.restaurant_rounded
                        : Icons.movie_rounded,
                    iconColor: isBeforeShow
                        ? AppColors.spotlightCoral
                        : AppColors.lavender,
                    time: isBeforeShow
                        ? reservation.timeSlot
                        : DateFormat('h:mm a').format(booking.showTime),
                    title: isBeforeShow
                        ? 'Dinner at ${reservation.restaurantName ?? "Restaurant"}'
                        : (booking.eventTitle ?? 'Movie Show'),
                    subtitle: isBeforeShow
                        ? 'Party of ${reservation.partySize} guests • 20% off with ticket'
                        : '${booking.venueName ?? "Cinema"} • ${booking.tickets.length} Seats (${booking.tickets.map((t) => t.seatNumber).join(", ")})',
                    isFirst: true,
                  ),

                  // Walking connector
                  _buildWalkingConnector(isDark, text: '15 min scenic walk buffer'),

                  _buildTimelineItem(
                    context: context,
                    isDark: isDark,
                    icon: isBeforeShow
                        ? Icons.movie_rounded
                        : Icons.restaurant_rounded,
                    iconColor: isBeforeShow
                        ? AppColors.lavender
                        : AppColors.spotlightCoral,
                    time: isBeforeShow
                        ? DateFormat('h:mm a').format(booking.showTime)
                        : reservation.timeSlot,
                    title: isBeforeShow
                        ? (booking.eventTitle ?? 'Movie Show')
                        : 'Post-Show Drinks at ${reservation.restaurantName ?? "Restaurant"}',
                    subtitle: isBeforeShow
                        ? '${booking.venueName ?? "Cinema"} • ${booking.tickets.length} Seats (${booking.tickets.map((t) => t.seatNumber).join(", ")})'
                        : 'Party of ${reservation.partySize} guests • 20% off after show',
                    isFirst: false,
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // 3. Countdown & Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.spotlightCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 13, color: AppColors.spotlightCoral),
                          const SizedBox(width: 4),
                          Text(
                            countdown,
                            style: const TextStyle(
                              color: AppColors.spotlightCoral,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        side: BorderSide(
                          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => context.push(AppRoutes.diningDetailPath(reservation.restaurantId)),
                      child: const Text('Dining Info', style: TextStyle(fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.spotlightCoral,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () => context.push(AppRoutes.ticketPath(booking.id)),
                      child: const Row(
                        children: [
                          Icon(Icons.qr_code_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('View Tickets', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String time,
    required String title,
    required String subtitle,
    required bool isFirst,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: iconColor, width: 1.5),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.marqueeAmber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalkingConnector(bool isDark, {required String text}) {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.marqueeAmber, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            children: [
              const Icon(
                Icons.directions_walk_rounded,
                size: 14,
                color: AppColors.marqueeAmber,
              ),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
