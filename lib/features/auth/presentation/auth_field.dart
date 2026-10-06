import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_palette.dart';
import 'package:showscape/core/theme/app_radius.dart';

InputDecoration authInputDecoration({
  required AppPalette palette,
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: palette.textMuted),
    filled: true,
    fillColor: palette.surface,
    labelStyle: TextStyle(color: palette.textMuted),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.border16,
      borderSide: BorderSide(color: palette.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.border16,
      borderSide: const BorderSide(color: AppColors.spotlightCoral, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.border16,
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.border16,
      borderSide: const BorderSide(color: AppColors.error, width: 1.4),
    ),
  );
}
