import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

class TicketCategoryItem {
  final String name;
  final double price;
  final String status;
  final Color statusColor;
  final String description;

  const TicketCategoryItem({
    required this.name,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.description,
  });
}

/// For Sports, Concerts, and Comedy: Shows venue details, event date/time, and ticket category tiers
class LiveEventInfoSection extends StatefulWidget {
  final Event event;
  final String? venueName;
  final String? venueAddress;

  const LiveEventInfoSection({
    super.key,
    required this.event,
    this.venueName,
    this.venueAddress,
  });

  @override
  State<LiveEventInfoSection> createState() => _LiveEventInfoSectionState();
}

class _LiveEventInfoSectionState extends State<LiveEventInfoSection> {
  int _selectedCategoryIndex = 0;

  List<TicketCategoryItem> _getCategories() {
    if (widget.event.type == EventType.sports) {
      return const [
        TicketCategoryItem(
          name: 'East Stand Tier 2',
          price: 950.0,
          status: 'Available',
          statusColor: AppColors.success,
          description: 'Elevated panoramic boundary view with open air seating',
        ),
        TicketCategoryItem(
          name: 'North Stand Lower',
          price: 2500.0,
          status: 'Filling Fast',
          statusColor: AppColors.warning,
          description: 'Close to boundary line & player dugout tunnel',
        ),
        TicketCategoryItem(
          name: 'Garware Pavilion Club',
          price: 5500.0,
          status: 'Few Left',
          statusColor: AppColors.spotlightCoral,
          description: 'Cushioned stadium seats with air-conditioned lounge access',
        ),
        TicketCategoryItem(
          name: 'Corporate Corporate Box',
          price: 15000.0,
          status: 'VIP Reserved',
          statusColor: AppColors.marqueeAmber,
          description: 'Private 15-seater hospitality suite with unlimited gourmet dining',
        ),
      ];
    } else if (widget.event.type == EventType.comedy) {
      return const [
        TicketCategoryItem(
          name: 'Silver Seating',
          price: 499.0,
          status: 'Available',
          statusColor: AppColors.success,
          description: 'General admission seating on first-come basis',
        ),
        TicketCategoryItem(
          name: 'Gold Preferred',
          price: 899.0,
          status: 'Filling Fast',
          statusColor: AppColors.warning,
          description: 'Front 6 rows guaranteed with priority entry',
        ),
        TicketCategoryItem(
          name: 'VIP Front Row + Meet',
          price: 1899.0,
          status: 'Few Left',
          statusColor: AppColors.spotlightCoral,
          description: 'Front row center seats + post-show artist meet & greet pass',
        ),
      ];
    }

    // Default Concert Categories
    return const [
      TicketCategoryItem(
        name: 'General Admission / Silver',
        price: 1500.0,
        status: 'Available',
        statusColor: AppColors.success,
        description: 'Open stadium pitch standing with 360-degree audio',
      ),
      TicketCategoryItem(
        name: 'Gold Standing Phase 2',
        price: 3500.0,
        status: 'Selling Fast',
        statusColor: AppColors.warning,
        description: 'Front pitch standing zone with dedicated entry lane & bars',
      ),
      TicketCategoryItem(
        name: 'Fan Pit / Infinity Zone',
        price: 7500.0,
        status: 'Few Left',
        statusColor: AppColors.spotlightCoral,
        description: 'Directly in front of runway stage with exclusive LED wristband',
      ),
      TicketCategoryItem(
        name: 'Lounge & Hospitality VIP',
        price: 14500.0,
        status: 'Limited',
        statusColor: AppColors.marqueeAmber,
        description: 'Elevated VIP deck, free flow gourmet buffet, and parking valet',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _getCategories();

    final eventDate = widget.event.releaseDate ?? DateTime(2026, 10, 18, 18, 0);
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(eventDate);
    final timeStr = DateFormat('h:mm a').format(eventDate);

    final resolvedVenue = widget.venueName ??
        (widget.event.type == EventType.sports
            ? 'Wankhede Stadium, Mumbai'
            : (widget.event.type == EventType.comedy
                ? 'The Habitat: Khar West, Mumbai'
                : 'DY Patil Stadium, Navi Mumbai'));

    final resolvedAddress = widget.venueAddress ??
        'Sector 7, Nerul, Navi Mumbai, Maharashtra 400706';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date & Time Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              borderRadius: AppRadius.border16,
              border: Border.all(
                color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                    borderRadius: AppRadius.border12,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    size: 22,
                    color: AppColors.spotlightCoral,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: AppTypography.body14(
                          color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Doors open at $timeStr • Gates close 30m before show',
                        style: AppTypography.caption12(
                          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. Venue Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.lightSurface,
              borderRadius: AppRadius.border16,
              border: Border.all(
                color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.marqueeAmber.withValues(alpha: 0.15),
                    borderRadius: AppRadius.border12,
                  ),
                  child: const Icon(
                    Icons.stadium_rounded,
                    size: 22,
                    color: AppColors.marqueeAmber,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resolvedVenue,
                        style: AppTypography.body14(
                          color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        resolvedAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption12(
                          color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Ticket Categories Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 18,
                  color: AppColors.spotlightCoral,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ticket Categories & Pricing',
                  style: AppTypography.body14(
                    color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Categories List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedCategoryIndex == index;

              return InkWell(
                borderRadius: AppRadius.border16,
                onTap: () {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? AppColors.surfaceElevated
                            : AppColors.lightSurfaceElevated)
                        : (isDark ? AppColors.surface : AppColors.lightSurface),
                    borderRadius: AppRadius.border16,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.spotlightCoral
                          : (isDark
                              ? AppColors.surfaceBorder
                              : AppColors.lightSurfaceBorder),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Radio check indicator
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.spotlightCoral
                                : (isDark
                                    ? AppColors.lavenderMuted
                                    : AppColors.textSecondaryLight),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.spotlightCoral,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),

                      // Category Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  cat.name,
                                  style: AppTypography.body14(
                                    color: isDark
                                        ? AppColors.lavender
                                        : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cat.statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    cat.status,
                                    style: AppTypography.caption12(
                                      color: cat.statusColor,
                                      fontWeight: FontWeight.w700,
                                    ).copyWith(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              cat.description,
                              style: AppTypography.caption12(
                                color: isDark
                                    ? AppColors.lavenderMuted
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Price
                      Text(
                        '₹${cat.price.toInt()}',
                        style: AppTypography.body14(
                          color: AppColors.spotlightCoral,
                          fontWeight: FontWeight.w800,
                        ).copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
