import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/widgets/primary_button.dart';

/// Cinematic Error State Display with Retry Callback
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    super.key,
    this.title = 'Something Went Wrong',
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.icon,
    this.padding = const EdgeInsets.all(24),
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final Widget? icon;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: icon ??
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 40,
                      color: AppColors.error,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.4,
                color: isDark
                    ? AppColors.lavenderMuted
                    : AppColors.textSecondaryLight,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: retryLabel,
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
