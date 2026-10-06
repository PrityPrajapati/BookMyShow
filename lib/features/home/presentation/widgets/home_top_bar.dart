import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/utils/app_haptics.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/widgets/gold_badge.dart';
import 'package:showscape/features/home/presentation/providers/home_providers.dart';
import 'package:showscape/features/notifications/presentation/providers/notification_providers.dart';

class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key});

  void _showCityPicker(BuildContext context, WidgetRef ref, String currentCity) {
    AppHaptics.medium();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                AppSpacing.vertical16,
                Text(
                  'Select Your City',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                  ),
                ),
                AppSpacing.vertical4,
                Text(
                  'Personalizing shows, cinemas & experiences nearby',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.lavenderMuted
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.vertical16,
                ...supportedCities.map((city) {
                  final isSelected = city == currentCity;
                  return InkWell(
                    onTap: () {
                      ref.read(selectedCityProvider.notifier).state = city;
                      Navigator.pop(ctx);
                    },
                    borderRadius: AppRadius.border12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.spotlightCoral.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: AppRadius.border12,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.spotlightCoral
                              : (isDark
                                  ? AppColors.surfaceBorder
                                  : AppColors.lightSurfaceBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 20,
                            color: isSelected
                                ? AppColors.spotlightCoral
                                : (isDark
                                    ? AppColors.lavenderMuted
                                    : AppColors.textSecondaryLight),
                          ),
                          AppSpacing.horizontal12,
                          Text(
                            city,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.spotlightCoral
                                  : (isDark
                                      ? AppColors.lavender
                                      : AppColors.textPrimaryLight),
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.spotlightCoral,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCity = ref.watch(selectedCityProvider);
    final notificationCount = ref.watch(unreadNotificationsCountProvider);
    final userAsync = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Flexible(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.coralGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'ShowScape',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: InkWell(
              onTap: () {
                AppHaptics.selection();
                _showCityPicker(context, ref, currentCity);
              },
              borderRadius: AppRadius.pill,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.lightSurfaceElevated,
                  borderRadius: AppRadius.pill,
                  border: Border.all(
                    color: isDark
                        ? AppColors.surfaceBorder
                        : AppColors.lightSurfaceBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      size: 14,
                      color: AppColors.spotlightCoral,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        currentCity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.lavender
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.lavenderMuted
                          : AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),

          // Gold VIP Badge if active
          userAsync.when(
            data: (user) {
              if (user != null && user.isGoldMember) {
                return const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: GoldBadge(text: 'GOLD VIP'),
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Notification Bell with Badge
          InkWell(
            onTap: () {
              AppHaptics.light();
              context.push(AppRoutes.notifications);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.lightSurfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? AppColors.surfaceBorder
                      : AppColors.lightSurfaceBorder,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.spotlightCoral,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
