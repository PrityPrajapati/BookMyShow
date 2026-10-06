import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/widgets.dart';

/// Interactive Design System Preview Page
class DesignPreviewScreen extends StatefulWidget {
  const DesignPreviewScreen({super.key, this.onToggleTheme, this.isDarkMode = true});

  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  @override
  State<DesignPreviewScreen> createState() => _DesignPreviewScreenState();
}

class _DesignPreviewScreenState extends State<DesignPreviewScreen> {
  bool _isLoadingButtons = false;
  String _selectedGenre = 'Action';
  final Set<String> _selectedFilters = {'Dolby Atmos', 'ShowScape Gold'};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Design System Preview', style: AppTypography.heading20()),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppColors.marqueeAmber,
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
          AppSpacing.horizontal8,
        ],
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          _buildTypographySection(isDark),
          AppSpacing.vertical24,
          _buildColorPaletteSection(),
          AppSpacing.vertical24,
          _buildButtonsSection(),
          AppSpacing.vertical24,
          _buildChipsSection(),
          AppSpacing.vertical24,
          _buildPriceAndBadgesSection(),
          AppSpacing.vertical24,
          _buildSectionHeaders(),
          AppSpacing.vertical24,
          _buildTicketStubSection(),
          AppSpacing.vertical24,
          _buildShimmerSection(),
          AppSpacing.vertical24,
          _buildStatesSection(),
          AppSpacing.vertical48,
        ],
      ),
    );
  }

  Widget _buildTypographySection(bool isDark) {
    final text = isDark ? AppColors.lavender : AppColors.textPrimaryLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '1. Typography Scale'),
        Text('Heading 32 - Poppins Bold', style: AppTypography.heading32(color: text)),
        AppSpacing.vertical8,
        Text('Heading 24 - Poppins SemiBold', style: AppTypography.heading24(color: text)),
        AppSpacing.vertical8,
        Text('Heading 20 - Poppins SemiBold', style: AppTypography.heading20(color: text)),
        AppSpacing.vertical8,
        Text('Body 16 - Inter Regular (Tickets, synopsis, details)', style: AppTypography.body16(color: text)),
        AppSpacing.vertical4,
        Text('Body 14 - Inter Regular Muted (Timings, locations)', style: AppTypography.body14()),
        AppSpacing.vertical4,
        Text('Caption 12 - Inter Regular (Metadata, tags, disclaimers)', style: AppTypography.caption12()),
      ],
    );
  }

  Widget _buildColorPaletteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '2. Brand Color Tokens'),
        AppSpacing.vertical8,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _colorChip('Midnight #140F2B', AppColors.midnight, border: true),
            _colorChip('Surface #1E1740', AppColors.surface),
            _colorChip('Coral #FF4D6D', AppColors.spotlightCoral),
            _colorChip('Amber #FFB547', AppColors.marqueeAmber, textColor: AppColors.midnight),
            _colorChip('Lavender #EEEAFB', AppColors.lavender, textColor: AppColors.midnight),
            _colorChip('Success #22C55E', AppColors.success),
            _colorChip('Warning #F59E0B', AppColors.warning),
            _colorChip('Error #EF4444', AppColors.error),
          ],
        ),
      ],
    );
  }

  Widget _colorChip(String label, Color color, {bool border = false, Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.border12,
        border: border ? Border.all(color: Colors.white24) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '3. Buttons & Interactive States',
          actionLabel: _isLoadingButtons ? 'Stop Loading' : 'Simulate Loading',
          onActionPressed: () => setState(() => _isLoadingButtons = !_isLoadingButtons),
        ),
        AppSpacing.vertical12,
        PrimaryButton(
          text: 'Book Tickets Now',
          icon: const Icon(Icons.confirmation_num_rounded, size: 20, color: Colors.white),
          isLoading: _isLoadingButtons,
          onPressed: () {},
        ),
        AppSpacing.vertical12,
        SecondaryButton(
          text: 'Explore Experiences & Dining',
          icon: const Icon(Icons.explore_rounded, size: 20),
          isLoading: _isLoadingButtons,
          onPressed: () {},
        ),
        AppSpacing.vertical12,
        const Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Disabled',
                onPressed: null,
                height: 48,
              ),
            ),
            AppSpacing.horizontal12,
            Expanded(
              child: SecondaryButton(
                text: 'Disabled',
                onPressed: null,
                height: 48,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChipsSection() {
    final genres = ['Action', 'Sci-Fi', 'IMAX 3D', 'Dolby Atmos', 'ShowScape Gold'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '4. App Chips'),
        AppSpacing.vertical8,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres.map((genre) {
            final isGold = genre == 'ShowScape Gold';
            final isSelected = genre == _selectedGenre || _selectedFilters.contains(genre);
            return AppChip(
              label: genre,
              isSelected: isSelected,
              activeColor: isGold ? AppColors.marqueeAmber : AppColors.spotlightCoral,
              icon: isGold ? const Icon(Icons.workspace_premium_rounded) : null,
              badgeText: isGold ? '48H VIP' : null,
              onSelected: (selected) {
                setState(() {
                  _selectedGenre = genre;
                  if (selected) {
                    _selectedFilters.add(genre);
                  } else {
                    _selectedFilters.remove(genre);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceAndBadgesSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: '5. Price Tag (en_IN) & Gold Badge'),
        AppSpacing.vertical8,
        Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PriceTag(amount: 299, fontSize: 24),
            PriceTag(amount: 449, originalAmount: 799, fontSize: 24),
            PriceTag(amount: 14999, originalAmount: 19999, fontSize: 20),
            GoldBadge(),
            GoldBadge(text: 'GOLD PRESALE', fontSize: 12),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeaders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '6. Section Headers'),
        SectionHeader(
          title: 'Trending in Mumbai',
          subtitle: 'Top rated movies & live events nearby',
          onActionPressed: () {},
        ),
      ],
    );
  }

  Widget _buildTicketStubSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '7. Ticket Stub Card (Clipper)'),
        AppSpacing.vertical12,
        TicketStubCard(
          topChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GoldBadge(text: 'GOLD EARLY ACCESS'),
                  PriceTag(amount: 450, fontSize: 20),
                ],
              ),
              AppSpacing.vertical12,
              Text('Dune: Part Two - IMAX Experience', style: AppTypography.heading20()),
              AppSpacing.vertical4,
              Text('PVR ICON: Phoenix Palladium, Lower Parel', style: AppTypography.body14()),
              AppSpacing.vertical8,
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.spotlightCoral),
                  AppSpacing.horizontal4,
                  Text('Tomorrow, 07:30 PM', style: AppTypography.caption12(color: AppColors.spotlightCoral)),
                  AppSpacing.horizontal16,
                  const Icon(Icons.event_seat_rounded, size: 14, color: AppColors.marqueeAmber),
                  AppSpacing.horizontal4,
                  Text('Prime Recliner: F12, F13', style: AppTypography.caption12(color: AppColors.marqueeAmber)),
                ],
              ),
            ],
          ),
          bottomChild: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SCAN AT ENTRANCE', style: AppTypography.caption12()),
                  AppSpacing.vertical4,
                  Text('TICKET ID: #SC-98234-IN', style: AppTypography.body14()),
                ],
              ),
              const Icon(Icons.qr_code_2_rounded, size: 48, color: AppColors.lavender),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: '8. ShimmerBox Skeletons'),
        AppSpacing.vertical12,
        Row(
          children: [
            ShimmerBox(width: 80, height: 100),
            AppSpacing.horizontal12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 18, width: 180),
                  AppSpacing.vertical8,
                  ShimmerBox(height: 14, width: 120),
                  AppSpacing.vertical12,
                  Row(
                    children: [
                      ShimmerBox(width: 60, height: 28),
                      AppSpacing.horizontal8,
                      ShimmerBox(width: 60, height: 28),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '9. Empty & Error States'),
        AppSpacing.vertical12,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: AppRadius.border20,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: EmptyState(
            title: 'No Upcoming Bookings',
            message: 'Discover the latest blockbusters and nightlife events in your city.',
            actionLabel: 'Explore Events',
            onActionPressed: () {},
          ),
        ),
        AppSpacing.vertical16,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: AppRadius.border20,
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: ErrorState(
            message: 'Unable to fetch real-time seat availability. Please check your connection.',
            onRetry: () {},
          ),
        ),
      ],
    );
  }
}
