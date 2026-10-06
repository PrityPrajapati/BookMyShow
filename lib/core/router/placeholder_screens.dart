export 'package:showscape/features/home/presentation/screens/home_screen.dart';
export 'package:showscape/features/explore/presentation/screens/explore_screen.dart';
export 'package:showscape/features/event_detail/presentation/screens/event_detail_screen.dart';
export 'package:showscape/features/showtimes/presentation/screens/showtimes_screen.dart';
export 'package:showscape/features/seats/presentation/screens/seats_screen.dart';
export 'package:showscape/features/food/presentation/screens/food_screen.dart';
export 'package:showscape/features/parking/presentation/screens/parking_screen.dart';
export 'package:showscape/features/checkout/presentation/screens/checkout_screen.dart';
export 'package:showscape/features/payment/presentation/screens/payment_result_screen.dart';
export 'package:showscape/features/auth/presentation/screens/onboarding_screen.dart';
export 'package:showscape/features/auth/presentation/screens/login_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/router/auth_state.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/gold_badge.dart';
import 'package:showscape/core/widgets/primary_button.dart';
import 'package:showscape/core/widgets/secondary_button.dart';

/// Reusable Base Screen Wrapper for Cinematic Route Placeholders
class _RouteScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final List<Widget> children;

  const _RouteScaffold({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppColors.spotlightCoral,
    this.trailing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.pop(),
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            AppSpacing.horizontal12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading20().copyWith(
                      color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption12().copyWith(
                      color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: trailing != null ? [trailing!, AppSpacing.horizontal8] : null,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: children,
        ),
      ),
    );
  }
}

/// Glassmorphic Card for Route Parameter Inspection & Details
class _ParamCard extends StatelessWidget {
  final Map<String, String> params;

  const _ParamCard({required this.params});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.border20,
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code_rounded, size: 18, color: AppColors.marqueeAmber),
              AppSpacing.horizontal8,
              Text(
                'Route Parameters & State',
                style: AppTypography.body14(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.vertical12,
          ...params.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.spotlightCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.key,
                        style: AppTypography.caption12(
                          color: AppColors.spotlightCoral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AppSpacing.horizontal8,
                    Expanded(
                      child: Text(
                        entry.value,
                        style: AppTypography.caption12(
                          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 1. MAIN NAVIGATION TABS
// -------------------------------------------------------------

/// Scout AI Screen Tab (Center Tab)
class ScoutScreen extends StatelessWidget {
  const ScoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      title: 'ShowScape Scout AI',
      subtitle: 'Your Personal Concierge & Event Scout',
      icon: Icons.auto_awesome_rounded,
      iconColor: const Color(0xFF9D4EDD),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF281647), Color(0xFF19102E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.border20,
            border: Border.all(color: const Color(0xFF9D4EDD).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.psychology_rounded, color: Color(0xFFC084FC), size: 22),
                  SizedBox(width: 8),
                  Text('AI Suggestions for You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              AppSpacing.vertical8,
              Text(
                'Scout analyzes your favorite genres, movie taste, and weekend vibe to plan your perfect night out.',
                style: AppTypography.body14(color: AppColors.lavenderMuted),
              ),
            ],
          ),
        ),
        AppSpacing.vertical16,
        PrimaryButton(
          text: 'Plan a Movie Date Night (/event/evt_dune_2)',
          icon: const Icon(Icons.favorite_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.eventPath('evt_dune_2')),
        ),
        AppSpacing.vertical12,
        SecondaryButton(
          text: 'Find Rooftop Dining Nearby (/dining/dine_aer_rooftop)',
          icon: const Icon(Icons.nightlife_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.diningDetailPath('dine_aer_rooftop')),
        ),
      ],
    );
  }
}

/// Tickets Screen Tab
class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      title: 'My Tickets',
      subtitle: 'Digital Wallet & Smart Passes',
      icon: Icons.confirmation_number_rounded,
      children: [
        PrimaryButton(
          text: 'View Dune 2 Ticket (/ticket/TICK-98234-IN)',
          icon: const Icon(Icons.qr_code_2_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.ticketPath('TICK-98234-IN')),
        ),
        AppSpacing.vertical12,
        SecondaryButton(
          text: 'Transfer Dune 2 Ticket (/transfer/TICK-98234-IN)',
          icon: const Icon(Icons.send_to_mobile_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.transferPath('TICK-98234-IN')),
        ),
      ],
    );
  }
}

