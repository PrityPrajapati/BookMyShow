import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';

/// ShowScape Typography Scale
/// Scale: 32 (Display/Headline 1), 24 (Heading 2), 20 (Heading 3),
///        16 (Body Large), 14 (Body Medium), 12 (Caption/Body Small)
/// Headings: Poppins | Body: Inter
abstract final class AppTypography {
  // Heading Styles (Poppins)
  static TextStyle heading32({Color color = AppColors.lavender}) =>
      GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle heading24({Color color = AppColors.lavender}) =>
      GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle heading20({Color color = AppColors.lavender}) =>
      GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  static TextStyle heading18({Color color = AppColors.lavender}) =>
      GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  // Body Styles (Inter)
  static TextStyle body16({
    Color color = AppColors.lavender,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: fontWeight,
        height: 1.5,
        color: color,
      );

  static TextStyle body14({
    Color color = AppColors.lavenderMuted,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: fontWeight,
        height: 1.45,
        color: color,
      );


  static TextStyle caption12({
    Color color = AppColors.lavenderMuted,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: fontWeight,
        height: 1.4,
        letterSpacing: 0.2,
        color: color,
      );

  // Button & Label Styles
  static TextStyle buttonLabel({Color color = Colors.white}) =>
      GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle chipLabel({Color color = AppColors.lavender}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: color,
      );

  // Standard Material style compatibility getters
  static TextStyle get headlineLarge => heading32();
  static TextStyle get headlineMedium => heading24();
  static TextStyle get headlineSmall => heading20();
  static TextStyle get bodyLarge => body16();
  static TextStyle get bodyMedium => body14();
  static TextStyle get bodySmall => caption12();
  static TextStyle get labelSmall => caption12();
  static TextStyle get caption => caption12();
}
