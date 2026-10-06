import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/shimmer_box.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/food/domain/services/combo_recommender.dart';
import 'package:showscape/features/food/presentation/widgets/combo_card.dart';
import 'package:showscape/features/food/presentation/widgets/floating_cart_bar.dart';
import 'package:showscape/features/food/presentation/widgets/fnb_item_card.dart';
import 'package:showscape/features/food/presentation/widgets/indian_diet_badge.dart';
import 'package:showscape/features/food/presentation/widgets/item_customisation_sheet.dart';

class FoodScreen extends ConsumerStatefulWidget {
  final String bookingDraftId;

  const FoodScreen({super.key, required this.bookingDraftId});

  @override
  ConsumerState<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends ConsumerState<FoodScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _onlyVeg = false;

  final List<String> _tabs = ['Combos', 'Popcorn', 'Beverages', 'Meals'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _proceedToNextStep(String venueId, bool hasParking) {
    HapticFeedback.mediumImpact();
    if (hasParking) {
      context.push(AppRoutes.parkingPath(venueId));
    } else {
      context.push(AppRoutes.checkout);
    }
  }

  void _openCustomisation(FnbItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemCustomisationSheet(
        item: item,
        onAddToCart: (cartItem) {
          ref.read(bookingDraftProvider.notifier).addFnbCartItem(cartItem);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final combosAsync = ref.watch(fnbCombosProvider);
    final itemsAsync = ref.watch(fnbItemsProvider);

    // Resolve venueId from draft or default to 'ven_001'
    final venueId = draft.venueId ?? 'ven_001';
    final venueAsync = ref.watch(venueDetailProvider(venueId));
    final hasParking = venueAsync.value?.parkingLots.isNotEmpty ?? true;

    final seatCount = draft.seatCount > 0 ? draft.seatCount : 2;

    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.lavender),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grab a Bite',
              style: AppTypography.heading20().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Pre-order fresh snacks & avoid queues',
              style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _proceedToNextStep(venueId, hasParking),
            child: Text(
              'Skip',
              style: AppTypography.buttonLabel(color: AppColors.spotlightCoral).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Pickup Option Selector & Veg Filter
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pickup Timing Section
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.border20,
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.delivery_dining_rounded,
                                    size: 16,
                                    color: AppColors.marqueeAmber,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'When should we prepare your order?',
                                    style: AppTypography.body14(color: AppColors.lavender).copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.vertical8,
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildPickupOption(
                                      title: 'Before show',
                                      subtitle: 'Ready at concession counter',
                                      icon: Icons.timer_outlined,
                                      isSelected:
                                          draft.pickupTiming == PickupTiming.beforeShow,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        ref
                                            .read(bookingDraftProvider.notifier)
                                            .setPickupTiming(PickupTiming.beforeShow);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildPickupOption(
                                      title: 'At interval',
                                      subtitle: 'Delivered to your seat',
                                      icon: Icons.local_activity_outlined,
                                      isSelected:
                                          draft.pickupTiming == PickupTiming.atInterval,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        ref
                                            .read(bookingDraftProvider.notifier)
                                            .setPickupTiming(PickupTiming.atInterval);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        AppSpacing.vertical12,

                        // Dietary Filter Chip Row
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _onlyVeg = !_onlyVeg);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _onlyVeg
                                      ? AppColors.success.withOpacity(0.15)
                                      : AppColors.surface,
                                  borderRadius: AppRadius.pill,
                                  border: Border.all(
                                    color: _onlyVeg
                                        ? AppColors.success
                                        : AppColors.surfaceBorder,
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const IndianDietBadge(isVeg: true, size: 12),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Pure Veg',
                                      style: AppTypography.caption12(
                                        color: _onlyVeg
                                            ? Colors.white
                                            : AppColors.lavenderMuted,
                                      ).copyWith(
                                        fontWeight:
                                            _onlyVeg ? FontWeight.w700 : FontWeight.w500,
                                      ),
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
                ),

                // Pinned Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      indicatorColor: AppColors.spotlightCoral,
                      indicatorWeight: 3,
                      labelColor: AppColors.spotlightCoral,
                      unselectedLabelColor: AppColors.lavenderMuted,
                      labelStyle: AppTypography.heading20().copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: AppTypography.heading20().copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: _tabs.map((name) => Tab(text: name)).toList(),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                // 1. Combos Tab
                combosAsync.when(
                  loading: () => _buildLoadingList(),
                  error: (err, _) => Center(child: Text('Error loading combos: $err')),
                  data: (combos) {
                    final bookingsAsync = ref.watch(allUserBookingsProvider);
                    final pastBookings = bookingsAsync.value ?? [];
                    final userFlavours = ComboRecommender.extractFlavoursFromBookings(pastBookings);
                    final bestFit = ComboRecommender.recommendCombo(
                      combos: combos,
                      groupSize: seatCount,
                      orderHistoryFlavours: userFlavours,
                    );
                    final filtered = _onlyVeg
                        ? combos
                            .where((c) => c.items.every((i) => i.isVeg))
                            .toList()
                        : combos;

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final combo = filtered[index];
                        final cartCombo = draft.fnbItems.cast<FnbCartItem?>().firstWhere(
                              (i) => i?.combo?.id == combo.id,
                              orElse: () => null,
                            );

                        return ComboCard(
                          combo: combo,
                          quantity: cartCombo?.quantity ?? 0,
                          isRecommended: combo.id == bestFit?.id,
                          isPickedForYou: combo.id == bestFit?.id,
                          recommendedSeatCount: seatCount,
                          onAdd: () {
                            HapticFeedback.lightImpact();
                            final cartItem = FnbCartItem(
                              id: 'combo_${combo.id}',
                              combo: combo,
                              unitPrice: combo.comboPrice,
                              quantity: 1,
                            );
                            ref.read(bookingDraftProvider.notifier).addFnbCartItem(cartItem);
                          },
                          onQuantityChanged: (qty) {
                            HapticFeedback.lightImpact();
                            ref
                                .read(bookingDraftProvider.notifier)
                                .updateFnbQuantity('combo_${combo.id}', qty);
                          },
                        );
                      },
                    );
                  },
                ),

                // 2. Popcorn Tab
                _buildItemsList(
                  itemsAsync,
                  categoryMatch: (cat) => cat.contains('popcorn'),
                  draft: draft,
                ),

                // 3. Beverages Tab
                _buildItemsList(
                  itemsAsync,
                  categoryMatch: (cat) =>
                      cat.contains('beverage') || cat.contains('drink'),
                  draft: draft,
                ),

                // 4. Meals Tab (Hot Food & Snacks)
                _buildItemsList(
                  itemsAsync,
                  categoryMatch: (cat) =>
                      cat.contains('snack') ||
                      cat.contains('hot food') ||
                      cat.contains('meal'),
                  draft: draft,
                ),
              ],
            ),
          ),