/// Profile Screen Tab
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return _RouteScaffold(
      title: 'Profile',
      subtitle: 'Account & VIP Privileges',
      icon: Icons.person_rounded,
      children: [
        _ParamCard(
          params: {
            'Status': auth.isAuthenticated ? 'Logged In' : 'Logged Out',
            'User ID': auth.state.userId ?? 'None',
            'Email': auth.state.email ?? 'None',
          },
        ),
        PrimaryButton(
          text: 'ShowScape Gold VIP Hub (/gold)',
          icon: const Icon(Icons.workspace_premium_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.gold),
        ),
        AppSpacing.vertical12,
        SecondaryButton(
          text: auth.isAuthenticated ? 'Sign Out (Test Redirect Guard)' : 'Sign In',
          icon: Icon(
            auth.isAuthenticated ? Icons.logout_rounded : Icons.login_rounded,
            size: 20,
            color: auth.isAuthenticated ? AppColors.error : AppColors.success,
          ),
          onPressed: () => ref.read(authNotifierProvider).toggleAuth(),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// 2. EVENT & BOOKING FLOW SCREENS
// -------------------------------------------------------------


// ShowtimesScreen and SeatsScreen are now fully implemented and exported from:
// - package:showscape/features/showtimes/presentation/screens/showtimes_screen.dart
// - package:showscape/features/seats/presentation/screens/seats_screen.dart

// FoodScreen and ParkingScreen are now fully implemented and exported above.

// CheckoutScreen and PaymentResultScreen are now fully implemented and exported above.

/// Ticket Detail Screen (`/ticket/:id`)
class TicketDetailScreen extends StatelessWidget {
  final String id;

  const TicketDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      title: 'Digital Ticket Pass',
      subtitle: 'Scan at Entrance or Share with Friends',
      icon: Icons.qr_code_2_rounded,
      children: [
        _ParamCard(params: {
          'Ticket ID (path)': id,
          'Deep Link Target': 'showscape://ticket/$id',
        }),
        PrimaryButton(
          text: 'Transfer Ticket to a Friend (/transfer/$id)',
          icon: const Icon(Icons.send_to_mobile_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.transferPath(id)),
        ),
        AppSpacing.vertical12,
        SecondaryButton(
          text: 'Venue Direction & Indoor Map (/venue-map/venue_pvr_palladium)',
          icon: const Icon(Icons.navigation_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.venueMapPath('venue_pvr_palladium')),
        ),
      ],
    );
  }
}

/// Transfer Ticket Screen (`/transfer/:ticketId`)
class TransferTicketScreen extends StatelessWidget {
  final String ticketId;

  const TransferTicketScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      title: 'Transfer Ticket',
      subtitle: 'Peer-to-Peer Secure Ticket Transfer',
      icon: Icons.send_to_mobile_rounded,
      children: [
        _ParamCard(params: {'Ticket ID (path)': ticketId}),
        PrimaryButton(
          text: 'Complete Transfer & Notify Recipient',
          icon: const Icon(Icons.check_circle_rounded, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket transfer initiated successfully!')),
            );
            context.pop();
          },
        ),
      ],
    );
  }
}

/// Venue Map Screen (`/venue-map/:venueId`)
class VenueMapScreen extends StatelessWidget {
  final String venueId;

  const VenueMapScreen({super.key, required this.venueId});

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      title: 'Venue Map',
      subtitle: 'Interactive Gates, Food Stalls, & Restrooms',
      icon: Icons.map_rounded,
      children: [
        _ParamCard(params: {'Venue ID (path)': venueId}),
        SecondaryButton(
          text: 'Reserve Parking at Venue (/parking/$venueId)',
          icon: const Icon(Icons.local_parking_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.parkingPath(venueId)),
        ),
      ],
    );
  }
}

/// Dining Screen (`/dining`)
class DiningScreen extends StatelessWidget {
  const DiningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      title: 'ShowScape Dining',
      subtitle: 'Lounge Tables & Curated Menus',
      icon: Icons.restaurant_rounded,
      children: [
        PrimaryButton(
          text: 'AER Rooftop Bar & Lounge (/dining/dine_aer_rooftop)',
          icon: const Icon(Icons.wine_bar_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.diningDetailPath('dine_aer_rooftop')),
        ),
        AppSpacing.vertical12,
        SecondaryButton(
          text: 'Bastian Bandra Experience (/dining/dine_bastian)',
          icon: const Icon(Icons.local_dining_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.diningDetailPath('dine_bastian')),
        ),
      ],
    );
  }
}

/// Dining Detail Screen (`/dining/:id`)
class DiningDetailScreen extends StatelessWidget {
  final String id;

  const DiningDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      title: 'Dining Experience',
      subtitle: 'Table Reservation & Pre-orders',
      icon: Icons.restaurant_menu_rounded,
      children: [
        _ParamCard(params: {'Dining ID (path)': id}),
        PrimaryButton(
          text: 'Reserve VIP Table with ShowScape Gold',
          icon: const Icon(Icons.star_rounded, size: 20),
          onPressed: () => context.push(AppRoutes.gold),
        ),
      ],
    );
  }
}

/// ShowScape Gold Membership Screen (`/gold`)
class GoldScreen extends StatelessWidget {
  const GoldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _RouteScaffold(
      title: 'ShowScape Gold',
      subtitle: 'VIP Lounge Passes, 0 Convenience Fee, Free Cancellation',
      icon: Icons.workspace_premium_rounded,
      iconColor: AppColors.marqueeAmber,
      trailing: const GoldBadge(text: 'VIP'),
      children: [
        const GoldBadge(text: 'SHOWSCAPE GOLD EXCLUSIVE', fontSize: 13),
        AppSpacing.vertical16,
        PrimaryButton(
          text: 'Join ShowScape Gold (₹1,499/year)',
          icon: const Icon(Icons.card_membership_rounded, size: 20),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Welcome to ShowScape Gold VIP!')),
            );
          },
        ),
      ],
    );
  }
}
