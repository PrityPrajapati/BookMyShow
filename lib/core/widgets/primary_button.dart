import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/utils/app_haptics.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';

/// Primary Brand Button with Pill Shape, Loading State, and Haptic Feedback
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 50.0,
    this.width,
    this.semanticLabel,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final double? width;
  final String? semanticLabel;

  void _handleTap() {
    if (onPressed == null || isLoading) return;
    AppHaptics.light();
    onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    final bg = backgroundColor ?? AppColors.spotlightCoral;
    final fg = foregroundColor ?? Colors.white;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel ?? text,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height < 48.0 ? 48.0 : height,
        child: ElevatedButton(
          onPressed: isDisabled ? null : _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledBackgroundColor: bg.withValues(alpha: 0.4),
            disabledForegroundColor: fg.withValues(alpha: 0.6),
            elevation: 0,
            shape: AppRadius.shapePill,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: fg,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
