import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/widgets/showscape_image.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/dining/domain/models/reservation.dart';
import 'package:showscape/features/food/domain/models/fnb_combo.dart';
import 'package:showscape/features/parking/domain/models/parking_lot.dart';
import 'package:showscape/services/pricing_engine.dart';

/// Rich PlanCard widget rendered inside Scout AI chat for Date Night / Night Out plans
class PlanCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> plan;

  const PlanCard({
    super.key,
    required this.plan,
  });

  @override
  ConsumerState<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<PlanCard> {
  late int _currentShowIndex;
  late int _currentRestaurantIndex;
  late bool _hasParking;
  bool _isBreakdownExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentShowIndex = (widget.plan['currentShowIndex'] as int?) ?? 0;
    _currentRestaurantIndex =
        (widget.plan['currentRestaurantIndex'] as int?) ?? 0;
    _hasParking = (widget.plan['hasParking'] as bool?) ?? true;
  }

  void _swapShow(int totalShows) {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentShowIndex = (_currentShowIndex + 1) % totalShows;
    });
  }

  void _swapRestaurant(int totalRestaurants) {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentRestaurantIndex =
          (_currentRestaurantIndex + 1) % totalRestaurants;
    });
  }

  void _toggleParking() {
    HapticFeedback.selectionClick();
    setState(() {
      _hasParking = !_hasParking;
    });
  }

  void _bookPlan({
    required Map<String, dynamic> currentShow,
    required Map<String, dynamic> currentRestaurant,
    required double grandTotal,
  }) {
    HapticFeedback.heavyImpact();

    // 1. Calculate seats and prices
    final seatsList = (currentShow['seats'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        ['D-4', 'D-5'];
    final unitPrice = (currentShow['unitPrice'] as num?)?.toDouble() ?? 499.0;
    final seatPrices = List<double>.filled(seatsList.length, unitPrice);

    // 2. Pre-fill BookingDraft
    final draftNotifier = ref.read(bookingDraftProvider.notifier);
    final now = DateTime.now();
    // Next Saturday 7:00 PM
    final daysUntilSaturday = (DateTime.saturday - now.weekday + 7) % 7;
    final showDate = DateTime(
      now.year,
      now.month,
      now.day + (daysUntilSaturday == 0 ? 7 : daysUntilSaturday),
      19,
      0,
    );

    draftNotifier.initForShow(
      draftId: 'draft_scout_${DateTime.now().millisecondsSinceEpoch}',
      showId: (currentShow['showId'] as String?) ?? 'show_comedy_bandra_01',
      eventId: (currentShow['eventId'] as String?) ?? 'event_comedy_01',
      eventTitle: (currentShow['title'] as String?) ?? 'Rahul Subramanian: Live Stand-Up',
      venueName: (currentShow['subtitle'] as String?) ?? 'Bal Gandharva Rang Mandir, Bandra',
      venueId: (currentShow['venueId'] as String?) ?? 'venue_bandra_01',
      showTime: showDate,
      isMovie: false,
      occupancyPct: 60.0,
      durationMinutes: 120,
      seatIds: seatsList,
      seatPrices: seatPrices,
    );

    // 3. Pre-fill Food Combo (Date Night Popcorn & Coke Duo)
    draftNotifier.clearFnb();
    draftNotifier.addFnbCartItem(
      const FnbCartItem(
        id: 'fnb_date_night_duo',
        unitPrice: 200.0,
        quantity: 1,
        size: 'Duo',
        flavour: 'Caramel & Butter Salted',
        combo: FnbCombo(
          id: 'combo_date_night',
          name: 'Date Night Popcorn & Coke Duo',
          description: 'Fresh caramel popcorn and 2 cold beverages',
          imageUrl:
              'https://images.unsplash.com/photo-1585647347384-2593bc35786b?w=400',
          originalPrice: 280.0,
          comboPrice: 200.0,
          items: [],
        ),
      ),
    );

    // 4. Pre-fill Parking if active
    if (_hasParking) {
      draftNotifier.setParking(
        const ParkingSelection(
          lot: ParkingLot(
            id: 'lot_bandra_01',
            name: 'Bal Gandharva Rang Mandir P1',
            vehicleType: VehicleType.fourWheeler,
            capacity: 100,
            available: 42,
            hourlyRate: 50.0,
            flatRate: 150.0,
            isCovered: true,
            hasValet: true,
          ),
          vehicleNumber: 'MH02EK2026',
          durationMinutes: 240,
          charge: 150.0,
        ),
      );
    } else {
      draftNotifier.clearParking();
    }

    // 5. Pre-fill Dining Reservation linked to this booking
    final restaurantId =
        (currentRestaurant['restaurantId'] as String?) ?? 'dine_bastian_bandra';
    final restaurantName =
        (currentRestaurant['title'] as String?) ?? 'Bastian Bandra';
    final reservationTime =
        (currentRestaurant['time'] as String?) ?? '9:30 PM';

    final reservation = Reservation(
      id: 'res_plan_${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      userId: 'usr_scout_user',
      guestName: 'Alex Rivera',
      guestPhone: '+91 98765 43210',
      partySize: 2,
      date: showDate,
      timeSlot: reservationTime,
      specialRequests: 'BOOKING:draft_scout;TYPE:DINE AFTER',
    );
    draftNotifier.setDiningReservation(reservation);

    // 6. Navigate to normal Checkout (Never skip checkout!)
    context.push(AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(currentUserProvider);
    final isGold = userAsync.value?.isGoldMember ?? false;

    // Shows pool
    final rawShows = widget.plan['shows'] as List<dynamic>?;
    final shows = (rawShows != null && rawShows.isNotEmpty)
        ? rawShows.map((e) => e as Map<String, dynamic>).toList()
        : [
            {
              'id': 'show_comedy_01',
              'showId': 'show_comedy_bandra_01',
              'eventId': 'event_comedy_01',
              'type': 'show',
              'time': '7:00 PM',
              'title': 'Rahul Subramanian: Who Are You? (Live)',
              'subtitle': 'Bal Gandharva Rang Mandir, Bandra West',
              'imageUrl':
                  'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?w=500',
              'price': 998.0,
              'unitPrice': 499.0,
              'seats': ['D-4', 'D-5'],
              'venueId': 'venue_bandra_01',
            }
          ];

    // Restaurants pool
    final rawRestaurants = widget.plan['restaurants'] as List<dynamic>?;
    final restaurants = (rawRestaurants != null && rawRestaurants.isNotEmpty)
        ? rawRestaurants.map((e) => e as Map<String, dynamic>).toList()
        : [
            {
              'id': 'dine_01',
              'restaurantId': 'dine_bastian_bandra',
              'type': 'dinner',
              'time': '9:30 PM',
              'title': 'Bastian Bandra',
              'subtitle': 'Seafood & Asian Tapas • Flat 20% off after show',
              'imageUrl':
                  'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
              'price': 1050.0,
            }
          ];

    final currentShow = shows[_currentShowIndex % shows.length];
    final currentRestaurant =
        restaurants[_currentRestaurantIndex % restaurants.length];

    final parkingData = (widget.plan['parking'] as Map<String, dynamic>?) ??
        {
          'id': 'park_01',
          'type': 'parking',
          'time': '6:45 PM',
          'title': 'Reserved Valet & 4-Wheeler Parking',
          'subtitle': 'Basement P1 (Guaranteed spot under venue)',
          'imageUrl':
              'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=500',
          'price': 150.0,
        };

    // Calculate cinema pricing strictly using PricingEngine
    final unitPrice = (currentShow['unitPrice'] as num?)?.toDouble() ?? 499.0;
    final seatPrices = [unitPrice, unitPrice];
    final parkingCharge = _hasParking ? 150.0 : 0.0;
    final fnbCharge = 200.0;

    final now = DateTime.now();
    final daysUntilSaturday = (DateTime.saturday - now.weekday + 7) % 7;
    final showDate = DateTime(
      now.year,
      now.month,
      now.day + (daysUntilSaturday == 0 ? 7 : daysUntilSaturday),
      19,
      0,
    );

    final pricingBreakdown = PricingEngine.calculate(
      seatPrices: seatPrices,
      showDate: showDate,
      isMovie: false,
      occupancyPct: 60.0,
      isGold: isGold,
      fnbTotal: fnbCharge,
      parkingCharge: parkingCharge,
    );

    final restaurantPrice =
        (currentRestaurant['price'] as num?)?.toDouble() ?? 1050.0;
    final grandTotal = pricingBreakdown.grandTotal + restaurantPrice;

    final targetBudget =
        (widget.plan['targetBudget'] as num?)?.toDouble() ?? 2500.0;
    final isImpossibleBudget =
        widget.plan['isImpossibleBudget'] == true || targetBudget < 1500.0;
    final isUnderBudget = grandTotal <= targetBudget;
    final budgetDifference = (targetBudget - grandTotal).abs().toInt();
    final progressFraction =
        (grandTotal / (targetBudget > 0 ? targetBudget : 2500.0)).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131622) : Colors.white,
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: isDark
              ? AppColors.marqueeAmber.withValues(alpha: 0.5)
              : AppColors.marqueeAmber.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.border20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.marqueeAmber.withValues(alpha: 0.25),
                    AppColors.spotlightCoral.withValues(alpha: 0.15),
                  ],
                ),
                border: const Border(
                  bottom: BorderSide(color: Colors.white12, width: 0.8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.marqueeAmber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.marqueeAmber,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (widget.plan['title'] as String?) ??
                              'Date Night Saturday in Bandra',
                          style: const TextStyle(
                            color: AppColors.marqueeAmber,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Curated Timeline • PricingEngine Verified',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.marqueeAmber.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'SCOUT PLAN',
                      style: TextStyle(
                        color: AppColors.marqueeAmber,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Impossible budget warning if applicable
            if (isImpossibleBudget)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.marqueeAmber.withValues(alpha: 0.12),
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: AppColors.marqueeAmber.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.marqueeAmber,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Target budget ₹${targetBudget.toInt()} is below minimum package entry for Bandra live comedy & dinner. Showing the closest, most affordable option below:',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 3. Timeline Items
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                children: [
                  // Item A: Parking (if included)
                  if (_hasParking) ...[
                    _buildTimelineItem(
                      time: parkingData['time'] as String? ?? '6:45 PM',
                      title: parkingData['title'] as String? ??
                          'Reserved Valet & 4-Wheeler Parking',
                      subtitle: parkingData['subtitle'] as String? ??
                          'Basement P1 • Guaranteed slot',
                      imageUrl: parkingData['imageUrl'] as String? ?? '',
                      price: (parkingData['price'] as num?)?.toDouble() ?? 150.0,
                      icon: Icons.local_parking_rounded,
                      iconColor: Colors.blueAccent,
                      isDark: isDark,
                    ),
                    _buildConnector(
                      text: 'Direct elevator to venue',
                      isDark: isDark,
                    ),
                  ],

                  // Item B: Show (7:00 PM)
                  _buildTimelineItem(
                    time: currentShow['time'] as String? ?? '7:00 PM',
                    title: currentShow['title'] as String? ??
                        'Rahul Subramanian: Live Stand-Up',
                    subtitle:
                        '${currentShow['subtitle']} • 2 Seats (${(currentShow['seats'] as List).join(", ")})',
                    imageUrl: currentShow['imageUrl'] as String? ?? '',
                    price: (currentShow['price'] as num?)?.toDouble() ?? 998.0,
                    icon: Icons.theater_comedy_rounded,
                    iconColor: AppColors.spotlightCoral,
                    isDark: isDark,
                  ),

                  // Connector between Show and Dinner
                  _buildConnector(
                    text: '15 min walk buffer (+ snacks during interval)',
                    isDark: isDark,
                  ),

                  // Item C: Dinner (9:30 PM)
                  _buildTimelineItem(
                    time: currentRestaurant['time'] as String? ?? '9:30 PM',
                    title: currentRestaurant['title'] as String? ??
                        'Bastian Bandra',
                    subtitle: currentRestaurant['subtitle'] as String? ??
                        'Seafood & Asian Tapas • Flat 20% off',
                    imageUrl: currentRestaurant['imageUrl'] as String? ?? '',
                    price: (currentRestaurant['price'] as num?)?.toDouble() ??
                        1050.0,
                    icon: Icons.restaurant_rounded,
                    iconColor: AppColors.marqueeAmber,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // 4. Budget Meter & PricingEngine Summary
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Meter Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PACKAGE TOTAL',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '₹${grandTotal.toInt()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => setState(() =>
                                    _isBreakdownExpanded = !_isBreakdownExpanded),
                                child: Row(
                                  children: [
                                    Text(
                                      _isBreakdownExpanded
                                          ? 'Hide bill'
                                          : 'View bill',
                                      style: const TextStyle(
                                        color: AppColors.marqueeAmber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Icon(
                                      _isBreakdownExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.marqueeAmber,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Budget Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUnderBudget
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.spotlightCoral.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isUnderBudget
                                ? AppColors.success
                                : AppColors.spotlightCoral,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUnderBudget
                                  ? Icons.check_circle_rounded
                                  : Icons.info_outline_rounded,
                              size: 14,
                              color: isUnderBudget
                                  ? AppColors.success
                                  : AppColors.spotlightCoral,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isUnderBudget
                                  ? '₹$budgetDifference under budget'
                                  : '₹$budgetDifference over budget',
                              style: TextStyle(
                                color: isUnderBudget
                                    ? AppColors.success
                                    : AppColors.spotlightCoral,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.vertical8,

                  // Budget Meter Bar
                  Stack(
                    children: [
                      Container(
                        height: 7,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressFraction,
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isUnderBudget
                                  ? [
                                      AppColors.success,
                                      const Color(0xFF2ECC71),
                                    ]
                                  : [
                                      AppColors.marqueeAmber,
                                      AppColors.spotlightCoral,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: (isUnderBudget
                                        ? AppColors.success
                                        : AppColors.spotlightCoral)
                                    .withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Budget: ₹${targetBudget.toInt()}',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                      Text(
                        '${(progressFraction * 100).toInt()}% utilized',
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),

                  // Collapsible PricingEngine breakdown
                  if (_isBreakdownExpanded) ...[
                    AppSpacing.vertical12,
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: AppRadius.border12,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          _buildPriceLine(
                            'Show Tickets (2 Seats)',
                            '₹${pricingBreakdown.ticketSubtotal.toInt()}',
                          ),
                          _buildPriceLine(
                            'Convenience Fee & GST',
                            isGold
                                ? 'Waived with Gold'
                                : '₹${(pricingBreakdown.convenienceFee + pricingBreakdown.gstOnFee).toInt()}',
                            isGreen: isGold,
                          ),
                          _buildPriceLine(
                            'Popcorn & Coke Duo Combo',
                            '₹${pricingBreakdown.fnbTotal.toInt()}',
                          ),
                          if (_hasParking)
                            _buildPriceLine(
                              'Valet Parking Slot (P1)',
                              '₹${pricingBreakdown.parking.toInt()}',
                            ),
                          _buildPriceLine(
                            'Dinner for Two (Table Reserved)',
                            '₹${restaurantPrice.toInt()}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 5. Interactive Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Row 1: Swaps & Parking Toggle
                  Row(
                    children: [
                      // Swap Show button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.border12,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                          ),
                          onPressed: () => _swapShow(shows.length),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                          label: const Text(
                            'Swap show',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Swap Restaurant button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.border12,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                          ),
                          onPressed: () =>
                              _swapRestaurant(restaurants.length),
                          icon: const Icon(Icons.restaurant_rounded, size: 15),
                          label: const Text(
                            'Swap dining',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Remove / Add Parking button
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _hasParking
                                ? AppColors.spotlightCoral
                                : AppColors.success,
                            side: BorderSide(
                              color: _hasParking
                                  ? AppColors.spotlightCoral.withValues(alpha: 0.6)
                                  : AppColors.success.withValues(alpha: 0.6),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.border12,
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 6),
                          ),
                          onPressed: _toggleParking,
                          icon: Icon(
                            _hasParking
                                ? Icons.close_rounded
                                : Icons.add_rounded,
                            size: 15,
                          ),
                          label: Text(
                            _hasParking ? 'Remove park' : 'Add park',
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),

                  AppSpacing.vertical12,

                  // Row 2: Book this plan button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.spotlightCoral,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.pill,
                        ),
                        elevation: 4,
                        shadowColor:
                            AppColors.spotlightCoral.withValues(alpha: 0.5),
                      ),
                      onPressed: () => _bookPlan(
                        currentShow: currentShow,
                        currentRestaurant: currentRestaurant,
                        grandTotal: grandTotal,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.confirmation_number_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Book this plan • ₹${grandTotal.toInt()}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String subtitle,
    required String imageUrl,
    required double price,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF191D2D) : Colors.grey.shade50,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 52,
              height: 52,
              child: ShowScapeImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Price Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              '₹${price.toInt()}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector({required String text, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 26),
          Container(
            width: 2,
            height: 22,
            color: AppColors.marqueeAmber.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 14),
          const Icon(
            Icons.directions_walk_rounded,
            size: 13,
            color: AppColors.marqueeAmber,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.marqueeAmber,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLine(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
          Text(
            value,
            style: TextStyle(
              color: isGreen ? AppColors.success : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
