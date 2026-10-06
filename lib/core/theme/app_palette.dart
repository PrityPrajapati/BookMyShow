import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';

/// Theme-aware colors so screens follow light and dark mode.
class AppPalette {
  const AppPalette._({required this.isDark});

  factory AppPalette.of(BuildContext context) {
    return AppPalette._(isDark: Theme.of(context).brightness == Brightness.dark);
  }

  final bool isDark;

  Color get background => isDark ? AppColors.midnight : AppColors.lightBackground;

  Color get surface => isDark ? AppColors.surface : AppColors.lightSurface;

  Color get surfaceElevated =>
      isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceElevated;

  Color get border => isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;

  Color get text => isDark ? AppColors.lavender : AppColors.textPrimaryLight;

  Color get textMuted => isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight;
}
