import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';

/// Selectable Chip with Optional Icon, Badge, and Theme Accent Colors
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    super.key,
    this.icon,
    this.activeColor,
    this.badgeText,
    this.semanticLabel,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Widget? icon;
  final Color? activeColor;
  final String? badgeText;
  final String? semanticLabel;

  void _handleTap() {
    HapticFeedback.selectionClick();
    onSelected(!isSelected);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = activeColor ?? AppColors.spotlightCoral;

    final unselectedBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final unselectedBorder = isDark
        ? AppColors.surfaceBorder
        : AppColors.lightSurfaceBorder;
    final unselectedText = isDark
        ? AppColors.lavenderMuted
        : AppColors.textSecondaryLight;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: AppRadius.border12,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : unselectedBg,
              borderRadius: AppRadius.border12,
              border: Border.all(
                color: isSelected ? selectedColor : unselectedBorder,
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(
                      size: 16,
                      color: isSelected ? Colors.white : unselectedText,
                    ),
                    child: icon!,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : unselectedText,
                  ),
                ),
                if (badgeText != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : AppColors.marqueeAmber.withValues(alpha: 0.2),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      badgeText!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.marqueeAmber,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
