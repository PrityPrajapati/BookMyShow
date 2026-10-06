import 'package:flutter/material.dart';

/// ShowScape Design System Color Palette
abstract final class AppColors {
  // Dark Palette (Primary / Default)
  static const Color midnight = Color(0xFF140F2B); // Dark scaffold background
  static const Color surface = Color(0xFF1E1740); // Dark card / container
  static const Color surfaceElevated = Color(0xFF2B2255); // Elevated cards
  static const Color surfaceBorder = Color(0xFF372D6B); // Borders on dark
  static const Color surfaceGlass = Color(0x331E1740); // Dark glassmorphism

  // Light Palette
  static const Color lightBackground = Color(0xFFF7F5FC); // Light scaffold
  static const Color lightSurface = Color(0xFFFFFFFF); // Light card
  static const Color lightSurfaceElevated = Color(0xFFEEEAFB); // Light elevated
  static const Color lightSurfaceBorder = Color(0xFFDDD6FE); // Light borders

  // Primary & Accent Brand Tokens
  static const Color spotlightCoral = Color(0xFFFF4D6D); // Primary Coral Accent
  static const Color spotlightCoralDark = Color(0xFFE03153); // Pressed Coral
  static const Color marqueeAmber = Color(0xFFFFB547); // Gold / Offers / VIP
  static const Color marqueeAmberDark = Color(0xFFE59828); // Amber pressed

  // Typography & Content Colors
  static const Color lavender = Color(0xFFEEEAFB); // Text on Dark
  static const Color lavenderMuted = Color(0xFFA59EB8); // Subtitle on Dark
  static const Color textPrimaryLight = Color(0xFF1A1333); // Text on Light
  static const Color textSecondaryLight = Color(0xFF6B6289); // Subtitle on Light

  // Feedback States
  static const Color success = Color(0xFF22C55E);
  static const Color successContainer = Color(0xFF143823);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFF3D2C0D);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFF3B1515);

  // Seat & Tier Accents
  static const Color reclinerGold = Color(0xFFFFD700);
  static const Color primeViolet = Color(0xFF9D4EDD);
  static const Color standardCyan = Color(0xFF06B6D4);
  // Convenient aliases
  static const Color primary = spotlightCoral;
  static const Color background = midnight;
  static const Color coral = spotlightCoral;
  static const Color amber = marqueeAmber;
  static const Color surfaceLight = surfaceElevated;
  static const Color surfaceVariant = surfaceElevated;
  static const Color textPrimary = lavender;
  static const Color textSecondary = lavenderMuted;
  static const Color textMuted = lavenderMuted;
  static const Color info = standardCyan;
  static const Color electricPurple = primeViolet;

  // Gradients
  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFFF758F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB547), Color(0xFFFFD074), Color(0xFFFF9E1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cinematicDarkGradient = LinearGradient(
    colors: [Color(0xFF22174A), Color(0xFF140F2B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
