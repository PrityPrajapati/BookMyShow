import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/explore/presentation/providers/explore_providers.dart';
import 'package:showscape/features/explore/presentation/widgets/filter_bottom_sheet.dart';

/// Search bar with 300ms debouncing, filter modal trigger, and recent searches
class ExploreSearchBar extends ConsumerStatefulWidget {
  const ExploreSearchBar({super.key});

  @override
  ConsumerState<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends ConsumerState<ExploreSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(
      exploreFilterNotifierProvider.select((c) => c.searchQuery),
    );
    _controller = TextEditingController(text: initialQuery);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(exploreFilterNotifierProvider.notifier).setSearchQuery(query);
      if (query.trim().length >= 3) {
        ref.read(recentSearchesProvider.notifier).addSearch(query.trim());
      }
    });
  }

  void _onSubmitted(String query) {
    _debounceTimer?.cancel();
    ref.read(exploreFilterNotifierProvider.notifier).setSearchQuery(query);
    if (query.trim().isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).addSearch(query.trim());
    }
    _focusNode.unfocus();
  }

  void _clearQuery() {
    _controller.clear();
    _debounceTimer?.cancel();
    ref.read(exploreFilterNotifierProvider.notifier).setSearchQuery('');
  }

  int _countActiveFilters() {
    final criteria = ref.read(exploreFilterNotifierProvider);
    int count = 0;
    if (criteria.selectedDate != null) count++;
    if (criteria.languages.isNotEmpty) count += criteria.languages.length;
    if (criteria.genres.isNotEmpty) count += criteria.genres.length;
    if (criteria.minPrice > 0 || criteria.maxPrice < 10000) count++;
    if (criteria.maxDistanceKm != null) count++;
    if (criteria.startDate != null || criteria.endDate != null) count++;
    if (criteria.formats.isNotEmpty) count += criteria.formats.length;
    if (criteria.ageRatings.isNotEmpty) count += criteria.ageRatings.length;
    if (criteria.sortBy.index != 0) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentSearches = ref.watch(recentSearchesProvider);
    final activeFiltersCount = _countActiveFilters();

    // Listen to external search query updates (e.g. from chip removal)
    ref.listen(
      exploreFilterNotifierProvider.select((c) => c.searchQuery),
      (prev, next) {
        if (next != _controller.text) {
          _controller.text = next;
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Search Bar + Filter Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    borderRadius: AppRadius.pill,
                    border: Border.all(
                      color: _isFocused
                          ? AppColors.spotlightCoral
                          : (isDark
                              ? AppColors.surfaceBorder
                              : AppColors.lightSurfaceBorder),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.05,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: _isFocused
                            ? AppColors.spotlightCoral
                            : (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: _onQueryChanged,
                          onSubmitted: _onSubmitted,
                          textInputAction: TextInputAction.search,
                          style: AppTypography.body14(
                            color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Search movies, concerts, artists...',
                            hintStyle: AppTypography.body14(
                              color: isDark
                                  ? AppColors.lavenderMuted.withValues(alpha: 0.6)
                                  : AppColors.textSecondaryLight.withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                          onPressed: _clearQuery,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Filter Bottom Sheet Button with Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: AppRadius.border12,
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const FilterBottomSheet(),
                        );
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: activeFiltersCount > 0
                              ? AppColors.spotlightCoral
                              : (isDark
                                  ? AppColors.surface
                                  : AppColors.lightSurface),
                          borderRadius: AppRadius.border12,
                          border: Border.all(
                            color: activeFiltersCount > 0
                                ? AppColors.spotlightCoral
                                : (isDark
                                    ? AppColors.surfaceBorder
                                    : AppColors.lightSurfaceBorder),
                            width: 1.2,
                          ),
                          boxShadow: activeFiltersCount > 0
                              ? [
                                  BoxShadow(
                                    color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 22,
                          color: activeFiltersCount > 0
                              ? Colors.white
                              : (isDark ? AppColors.lavender : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                  ),
                  if (activeFiltersCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.marqueeAmber,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$activeFiltersCount',
                          textAlign: TextAlign.center,
                          style: AppTypography.caption12(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Recent Searches Row (when focused or user has search history)
        if (_isFocused && recentSearches.isNotEmpty) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 14, color: AppColors.spotlightCoral),
                    const SizedBox(width: 4),
                    Text(
                      'Recent Searches',
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    ref.read(recentSearchesProvider.notifier).clearAll();
                  },
                  child: Text(
                    'Clear',
                    style: AppTypography.caption12(
                      color: AppColors.spotlightCoral,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentSearches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final query = recentSearches[index];
                return InkWell(
                  borderRadius: AppRadius.pill,
                  onTap: () {
                    _controller.text = query;
                    _onSubmitted(query);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : AppColors.lightBackground,
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          query,
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavenderMuted : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(recentSearchesProvider.notifier)
                                .removeSearch(query);
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
