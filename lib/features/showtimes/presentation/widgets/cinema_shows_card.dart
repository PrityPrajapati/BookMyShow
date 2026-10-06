import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/features/showtimes/presentation/widgets/showtime_chip.dart';
import 'package:showscape/features/venue_map/domain/models/venue.dart';

/// Cinema Card showing cinema details, distance, favourite star toggle, amenities, and showtime chips
class CinemaShowsCard extends StatefulWidget {
  final Venue cinema;
  final double distanceKm;
  final List<Show> shows;
  final bool isUserGold;
  final bool isTuesday;

  const CinemaShowsCard({
    super.key,
    required this.cinema,
    required this.distanceKm,
    required this.shows,
    this.isUserGold = false,
    this.isTuesday = false,
  });

  @override
  State<CinemaShowsCard> createState() => _CinemaShowsCardState();
}

class _CinemaShowsCardState extends State<CinemaShowsCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cinema Name + Distance + Favourite Star
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cinema.name,
                      style: AppTypography.heading20(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      ).copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_rounded,
                          size: 13,
                          color: AppColors.spotlightCoral,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.distanceKm.toStringAsFixed(1)} km away',
                          style: AppTypography.caption12(
                            color: AppColors.spotlightCoral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.cinema.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption12(
                              color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favourite Star Button
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: _isFavorite
                      ? AppColors.marqueeAmber
                      : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                  size: 22,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Favourite Cinema',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isFavorite
                            ? '${widget.cinema.name} added to favourites'
                            : '${widget.cinema.name} removed from favourites',
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),

          // 2. Amenities Pills (e.g. M-Ticket, Food & Beverage, Dolby Atmos)
          if (widget.cinema.amenities.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // M-Ticket badge
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_iphone_rounded,
                          size: 11,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'M-Ticket',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cinema amenities
                  ...widget.cinema.amenities.take(3).map((amenity) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        amenity,
                        style: AppTypography.caption12(
                          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                        ).copyWith(fontSize: 10),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // 3. Showtime Chips Grid / Wrap
          if (widget.shows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No showtimes matching filters at this cinema.',
                style: AppTypography.caption12(
                  color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: widget.shows.map((show) {
                return ShowtimeChip(
                  show: show,
                  cinemaName: widget.cinema.name,
                  isUserGold: widget.isUserGold,
                  isTuesday: widget.isTuesday,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
