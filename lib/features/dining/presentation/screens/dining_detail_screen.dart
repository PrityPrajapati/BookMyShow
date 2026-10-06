import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/dining/domain/models/restaurant.dart';
import 'package:showscape/features/dining/presentation/providers/dining_providers.dart';
import 'package:showscape/features/dining/presentation/widgets/table_reservation_sheet.dart';

/// Restaurant Detail Screen (/dining/:id) with Photo Carousel, Menu Highlights, Offers & Table Reservation
class DiningDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const DiningDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DiningDetailScreen> createState() => _DiningDetailScreenState();
}

class _DiningDetailScreenState extends ConsumerState<DiningDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
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
    final restaurantAsync = ref.watch(restaurantDetailProvider(widget.id));

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      body: restaurantAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.spotlightCoral),
          ),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(leading: const BackButton()),
          body: Center(child: Text('Error loading restaurant: $err')),
        ),
        data: (restaurant) {
          if (restaurant == null) {
            return Scaffold(
              appBar: AppBar(leading: const BackButton()),
              body: const Center(child: Text('Restaurant not found')),
            );
          }

          final photos = restaurant.galleryPhotos;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // 1. Sliver App Bar with Photo Carousel
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Restaurant link copied to clipboard'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: photos.length,
                            onPageChanged: (i) => setState(() => _currentPhotoIndex = i),
                            itemBuilder: (ctx, i) {
                              return Image.network(
                                photos[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade900,
                                  child: const Icon(Icons.image_not_supported, color: Colors.white38),
                                ),
                              );
                            },
                          ),
                          // Dark gradient overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black45,
                                    Colors.transparent,
                                    (isDark ? AppColors.midnight : Colors.black).withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Carousel Dots Indicator
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                photos.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: _currentPhotoIndex == index ? 20 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _currentPhotoIndex == index
                                        ? AppColors.spotlightCoral
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Main Details Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Name, Veg badge & Rating
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: AppTypography.heading24(
                                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                                      ).copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      restaurant.cuisine.join(' • '),
                                      style: TextStyle(
                                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (restaurant.isPureVeg)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B5E20).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.greenAccent),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.eco_rounded, color: Colors.greenAccent, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'PURE VEG',
                                        style: TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Rating, Cost & Distance Row
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surface : AppColors.lightSurface,
                              borderRadius: AppRadius.border16,
                              border: Border.all(
                                color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Rating
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: AppColors.marqueeAmber, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          restaurant.rating.toStringAsFixed(1),
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${restaurant.reviewCount}+ reviews',
                                      style: TextStyle(
                                        color: isDark ? Colors.white38 : Colors.black38,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 28,
                                  width: 1,
                                  color: isDark ? Colors.white12 : Colors.black12,
                                ),
                                // Cost for two
                                Column(
                                  children: [
                                    Text(
                                      '₹${restaurant.costForTwo.toInt()}',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Cost for two',
                                      style: TextStyle(
                                        color: isDark ? Colors.white38 : Colors.black38,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 28,
                                  width: 1,
                                  color: isDark ? Colors.white12 : Colors.black12,
                                ),
                                // Distance
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.near_me_rounded, color: AppColors.spotlightCoral, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${restaurant.distanceKm.toStringAsFixed(1)} km',
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'From venue',
                                      style: TextStyle(
                                        color: isDark ? Colors.white38 : Colors.black38,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Location & Hours
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18, color: AppColors.spotlightCoral),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${restaurant.address}, ${restaurant.city}',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 18, color: AppColors.spotlightCoral),
                              const SizedBox(width: 8),
                              Text(
                                'Open Today: ${restaurant.openTime} – ${restaurant.closeTime}',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Offers Section
                          Text(
                            'Special Offers & Discounts',
                            style: AppTypography.heading18(
                              color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          ...restaurant.offers.map(
                            (offer) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.marqueeAmber.withValues(alpha: 0.1),
                                borderRadius: AppRadius.border12,
                                border: Border.all(
                                  color: AppColors.marqueeAmber.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_offer_rounded, color: AppColors.marqueeAmber, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      offer,
                                      style: const TextStyle(
                                        color: AppColors.marqueeAmber,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.check_circle_rounded, color: AppColors.marqueeAmber, size: 16),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Menu Highlights
                          Text(
                            'Signature Menu Highlights',
                            style: AppTypography.heading18(
                              color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          if (restaurant.featuredDishes.isNotEmpty)
                            SizedBox(
                              height: 110,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: restaurant.featuredDishes.length,
                                itemBuilder: (ctx, i) {
                                  final dish = restaurant.featuredDishes[i];
                                  return Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surface : AppColors.lightSurface,
                                      borderRadius: AppRadius.border16,
                                      border: Border.all(
                                        color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.restaurant_menu_rounded,
                                            size: 16,
                                            color: AppColors.spotlightCoral,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          dish,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Chef Special',
                                          style: TextStyle(color: AppColors.marqueeAmber, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            const Text('Menu items available upon dining in.'),

                          const SizedBox(height: 24),

                          // Amenities
                          if (restaurant.amenities.isNotEmpty) ...[
                            Text(
                              'Amenities & Features',
                              style: AppTypography.heading18(
                                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: restaurant.amenities
                                  .map(
                                    (a) => Chip(
                                      avatar: const Icon(Icons.check_rounded, size: 14, color: AppColors.spotlightCoral),
                                      label: Text(a),
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : Colors.black87,
                                      ),
                                      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
                                      side: BorderSide(
                                        color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // 3. Sticky Bottom Reservation Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Table Reservation',
                            style: TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Instant Confirmation',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.bolt_rounded, color: AppColors.success, size: 16),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.spotlightCoral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                        ),
                        onPressed: () => _openReservationSheet(context, restaurant),
                        child: const Row(
                          children: [
                            Icon(Icons.table_restaurant_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Reserve a Table',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
