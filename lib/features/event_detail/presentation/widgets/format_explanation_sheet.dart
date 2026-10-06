import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/event_detail/domain/models/format_info.dart';

/// Modal bottom sheet detailing all cinematic screen formats
class FormatExplanationSheet extends StatelessWidget {
  const FormatExplanationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: AppRadius.pill,
                ),
              ),

              // Title Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 20,
                            color: AppColors.spotlightCoral,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Experience Formats Explained',
                              style: AppTypography.heading20(
                                color: isDark
                                    ? AppColors.lavender
                                    : AppColors.textPrimaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Formats List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: FormatInfo.allFormats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final fmt = FormatInfo.allFormats[index];
                    return _FormatDetailCard(format: fmt);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FormatDetailCard extends StatelessWidget {
  final FormatInfo format;

  const _FormatDetailCard({required this.format});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnight : AppColors.lightBackground,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                  borderRadius: AppRadius.border12,
                ),
                child: Icon(
                  format.icon,
                  size: 20,
                  color: AppColors.spotlightCoral,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      format.name,
                      style: AppTypography.body14(
                        color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      format.tag == 'Base'
                          ? 'Standard Ticket Tier'
                          : 'Premium Upgrade (${format.tag})',
                      style: AppTypography.caption12(
                        color: format.tag == 'Base'
                            ? (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight)
                            : AppColors.spotlightCoral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            format.description,
            style: AppTypography.body14(
              color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up_rounded, size: 14, color: AppColors.marqueeAmber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          format.audioSpec,
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                          ).copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam_rounded, size: 14, color: AppColors.spotlightCoral),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          format.visualSpec,
                          style: AppTypography.caption12(
                            color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                          ).copyWith(fontSize: 11),
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
    );
  }
}
