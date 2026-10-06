import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:showscape/core/constants/app_colors.dart';

/// Unified image widget for ShowScape supporting both local bundled assets
/// ('assets/images/...') and remote URLs with graceful fallback placeholders.
class ShowScapeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const ShowScapeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    final trimmed = imageUrl.trim();

    if (trimmed.isEmpty) {
      image = errorWidget ?? _buildFallback();
    } else if (trimmed.startsWith('assets/')) {
      image = Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildFallback(),
      );
    } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      image = CachedNetworkImage(
        imageUrl: trimmed,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) =>
            placeholder ??
            Container(
              width: width,
              height: height,
              color: AppColors.surfaceElevated,
            ),
        errorWidget: (_, __, ___) =>
            errorWidget ?? _buildFallback(),
      );
    } else {
      image = errorWidget ?? _buildFallback();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E1B38),
            Color(0xFF0F0E1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_filter_rounded,
          size: (width != null && width! < 80) ? 22 : 36,
          color: AppColors.spotlightCoral.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
