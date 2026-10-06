import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/demo_mode_provider.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/gold_badge.dart';
import 'package:showscape/core/widgets/price_summary_bar.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/food/presentation/widgets/indian_diet_badge.dart';
import 'package:showscape/features/notifications/presentation/providers/notification_providers.dart';
import 'package:showscape/features/payment/domain/models/payment_request.dart';
import 'package:showscape/features/payment/domain/models/saved_payment_method.dart';
import 'package:showscape/features/payment/presentation/providers/payment_provider.dart';
import 'package:showscape/features/payment/presentation/providers/saved_payment_methods_provider.dart';
import 'package:showscape/features/payment/presentation/widgets/payment_method_picker.dart';
import 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart';
import 'package:showscape/services/pricing_engine.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _agreedToTerms = true;
  bool _isProcessingPayment = false;
  String? _appliedCoupon;
  double _couponDiscount = 0.0;
  bool _isBreakdownExpanded = true;
  String? _selectedPaymentMethodId;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(String code) {
    HapticFeedback.lightImpact();
    final normalized = code.trim().toUpperCase();
    if (normalized == 'SHOW100') {
      setState(() {
        _appliedCoupon = 'SHOW100';
        _couponDiscount = 100.0;
        _couponController.text = 'SHOW100';
      });
      _showToast('Coupon SHOW100 applied! Saved ₹100');
    } else if (normalized == 'GOLD50') {
      setState(() {
        _appliedCoupon = 'GOLD50';
        _couponDiscount = 150.0;
        _couponController.text = 'GOLD50';
      });
      _showToast('Coupon GOLD50 applied! Saved ₹150');
    } else if (normalized == 'WEEKEND20') {
      final draft = ref.read(bookingDraftProvider);
      final discount = (draft.ticketSubtotal * 0.20).clamp(0.0, 200.0);
      setState(() {
        _appliedCoupon = 'WEEKEND20';
        _couponDiscount = discount;
        _couponController.text = 'WEEKEND20';
      });
      _showToast('Coupon WEEKEND20 applied! Saved ₹${discount.toInt()}');
    } else {
      _showToast('Invalid promo code. Try SHOW100 or GOLD50');
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon = null;
      _couponDiscount = 0.0;
      _couponController.clear();
    });
    _showToast('Coupon removed');
  }

  SavedPaymentMethod? _resolvePaymentMethod(List<SavedPaymentMethod> methods) {
    if (_selectedPaymentMethodId != null) {
      for (final method in methods) {
        if (method.id == _selectedPaymentMethodId) return method;
      }
    }
    for (final method in methods) {
      if (method.isDefault) return method;
    }
    if (methods.isEmpty) return null;
    return methods.first;
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showConvenienceFeeInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.border20),
          title: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.spotlightCoral),
              const SizedBox(width: 8),
              Text(
                'Convenience Fee Slabs',
                style: AppTypography.heading20().copyWith(fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Per-ticket convenience fee is mandated by cinema exhibition guidelines:',
                style: AppTypography.body14(color: AppColors.lavenderMuted),
              ),
              AppSpacing.vertical12,
              _buildSlabRow('Tickets up to ₹199', '₹20 / seat'),
              _buildSlabRow('Tickets ₹200 to ₹699', '₹30 / seat'),
              _buildSlabRow('Tickets ₹700 & above', '₹40 / seat'),
              AppSpacing.vertical8,
              Text(
                'GST of 18% is applied on the convenience fee as per tax regulations.',
                style: AppTypography.caption12(color: AppColors.lavenderMuted),
              ),
              AppSpacing.vertical8,
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.marqueeAmber.withValues(alpha: 0.12),
                  borderRadius: AppRadius.border12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 16, color: AppColors.marqueeAmber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ShowScape Gold members enjoy 100% waived fee & GST!',
                        style: AppTypography.caption12(color: AppColors.marqueeAmber).copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Got It',
                style: AppTypography.buttonLabel(color: AppColors.spotlightCoral),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSlabRow(String slab, String fee) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(slab, style: AppTypography.body14(color: AppColors.lavender)),
          Text(fee, style: AppTypography.body14(color: AppColors.spotlightCoral).copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Future<void> _handlePayment(BookingDraft draft, double finalTotal) async {
    if (!_agreedToTerms) {
      _showToast('Please accept the Terms & Conditions to proceed');
      return;
    }

    setState(() => _isProcessingPayment = true);
    final paymentService = ref.read(paymentServiceProvider);

    final methods = ref.read(savedPaymentMethodsProvider);
    final selectedMethod = _resolvePaymentMethod(methods);
    if (selectedMethod == null) {
      setState(() => _isProcessingPayment = false);
      _showToast('Add a payment method to continue');
      return;
    }

    final user = ref.read(currentUserProvider).asData?.value;
    final request = PaymentRequest(
      amount: finalTotal,
      orderId: draft.id,
      name: 'ShowScape Movies',
      description: '${draft.eventTitle ?? 'Movie Tickets'} (${draft.seatCount} seats)',
      prefillEmail: user?.email ?? 'guest@showscape.in',
      prefillPhone: user?.phone ?? '9876543210',
      notes: {
        'showId': draft.showId,
        'seats': draft.seatIds.join(','),
        'paymentMethod': selectedMethod.channelLabel,
        'paymentDetail': selectedMethod.detail,
      },
    );

    try {
      final result = await paymentService.openCheckout(request);

      if (!mounted) return;

      if (result.isSuccess) {
        // Confirm booking in repository
        final bookingRepo = ref.read(bookingRepositoryProvider);
        final confirmedBooking = await bookingRepo.confirmBooking(
          draft: draft,
          paymentId: result.paymentId ?? 'pay_success',
        );

        // If a dining reservation is linked (e.g. from Scout Date Night Plan),
        // link it to this confirmed booking so it appears in Tickets as a Night Out Itinerary
        if (draft.diningReservation != null) {
          ref.read(userReservationsProvider.notifier).addReservation(
            draft.diningReservation!.copyWith(
              id: 'res_${confirmedBooking.id}',
              userId: confirmedBooking.userId,
              specialRequests: 'BOOKING:${confirmedBooking.id};TYPE:NIGHT_OUT',
            ),
          );
        }

        // Refresh bookings so Tickets screen displays the new booking immediately
        ref.invalidate(allUserBookingsProvider);

        // Schedule 24h, 3h, 45m & Smart Leave-Now reminders
        try {
          final notifService = ref.read(notificationServiceProvider);
          final notifPrefs = ref.read(notificationPreferencesProvider);
          await notifService.scheduleBookingReminders(
            booking: confirmedBooking,
            preferences: notifPrefs,
          );
        } catch (e) {
          debugPrint('Error scheduling booking reminders: $e');
        }

        if (!mounted) return;
        setState(() => _isProcessingPayment = false);
        context.push(AppRoutes.paymentResult);
      } else {
        setState(() => _isProcessingPayment = false);
        // Show failure dialog with retry keeping hold timer
        _showPaymentFailureDialog(result.errorMessage ?? 'Payment cancelled or declined');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessingPayment = false);
      _showPaymentFailureDialog(e.toString());
    }
  }

  void _showPaymentFailureDialog(String error) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.border20),
          title: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Payment Incomplete',
                style: AppTypography.heading20().copyWith(fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                error,
                style: AppTypography.body14(color: AppColors.lavenderMuted),
              ),
              AppSpacing.vertical12,
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.border12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.marqueeAmber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your seats remain held for the next 8 minutes. You can retry safely.',
                        style: AppTypography.caption12(color: AppColors.marqueeAmber),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Retry Payment',
                style: AppTypography.buttonLabel(color: AppColors.spotlightCoral),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(bookingDraftProvider);
    final userAsync = ref.watch(currentUserProvider);
    final isGold = draft.isGold || (userAsync.value?.isGoldMember ?? false);
    final isDemoTuesday = ref.watch(isDemoTuesdayProvider);

    // Calculate live pricing through pure Dart PricingEngine
    final engineBreakdown = PricingEngine.calculate(
      seatPrices: draft.seatPrices,
      showDate: draft.showTime ?? DateTime.now(),
      isMovie: draft.isMovie,
      occupancyPct: draft.occupancyPct,
      isGold: isGold,
      fnbTotal: draft.fnbTotal,
      parkingCharge: draft.parkingCharge,
      forceTuesday: isDemoTuesday,
    );

    // Apply coupon discount to grand total
    final finalGrandTotal = (engineBreakdown.grandTotal - _couponDiscount).clamp(0.0, double.infinity);

    // Non-gold potential savings
    final normalBreakdown = PricingEngine.calculate(
      seatPrices: draft.seatPrices,
      showDate: draft.showTime ?? DateTime.now(),
      isMovie: draft.isMovie,
      occupancyPct: draft.occupancyPct,
      isGold: false,
      fnbTotal: draft.fnbTotal,
      parkingCharge: draft.parkingCharge,
      forceTuesday: isDemoTuesday,
    );
    final potentialGoldSavings = normalBreakdown.convenienceFee + normalBreakdown.gstOnFee;

    final showDateFormat = DateFormat('EEE, d MMM • hh:mm a');
    final formattedShowTime = draft.showTime != null
        ? showDateFormat.format(draft.showTime!)
        : 'Sat, 3 Oct • 07:30 PM';

    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.lavender),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: AppTypography.heading20().copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Event Summary Card
                _buildEventSummaryCard(draft, formattedShowTime),

                AppSpacing.vertical16,

                // 2. Gold Upsell Card (for non-gold) or Gold Active Badge (for gold)
                if (isGold)
                  _buildGoldActiveBanner()
                else if (potentialGoldSavings > 0)
                  _buildGoldUpsellCard(potentialGoldSavings),

                AppSpacing.vertical16,

                // 3. Editable Food Section
                _buildFoodSection(draft),

                AppSpacing.vertical16,

                // 4. Editable Parking Section
                _buildParkingSection(draft),

                AppSpacing.vertical16,

                // 5. Coupon Code Input & Suggested Coupons
                _buildCouponSection(),

                AppSpacing.vertical20,

                // 6. Expandable Price Breakdown (PricingEngine)
                _buildPriceBreakdownCard(
                  engineBreakdown: engineBreakdown,
                  isGold: isGold,
                  couponDiscount: _couponDiscount,
                  finalTotal: finalGrandTotal,
                ),

                AppSpacing.vertical16,

                PaymentMethodPicker(
                  selectedId: _resolvePaymentMethod(
                    ref.watch(savedPaymentMethodsProvider),
                  )?.id,
                  onSelected: (method) {
                    setState(() => _selectedPaymentMethodId = method.id);
                  },
                ),

                AppSpacing.vertical16,

                // 7. Terms & Conditions Checkbox
                _buildTermsCheckbox(),
              ],
            ),
          ),

          // 8. Sticky 'Pay ₹X' PriceSummaryBar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: PriceSummaryBar(
                totalAmount: finalGrandTotal,
                label: 'GRAND TOTAL',
                subtitle: '${draft.seatCount} Seats${draft.fnbTotalCount > 0 ? ' + ${draft.fnbTotalCount} Snacks' : ''}',
                buttonText: 'Pay ₹${finalGrandTotal.toInt()}',
                isLoading: _isProcessingPayment,
                isButtonEnabled: _agreedToTerms,
                onButtonPressed: () => _handlePayment(draft, finalGrandTotal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSummaryCard(BookingDraft draft, String formattedShowTime) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.border12,
            child: SizedBox(
              width: 76,
              height: 104,
              child: CachedNetworkImage(
                imageUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400',
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.surfaceElevated),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceElevated,
                  child: const Icon(Icons.movie_rounded, color: AppColors.lavenderMuted),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        draft.eventTitle ?? 'Dune: Part Two',
                        style: AppTypography.heading20().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'IMAX 2D',
                        style: AppTypography.caption12(color: AppColors.spotlightCoral).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.vertical4,
                Text(
                  draft.venueName ?? 'PVR INOX: Phoenix Palladium • Audi 3',
                  style: AppTypography.body14(color: AppColors.lavenderMuted).copyWith(
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.vertical4,
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.lavenderMuted),
                    const SizedBox(width: 4),
                    Text(
                      formattedShowTime,
                      style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                AppSpacing.vertical8,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Seats: ${draft.seatIds.isNotEmpty ? draft.seatIds.join(', ') : 'E-5, E-6'} (${draft.seatCount} tickets)',
                    style: AppTypography.caption12(color: AppColors.lavender).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldActiveBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.marqueeAmber.withValues(alpha: 0.12),
        borderRadius: AppRadius.border16,
        border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const GoldBadge(text: 'VIP GOLD'),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Convenience fee & GST are 100% waived on this booking!',
              style: AppTypography.caption12(color: AppColors.marqueeAmber).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoldUpsellCard(double savings) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceElevated,
            AppColors.surface,
          ],
        ),
        borderRadius: AppRadius.border16,
        border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save ₹${savings.toInt()} on this booking with Gold',
                  style: AppTypography.heading20().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.marqueeAmber,
                  ),
                ),
                Text(
                  'Zero convenience fees, free cancellation & VIP perks.',
                  style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(bookingDraftProvider.notifier).setDraft(
                    ref.read(bookingDraftProvider).copyWith(isGold: true),
                  );
              _showToast('Gold VIP preview activated! Fees waived.');
            },
            child: Text(
              'Unlock',
              style: AppTypography.buttonLabel(color: AppColors.marqueeAmber).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSection(BookingDraft draft) {
    final items = draft.fnbItems;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.fastfood_rounded, size: 18, color: AppColors.spotlightCoral),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Food & Beverages',
                        style: AppTypography.heading20().copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.push(AppRoutes.foodPath(draft.id)),
                child: Text(
                  items.isNotEmpty ? 'Edit' : '+ Add Snacks',
                  style: AppTypography.buttonLabel(color: AppColors.spotlightCoral).copyWith(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'No snacks added yet. Pre-order fresh popcorn & drinks.',
                style: AppTypography.caption12(color: AppColors.lavenderMuted),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Pickup: ${draft.pickupTiming == PickupTiming.beforeShow ? '🕒 Before show' : '🍿 At interval'}',
                style: AppTypography.caption12(color: AppColors.spotlightCoral).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    IndianDietBadge(isVeg: item.isVeg, size: 12),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.name} (${item.quantity}×)',
                        style: AppTypography.body14(color: AppColors.lavender),
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice.toInt()}',
                      style: AppTypography.body14(color: AppColors.lavender).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(bookingDraftProvider.notifier).removeFnbItem(item.id);
                      },
                      child: const Icon(Icons.close, size: 16, color: AppColors.lavenderMuted),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildParkingSection(BookingDraft draft) {
    final parking = draft.parking;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.local_parking_rounded, size: 18, color: AppColors.spotlightCoral),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Smart Parking',
                        style: AppTypography.heading20().copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => context.push(AppRoutes.parkingPath(draft.venueId ?? 'ven_001')),
                child: Text(
                  parking != null ? 'Change' : '+ Add Parking',
                  style: AppTypography.buttonLabel(color: AppColors.spotlightCoral).copyWith(
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (parking == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Reserved contactless parking slot at venue.',
                style: AppTypography.caption12(color: AppColors.lavenderMuted),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${parking.lot.name} (${parking.vehicleNumber})',
                      style: AppTypography.body14(color: AppColors.lavender).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Duration: ${parking.durationMinutes}m (~${(parking.durationMinutes / 60).toStringAsFixed(1)} hrs)',
                      style: AppTypography.caption12(color: AppColors.lavenderMuted),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '₹${parking.charge.toInt()}',
                      style: AppTypography.body14(color: AppColors.lavender).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(bookingDraftProvider.notifier).clearParking();
                      },
                      child: const Icon(Icons.close, size: 16, color: AppColors.lavenderMuted),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: const EdgeInsets.all(14),
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
              const Icon(Icons.local_offer_rounded, size: 18, color: AppColors.marqueeAmber),
              const SizedBox(width: 8),
              Text(
                'Promo Code & Offers',
                style: AppTypography.heading20().copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          AppSpacing.vertical12,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  style: AppTypography.body14(color: AppColors.lavender).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    hintStyle: AppTypography.body14(color: AppColors.lavenderMuted.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.border12,
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.border12,
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.border12,
                      borderSide: const BorderSide(color: AppColors.spotlightCoral),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  if (_appliedCoupon != null) {
                    _removeCoupon();
                  } else {
                    _applyCoupon(_couponController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _appliedCoupon != null ? AppColors.error : AppColors.spotlightCoral,
                  minimumSize: const Size(80, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.border12),
                ),
                child: Text(
                  _appliedCoupon != null ? 'Remove' : 'Apply',
                  style: AppTypography.buttonLabel(color: Colors.white).copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
          AppSpacing.vertical8,
          // Quick Coupon Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickCouponChip('SHOW100', 'Flat ₹100 OFF'),
                _buildQuickCouponChip('GOLD50', '50% OFF on VIP'),
                _buildQuickCouponChip('WEEKEND20', '20% Weekend Promo'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCouponChip(String code, String desc) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _applyCoupon(code),
        borderRadius: AppRadius.border12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.border12,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.discount_outlined, size: 12, color: AppColors.marqueeAmber),
              const SizedBox(width: 4),
              Text(
                '$code ($desc)',
                style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard({
    required PriceBreakdown engineBreakdown,
    required bool isGold,
    required double couponDiscount,
    required double finalTotal,
  }) {
    String? discountLabel;
    if (engineBreakdown.discountType == DiscountType.tuesday) {
      discountLabel = 'Tuesday 50% OFF';
    } else if (engineBreakdown.discountType == DiscountType.group) {
      discountLabel = 'Group 10% OFF';
    } else if (_appliedCoupon != null) {
      discountLabel = _appliedCoupon;
    }

    final totalDiscount = engineBreakdown.discountAmount + couponDiscount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: [
          // Header toggle
          InkWell(
            onTap: () => setState(() => _isBreakdownExpanded = !_isBreakdownExpanded),
            borderRadius: AppRadius.border20,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded, color: AppColors.spotlightCoral, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Price Breakdown',
                        style: AppTypography.heading20().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isBreakdownExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.lavenderMuted,
                  ),
                ],
              ),
            ),
          ),

          if (_isBreakdownExpanded) ...[
            const Divider(color: AppColors.surfaceBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 1. Tickets Subtotal
                  _buildPriceRow('Tickets', '₹${engineBreakdown.ticketSubtotal.toInt()}'),

                  // 2. Discount
                  if (totalDiscount > 0)
                    _buildPriceRow(
                      'Discount (${discountLabel ?? 'Promo'})',
                      '-₹${totalDiscount.toInt()}',
                      textColor: AppColors.success,
                    ),

                  // 3. Convenience fee with info tooltip
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Convenience Fee',
                                  style: AppTypography.body14(color: AppColors.lavenderMuted),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: _showConvenienceFeeInfo,
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: AppColors.lavenderMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isGold || engineBreakdown.feeWaived)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${PricingEngine.getSeatConvenienceFee(300.0).toInt() * (engineBreakdown.ticketSubtotal > 0 ? 2 : 0)}',
                                style: AppTypography.body14(color: AppColors.lavenderMuted).copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Waived with Gold',
                                style: AppTypography.caption12(color: AppColors.marqueeAmber).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const GoldBadge(fontSize: 8, padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2)),
                            ],
                          )
                        else
                          Text(
                            '₹${engineBreakdown.convenienceFee.toInt()}',
                            style: AppTypography.body14(color: AppColors.lavender).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 4. GST on fee (18%)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'GST on Convenience Fee (18%)',
                            style: AppTypography.body14(color: AppColors.lavenderMuted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isGold || engineBreakdown.feeWaived)
                          Text(
                            '₹0 (Waived)',
                            style: AppTypography.body14(color: AppColors.marqueeAmber).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          )
                        else
                          Text(
                            '₹${engineBreakdown.gstOnFee.toInt()}',
                            style: AppTypography.body14(color: AppColors.lavender).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 5. Food & beverages
                  if (engineBreakdown.fnbTotal > 0)
                    _buildPriceRow('Food & Beverages', '₹${engineBreakdown.fnbTotal.toInt()}'),

                  // 6. Parking
                  if (engineBreakdown.parking > 0)
                    _buildPriceRow('Reserved Parking', '₹${engineBreakdown.parking.toInt()}'),

                  const Divider(color: AppColors.surfaceBorder, height: 20),

                  // 7. Total Payable
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: AppTypography.heading20().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '₹${finalTotal.toInt()}',
                        style: AppTypography.heading24(color: AppColors.spotlightCoral),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body14(color: AppColors.lavenderMuted),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTypography.body14(color: textColor ?? AppColors.lavender).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      borderRadius: AppRadius.border12,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreedToTerms,
              activeColor: AppColors.spotlightCoral,
              onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'I agree to the Terms & Conditions and Cancellation Policy. Tickets once booked cannot be exchanged, but can be transferred or cancelled up to 2 hours before showtime.',
                  style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
