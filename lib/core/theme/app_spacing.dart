import 'package:flutter/material.dart';

/// 4-pt grid system spacing constants and helpers
abstract final class AppSpacing {
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s28 = 28.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;

  // SizedBox spacing widgets
  static const Widget vertical4 = SizedBox(height: s4);
  static const Widget vertical8 = SizedBox(height: s8);
  static const Widget vertical12 = SizedBox(height: s12);
  static const Widget vertical16 = SizedBox(height: s16);
  static const Widget vertical20 = SizedBox(height: s20);
  static const Widget vertical24 = SizedBox(height: s24);
  static const Widget vertical32 = SizedBox(height: s32);
  static const Widget vertical48 = SizedBox(height: s48);

  static const Widget horizontal4 = SizedBox(width: s4);
  static const Widget horizontal8 = SizedBox(width: s8);
  static const Widget horizontal12 = SizedBox(width: s12);
  static const Widget horizontal16 = SizedBox(width: s16);
  static const Widget horizontal20 = SizedBox(width: s20);
  static const Widget horizontal24 = SizedBox(width: s24);

  // Common Insets
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: s16,
    vertical: s20,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(s16);
  static const EdgeInsets compactPadding = EdgeInsets.all(s8);
}
