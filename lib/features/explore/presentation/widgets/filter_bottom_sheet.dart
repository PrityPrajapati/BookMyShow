import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/primary_button.dart';
import 'package:showscape/features/explore/domain/models/app_mood.dart';
import 'package:showscape/features/explore/domain/models/explore_filter_criteria.dart';
import 'package:showscape/features/explore/presentation/providers/explore_providers.dart';

/// Modal bottom sheet for configuring advanced Explore filters
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late ExploreFilterCriteria _draft;

  static const List<String> _allLanguages = [
    'Hindi',
    'English',
    'Telugu',
    'Tamil',
    'Malayalam',
    'Kannada',
    'Punjabi',
    'Bengali',
  ];

  static const List<String> _allGenres = [
    'Action',
    'Drama',
    'Comedy',
    'Sci-Fi',
    'Romance',
    'Thriller',
    'Music',
    'Sports',
    'Cricket',
    'Football',
    'Stand-up',
    'Bollywood',
  ];

  static const List<String> _allFormats = [
    '2D',
    '3D',
    'IMAX 2D',
    'IMAX 3D',
    '4DX',
  ];

  static const List<String> _allAgeRatings = [
    'U',
    'UA',
    'UA 16+',
    'A',
  ];

  @override
  void initState() {
    super.initState();
    // Copy current state
    _draft = ref.read(exploreFilterNotifierProvider);
  }

  void _resetAll() {
    setState(() {
      _draft = ExploreFilterCriteria(category: _draft.category);
    });
  }

  void _applyAndClose() {
    ref.read(exploreFilterNotifierProvider.notifier).applyCriteria(_draft);
    Navigator.of(context).pop();
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime(2026, 10, 1);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _draft.startDate != null && _draft.endDate != null
          ? DateTimeRange(start: _draft.startDate!, end: _draft.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.spotlightCoral,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _draft = _draft.copyWith(
          startDate: picked.start,
          endDate: picked.end,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: AppRadius.pill,
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters & Preferences',
                      style: AppTypography.heading20(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: _resetAll,
                      child: Text(
                        'Reset All',
                        style: AppTypography.caption12(
                          color: AppColors.spotlightCoral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Filter Options List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  children: [
                    // 1. SORT BY
                    _buildSectionTitle('Sort By'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ExploreSortBy.values.map((sortOption) {
                        final isSelected = _draft.sortBy == sortOption;
                        return ChoiceChip(
                          label: Text(sortOption.label),
                          selected: isSelected,
                          selectedColor: AppColors.spotlightCoral,
                          backgroundColor:
                              isDark ? AppColors.surface : AppColors.lightSurface,
                          labelStyle: AppTypography.caption12(
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.lavender
                                    : AppColors.textPrimaryLight),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _draft = _draft.copyWith(sortBy: sortOption);
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 2. PRICE RANGE SLIDER (₹0 - ₹10,000)
                    _buildSectionTitle(
                      'Price Range: ₹${_draft.minPrice.toInt()} – ₹${_draft.maxPrice.toInt()}',
                    ),
                    RangeSlider(
                      values: RangeValues(_draft.minPrice, _draft.maxPrice),
                      min: 0.0,
                      max: 10000.0,
                      divisions: 100,
                      activeColor: AppColors.spotlightCoral,
                      inactiveColor: isDark ? Colors.white12 : Colors.black12,
                      labels: RangeLabels(
                        '₹${_draft.minPrice.toInt()}',
                        '₹${_draft.maxPrice.toInt()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _draft = _draft.copyWith(
                            minPrice: values.start,
                            maxPrice: values.end,
                          );
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // 3. DISTANCE
                    _buildSectionTitle(
                      _draft.maxDistanceKm == null
                          ? 'Distance: Any'
                          : 'Distance: Within ${_draft.maxDistanceKm!.toInt()} km',
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterPill(
                          label: 'Any',
                          isSelected: _draft.maxDistanceKm == null,
                          onTap: () {
                            setState(() {
                              _draft = _draft.copyWith(clearMaxDistance: true);
                            });
                          },
                        ),
                        _buildFilterPill(
                          label: '5 km',
                          isSelected: _draft.maxDistanceKm == 5.0,
                          onTap: () {
                            setState(() {
                              _draft = _draft.copyWith(maxDistanceKm: 5.0);
                            });
                          },
                        ),
                        _buildFilterPill(
                          label: '10 km',
                          isSelected: _draft.maxDistanceKm == 10.0,
                          onTap: () {
                            setState(() {
                              _draft = _draft.copyWith(maxDistanceKm: 10.0);
                            });
                          },
                        ),
                        _buildFilterPill(
                          label: '25 km',
                          isSelected: _draft.maxDistanceKm == 25.0,
                          onTap: () {
                            setState(() {
                              _draft = _draft.copyWith(maxDistanceKm: 25.0);
                            });
                          },
                        ),
                        _buildFilterPill(
                          label: '50 km',
                          isSelected: _draft.maxDistanceKm == 50.0,
                          onTap: () {
                            setState(() {
                              _draft = _draft.copyWith(maxDistanceKm: 50.0);
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 4. DATE RANGE
                    _buildSectionTitle('Date Range'),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: AppRadius.border12,
                            onTap: _pickCustomDateRange,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.surface
                                    : AppColors.lightSurface,
                                borderRadius: AppRadius.border12,
                                border: Border.all(
                                  color: (_draft.startDate != null)
                                      ? AppColors.spotlightCoral
                                      : (isDark
                                          ? AppColors.surfaceBorder
                                          : AppColors.lightSurfaceBorder),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.date_range_rounded,
                                    size: 18,
                                    color: AppColors.spotlightCoral,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _draft.startDate != null &&
                                              _draft.endDate != null
                                          ? '${DateFormat('d MMM').format(_draft.startDate!)} – ${DateFormat('d MMM').format(_draft.endDate!)}'
                                          : 'Select Date Range...',
                                      style: AppTypography.body14(
                                        color: isDark
                                            ? AppColors.lavender
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                  if (_draft.startDate != null)
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _draft = _draft.copyWith(
                                            clearDateRange: true,
                                          );
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: AppColors.spotlightCoral,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 5. LANGUAGES
                    _buildSectionTitle('Languages'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allLanguages.map((lang) {
                        final isSelected = _draft.languages.contains(lang);
                        return _buildFilterPill(
                          label: lang,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              final updated = Set<String>.from(_draft.languages);
                              if (isSelected) {
                                updated.remove(lang);
                              } else {
                                updated.add(lang);
                              }
                              _draft = _draft.copyWith(languages: updated);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 5b. MOOD / VIBE (Canonical 6 moods)
                    _buildSectionTitle('Mood & Vibe'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppMood.values.map((mood) {
                        final isSelected = _draft.moods.contains(mood.id);
                        return _buildFilterPill(
                          label: '${mood.emoji} ${mood.label}',
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              final updated = Set<String>.from(_draft.moods);
                              if (isSelected) {
                                updated.remove(mood.id);
                              } else {
                                updated.add(mood.id);
                              }
                              _draft = _draft.copyWith(moods: updated);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 6. GENRES
                    _buildSectionTitle('Genres'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allGenres.map((genre) {
                        final isSelected = _draft.genres.contains(genre);
                        return _buildFilterPill(
                          label: genre,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              final updated = Set<String>.from(_draft.genres);
                              if (isSelected) {
                                updated.remove(genre);
                              } else {
                                updated.add(genre);
                              }
                              _draft = _draft.copyWith(genres: updated);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 7. FORMATS (2D, 3D, IMAX, 4DX)
                    _buildSectionTitle('Screen Formats'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allFormats.map((fmt) {
                        final isSelected = _draft.formats.contains(fmt);
                        return _buildFilterPill(
                          label: fmt,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              final updated = Set<String>.from(_draft.formats);
                              if (isSelected) {
                                updated.remove(fmt);
                              } else {
                                updated.add(fmt);
                              }
                              _draft = _draft.copyWith(formats: updated);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // 8. AGE RATINGS
                    _buildSectionTitle('Age Rating / Certificate'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allAgeRatings.map((rating) {
                        final isSelected = _draft.ageRatings.contains(rating);
                        return _buildFilterPill(
                          label: rating,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              final updated = Set<String>.from(_draft.ageRatings);
                              if (isSelected) {
                                updated.remove(rating);
                              } else {
                                updated.add(rating);
                              }
                              _draft = _draft.copyWith(ageRatings: updated);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Bottom Sticky Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.lightSurface,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: PrimaryButton(
                    text: 'Apply Filters',
                    onPressed: _applyAndClose,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppTypography.body14(
          color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.pill,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.spotlightCoral
                : (isDark ? AppColors.surface : AppColors.lightSurface),
            borderRadius: AppRadius.pill,
            border: Border.all(
              color: isSelected
                  ? AppColors.spotlightCoral
                  : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.spotlightCoral.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.chipLabel(
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.lavender : AppColors.textPrimaryLight),
            ).copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
