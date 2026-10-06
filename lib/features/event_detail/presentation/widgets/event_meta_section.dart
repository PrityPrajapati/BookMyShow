import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/event_detail/presentation/widgets/trailer_modal_sheet.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

/// Event Meta Information Section: Title, Rating, Duration, Languages, Certificate, Genres & Trailer CTA
class EventMetaSection extends StatelessWidget {
  final Event event;

  const EventMetaSection({super.key, required this.event});

  void _openTrailer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TrailerModalSheet(event: event),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return 'Duration TBA';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    }
    return '${remainingMinutes}m';
  }

  String _formatVotes(int count) {
    if (count <= 0) return 'Recent Release';
    return '${NumberFormat.compact().format(count)} votes';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.lavender : AppColors.textPrimaryLight;
    final subtextColor = isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Event Title
          Text(
            event.title,
            style: AppTypography.heading24(color: textColor).copyWith(
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),

          // 2. Rating & Votes Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: AppRadius.border12,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.marqueeAmber,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  event.rating > 0 ? event.rating.toStringAsFixed(1) : 'New',
                  style: AppTypography.heading20(color: textColor).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '/10',
                  style: AppTypography.caption12(color: subtextColor),
                ),
                const SizedBox(width: 8),
                Text(
                  '•',
                  style: TextStyle(color: subtextColor, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatVotes(event.votesCount),
                    style: AppTypography.body14(color: subtextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Quick Rate action
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Rating feature for "${event.title}" coming soon!'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: AppRadius.pill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.spotlightCoral.withValues(alpha: 0.12),
                      borderRadius: AppRadius.pill,
                      border: Border.all(
                        color: AppColors.spotlightCoral.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_border_rounded,
                          size: 14,
                          color: AppColors.spotlightCoral,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rate',
                          style: AppTypography.caption12(
                            color: AppColors.spotlightCoral,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Metadata Pills: Duration, Languages, Certificate, Release Date
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Certificate Pill
              if (event.certificate != null && event.certificate!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white38 : Colors.black38,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    event.certificate!,
                    style: AppTypography.caption12(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

              // Duration Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: subtextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(event.durationMins),
                      style: AppTypography.caption12(color: textColor),
                    ),
                  ],
                ),
              ),

              // Languages Pill
              if (event.languages.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.translate_rounded,
                        size: 14,
                        color: subtextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.languages.join(', '),
                        style: AppTypography.caption12(color: textColor),
                      ),
                    ],
                  ),
                ),

              // Release Date (if present)
              if (event.releaseDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: subtextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(event.releaseDate!),
                        style: AppTypography.caption12(color: textColor),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Genre Chips Row
          if (event.genres.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: event.genres.map((genre) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: AppRadius.pill,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Text(
                        genre,
                        style: AppTypography.caption12(
                          color: subtextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 14),

          // 5. Watch Trailer Button (prominent in meta section for easy access)
          if (event.trailerUrl.isNotEmpty)
            InkWell(
              onTap: () => _openTrailer(context),
              borderRadius: AppRadius.border12,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.spotlightCoral.withValues(alpha: 0.15),
                      AppColors.primeViolet.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: AppRadius.border12,
                  border: Border.all(
                    color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.spotlightCoral,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Watch Trailer & Teaser',
                      style: AppTypography.body14(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
