import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';

/// ShowScape Theme Configuration - Material 3
abstract final class AppTheme {
  /// Cinematic Dark Theme (Default)
  static ThemeData dark() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final headingTextTheme = GoogleFonts.poppinsTextTheme();

    final textTheme = baseTextTheme.copyWith(
      displayLarge: headingTextTheme.displayLarge?.copyWith(
        color: AppColors.lavender,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: headingTextTheme.headlineMedium?.copyWith(
        color: AppColors.lavender,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: headingTextTheme.titleLarge?.copyWith(
        color: AppColors.lavender,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: AppColors.lavender,
        fontSize: 16,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: AppColors.lavenderMuted,
        fontSize: 14,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: AppColors.lavenderMuted,
        fontSize: 12,
      ),
      labelLarge: headingTextTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.midnight,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.spotlightCoral,
        onPrimary: Colors.white,
        secondary: AppColors.marqueeAmber,
        onSecondary: AppColors.midnight,
        surface: AppColors.surface,
        onSurface: AppColors.lavender,
        surfaceContainerHighest: AppColors.surfaceElevated,
        outline: AppColors.surfaceBorder,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: AppRadius.shape20,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.spotlightCoral,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: AppRadius.shapePill,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.midnight,
        foregroundColor: AppColors.lavender,
        elevation: 0,
        centerTitle: false,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.spotlightCoral,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.border12,
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.lavender,
        ),
      ),
    );
  }

  /// Refined Light Theme
  static ThemeData light() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final headingTextTheme = GoogleFonts.poppinsTextTheme();

    final textTheme = baseTextTheme.copyWith(
      displayLarge: headingTextTheme.displayLarge?.copyWith(
        color: AppColors.textPrimaryLight,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: headingTextTheme.headlineMedium?.copyWith(
        color: AppColors.textPrimaryLight,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: headingTextTheme.titleLarge?.copyWith(
        color: AppColors.textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimaryLight,
        fontSize: 16,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryLight,
        fontSize: 14,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: AppColors.textSecondaryLight,
        fontSize: 12,
      ),
      labelLarge: headingTextTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.spotlightCoral,
        onPrimary: Colors.white,
        secondary: AppColors.marqueeAmberDark,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.lightSurfaceElevated,
        outline: AppColors.lightSurfaceBorder,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: AppRadius.shape20,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.spotlightCoral,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: AppRadius.shapePill,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedColor: AppColors.spotlightCoral,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.border12,
          side: const BorderSide(color: AppColors.lightSurfaceBorder),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  /// Backward compatibility default
  static ThemeData get darkTheme => dark();
}
