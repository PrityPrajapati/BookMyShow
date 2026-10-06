import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

/// Horizontal carousel displaying leading Cast & Crew members
class CastCarousel extends StatelessWidget {
  final Event event;

  const CastCarousel({super.key, required this.event});

  Color _getAvatarGradientColor(int index) {
    final colors = [
      AppColors.spotlightCoral,
      AppColors.marqueeAmber,
      AppColors.primeViolet,
      AppColors.standardCyan,
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final castList = event.cast;
    final crewList = event.crew;

    if (castList.isEmpty && crewList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event.type == EventType.movie
                    ? 'Cast & Artists'
                    : (event.type == EventType.sports
                        ? 'Key Players & Squad'
                        : 'Headlining Artists'),
                style: AppTypography.heading20(
                  color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                ).copyWith(fontSize: 18),
              ),
              Text(
                '${castList.length} members',
                style: AppTypography.caption12(
                  color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // Cast Horizontal List
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: castList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final member = castList[index];
              final initials = member
                  .split(' ')
                  .where((s) => s.isNotEmpty)
                  .take(2)
                  .map((s) => s[0])
                  .join()
                  .toUpperCase();
              final accentColor = _getAvatarGradientColor(index);

              return SizedBox(
                width: 76,
                child: Column(
                  children: [
                    // Avatar Circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.8),
                            accentColor.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials.isNotEmpty ? initials : '★',
                          style: AppTypography.body14(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Name
                    Text(
                      member,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption12(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 11, height: 1.2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Crew Row (if available)
        if (crewList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: crewList.map((crewItem) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? AppColors.surfaceBorder
                          : AppColors.lightSurfaceBorder,
                    ),
                  ),
                  child: Text(
                    crewItem,
                    style: AppTypography.caption12(
                      color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                    ).copyWith(fontSize: 11),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
