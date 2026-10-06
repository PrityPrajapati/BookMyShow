import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';

/// Formatted Indian Rupee Price Tag with optional strikethrough original price
class PriceTag extends StatelessWidget {
  const PriceTag({
    required this.amount,
    super.key,
    this.originalAmount,
    this.fontSize = 18.0,
    this.color,
    this.originalPriceColor,
    this.fontWeight = FontWeight.w700,
    this.showDecimals = false,
  });

  final num amount;
  final num? originalAmount;
  final double fontSize;
  final Color? color;
  final Color? originalPriceColor;
  final FontWeight fontWeight;
  final bool showDecimals;

  static String formatInr(num value, {bool decimals = false}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: decimals ? 2 : 0,
    );
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = color ?? (isDark ? AppColors.lavender : AppColors.textPrimaryLight);
    final secondaryColor = originalPriceColor ??
        (isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formatInr(amount, decimals: showDecimals),
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: primaryColor,
          ),
        ),
        if (originalAmount != null && originalAmount! > amount) ...[
          const SizedBox(width: 6),
          Text(
            formatInr(originalAmount!, decimals: showDecimals),
            style: GoogleFonts.inter(
              fontSize: fontSize * 0.75,
              fontWeight: FontWeight.w400,
              color: secondaryColor,
              decoration: TextDecoration.lineThrough,
              decorationColor: secondaryColor,
            ),
          ),
        ],
      ],
    );
  }
}
