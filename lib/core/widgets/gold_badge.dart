import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';

/// ShowScape Gold VIP Membership Badge
class GoldBadge extends StatelessWidget {
  const GoldBadge({
    super.key,
    this.text = 'GOLD',
    this.showIcon = true,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  final String text;
  final bool showIcon;
  final double fontSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: AppRadius.pill,
        boxShadow: [
          BoxShadow(
            color: AppColors.marqueeAmber.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.workspace_premium_rounded,
              size: fontSize + 3,
              color: AppColors.midnight,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.midnight,
            ),
          ),
        ],
      ),
    );
  }
}
