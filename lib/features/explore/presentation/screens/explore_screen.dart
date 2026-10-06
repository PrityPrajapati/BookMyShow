import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/explore/presentation/providers/explore_providers.dart';
import 'package:showscape/features/explore/presentation/widgets/active_filter_chips.dart';
import 'package:showscape/features/explore/presentation/widgets/category_tabs_bar.dart';
import 'package:showscape/features/explore/presentation/widgets/collapsible_calendar.dart';
import 'package:showscape/features/explore/presentation/widgets/explore_mood_chips_bar.dart';
import 'package:showscape/features/explore/presentation/widgets/explore_results_view.dart';
import 'package:showscape/features/explore/presentation/widgets/explore_search_bar.dart';

/// Explore Screen: Category tabs, collapsible table_calendar with coral event markers,
/// advanced filter bottom sheet, active removable chips with 'Clear all',
/// results toggling between list and grid, debounced search with typo tolerance and recent searches,
/// and Hive filter persistence.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.spotlightCoral,
          backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
          onRefresh: () async {
            ref.invalidate(allEventsProvider);
            ref.invalidate(allShowsListProvider);
            ref.invalidate(venuesProvider);
            ref.invalidate(restaurantsProvider);
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Screen Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          size: 20,
                          color: AppColors.spotlightCoral,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore',
                            style: AppTypography.heading24(
                              color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'Movies, Shows, Concerts & Dining',
                            style: AppTypography.caption12(
                              color: isDark
                                  ? AppColors.lavenderMuted
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar with 300ms Debounce and Recent Searches
              const SliverToBoxAdapter(
                child: ExploreSearchBar(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 12),
              ),

              // Category Tabs (All, Movies, Events, Sports, Comedy, Dining)
              const SliverToBoxAdapter(
                child: CategoryTabsBar(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              // Mood Filter Bar (Canonical 6 moods)
              const SliverToBoxAdapter(
                child: ExploreMoodChipsBar(),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 4),
              ),

              // Collapsible Table Calendar (Week/Month mode with Coral dot markers)
              const SliverToBoxAdapter(
                child: CollapsibleCalendar(),
              ),

              // Active Filter Chips with 'Clear all'
              const SliverToBoxAdapter(
                child: ActiveFilterChips(),
              ),

              // Results View (Toggles between Grid & List)
              const SliverToBoxAdapter(
                child: ExploreResultsView(),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
