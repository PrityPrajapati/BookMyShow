import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/event_detail/data/review_summary_cache_service.dart';
import 'package:showscape/features/event_detail/domain/models/event_review_summary.dart';
import 'package:showscape/features/event_detail/domain/services/event_summary_manager.dart';
import 'package:showscape/features/explore/data/repositories/mock_event_repository.dart';
import 'package:showscape/features/explore/domain/models/app_mood.dart';
import 'package:showscape/features/explore/domain/models/event.dart';
import 'package:showscape/services/ai/ai_service.dart';

/// Debug Screen for inspecting, testing, and regenerating AI review summaries and canonical mood tags
class AiDebugScreen extends ConsumerStatefulWidget {
  const AiDebugScreen({super.key});

  @override
  ConsumerState<AiDebugScreen> createState() => _AiDebugScreenState();
}

class _AiDebugScreenState extends ConsumerState<AiDebugScreen> {
  bool _isBatchProcessing = false;
  String? _batchStatusMessage;
  final Set<String> _regeneratingEventIds = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allEventsAsync = ref.watch(allEventsProvider);
    final cacheService = ref.watch(reviewSummaryCacheServiceProvider);
    final aiService = ref.watch(aiServiceProvider);
    final isMock = aiService is MockAiService;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnight : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'AI Summaries & Moods Debugger',
          style: AppTypography.heading18(
            color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh screen',
            onPressed: () {
              ref.invalidate(allEventsProvider);
              setState(() {});
            },
          ),
        ],
      ),
      body: allEventsAsync.when(
        data: (events) => _buildBody(context, events, cacheService, isMock, isDark),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.spotlightCoral),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading events: $err',
              style: AppTypography.body14(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<Event> events,
    ReviewSummaryCacheService cacheService,
    bool isMock,
    bool isDark,
  ) {
    final todayKey = cacheService.getDayKey();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // System Info & Cache Status Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.lightSurface,
            borderRadius: AppRadius.border16,
            border: Border.all(
              color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.memory_rounded,
                      color: AppColors.spotlightCoral,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Review & Mood Engine',
                          style: AppTypography.heading18(
                            color: isDark
                                ? AppColors.lavender
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          isMock
                              ? 'Mode: MockAiService (Offline Deterministic Fallbacks)'
                              : 'Mode: GeminiAiService',
                          style: AppTypography.caption12(
                            color: AppColors.spotlightCoral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Cache Key (yyyyMMdd):',
                    style: AppTypography.caption12(
                      color: isDark
                          ? AppColors.lavenderMuted
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.spotlightCoral.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      todayKey,
                      style: GoogleFonts.firaCode(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.spotlightCoral,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hive Cache Partition:',
                    style: AppTypography.caption12(
                      color: isDark
                          ? AppColors.lavenderMuted
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    'summary_{eventId}_$todayKey',
                    style: GoogleFonts.firaCode(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.lavender
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Canonical Moods Supported:',
                    style: AppTypography.caption12(
                      color: isDark
                          ? AppColors.lavenderMuted
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    'chill, laugh, thrill, date_night, family, music',
                    style: GoogleFonts.firaCode(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.marqueeAmber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Batch Action Buttons
              if (_isBatchProcessing) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.spotlightCoral,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _batchStatusMessage ?? 'Processing batch...',
                        style: AppTypography.caption12(
                          color: AppColors.spotlightCoral,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                        label: const Text('Regenerate All Summaries'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.spotlightCoral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => _regenerateAllSummaries(events),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: const Text('Clear All Caches'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _clearAllCaches(),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Event List Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Events (${events.length})',
              style: AppTypography.heading18(
                color: isDark ? AppColors.lavender : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              'Tap card to inspect',
              style: AppTypography.caption12(
                color: isDark
                    ? AppColors.lavenderMuted
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Event Cards
        ...events.map((event) => _buildEventDebugCard(context, event, isDark)),
      ],
    );
  }

  Widget _buildEventDebugCard(BuildContext context, Event event, bool isDark) {
    final manager = ref.watch(eventSummaryManagerProvider);
    final isRegenerating = _regeneratingEventIds.contains(event.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.lightSurface,
        borderRadius: AppRadius.border16,
        border: Border.all(
          color: isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Title & Type
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  event.posterUrl,
                  width: 44,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 44,
                    height: 60,
                    color: AppColors.surfaceBorder,
                    child: const Icon(Icons.movie, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTypography.body14(
                        color: isDark
                            ? AppColors.lavender
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${event.type.name.toUpperCase()} • ${event.genres.join(', ')}',
                      style: AppTypography.caption12(
                        color: isDark
                            ? AppColors.lavenderMuted
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Canonical Mood Chips
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: event.moodTags.map((m) {
                        final appMood = AppMood.tryFrom(m);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            appMood != null
                                ? '${appMood.emoji} ${appMood.label}'
                                : m,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.spotlightCoral,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Cached Summary Preview
          FutureBuilder<EventReviewSummary?>(
            future: manager.cacheService.getCachedSummary(event.id),
            builder: (context, snapshot) {
              final cached = snapshot.data;
              final hasCached = cached != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        hasCached
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        size: 14,
                        color: hasCached
                            ? AppColors.marqueeAmber
                            : (isDark
                                ? AppColors.lavenderMuted
                                : AppColors.textSecondaryLight),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasCached
                            ? 'Cached for Today (${manager.cacheService.getDayKey(cached.cachedAt)})'
                            : 'Not yet cached today (will generate on view)',
                        style: AppTypography.caption12(
                          color: hasCached
                              ? AppColors.marqueeAmber
                              : (isDark
                                  ? AppColors.lavenderMuted
                                  : AppColors.textSecondaryLight),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  if (hasCached) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.midnight
                            : AppColors.lightBackground,
                        borderRadius: AppRadius.border12,
                        border: Border.all(
                          color: AppColors.spotlightCoral.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'What people say (3 bullets):',
                            style: AppTypography.caption12(
                              color: AppColors.spotlightCoral,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          for (final b in cached.bullets)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '• $b',
                                style: AppTypography.caption12(
                                  color: isDark
                                      ? AppColors.lavender
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text.rich(
                            TextSpan(
                              text: 'Verdict: ',
                              style: AppTypography.caption12(
                                color: AppColors.marqueeAmber,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(
                                  text: cached.verdict,
                                  style: AppTypography.caption12(
                                    color: isDark
                                        ? AppColors.lavender
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Action Buttons per Event
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: isRegenerating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.spotlightCoral,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    isRegenerating ? 'Generating...' : 'Regenerate Summary',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.spotlightCoral,
                    side: const BorderSide(color: AppColors.spotlightCoral),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isRegenerating
                      ? null
                      : () => _regenerateSingleSummary(event),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.tag_rounded, size: 16),
                label: const Text('Re-tag Moods'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.marqueeAmber,
                  side: const BorderSide(color: AppColors.marqueeAmber),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _retagEventMoods(event),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _regenerateSingleSummary(Event event) async {
    setState(() => _regeneratingEventIds.add(event.id));

    try {
      final manager = ref.read(eventSummaryManagerProvider);
      // Force refresh regenerates from top 20 mock reviews via AiService.summarise
      await manager.getOrGenerateSummary(event, forceRefresh: true);
      ref.invalidate(eventReviewSummaryProvider(event));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Regenerated 3 bullets & verdict for "${event.title}"',
              style: AppTypography.caption12(color: Colors.white),
            ),
            backgroundColor: AppColors.surface,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _regeneratingEventIds.remove(event.id));
      }
    }
  }

  Future<void> _retagEventMoods(Event event) async {
    final manager = ref.read(eventSummaryManagerProvider);
    final moods = await manager.tagAndStoreMoods(event, forceRefresh: true);
    MockEventRepository.updateCachedMoods(event.id, moods);
    ref.invalidate(allEventsProvider);
    ref.invalidate(eventMoodTagsProvider(event));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Re-tagged moods for "${event.title}": [${moods.join(', ')}]',
            style: AppTypography.caption12(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _regenerateAllSummaries(List<Event> events) async {
    setState(() {
      _isBatchProcessing = true;
      _batchStatusMessage = 'Regenerating summaries for 0/${events.length}...';
    });

    final manager = ref.read(eventSummaryManagerProvider);
    for (int i = 0; i < events.length; i++) {
      final e = events[i];
      if (mounted) {
        setState(() {
          _batchStatusMessage =
              'Regenerating summary for "${e.title}" (${i + 1}/${events.length})...';
        });
      }
      await manager.getOrGenerateSummary(e, forceRefresh: true);
      ref.invalidate(eventReviewSummaryProvider(e));
    }

    if (mounted) {
      setState(() {
        _isBatchProcessing = false;
        _batchStatusMessage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully regenerated daily summaries for all ${events.length} events!',
            style: AppTypography.caption12(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _clearAllCaches() async {
    final cacheService = ref.read(reviewSummaryCacheServiceProvider);
    await cacheService.clearAll();
    ref.invalidate(allEventsProvider);

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cleared all daily AI review summary caches from Hive.',
            style: AppTypography.caption12(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