          // Floating Cart Bar pinned at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: FloatingCartBar(
                items: draft.fnbItems,
                onProceed: () => _proceedToNextStep(venueId, hasParking),
                onViewDetails: () => _showCartDetailsSheet(context, draft),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.border12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.spotlightCoral.withOpacity(0.12)
              : AppColors.surfaceElevated,
          borderRadius: AppRadius.border12,
          border: Border.all(
            color: isSelected ? AppColors.spotlightCoral : AppColors.surfaceBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.spotlightCoral : AppColors.lavenderMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading20().copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppColors.spotlightCoral : AppColors.lavender,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    AsyncValue<List<FnbItem>> itemsAsync, {
    required bool Function(String category) categoryMatch,
    required BookingDraft draft,
  }) {
    return itemsAsync.when(
      loading: () => _buildLoadingList(),
      error: (err, _) => Center(child: Text('Error loading items: $err')),
      data: (items) {
        final filtered = items.where((i) {
          final cat = i.category.toLowerCase();
          final matchesCat = categoryMatch(cat);
          if (!matchesCat) return false;
          if (_onlyVeg && !i.isVeg) return false;
          return true;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.no_meals_rounded,
                  size: 48,
                  color: AppColors.lavenderMuted,
                ),
                AppSpacing.vertical12,
                Text(
                  'No items available in this category',
                  style: AppTypography.body14(color: AppColors.lavenderMuted),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            final cartItems = draft.fnbItems.where((i) => i.item?.id == item.id);
            final totalQty = cartItems.fold<int>(0, (sum, i) => sum + i.quantity);

            return FnbItemCard(
              item: item,
              cartQuantity: totalQty,
              onTap: () => _openCustomisation(item),
              onAdd: () => _openCustomisation(item),
              onQuantityChanged: (newQty) {
                HapticFeedback.lightImpact();
                if (cartItems.isNotEmpty) {
                  ref
                      .read(bookingDraftProvider.notifier)
                      .updateFnbQuantity(cartItems.first.id, newQty);
                } else {
                  _openCustomisation(item);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ShimmerBox(
          width: double.infinity,
          height: 140,
          borderRadius: AppRadius.border20,
        ),
      ),
    );
  }

  void _showCartDetailsSheet(BuildContext context, BookingDraft draft) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop28,
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Snack Cart',
                      style: AppTypography.heading20().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.lavenderMuted),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const Divider(color: AppColors.surfaceBorder),
                ...draft.fnbItems.map((cartItem) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        IndianDietBadge(isVeg: cartItem.isVeg, size: 12),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem.name,
                                style: AppTypography.body14(color: AppColors.lavender).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (cartItem.size != null || cartItem.flavour != null)
                                Text(
                                  [cartItem.size, cartItem.flavour]
                                      .where((e) => e != null)
                                      .join(' • '),
                                  style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '${cartItem.quantity} × ₹${cartItem.unitPrice.toInt()}',
                          style: AppTypography.caption12(color: AppColors.lavenderMuted),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '₹${cartItem.totalPrice.toInt()}',
                          style: AppTypography.body16(color: AppColors.lavender, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(color: AppColors.surfaceBorder, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: AppTypography.heading20().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '₹${draft.fnbTotal.toInt()}',
                      style: AppTypography.heading24(color: AppColors.spotlightCoral),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.midnight,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
