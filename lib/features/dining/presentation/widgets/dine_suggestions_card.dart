import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/dining/presentation/providers/dining_providers.dart';
import 'package:showscape/features/dining/presentation/widgets/table_reservation_sheet.dart';

/// Card showing 'Dine before' and 'Dine after' suggestions with walking buffer automatically aligned to showtime
class DineSuggestionsCard extends ConsumerWidget {
  final DateTime showStart;
  final DateTime showEnd;
  final String venueId;
  final String? bookingId;
  final String? venueName;

  const DineSuggestionsCard({
    super.key,
    required this.showStart,
    required this.showEnd,
    required this.venueId,
    this.bookingId,
    this.venueName,
  });

  void _openReservationSheet(
    BuildContext context,
    Restaurant restaurant,
    String prefilledSlot,
    String suggestionType,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TableReservationSheet(
        restaurant: restaurant,
        initialTimeSlot: prefilledSlot,
        linkedBookingId: bookingId,
        reservationType: suggestionType,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if reservation is already made for this booking
    final userReservationsNotifier = ref.watch(userReservationsProvider.notifier);
    final existingReservation = bookingId != null
        ? userReservationsNotifier.getReservationForBooking(bookingId!)
        : null;

    final suggestionsAsync = ref.watch(
      showDiningSuggestionsProvider((
        showStart: showStart,
        showEnd: showEnd,
        venueId: venueId,
      )),
    );

    return suggestionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (suggestions) {
        if (suggestions == null) return const SizedBox.shrink();

        final restaurant = suggestions.restaurant;

        // If table already reserved, show confirmed badge
        if (existingReservation != null) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E2835), const Color(0xFF151922)]
                    : [Colors.green.shade50, Colors.white],
              ),
              borderRadius: AppRadius.border20,
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
                ),
                AppSpacing.horizontal12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Night Out Itinerary Active',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.stars_rounded, color: AppColors.marqueeAmber, size: 14),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Table Reserved at ${existingReservation.restaurantName ?? restaurant.name}',
                        style: TextStyle(
                          color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${existingReservation.timeSlot} • Party of ${existingReservation.partySize} guests',
                        style: TextStyle(
                          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onPressed: () => context.push(AppRoutes.diningDetailPath(restaurant.id)),
                ),
              ],
            ),
          );
        }

        // Suggestions Card
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: AppRadius.border20,
            border: Border.all(
              color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header ribbon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.spotlightCoral.withValues(alpha: 0.15),
                      AppColors.marqueeAmber.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wine_bar_rounded, size: 16, color: AppColors.spotlightCoral),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'COMPLETE YOUR NIGHT OUT',
                        style: TextStyle(
                          color: AppColors.spotlightCoral,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_walk_rounded, size: 12, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(
                            '${suggestions.walkingMinutes.toInt()}m walk',
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Restaurant basic info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.border12,
                          child: Image.network(
                            restaurant.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.restaurant, color: Colors.white24),
                            ),
                          ),
                        ),
                        AppSpacing.horizontal12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: AppTypography.heading18(
                                  color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                                ).copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${restaurant.cuisine.first} • ₹${restaurant.costForTwo.toInt()} for two',
                                style: AppTypography.caption12(
                                  color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(Icons.local_offer_rounded, size: 12, color: AppColors.marqueeAmber),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Flat 20% off with show ticket',
                                      style: TextStyle(
                                        color: AppColors.marqueeAmber,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dine Before & Dine After Slots Buttons
                    Row(
                      children: [
                        // Dine Before
                        Expanded(
                          child: InkWell(
                            onTap: () => _openReservationSheet(
                              context,
                              restaurant,
                              suggestions.dineBeforeSlot,
                              'DINE BEFORE',
                            ),
                            borderRadius: AppRadius.border12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2235) : Colors.grey.shade100,
                                borderRadius: AppRadius.border12,
                                border: Border.all(
                                  color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.wb_twilight_rounded, size: 14, color: AppColors.spotlightCoral),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Dine Before',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          color: AppColors.spotlightCoral,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    suggestions.dineBeforeSlot,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '1h 15m pre-show',
                                    style: TextStyle(
                                      color: isDark ? Colors.white38 : Colors.black38,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Dine After
                        Expanded(
                          child: InkWell(
                            onTap: () => _openReservationSheet(
                              context,
                              restaurant,
                              suggestions.dineAfterSlot,
                              'DINE AFTER',
                            ),
                            borderRadius: AppRadius.border12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2235) : Colors.grey.shade100,
                                borderRadius: AppRadius.border12,
                                border: Border.all(
                                  color: AppColors.lavender.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.nightlife_rounded, size: 14, color: AppColors.lavender),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Dine After',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          color: AppColors.lavender,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    suggestions.dineAfterSlot,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '+15m walk buffer',
                                    style: TextStyle(
                                      color: isDark ? Colors.white38 : Colors.black38,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      },
    );
  }
}
