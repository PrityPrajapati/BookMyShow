import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/primary_button.dart';
import 'package:showscape/features/event_detail/presentation/widgets/about_section.dart';
import 'package:showscape/features/event_detail/presentation/widgets/ai_summary_card.dart';
import 'package:showscape/features/event_detail/presentation/widgets/cast_carousel.dart';
import 'package:showscape/features/event_detail/presentation/widgets/event_detail_app_bar.dart';
import 'package:showscape/features/event_detail/presentation/widgets/event_meta_section.dart';
import 'package:showscape/features/event_detail/presentation/widgets/format_chips_section.dart';
import 'package:showscape/features/event_detail/presentation/widgets/live_event_info_section.dart';
import 'package:showscape/features/event_detail/presentation/widgets/sticky_booking_bar.dart';
import 'package:showscape/features/explore/domain/models/event.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/features/venue_map/domain/models/venue.dart';

/// Event Detail Screen with Collapsing SliverAppBar, Poster Hero, AI Summary, Format Chips, and Sticky Booking Bar
class EventDetailScreen extends ConsumerWidget {
  final String id;

  const EventDetailScreen({super.key, required this.id});

  double _computeStartingPrice(Event event, List<Show> shows) {
    if (shows.isNotEmpty) {
      double minPrice = double.infinity;
      for (final s in shows) {
        if (s.categoryPrices.isNotEmpty) {
          final showMin = s.categoryPrices.values.reduce(min);
          if (showMin < minPrice) {
            minPrice = showMin;
          }
        }
      }
      if (minPrice != double.infinity && minPrice > 0) {
        return minPrice;
      }
    }

    // Default baseline pricing by event type
    switch (event.type) {
      case EventType.movie:
        return 250.0;
      case EventType.sports:
        return 950.0;
      case EventType.concert:
        return 1499.0;
      case EventType.comedy:
        return 499.0;
      case EventType.theatre:
        return 750.0;
    }
  }

  String? _resolveNearestCinemaName(List<Show> shows, List<Venue> venues) {
    if (shows.isNotEmpty) {
      final firstShowVenueId = shows.first.venueId;
      final matchedVenue = venues.cast<Venue?>().firstWhere(
            (v) => v?.id == firstShowVenueId,
            orElse: () => null,
          );
      if (matchedVenue != null) {
        return matchedVenue.name;
      }
    }

    final firstCinema = venues.cast<Venue?>().firstWhere(
          (v) => v?.type == VenueType.cinema,
          orElse: () => null,
        );
    return firstCinema?.name ?? 'PVR INOX Palladium';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventAsync = ref.watch(eventDetailProvider(id));
    final showsAsync = ref.watch(showsForEventProvider(id));
    final venuesAsync = ref.watch(venuesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      body: eventAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.spotlightCoral),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load event details',
                  style: AppTypography.heading20(
                    color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTypography.body14(
                    color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: 'Try Again',
                  onPressed: () => ref.refresh(eventDetailProvider(id)),
                ),
              ],
            ),
          ),
        ),
        data: (event) {
          if (event == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.movie_creation_outlined,
                    size: 54,
                    color: AppColors.spotlightCoral,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Event Not Found',
                    style: AppTypography.heading20(
                      color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Go Back',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            );
          }

          final shows = showsAsync.value ?? <Show>[];
          final venues = venuesAsync.value ?? <Venue>[];
          final startingPrice = _computeStartingPrice(event, shows);
          final nearestCinemaName = _resolveNearestCinemaName(shows, venues);

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 1. SliverAppBar with Blurred Banner & Hero Poster
                  EventDetailAppBar(event: event),

                  // 2. Title, Rating, Duration, Languages, Certificate, Genres, Trailer CTA
                  SliverToBoxAdapter(
                    child: EventMetaSection(event: event),
                  ),

                  // 3. Format Chips (For Movies) OR Venue/Date/Ticket Categories (For Sports/Live Events)
                  if (event.type == EventType.movie)
                    SliverToBoxAdapter(
                      child: FormatChipsSection(
                        shows: shows,
                        nearestCinemaName: nearestCinemaName,
                        onFormatSelected: (format) {
                          // Format selected
                        },
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: LiveEventInfoSection(
                        event: event,
                        venueName: nearestCinemaName,
                      ),
                    ),

                  // 4. AI Summary Card (3 bullets + spoiler-free verdict + thumbs up/down)
                  SliverToBoxAdapter(
                    child: AiSummaryCard(event: event),
                  ),

                  // 5. About Section with 'Read more' toggle
                  SliverToBoxAdapter(
                    child: AboutSection(event: event),
                  ),

                  // 6. Cast & Crew Carousel
                  SliverToBoxAdapter(
                    child: CastCarousel(event: event),
                  ),

                  // Bottom padding so content isn't obscured by sticky bottom bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),

              // 7. Sticky Bottom Bar with 'from ₹X' and 'Book tickets' Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: StickyBookingBar(
                  event: event,
                  startingPrice: startingPrice,
                  onBookPressed: () {
                    context.push(AppRoutes.showtimesPath(event.id));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
