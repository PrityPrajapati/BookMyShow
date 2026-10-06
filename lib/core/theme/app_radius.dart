import 'package:flutter/material.dart';

/// ShowScape Corner Radius Tokens (12 / 20 / 28)
abstract final class AppRadius {
  static const double r12 = 12.0; // Chips, small buttons, inner containers
  static const double r16 = 16.0; // Medium cards, inputs
  static const double r20 = 20.0; // Cards, modals, bottom sheets, stubs
  static const double r28 = 28.0; // Hero banners, large dialogs, pills

  // BorderRadius helpers
  static final BorderRadius border12 = BorderRadius.circular(r12);
  static final BorderRadius border16 = BorderRadius.circular(r16);
  static final BorderRadius border20 = BorderRadius.circular(r20);
  static final BorderRadius border28 = BorderRadius.circular(r28);
  static final BorderRadius pill = BorderRadius.circular(999.0);

  // Top Rounded Corners (e.g. Bottom Sheets)
  static const BorderRadius sheetTop20 = BorderRadius.only(
    topLeft: Radius.circular(r20),
    topRight: Radius.circular(r20),
  );

  static const BorderRadius sheetTop28 = BorderRadius.only(
    topLeft: Radius.circular(r28),
    topRight: Radius.circular(r28),
  );

  // Rounded Rectangle Borders
  static final RoundedRectangleBorder shape12 = RoundedRectangleBorder(
    borderRadius: border12,
  );
  static final RoundedRectangleBorder shape20 = RoundedRectangleBorder(
    borderRadius: border20,
  );
  static final RoundedRectangleBorder shape28 = RoundedRectangleBorder(
    borderRadius: border28,
  );
  static final RoundedRectangleBorder shapePill = RoundedRectangleBorder(
    borderRadius: pill,
  );
}
