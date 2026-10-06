import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/event_detail/domain/models/event_review_summary.dart';
import 'package:showscape/features/event_detail/domain/services/event_summary_manager.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

enum ThumbsState { none, up, down }

/// 'What people say' card on Event Detail:
/// Generated via AiService.summarise from top 20 mock reviews.
/// Contains exactly 3 short bullets + a one-line spoiler-free verdict.
/// Cached per event per day in Hive.
class AiSummaryCard extends ConsumerStatefulWidget {
  final Event event;

  const AiSummaryCard({super.key, required this.event});

  @override
  ConsumerState<AiSummaryCard> createState() => _AiSummaryCardState();
}

class _AiSummaryCardState extends ConsumerState<AiSummaryCard> {
  ThumbsState _feedback = ThumbsState.none;

  void _onThumbsTap(ThumbsState state) {
    setState(() {
      _feedback = _feedback == state ? ThumbsState.none : state;
    });

    if (_feedback != ThumbsState.none) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _feedback == ThumbsState.up
                ? 'Thanks! We will keep generating helpful summaries.'
                : 'Thanks for the feedback! We are refining our AI models.',
            style: AppTypography.caption12(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(eventReviewSummaryProvider(widget.event));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: AppColors.spotlightCoral.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.spotlightCoral
                .withValues(alpha: isDark ? 0.08 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Sparkle + 'What people say' + Badge + Thumbs feedback
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.spotlightCoral, AppColors.marqueeAmber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What people say',
                      style: AppTypography.body14(
                        color: isDark
                            ? AppColors.lavender
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'AI-generated from top 20 verified reviews',
                      style: AppTypography.caption12(
                        color: AppColors.spotlightCoral,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),

              // Thumbs Up / Down
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _feedback == ThumbsState.up
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_alt_outlined,
                      size: 16,
                      color: _feedback == ThumbsState.up
                          ? AppColors.spotlightCoral
                          : (isDark
                              ? AppColors.lavenderMuted
                              : AppColors.textSecondaryLight),
                    ),
                    onPressed: () => _onThumbsTap(ThumbsState.up),
                    padding: const EdgeInsets.all(4),
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    tooltip: 'Helpful',
                  ),
                  IconButton(
                    icon: Icon(
                      _feedback == ThumbsState.down
                          ? Icons.thumb_down_rounded
                          : Icons.thumb_down_alt_outlined,
                      size: 16,
                      color: _feedback == ThumbsState.down
                          ? AppColors.spotlightCoral
                          : (isDark
                              ? AppColors.lavenderMuted
                              : AppColors.textSecondaryLight),
                    ),
                    onPressed: () => _onThumbsTap(ThumbsState.down),
                    padding: const EdgeInsets.all(4),
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    tooltip: 'Not helpful',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Content body: Display summary with deterministic fallback
          _buildSummaryContent(
            summaryAsync.valueOrNull ??
                EventReviewSummary.deterministicFallback(
                  eventId: widget.event.id,
                  event: widget.event,
                ),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(EventReviewSummary summary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exactly 3 Bullet Points
        ...summary.bullets.take(3).map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 10),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.spotlightCoral,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: AppTypography.body14(
                          color: isDark
                              ? AppColors.lavender
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

        const SizedBox(height: 8),

        // One-Line Spoiler-Free Verdict Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.midnight : AppColors.lightBackground,
            borderRadius: AppRadius.border12,
            border: Border.all(
              color: AppColors.marqueeAmber.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 16,
                color: AppColors.marqueeAmber,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Spoiler-Free Verdict: ${summary.verdict}',
                  style: AppTypography.caption12(
                    color: AppColors.marqueeAmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
