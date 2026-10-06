import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/widgets/showscape_image.dart';
import 'package:showscape/features/event_detail/presentation/widgets/trailer_modal_sheet.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

/// SliverAppBar with Hero poster expanding into blurred cinematic banner backdrop
class EventDetailAppBar extends StatefulWidget {
  final Event event;

  const EventDetailAppBar({super.key, required this.event});

  @override
  State<EventDetailAppBar> createState() => _EventDetailAppBarState();
}

class _EventDetailAppBarState extends State<EventDetailAppBar> {
  bool _isFavorite = false;

  void _openTrailer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TrailerModalSheet(event: widget.event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 360.0,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
        ),
      ),
      actions: [
        // Favorite Button
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: _isFavorite ? AppColors.spotlightCoral : Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? 'Added to your Watchlist & Favorites!'
                        : 'Removed from Favorites.',
                    style: AppTypography.caption12(color: Colors.white),
                  ),
                  backgroundColor: AppColors.surface,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),

        // Share Button
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share_rounded,
              size: 18,
              color: Colors.white,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sharing "${widget.event.title}" link copied!'),
                  backgroundColor: AppColors.surface,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final isCollapsed = top <= kToolbarHeight + 80;

          return FlexibleSpaceBar(
            centerTitle: true,
            title: isCollapsed
                ? Text(
                    widget.event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body14(
                      color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
            background: Stack(
              fit: StackFit.expand,
              children: [
                // 1. High-Res Banner Image
                ShowScapeImage(
                  imageUrl: widget.event.bannerUrl.isNotEmpty
                      ? widget.event.bannerUrl
                      : widget.event.posterUrl,
                  fit: BoxFit.cover,
                ),

                // 2. Backdrop Filter Blur Effect
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),

                // 3. Gradient Vignette Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                        isDark ? AppColors.midnight : AppColors.lightBackground,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),

                // 4. Centered Hero Poster and Watch Trailer CTA
                Positioned(
                  bottom: 24,
                  left: 20,
                  right: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Hero Poster Card
                      Hero(
                        tag: 'event-poster-${widget.event.id}',
                        child: Container(
                          width: 125,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.border16,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: AppRadius.border16,
                            child: ShowScapeImage(
                              imageUrl: widget.event.posterUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Quick Info on Header + Trailer Button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Watch Trailer Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: AppRadius.pill,
                                onTap: _openTrailer,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.spotlightCoral,
                                        AppColors.spotlightCoralDark,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: AppRadius.pill,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.play_circle_fill_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Watch Trailer',
                                        style: AppTypography.caption12(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Certificate & Language Tag
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (widget.event.certificate != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      widget.event.certificate!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.event.languages.take(2).join(', '),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
