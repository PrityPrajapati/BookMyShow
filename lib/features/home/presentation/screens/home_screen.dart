import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/features/home/presentation/providers/home_providers.dart';
import 'package:showscape/features/home/presentation/widgets/event_rail.dart';
import 'package:showscape/features/home/presentation/widgets/floating_scout_orb.dart';
import 'package:showscape/features/home/presentation/widgets/hero_featured_carousel.dart';
import 'package:showscape/features/home/presentation/widgets/home_search_bar.dart';
import 'package:showscape/features/home/presentation/widgets/home_shimmer_skeletons.dart';
import 'package:showscape/features/home/presentation/widgets/home_top_bar.dart';
import 'package:showscape/features/home/presentation/widgets/mood_chips_row.dart';
import 'package:showscape/features/home/presentation/widgets/restaurant_rail.dart';
import 'package:showscape/features/home/presentation/widgets/tuesday_deals_banner.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:showscape/core/providers/accessibility_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _handleRefresh(WidgetRef ref) async {
    // Invalidate feeds to re-fetch with simulated delay
    ref.invalidate(allEventsProvider);
    ref.invalidate(moviesProvider);
    ref.invalidate(featuredEventsProvider);
    ref.invalidate(currentUserProvider);
    ref.invalidate(dineAfterShowProvider);
    await ref.read(forYouEventsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSimpleMode = ref.watch(simpleModeProvider);

    void precache(String url) {
      if (url.isEmpty || !context.mounted) return;
      if (url.startsWith('assets/')) {
        precacheImage(AssetImage(url), context);
      } else if (url.startsWith('http://') || url.startsWith('https://')) {
        precacheImage(CachedNetworkImageProvider(url), context);
      }
    }

    // Precache hero poster images into memory cache to eliminate layout shifts
    ref.listen<AsyncValue<List<Event>>>(featuredEventsProvider, (previous, next) {
      if (next.hasValue && context.mounted) {
        for (final event in next.value!.take(5)) {
          precache(event.bannerUrl);
          precache(event.posterUrl);
        }
      }
    });

    ref.listen<AsyncValue<List<Event>>>(nowShowingEventsProvider, (previous, next) {
      if (next.hasValue && context.mounted) {
        for (final event in next.value!.take(6)) {
          precache(event.posterUrl);
        }
      }
    });

    final featuredAsync = ref.watch(featuredEventsProvider);
    final forYouAsync = ref.watch(forYouEventsProvider);
    final nowShowingAsync = ref.watch(nowShowingEventsProvider);
    final weekendAsync = ref.watch(weekendEventsProvider);
    final sportsAsync = ref.watch(sportsEventsProvider);
    final diningAsync = ref.watch(dineAfterShowProvider);

    if (isSimpleMode) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text(
            'ShowScape Simple',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          elevation: 2,
        ),
        body: forYouAsync.when(
          data: (events) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final event = events[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.surfaceBorder : Colors.grey.shade400,
                    width: 2.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${event.type.name.toUpperCase()} • ${event.genres.join(", ")}',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.confirmation_number_rounded),
                        label: const Text(
                          'Book Tickets',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.spotlightCoral,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => context.push(AppRoutes.eventPath(event.id)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Unable to load events')),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.spotlightCoral,
              backgroundColor: isDark ? AppColors.surface : Colors.white,
              onRefresh: () => _handleRefresh(ref),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // 1. Top Bar: City Selector & Notifications
                  const SliverToBoxAdapter(
                    child: HomeTopBar(),
                  ),

                  // 2. Large Search Bar (opens Scout AI)
                  const SliverToBoxAdapter(
                    child: HomeSearchBar(),
                  ),
                  const SliverToBoxAdapter(
                    child: AppSpacing.vertical8,
                  ),

                  // 3. Mood Chips Row
                  const SliverToBoxAdapter(
                    child: MoodChipsRow(),
                  ),
                  const SliverToBoxAdapter(
                    child: AppSpacing.vertical16,
                  ),

                  // 4. Auto-playing Hero Carousel with Parallax
                  SliverToBoxAdapter(
                    child: featuredAsync.when(
                      data: (featuredList) =>
                          HeroFeaturedCarousel(events: featuredList),
                      loading: () => const HeroCarouselSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: AppSpacing.vertical8,
                  ),

                  // 5. 'Tuesday Deals' Banner Card
                  const SliverToBoxAdapter(
                    child: TuesdayDealsBanner(),
                  ),
                  const SliverToBoxAdapter(
                    child: AppSpacing.vertical8,
                  ),

                  // 6. Rail: 'For You' (Ranked by domain scoring function)
                  SliverToBoxAdapter(
                    child: forYouAsync.when(
                      data: (events) => EventRail(
                        title: 'For You',
                        subtitle: 'AI curated based on your genres & languages',
                        events: events,
                      ),
                      loading: () =>
                          const EventRailSkeleton(title: 'For You'),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: AppSpacing.vertical16,
                  ),

                  // 7. Rail: 'Now Showing'
                  SliverToBoxAdapter(
                    child: nowShowingAsync.when(
                      data: (movies) => EventRail(
                        title: 'Now Showing',
                        subtitle: 'In cinemas around you',
                        events: movies,
                      ),
                      loading: () =>
                          const EventRailSkeleton(title: 'Now Showing'),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: AppSpacing.vertical16,
                  ),

                  // 8. Rail: 'Events This Weekend'
                  SliverToBoxAdapter(
                    child: weekendAsync.when(
                      data: (events) => EventRail(
                        title: 'Events This Weekend',
                        subtitle: 'Concerts, standup specials & live gigs',
                        events: events,
                      ),
                      loading: () => const EventRailSkeleton(
                        title: 'Events This Weekend',
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: AppSpacing.vertical16,
                  ),

                  // 9. Rail: 'Sports'
                  SliverToBoxAdapter(
                    child: sportsAsync.when(
                      data: (sports) => EventRail(
                        title: 'Sports & Stadium Thrills',
                        subtitle: 'IPL blockbusters, ISL finals & live derbies',
                        events: sports,
                      ),
                      loading: () =>
                          const EventRailSkeleton(title: 'Sports'),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: AppSpacing.vertical16,
                  ),

                  // 10. Rail: 'Dine After the Show'
                  SliverToBoxAdapter(
                    child: diningAsync.when(
                      data: (restaurants) =>
                          RestaurantRail(restaurants: restaurants),
                      loading: () => const RestaurantRailSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),

                  // Bottom padding for scroll clearance above bottom nav bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),

          // Floating Scout Orb
          const Positioned(
            bottom: 24,
            right: 18,
            child: FloatingScoutOrb(),
          ),
        ],
      ),
    );
  }
}
