import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/showtimes/domain/models/show.dart';
import 'package:showscape/features/showtimes/domain/models/showtime_filters.dart';
import 'package:showscape/features/showtimes/presentation/widgets/cinema_shows_card.dart';
import 'package:showscape/features/showtimes/presentation/widgets/date_strip.dart';
import 'package:showscape/features/showtimes/presentation/widgets/occupancy_legend.dart';
import 'package:showscape/features/showtimes/presentation/widgets/showtime_filter_bar.dart';
import 'package:showscape/features/venue_map/domain/models/venue.dart';

/// Show Timings Screen with 7-day date strip, filters, distance-sorted cinemas, and occupancy chips
class ShowtimesScreen extends ConsumerStatefulWidget {
  final String eventId;

  const ShowtimesScreen({super.key, required this.eventId});

  @override
  ConsumerState<ShowtimesScreen> createState() => _ShowtimesScreenState();
}

class _ShowtimesScreenState extends ConsumerState<ShowtimesScreen> {
  late ShowtimeFilters _filters;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _filters = ShowtimeFilters(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Precomputed simulated distance based on cinema ID for realism
  double _getCinemaDistance(Venue cinema, int index) {
    final distances = [1.8, 3.2, 4.5, 6.1, 7.8, 9.4, 12.0, 15.5];
    return distances[index % distances.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final showsAsync = ref.watch(showsForEventProvider(widget.eventId));
    final cinemasAsync = ref.watch(cinemasProvider);
    final userAsync = ref.watch(currentUserProvider);

    final isUserGold = userAsync.value?.isGoldMember ?? false;
    final isTuesday = _filters.selectedDate.weekday == DateTime.tuesday;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: eventAsync.when(
          data: (event) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event?.title ?? 'Select Showtimes',
                style: AppTypography.heading20(
                  color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                ).copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (event != null)
                Text(
                  '${event.certificate ?? "UA"} • ${event.genres.take(2).join(", ")}',
                  style: AppTypography.caption12(
                    color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Showtimes'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing showtimes link...'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: showsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.spotlightCoral),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text('Failed to load showtimes', style: AppTypography.heading20()),
                const SizedBox(height: 8),
                Text(err.toString(), style: AppTypography.caption12()),
              ],
            ),
          ),
        ),
        data: (allShows) {
          final allCinemas = cinemasAsync.value ?? <Venue>[];

          // Collect available languages
          final languages = allShows.map((s) => s.language).toSet().toList();

          // Filter shows by selected date, format, language, and time of day
          final filteredShows = allShows.where((s) {
            if (!_isSameDay(s.startTime, _filters.selectedDate)) return false;
            if (_filters.format != null && s.format != _filters.format) return false;
            if (_filters.language != null && s.language != _filters.language) return false;
            if (!_filters.timeOfDay.matches(s.startTime)) return false;
            return true;
          }).toList();

          // Group shows by cinema / venueId
          final showsByVenue = <String, List<Show>>{};
          for (final s in filteredShows) {
            showsByVenue.putIfAbsent(s.venueId, () => []).add(s);
          }

          // Sort shows in each cinema by startTime
          for (final list in showsByVenue.values) {
            list.sort((a, b) => a.startTime.compareTo(b.startTime));
          }

          // Cinemas sorted by distance
          final List<MapEntry<Venue, double>> sortedCinemasWithDist = [];
          for (int i = 0; i < allCinemas.length; i++) {
            final cinema = allCinemas[i];
            final dist = _getCinemaDistance(cinema, i);
            sortedCinemasWithDist.add(MapEntry(cinema, dist));
          }
          sortedCinemasWithDist.sort((a, b) => a.value.compareTo(b.value));

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              // 1. Horizontal 7-Day Date Strip
              DateStrip(
                selectedDate: _filters.selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _filters = _filters.copyWith(selectedDate: date);
                  });
                },
              ),
              const SizedBox(height: 12),

              // 2. Format, Language, and Time of Day Filter Bar
              ShowtimeFilterBar(
                filters: _filters,
                availableLanguages: languages,
                onFiltersChanged: (newFilters) {
                  setState(() {
                    _filters = newFilters;
                  });
                },
              ),
              const SizedBox(height: 8),

              // 3. Occupancy Legend
              const OccupancyLegend(),
              const SizedBox(height: 8),

              // 4. List of Cinemas sorted by distance
              if (showsByVenue.isEmpty)
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    borderRadius: AppRadius.border20,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_busy_rounded,
                        size: 48,
                        color: AppColors.spotlightCoral,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Shows Available',
                        style: AppTypography.heading20(
                          color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        ).copyWith(fontSize: 17),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No showtimes match the selected date and filters. Try picking another date or clearing filters.',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption12(
                          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.spotlightCoral,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                        ),
                        onPressed: () {
                          setState(() {
                            _filters = ShowtimeFilters(
                              selectedDate: _filters.selectedDate,
                            );
                          });
                        },
                        child: const Text('Reset Filters'),
                      ),
                    ],
                  ),
                )
              else
                ...sortedCinemasWithDist.map((entry) {
                  final cinema = entry.key;
                  final distance = entry.value;
                  final cinemaShows = showsByVenue[cinema.id] ?? <Show>[];

                  // Only show cinemas that have shows (or show with empty list)
                  if (cinemaShows.isEmpty) return const SizedBox.shrink();

                  return CinemaShowsCard(
                    cinema: cinema,
                    distanceKm: distance,
                    shows: cinemaShows,
                    isUserGold: isUserGold,
                    isTuesday: isTuesday,
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
