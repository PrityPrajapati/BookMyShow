import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/showscape_image.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';
import 'package:showscape/features/explore/presentation/providers/explore_providers.dart';

/// Results section for Explore screen supporting Grid and List view modes
class ExploreResultsView extends ConsumerWidget {
  const ExploreResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(exploreFilterNotifierProvider);
    final viewMode = ref.watch(exploreViewModeProvider);
    final eventsAsync = ref.watch(filteredExploreEventsProvider);
    final restaurantsAsync = ref.watch(filteredExploreRestaurantsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isDiningOnly = criteria.category == ExploreCategory.dining;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header (count + Grid/List toggle)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              eventsAsync.when(
                data: (events) {
                  final diningCount =
                      restaurantsAsync.valueOrNull?.length ?? 0;
                  final totalCount = isDiningOnly
                      ? diningCount
                      : (criteria.category == ExploreCategory.all
                          ? events.length + diningCount
                          : events.length);

                  return Row(
                    children: [
                      Text(
                        '$totalCount ',
                        style: AppTypography.body14(
                          color: AppColors.spotlightCoral,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        totalCount == 1 ? 'experience found' : 'experiences found',
                        style: AppTypography.body14(
                          color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Text(
                  'Searching experiences...',
                  style: AppTypography.caption12(
                    color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                  ),
                ),
                error: (_, __) => Text(
                  'Results',
                  style: AppTypography.body14(
                    color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                  ),
                ),
              ),

              // Grid vs List Mode Toggle
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.lightSurface,
                  borderRadius: AppRadius.pill,
                  border: Border.all(
                    color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        size: 18,
                        color: viewMode == ExploreViewMode.grid
                            ? AppColors.spotlightCoral
                            : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        ref.read(exploreViewModeProvider.notifier).state =
                            ExploreViewMode.grid;
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.view_list_rounded,
                        size: 20,
                        color: viewMode == ExploreViewMode.list
                            ? AppColors.spotlightCoral
                            : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        ref.read(exploreViewModeProvider.notifier).state =
                            ExploreViewMode.list;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Results Content
        eventsAsync.when(
          data: (events) {
            final restaurants =
                restaurantsAsync.valueOrNull ?? <Restaurant>[];

            if (isDiningOnly) {
              if (restaurants.isEmpty) {
                return _buildEmptyState(context, ref);
              }
              return _buildRestaurantsList(context, restaurants, viewMode);
            }

            if (events.isEmpty &&
                (criteria.category != ExploreCategory.all ||
                    restaurants.isEmpty)) {
              return _buildEmptyState(context, ref);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewMode == ExploreViewMode.grid)
                  _buildEventGrid(context, events)
                else
                  _buildEventList(context, events),

                // If 'All' is selected and there are restaurants, display dining section
                if (criteria.category == ExploreCategory.all &&
                    restaurants.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restaurant_rounded,
                          size: 18,
                          color: AppColors.spotlightCoral,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Dining & Lounge Experiences',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildRestaurantsList(context, restaurants, viewMode),
                ],
              ],
            );
          },
          loading: () => _buildShimmerLoading(context, viewMode),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text('Error loading results: $err')),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Grid Mode Builder
  // ---------------------------------------------------------------------------

  Widget _buildEventGrid(BuildContext context, List<Event> events) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.60,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _EventGridCard(event: event);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // List Mode Builder
  // ---------------------------------------------------------------------------

  Widget _buildEventList(BuildContext context, List<Event> events) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return _EventListCard(event: event);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Restaurants List Builder
  // ---------------------------------------------------------------------------

  Widget _buildRestaurantsList(
    BuildContext context,
    List<Restaurant> restaurants,
    ExploreViewMode viewMode,
  ) {
    if (viewMode == ExploreViewMode.grid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
        ),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final rest = restaurants[index];
          return _RestaurantGridCard(restaurant: rest);
        },
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rest = restaurants[index];
        return _RestaurantListCard(restaurant: rest);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Empty State
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.spotlightCoral.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppColors.spotlightCoral,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Matching Experiences Found',
              textAlign: TextAlign.center,
              style: AppTypography.heading20(
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try relaxing your filters, searching with different keywords, or picking another date on the calendar.',
              textAlign: TextAlign.center,
              style: AppTypography.caption12(
                color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spotlightCoral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                ref.read(exploreFilterNotifierProvider.notifier).clearAllFilters();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shimmer Skeletons
  // ---------------------------------------------------------------------------

  Widget _buildShimmerLoading(BuildContext context, ExploreViewMode viewMode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surface : Colors.grey.shade300;
    final highlightColor = isDark ? AppColors.surfaceElevated : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: viewMode == ExploreViewMode.grid
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.border16,
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.border16,
                  ),
                ),
              ),
      ),
    );
  }
}

// =============================================================================
// Event Grid Card
// =============================================================================

class _EventGridCard extends StatelessWidget {
  final Event event;

  const _EventGridCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.border16,
        onTap: () => context.push(AppRoutes.eventPath(event.id)),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: AppRadius.border16,
            border: Border.all(
              color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster with Hero Tag and Rating Badge
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Hero(
                        tag: 'event-poster-${event.id}',
                        child: ShowScapeImage(
                          imageUrl: event.posterUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Rating Pill Top Right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: AppRadius.pill,
                          border: Border.all(
                            color: AppColors.marqueeAmber.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: AppColors.marqueeAmber),
                            const SizedBox(width: 3),
                            Text(
                              event.rating > 0 ? event.rating.toStringAsFixed(1) : 'New',
                              style: AppTypography.caption12(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Certificate Badge (Top Left)
                    if (event.certificate != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.spotlightCoral.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.certificate!,
                            style: AppTypography.caption12(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ).copyWith(fontSize: 9),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Title and Meta Info
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body14(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.genres.join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ).copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          event.languages.take(2).join(', '),
                          style: AppTypography.caption12(
                            color: AppColors.spotlightCoral,
                            fontWeight: FontWeight.w600,
                          ).copyWith(fontSize: 11),
                        ),
                        Text(
                          '${event.durationMins}m',
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                          ).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Event List Card
// =============================================================================

class _EventListCard extends StatelessWidget {
  final Event event;

  const _EventListCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.border16,
        onTap: () => context.push(AppRoutes.eventPath(event.id)),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: AppRadius.border16,
            border: Border.all(
              color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Poster Left
              ClipRRect(
                borderRadius: AppRadius.border12,
                child: AspectRatio(
                  aspectRatio: 0.72,
                  child: Hero(
                    tag: 'event-poster-${event.id}',
                    child: ShowScapeImage(
                      imageUrl: event.posterUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Center Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body14(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.genres.join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.marqueeAmber),
                        const SizedBox(width: 3),
                        Text(
                          event.rating > 0 ? event.rating.toStringAsFixed(1) : 'New',
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.languages.take(2).join(', '),
                          style: AppTypography.caption12(
                            color: AppColors.spotlightCoral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (event.certificate != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white12 : Colors.black12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              event.certificate!,
                              style: AppTypography.caption12(
                                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Right Action Button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.spotlightCoral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () => context.push(AppRoutes.eventPath(event.id)),
                    child: Text(
                      'Book',
                      style: AppTypography.caption12(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Restaurant Grid & List Cards
// =============================================================================

class _RestaurantGridCard extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantGridCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.border16,
        onTap: () => context.push(AppRoutes.diningDetailPath(restaurant.id)),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: AppRadius.border16,
            border: Border.all(
              color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorWidget: (_, __, ___) => const Icon(Icons.restaurant_rounded),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body14(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      restaurant.cuisine.take(2).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ).copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${restaurant.costForTwo.toInt()} for two',
                          style: AppTypography.caption12(
                            fontWeight: FontWeight.w600,
                            color: AppColors.spotlightCoral,
                          ).copyWith(fontSize: 11),
                        ),
                        Text(
                          '${restaurant.distanceKm} km',
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                          ).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantListCard extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantListCard({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.border16,
        onTap: () => context.push(AppRoutes.diningDetailPath(restaurant.id)),
        child: Container(
          height: 105,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: AppRadius.border16,
            border: Border.all(
              color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.border12,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(Icons.restaurant_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      restaurant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body14(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      restaurant.cuisine.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.marqueeAmber),
                        const SizedBox(width: 3),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight)),
                        const SizedBox(width: 8),
                        Text(
                          '₹${restaurant.costForTwo.toInt()} for two',
                          style: AppTypography.caption12(
                            color: AppColors.spotlightCoral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight)),
                        const SizedBox(width: 8),
                        Text(
                          '${restaurant.distanceKm} km',
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
