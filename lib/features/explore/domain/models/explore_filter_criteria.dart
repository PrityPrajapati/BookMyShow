enum ExploreCategory {
  all,
  movies,
  events,
  sports,
  comedy,
  dining;

  String get label {
    switch (this) {
      case ExploreCategory.all:
        return 'All';
      case ExploreCategory.movies:
        return 'Movies';
      case ExploreCategory.events:
        return 'Events';
      case ExploreCategory.sports:
        return 'Sports';
      case ExploreCategory.comedy:
        return 'Comedy';
      case ExploreCategory.dining:
        return 'Dining';
    }
  }
}

enum ExploreSortBy {
  relevance,
  popularity,
  priceAsc,
  date,
  distance;

  String get label {
    switch (this) {
      case ExploreSortBy.relevance:
        return 'Relevance';
      case ExploreSortBy.popularity:
        return 'Popularity';
      case ExploreSortBy.priceAsc:
        return 'Price: Low to High';
      case ExploreSortBy.date:
        return 'Date: Upcoming First';
      case ExploreSortBy.distance:
        return 'Distance: Nearest First';
    }
  }
}

class ExploreFilterCriteria {
  final ExploreCategory category;
  final DateTime? selectedDate;
  final Set<String> languages;
  final Set<String> genres;
  final Set<String> moods;
  final double minPrice;
  final double maxPrice;
  final double? maxDistanceKm;
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> formats;
  final Set<String> ageRatings;
  final ExploreSortBy sortBy;
  final String searchQuery;

  const ExploreFilterCriteria({
    this.category = ExploreCategory.all,
    this.selectedDate,
    this.languages = const {},
    this.genres = const {},
    this.moods = const {},
    this.minPrice = 0.0,
    this.maxPrice = 10000.0,
    this.maxDistanceKm,
    this.startDate,
    this.endDate,
    this.formats = const {},
    this.ageRatings = const {},
    this.sortBy = ExploreSortBy.relevance,
    this.searchQuery = '',
  });

  /// Check whether any non-default filters are active
  bool get hasActiveFilters {
    return selectedDate != null ||
        languages.isNotEmpty ||
        genres.isNotEmpty ||
        moods.isNotEmpty ||
        minPrice > 0.0 ||
        maxPrice < 10000.0 ||
        maxDistanceKm != null ||
        startDate != null ||
        endDate != null ||
        formats.isNotEmpty ||
        ageRatings.isNotEmpty ||
        sortBy != ExploreSortBy.relevance;
  }

  ExploreFilterCriteria copyWith({
    ExploreCategory? category,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    Set<String>? languages,
    Set<String>? genres,
    Set<String>? moods,
    double? minPrice,
    double? maxPrice,
    double? maxDistanceKm,
    bool clearMaxDistance = false,
    DateTime? startDate,
    DateTime? endDate,
    bool clearDateRange = false,
    Set<String>? formats,
    Set<String>? ageRatings,
    ExploreSortBy? sortBy,
    String? searchQuery,
  }) {
    return ExploreFilterCriteria(
      category: category ?? this.category,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      languages: languages ?? this.languages,
      genres: genres ?? this.genres,
      moods: moods ?? this.moods,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDistanceKm:
          clearMaxDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      startDate: clearDateRange ? null : (startDate ?? this.startDate),
      endDate: clearDateRange ? null : (endDate ?? this.endDate),
      formats: formats ?? this.formats,
      ageRatings: ageRatings ?? this.ageRatings,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'selectedDate': selectedDate?.toIso8601String(),
      'languages': languages.toList(),
      'genres': genres.toList(),
      'moods': moods.toList(),
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'maxDistanceKm': maxDistanceKm,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'formats': formats.toList(),
      'ageRatings': ageRatings.toList(),
      'sortBy': sortBy.name,
      'searchQuery': searchQuery,
    };
  }

  factory ExploreFilterCriteria.fromJson(Map<String, dynamic> json) {
    return ExploreFilterCriteria(
      category: ExploreCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ExploreCategory.all,
      ),
      selectedDate: json['selectedDate'] != null
          ? DateTime.tryParse(json['selectedDate'] as String)
          : null,
      languages: ((json['languages'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toSet(),
      genres: ((json['genres'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toSet(),
      moods: ((json['moods'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toSet(),
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 10000.0,
      maxDistanceKm: (json['maxDistanceKm'] as num?)?.toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
      formats: ((json['formats'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toSet(),
      ageRatings: ((json['ageRatings'] as List<dynamic>?) ?? [])
          .map((e) => e.toString())
          .toSet(),
      sortBy: ExploreSortBy.values.firstWhere(
        (s) => s.name == json['sortBy'],
        orElse: () => ExploreSortBy.relevance,
      ),
      searchQuery: (json['searchQuery'] as String?) ?? '',
    );
  }
}
