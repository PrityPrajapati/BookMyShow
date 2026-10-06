import 'package:flutter/material.dart';
import 'package:showscape/core/theme/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';

/// Modal sheet showing venue floor map and amenities
class VenueMapSheet extends StatelessWidget {
  const VenueMapSheet({
    required this.venueName,
    super.key,
    this.screenName = 'Audi 4 (IMAX Laser)',
  });

  final String venueName;
  final String screenName;

  static void show(BuildContext context, {required String venueName, String? screenName}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VenueMapSheet(
        venueName: venueName,
        screenName: screenName ?? 'Audi 4 (IMAX Laser)',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.r20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.coral.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.map_rounded, color: AppColors.coral, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venue Map & Directions',
                        style: AppTypography.headlineSmall.copyWith(fontSize: 18),
                      ),
                      Text(
                        venueName,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stylized Floor Plan Card
                  Container(
                    height: 220,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceLight : AppColors.lightSurfaceBorder.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.r16),
                      border: Border.all(
                        color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Grid background
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _GridPainter(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                          ),
                        ),
                        // Screen Area
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 180,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.coral.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.coral.withValues(alpha: 0.6)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.tv_rounded, color: AppColors.coral, size: 20),
                                const SizedBox(height: 4),
                                Text(
                                  screenName,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.coral,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Concessions / Food counter
                        Positioned(
                          left: 10,
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.fastfood_rounded, color: AppColors.amber, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Food Counter',
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.amber),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Restrooms
                        Positioned(
                          right: 10,
                          bottom: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.info.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.wc_rounded, color: AppColors.info, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Restrooms',
                                  style: AppTypography.labelSmall.copyWith(color: AppColors.info),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Entry gate
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surface : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.meeting_room_rounded, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  'Gate B Entry',
                                  style: AppTypography.labelSmall.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amenities Guide
                  Text(
                    'Key Amenities',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAmenityRow(
                    Icons.fastfood_rounded,
                    'Gourmet Concessions Counter 3',
                    'Level 3, adjacent to Audi 4 entry',
                    AppColors.amber,
                  ),
                  const SizedBox(height: 10),
                  _buildAmenityRow(
                    Icons.local_parking_rounded,
                    'Parking & Valet Pick-up',
                    'Basement Level 2 (take elevator lobby B)',
                    AppColors.electricPurple,
                  ),
                  const SizedBox(height: 10),
                  _buildAmenityRow(
                    Icons.wheelchair_pickup_rounded,
                    'Wheelchair Accessible Elevator',
                    'Located right beside Screen 4 entrance',
                    AppColors.success,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityRow(IconData icon, String title, String subtitle, Color color) {
    return Semantics(
      label: 'Amenity: $title, $subtitle',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.color != color;
}
