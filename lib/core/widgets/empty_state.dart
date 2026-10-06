import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/widgets/primary_button.dart';

/// Cinematic Empty State Display
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    super.key,
    this.message,
    this.icon,
    this.actionLabel,
    this.onActionPressed,
    this.padding = const EdgeInsets.all(24),
  });

  final String title;
  final String? message;
  final Widget? icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
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
                color: (isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceElevated)
                    .withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
                ),
              ),
              child: Center(
                child: icon ??
                    const Icon(
                      Icons.movie_creation_outlined,
                      size: 40,
                      color: AppColors.spotlightCoral,
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
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark
                      ? AppColors.lavenderMuted
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: actionLabel!,
                onPressed: onActionPressed,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
