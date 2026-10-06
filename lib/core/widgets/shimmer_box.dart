import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';

/// Skeleton Shimmer Loading Container
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = baseColor ??
        (isDark ? AppColors.surface : AppColors.lightSurfaceElevated);
    final highlight = highlightColor ??
        (isDark ? AppColors.surfaceElevated : Colors.white);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? (borderRadius ?? AppRadius.border12)
              : null,
        ),
      ),
    );
  }
}
