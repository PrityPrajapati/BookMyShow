import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/widgets/gold_badge.dart';
import 'package:showscape/features/auth/domain/models/app_user.dart';
import 'package:showscape/features/payment/domain/models/payment_request.dart';
import 'package:showscape/features/payment/presentation/providers/payment_provider.dart';
import 'package:showscape/features/tickets/presentation/providers/ticket_providers.dart';

/// Provider calculating total savings accumulated through Gold membership
final userGoldSavingsProvider = Provider<double>((ref) {
  final bookingsAsync = ref.watch(allUserBookingsProvider);
  return bookingsAsync.maybeWhen(
    data: (bookings) {
      double total = 0.0;
      for (final b in bookings) {
        total += (b.priceBreakdown.convenienceFee + b.priceBreakdown.gst);
        total += b.priceBreakdown.discount;
      }
      return total > 0 ? total : 1340.0;
    },
    orElse: () => 1340.0,
  );
});

/// Premium Amber-on-Midnight ShowScape Gold Membership Screen (/gold)
class GoldScreen extends ConsumerStatefulWidget {
  const GoldScreen({super.key});

  @override
  ConsumerState<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends ConsumerState<GoldScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinOrRenewGold(BuildContext context, AppUser? user) async {
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    final paymentService = ref.read(paymentServiceProvider);
    final orderId = 'gold_sub_${DateTime.now().millisecondsSinceEpoch}';

    final request = PaymentRequest(
      amount: 999.0,
      orderId: orderId,
      name: 'ShowScape Gold VIP',
      description: '1-Year Annual ShowScape Gold Membership',
      prefillEmail: user?.email ?? 'alex.rivera@showscape.io',
      prefillPhone: user?.phone ?? '+91 98765 43210',
      notes: {'membership_type': 'annual_gold', 'user_id': user?.id ?? 'usr_001'},
    );

    try {
      final result = await paymentService.openCheckout(request);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (result.isSuccess) {
        // Update user state with Gold membership
        final updatedExpiry = DateTime.now().add(const Duration(days: 365));
        final currentUser = user ??
            const AppUser(
              id: 'usr_001',
              name: 'Alex Rivera',
              email: 'alex.rivera@showscape.io',
              phone: '+91 98765 43210',
            );

        final updatedUser = currentUser.copyWith(
          isGoldMember: true,
          goldExpiry: updatedExpiry,
        );

        final userRepo = ref.read(userRepositoryProvider);
        await userRepo.updateProfile(updatedUser);
        ref.invalidate(currentUserProvider);

        if (!mounted) return;
        _showSuccessCelebration(context, updatedExpiry);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Payment cancelled or failed. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initiating payment: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessCelebration(BuildContext context, DateTime expiry) {
    HapticFeedback.heavyImpact();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141622),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.border20,
          side: const BorderSide(color: AppColors.marqueeAmber, width: 1.5),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.marqueeAmber.withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded, size: 40, color: AppColors.midnight),
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Gold VIP!',
              style: TextStyle(
                color: AppColors.marqueeAmber,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your ShowScape Gold membership is now active. Enjoy zero convenience fees, 48h early presale access, and VIP perks across all bookings.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: AppRadius.border12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.marqueeAmber),
                  const SizedBox(width: 8),
                  Text(
                    'Valid until ${DateFormat('d MMMM yyyy').format(expiry)}',
                    style: const TextStyle(color: AppColors.marqueeAmber, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.marqueeAmber,
                foregroundColor: AppColors.midnight,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Start Exploring', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    final totalSavings = ref.watch(userGoldSavingsProvider);

    final isGold = user?.isGoldMember ?? false;
    final goldExpiry = user?.goldExpiry;

    // Check if renewal is due within 7 days
    final now = DateTime.now();
    final isRenewalDue = isGold &&
        goldExpiry != null &&
        goldExpiry.isAfter(now) &&
        goldExpiry.difference(now).inDays <= 7;
    final daysUntilExpiry = isRenewalDue ? goldExpiry.difference(now).inDays : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF090A0F), // Midnight dark
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: AppColors.marqueeAmber, size: 20),
            SizedBox(width: 8),
            Text(
              'ShowScape Gold',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GoldBadge(text: 'VIP'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 7-Day Renewal Reminder Banner
            if (isRenewalDue)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8D6E14).withValues(alpha: 0.35),
                      const Color(0xFF4A3403).withValues(alpha: 0.25),
                    ],
                  ),
                  borderRadius: AppRadius.border16,
                  border: Border.all(color: AppColors.marqueeAmber, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.marqueeAmber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.alarm_rounded, color: AppColors.midnight, size: 18),
                    ),
                    AppSpacing.horizontal12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Renewal Reminder: $daysUntilExpiry Days Left',
                            style: const TextStyle(
                              color: AppColors.marqueeAmber,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Renew now to maintain zero fees & early access perks without interruption.',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.marqueeAmber,
                        foregroundColor: AppColors.midnight,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                      ),
                      onPressed: () => _handleJoinOrRenewGold(context, user),
                      child: const Text('Renew', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // 2. Shimmering Gold VIP Card
            _buildShimmeringGoldCard(user, isGold, goldExpiry),

            const SizedBox(height: 20),

            // 3. Savings Tracker Widget
            _buildSavingsTracker(totalSavings, isGold),

            const SizedBox(height: 24),

            // 4. Gold Benefits List
            const Text(
              'EXCLUSIVE GOLD PRIVILEGES',
              style: TextStyle(
                color: AppColors.marqueeAmber,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            _buildBenefitsList(),

            const SizedBox(height: 24),

            // 5. Comparison or Guarantee Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF13151F),
                borderRadius: AppRadius.border16,
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: AppColors.success, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Satisfaction Guarantee',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Save more than ₹999 on booking convenience fees in your first 5 bookings or contact support.',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Bottom Join / Renew Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: const Color(0xFF10121A),
          border: const Border(top: BorderSide(color: Colors.white12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '₹999',
                      style: TextStyle(
                        color: AppColors.marqueeAmber,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/ year',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹1,999',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Includes all VIP privileges',
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.marqueeAmber,
                foregroundColor: AppColors.midnight,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                elevation: 4,
                shadowColor: AppColors.marqueeAmber.withValues(alpha: 0.5),
              ),
              onPressed: _isProcessing ? null : () => _handleJoinOrRenewGold(context, user),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.midnight),
                      ),
                    )
                  : Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          isGold ? 'Renew Gold' : 'Join Gold',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
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
  // Shimmering Gold Card
  // ===========================================================================

  Widget _buildShimmeringGoldCard(AppUser? user, bool isGold, DateTime? goldExpiry) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppRadius.border20,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C1E0A),
            Color(0xFF1B1405),
            Color(0xFF38270F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.marqueeAmber.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.8), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.border20,
        child: Stack(
          children: [
            // Shimmer overlay
            Positioned.fill(
              child: Shimmer(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    AppColors.marqueeAmber.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.35, 0.5, 0.65],
                ),
                child: Container(color: Colors.white),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: Brand & Status Chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              gradient: AppColors.goldGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome, size: 14, color: AppColors.midnight),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SHOWSCAPE GOLD',
                            style: TextStyle(
                              color: AppColors.marqueeAmber,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isGold
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.marqueeAmber.withValues(alpha: 0.15),
                          borderRadius: AppRadius.pill,
                          border: Border.all(
                            color: isGold ? AppColors.success : AppColors.marqueeAmber,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isGold ? 'ACTIVE VIP' : 'EXCLUSIVE PASS',
                          style: TextStyle(
                            color: isGold ? AppColors.success : AppColors.marqueeAmber,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Middle Card Chip & Number
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE5C07B), Color(0xFFD19A66)],
                          ),
                        ),
                        child: const Icon(Icons.nfc_rounded, size: 18, color: Colors.black54),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '•••• •••• •••• 8823',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 16,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  // Bottom row: Member Name & Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MEMBER NAME',
                            style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.name ?? 'Alex Rivera',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'VALID THRU',
                            style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goldExpiry != null
                                ? DateFormat('MM/yy').format(goldExpiry)
                                : '1 YEAR',
                            style: const TextStyle(
                              color: AppColors.marqueeAmber,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
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
  // Savings Tracker
  // ===========================================================================

  Widget _buildSavingsTracker(double totalSavings, bool isGold) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF13151F),
        borderRadius: AppRadius.border20,
        border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.savings_rounded, color: AppColors.success, size: 20),
              ),
              AppSpacing.horizontal12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR SAVINGS TRACKER',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You’ve saved ₹${totalSavings.toInt()} this year',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${((totalSavings / 999.0) * 100).toInt()}% ROI',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSavingsStat('Convenience Fees', '₹${(totalSavings * 0.7).toInt()}', '100% Waived'),
              _buildSavingsStat('Presale Deals', '₹${(totalSavings * 0.3).toInt()}', 'Exclusive early rates'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsStat(String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: AppColors.marqueeAmber, fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 1),
        Text(sub, style: const TextStyle(color: Colors.white30, fontSize: 10)),
      ],
    );
  }

  // ===========================================================================
  // Benefits List
  // ===========================================================================

  Widget _buildBenefitsList() {
    final benefits = [
      (
        icon: Icons.money_off_rounded,
        title: 'Zero Convenience Fee',
        desc: 'Save ₹40–₹80 per ticket on every movie, concert, and event booking unlimited times.',
      ),
      (
        icon: Icons.lock_open_rounded,
        title: '48-Hour Early Access to Presales',
        desc: 'Book coveted blockbuster shows, IMAX screenings & music tours 2 days before public release.',
      ),
      (
        icon: Icons.workspace_premium_rounded,
        title: 'Exclusive Gold VIP Badge',
        desc: 'Display an illustrious glowing Gold VIP badge across your profile avatar, ticket stubs, and checkout.',
      ),
      (
        icon: Icons.support_agent_rounded,
        title: 'Priority 24/7 VIP Support',
        desc: 'Dedicated concierge desk with instant chat & phone resolution without waiting in queues.',
      ),
      (
        icon: Icons.free_cancellation_rounded,
        title: 'Free Seat Cancellation',
        desc: '100% refund up to 2 hours prior to showtime credited instantly as ShowScape Credits.',
      ),
      (
        icon: Icons.restaurant_rounded,
        title: 'VIP Lounge & Dining Treats',
        desc: 'Complimentary welcome desserts & 20% off at ShowScape partner dining lounges.',
      ),
    ];

    return Column(
      children: benefits.map((b) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF13151F),
            borderRadius: AppRadius.border16,
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.marqueeAmber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(b.icon, color: AppColors.marqueeAmber, size: 18),
              ),
              AppSpacing.horizontal12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      b.desc,
                      style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
