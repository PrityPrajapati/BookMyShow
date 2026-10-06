import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/features/dining/domain/models/reservation.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';

/// Extension on Restaurant for extra photos, offers and menu highlights
extension RestaurantUIExtension on Restaurant {
  List<String> get offers => [
        'Flat 20% off after the show with ShowScape Ticket',
        if (rating >= 4.5) 'Complimentary welcome dessert for Gold VIP',
        'Special 2-course cinema pre-theater combo',
      ];

  List<String> get galleryPhotos => [
        bannerUrl,
        imageUrl,
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=1200&auto=format&fit=crop&q=80',
      ];
}

/// Filter state for dining module
class DiningFilterState {
  final String? selectedCuisine;
  final bool vegOnly;
  final double? maxCostForTwo;
  final double? maxDistanceKm;
  final bool hasOffersOnly;
  final String searchQuery;

  const DiningFilterState({
    this.selectedCuisine,
    this.vegOnly = false,
    this.maxCostForTwo,
    this.maxDistanceKm,
    this.hasOffersOnly = false,
    this.searchQuery = '',
  });

  DiningFilterState copyWith({
    String? selectedCuisine,
    bool? clearCuisine,
    bool? vegOnly,
    double? maxCostForTwo,
    bool? clearCost,
    double? maxDistanceKm,
    bool? clearDistance,
    bool? hasOffersOnly,
    String? searchQuery,
  }) {
    return DiningFilterState(
      selectedCuisine: clearCuisine == true
          ? null
          : (selectedCuisine ?? this.selectedCuisine),
      vegOnly: vegOnly ?? this.vegOnly,
      maxCostForTwo:
          clearCost == true ? null : (maxCostForTwo ?? this.maxCostForTwo),
      maxDistanceKm: clearDistance == true
          ? null
          : (maxDistanceKm ?? this.maxDistanceKm),
      hasOffersOnly: hasOffersOnly ?? this.hasOffersOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier managing dining filters
class DiningFilterNotifier extends StateNotifier<DiningFilterState> {
  DiningFilterNotifier() : super(const DiningFilterState());

  void setCuisine(String? cuisine) {
    if (state.selectedCuisine == cuisine) {
      state = state.copyWith(clearCuisine: true);
    } else {
      state = state.copyWith(selectedCuisine: cuisine);
    }
  }

  void toggleVegOnly(bool veg) {
    state = state.copyWith(vegOnly: veg);
  }

  void setMaxCostForTwo(double? maxCost) {
    if (state.maxCostForTwo == maxCost) {
      state = state.copyWith(clearCost: true);
    } else {
      state = state.copyWith(maxCostForTwo: maxCost);
    }
  }

  void setMaxDistance(double? maxDist) {
    if (state.maxDistanceKm == maxDist) {
      state = state.copyWith(clearDistance: true);
    } else {
      state = state.copyWith(maxDistanceKm: maxDist);
    }
  }

  void toggleOffersOnly(bool offers) {
    state = state.copyWith(hasOffersOnly: offers);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reset() {
    state = const DiningFilterState();
  }
}

final diningFilterProvider =
    StateNotifierProvider<DiningFilterNotifier, DiningFilterState>((ref) {
  return DiningFilterNotifier();
});

/// All restaurants fetched from repository
final allRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  final repo = ref.watch(diningRepositoryProvider);
  return repo.getRestaurants();
});

/// Filtered restaurants based on active filters
final filteredRestaurantsProvider = Provider<AsyncValue<List<Restaurant>>>((ref) {
  final restaurantsAsync = ref.watch(allRestaurantsProvider);
  final filter = ref.watch(diningFilterProvider);

  return restaurantsAsync.whenData((list) {
    return list.where((r) {
      // 1. Cuisine filter
      if (filter.selectedCuisine != null) {
        final matches = r.cuisine.any(
          (c) => c.toLowerCase().contains(filter.selectedCuisine!.toLowerCase()),
        );
        if (!matches) return false;
      }

      // 2. Veg only filter
      if (filter.vegOnly && !r.isPureVeg) {
        return false;
      }

      // 3. Cost for two filter
      if (filter.maxCostForTwo != null && r.costForTwo > filter.maxCostForTwo!) {
        return false;
      }

      // 4. Distance filter
      if (filter.maxDistanceKm != null && r.distanceKm > filter.maxDistanceKm!) {
        return false;
      }

      // 5. Search query
      if (filter.searchQuery.isNotEmpty) {
        final q = filter.searchQuery.toLowerCase();
        final matchName = r.name.toLowerCase().contains(q);
        final matchCuisine =
            r.cuisine.any((c) => c.toLowerCase().contains(q));
        final matchAddress = r.address.toLowerCase().contains(q);
        if (!matchName && !matchCuisine && !matchAddress) return false;
      }

      return true;
    }).toList();
  });
});

/// Single restaurant detail provider
final restaurantDetailProvider =
    FutureProvider.family<Restaurant?, String>((ref, id) async {
  final repo = ref.watch(diningRepositoryProvider);
  return repo.getRestaurantById(id);
});

/// StateNotifier for managing confirmed user table reservations
class UserReservationsNotifier extends StateNotifier<List<Reservation>> {
  UserReservationsNotifier() : super([]);

  void addReservation(Reservation reservation) {
    state = [reservation, ...state];
  }

  void cancelReservation(String id) {
    state = state.map((r) {
      if (r.id == id) {
        return r.copyWith(status: ReservationStatus.cancelled);
      }
      return r;
    }).toList();
  }

  Reservation? getReservationForBooking(String bookingId) {
    try {
      return state.firstWhere(
        (r) =>
            r.status == ReservationStatus.confirmed &&
            r.specialRequests != null &&
            r.specialRequests!.contains('BOOKING:$bookingId'),
      );
    } catch (_) {
      return null;
    }
  }
}

final userReservationsProvider =
    StateNotifierProvider<UserReservationsNotifier, List<Reservation>>((ref) {
  return UserReservationsNotifier();
});

/// Suggestion bundle for show alignment (Dine Before & Dine After)
class ShowDiningSuggestions {
  final Restaurant restaurant;
  final String dineBeforeSlot;
  final String dineAfterSlot;
  final DateTime showStart;
  final DateTime showEnd;
  final double walkingMinutes;

  const ShowDiningSuggestions({
    required this.restaurant,
    required this.dineBeforeSlot,
    required this.dineAfterSlot,
    required this.showStart,
    required this.showEnd,
    this.walkingMinutes = 15.0,
  });
}

/// Aligned Dine-Before and Dine-After suggestions provider for a show
final showDiningSuggestionsProvider = Provider.family<
    AsyncValue<ShowDiningSuggestions?>,
    ({DateTime showStart, DateTime showEnd, String venueId})>((ref, params) {
  final restaurantsAsync = ref.watch(allRestaurantsProvider);

  return restaurantsAsync.whenData((restaurants) {
    if (restaurants.isEmpty) return null;

    // Pick top rated restaurant closest to venue
    final sorted = [...restaurants]..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final best = sorted.first;

    final formatter = DateFormat('h:mm a');

    // Dine before: showStart - 75m to 90m (dining + 15m walk buffer)
    final beforeTime = params.showStart.subtract(const Duration(minutes: 75));
    final dineBeforeSlot = formatter.format(beforeTime);

    // Dine after: showEnd + 15m (walk buffer)
    final afterTime = params.showEnd.add(const Duration(minutes: 15));
    final dineAfterSlot = formatter.format(afterTime);

    return ShowDiningSuggestions(
      restaurant: best,
      dineBeforeSlot: dineBeforeSlot,
      dineAfterSlot: dineAfterSlot,
      showStart: params.showStart,
      showEnd: params.showEnd,
    );
  });
});
