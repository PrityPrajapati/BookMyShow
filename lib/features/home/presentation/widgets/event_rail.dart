import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/models/models.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/widgets/section_header.dart';
import 'package:showscape/core/widgets/showscape_image.dart';

class EventRail extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Event> events;
  final VoidCallback? onSeeAll;

  const EventRail({
    required this.title,
    required this.events,
    this.subtitle,
    this.onSeeAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          onActionPressed: onSeeAll ??
              () {
                context.push(AppRoutes.explore);
              },
        ),
        SizedBox(
          height: 250,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventPosterCard(
                event: event,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EventPosterCard extends StatelessWidget {
  final Event event;
  final bool isDark;

  const _EventPosterCard({
    required this.event,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: InkWell(
        onTap: () {
          context.push(AppRoutes.eventPath(event.id));
        },
        borderRadius: AppRadius.border16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster with Hero Animation Tag
            ClipRRect(
              borderRadius: AppRadius.border16,
              child: Stack(
                children: [
                  Hero(
                    tag: 'event-poster-${event.id}',
                    child: ShowScapeImage(
                      imageUrl: event.posterUrl,
                      width: 140,
                      height: 190,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        width: 140,
                        height: 190,
                        color: isDark
                            ? AppColors.surfaceElevated
                            : AppColors.lightSurfaceElevated,
                      ),
                    ),
                  ),

                  // Bottom Gradient on Poster
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Rating Badge on Poster bottom left
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.marqueeAmber.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: AppColors.marqueeAmber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            event.rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Certificate Badge on top right
                  if (event.certificate != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.certificate!,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              event.title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Genres / Language subtitle
            Text(
              event.genres.take(2).join(', '),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark
                    ? AppColors.lavenderMuted
                    : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
