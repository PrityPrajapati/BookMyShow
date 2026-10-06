import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/dining/presentation/providers/dining_providers.dart';
import 'package:showscape/features/dining/presentation/widgets/table_reservation_sheet.dart';

/// Dining Screen (/dining) with comprehensive filters & restaurant cards
class DiningScreen extends ConsumerStatefulWidget {
  const DiningScreen({super.key});

  @override
  ConsumerState<DiningScreen> createState() => _DiningScreenState();
}

class _DiningScreenState extends ConsumerState<DiningScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _cuisines = const [
    'All',
    'Italian',
    'Asian',
    'North Indian',
    'Continental',
    'Cafe',
    'Rooftop Lounge',
    'Seafood',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openReservationSheet(BuildContext context, Restaurant restaurant) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TableReservationSheet(restaurant: restaurant),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterState = ref.watch(diningFilterProvider);
    final filterNotifier = ref.read(diningFilterProvider.notifier);
    final restaurantsAsync = ref.watch(filteredRestaurantsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => context.pop(),
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                size: 18,
                color: AppColors.spotlightCoral,
              ),
            ),
            AppSpacing.horizontal12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ShowScape Dining',
                    style: AppTypography.heading18(
                      color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Reserve tables before & after the show',
                    style: AppTypography.caption12(
                      color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_rounded, color: AppColors.marqueeAmber),
            tooltip: 'ShowScape Gold Dining Perks',
            onPressed: () => context.push(AppRoutes.gold),
          ),
          AppSpacing.horizontal8,
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurface,
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                onChanged: (val) => filterNotifier.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search restaurants, cuisines, lounges...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.spotlightCoral),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            filterNotifier.setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // 2. Horizontal Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Veg Only Switch Filter
                FilterChip(
                  avatar: const Icon(Icons.eco_rounded, size: 14, color: AppColors.success),
                  label: const Text('Pure Veg'),
                  selected: filterState.vegOnly,
                  selectedColor: AppColors.success.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.success,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: filterState.vegOnly
                        ? AppColors.success
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.pill,
                    side: BorderSide(
                      color: filterState.vegOnly
                          ? AppColors.success
                          : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                    ),
                  ),
                  onSelected: (val) => filterNotifier.toggleVegOnly(val),
                ),
                AppSpacing.horizontal8,

                // Offers Filter
                FilterChip(
                  avatar: const Icon(Icons.local_offer_rounded, size: 14, color: AppColors.marqueeAmber),
                  label: const Text('Offers'),
                  selected: filterState.hasOffersOnly,
                  selectedColor: AppColors.marqueeAmber.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.marqueeAmber,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: filterState.hasOffersOnly
                        ? AppColors.marqueeAmber
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                  backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.pill,
                    side: BorderSide(
                      color: filterState.hasOffersOnly
                          ? AppColors.marqueeAmber
                          : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                    ),
                  ),
                  onSelected: (val) => filterNotifier.toggleOffersOnly(val),
                ),
                AppSpacing.horizontal8,

                // Cost for Two Filter Dropdown / Pill
                PopupMenuButton<double?>(
                  tooltip: 'Filter by Cost for Two',
                  color: isDark ? AppColors.surface : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.border16),
                  onSelected: (val) => filterNotifier.setMaxCostForTwo(val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: null, child: Text('Any Cost')),
                    const PopupMenuItem(value: 1200.0, child: Text('Under ₹1,200 for two')),
                    const PopupMenuItem(value: 2000.0, child: Text('Under ₹2,000 for two')),
                    const PopupMenuItem(value: 3000.0, child: Text('Under ₹3,000 for two')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: filterState.maxCostForTwo != null
                          ? AppColors.spotlightCoral.withValues(alpha: 0.2)
                          : (isDark ? AppColors.surface : AppColors.lightSurface),
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: filterState.maxCostForTwo != null
                            ? AppColors.spotlightCoral
                            : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.currency_rupee_rounded,
                          size: 14,
                          color: filterState.maxCostForTwo != null
                              ? AppColors.spotlightCoral
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filterState.maxCostForTwo != null
                              ? '< ₹${filterState.maxCostForTwo!.toInt()}'
                              : 'Cost for two',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: filterState.maxCostForTwo != null
                                ? AppColors.spotlightCoral
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.horizontal8,

                // Distance from Venue Filter
                PopupMenuButton<double?>(
                  tooltip: 'Filter by Distance',
                  color: isDark ? AppColors.surface : AppColors.lightSurface,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.border16),
                  onSelected: (val) => filterNotifier.setMaxDistance(val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: null, child: Text('Any Distance')),
                    const PopupMenuItem(value: 2.0, child: Text('< 2 km from venue')),
                    const PopupMenuItem(value: 5.0, child: Text('< 5 km from venue')),
                    const PopupMenuItem(value: 10.0, child: Text('< 10 km from venue')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: filterState.maxDistanceKm != null
                          ? AppColors.spotlightCoral.withValues(alpha: 0.2)
                          : (isDark ? AppColors.surface : AppColors.lightSurface),
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: filterState.maxDistanceKm != null
                            ? AppColors.spotlightCoral
                            : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.near_me_rounded,
                          size: 14,
                          color: filterState.maxDistanceKm != null
                              ? AppColors.spotlightCoral
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filterState.maxDistanceKm != null
                              ? '< ${filterState.maxDistanceKm!.toStringAsFixed(0)} km'
                              : 'Distance',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: filterState.maxDistanceKm != null
                                ? AppColors.spotlightCoral
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.horizontal8,

                // Reset Button if any filter active
                if (filterState.selectedCuisine != null ||
                    filterState.vegOnly ||
                    filterState.maxCostForTwo != null ||
                    filterState.maxDistanceKm != null ||
                    filterState.hasOffersOnly)
                  ActionChip(
                    avatar: const Icon(Icons.replay_rounded, size: 14, color: AppColors.spotlightCoral),
                    label: const Text('Reset'),
                    labelStyle: const TextStyle(fontSize: 12, color: AppColors.spotlightCoral),
                    backgroundColor: AppColors.spotlightCoral.withValues(alpha: 0.1),
                    onPressed: () => filterNotifier.reset(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. Cuisine Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _cuisines.map((cuisine) {
                final isSelected = (cuisine == 'All' && filterState.selectedCuisine == null) ||
                    filterState.selectedCuisine == cuisine;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cuisine),
                    selected: isSelected,
                    selectedColor: AppColors.spotlightCoral,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.pill,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.spotlightCoral
                            : (isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder),
                      ),
                    ),
                    onSelected: (_) {
                      filterNotifier.setCuisine(cuisine == 'All' ? null : cuisine);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // 4. Restaurant Cards List
          Expanded(
            child: restaurantsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.spotlightCoral),
                ),
              ),
              error: (err, _) => Center(
                child: Text('Failed to load restaurants: $err'),
              ),
              data: (restaurants) {
                if (restaurants.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.restaurant_outlined, size: 54, color: AppColors.spotlightCoral),
                          const SizedBox(height: 16),
                          Text(
                            'No restaurants found',
                            style: AppTypography.heading18(
                              color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try changing or clearing your filters to see more dining spots near your venue.',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption12(
                              color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.spotlightCoral,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Reset All Filters'),
                            onPressed: () => filterNotifier.reset(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final r = restaurants[index];
                    return _RestaurantCard(
                      restaurant: r,
                      onTap: () => context.push(AppRoutes.diningDetailPath(r.id)),
                      onReserve: () => _openReservationSheet(context, r),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Single Restaurant Card in List
class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback onReserve;

  const _RestaurantCard({
    required this.restaurant,
    required this.onTap,
    required this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.border20,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Photo Banner with Rating & Veg Badges
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 8.5,
                    child: Image.network(
                      restaurant.bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: const Icon(Icons.restaurant, color: Colors.white24, size: 40),
                      ),
                    ),
                  ),
                  // Dark gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Pure Veg badge if applicable
                  if (restaurant.isPureVeg)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.greenAccent, width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco_rounded, color: Colors.greenAccent, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'PURE VEG',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Top right: Gold VIP Lounge tag
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.8)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: AppColors.marqueeAmber, size: 14),
                          SizedBox(width: 3),
                          Text(
                            'SHOWSCAPE PARTNER',
                            style: TextStyle(
                              color: AppColors.marqueeAmber,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Info on Banner: Rating & Timing
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                restaurant.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.star, color: Colors.white, size: 12),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${restaurant.reviewCount}+ reviews',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${restaurant.openTime} - ${restaurant.closeTime}',
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Restaurant Info & Offers
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: AppTypography.heading18(
                                  color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                restaurant.cuisine.join(' • '),
                                style: AppTypography.caption12(
                                  color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${restaurant.costForTwo.toInt()}',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'for two',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Distance & Address
                    Row(
                      children: [
                        const Icon(Icons.near_me_rounded, size: 13, color: AppColors.spotlightCoral),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.distanceKm.toStringAsFixed(1)} km from venue',
                          style: const TextStyle(
                            color: AppColors.spotlightCoral,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('•', style: TextStyle(color: isDark ? Colors.white24 : Colors.black26)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            restaurant.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Offers Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.marqueeAmber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.marqueeAmber.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.local_offer_rounded, size: 14, color: AppColors.marqueeAmber),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Flat 20% off after the show with ShowScape Ticket',
                              style: TextStyle(
                                color: AppColors.marqueeAmber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                              side: BorderSide(
                                color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: onTap,
                            child: const Text('View Menu & Photos', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        AppSpacing.horizontal12,
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.spotlightCoral,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: onReserve,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.table_restaurant_rounded, size: 14),
                                SizedBox(width: 5),
                                Text(
                                  'Reserve Table',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
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
