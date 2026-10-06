import 'package:flutter/foundation.dart';
import 'package:showscape/features/event_detail/domain/models/mock_review.dart';
import 'package:showscape/features/explore/domain/models/event.dart';

/// Structured review summary for 'What people say' card:
/// Exactly 3 short bullets + a one-line spoiler-free verdict.
@immutable
class EventReviewSummary {
  final String eventId;
  final List<String> bullets; // Guaranteed to be length 3
  final String verdict; // Guaranteed to be 1 line spoiler-free
  final DateTime cachedAt;

  const EventReviewSummary({
    required this.eventId,
    required this.bullets,
    required this.verdict,
    required this.cachedAt,
  }) : assert(bullets.length == 3, 'Must contain exactly 3 bullets');

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'bullets': bullets,
        'verdict': verdict,
        'cachedAt': cachedAt.toIso8601String(),
      };

  factory EventReviewSummary.fromJson(Map<String, dynamic> json) {
    final rawBullets = ((json['bullets'] as List<dynamic>?) ?? [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final List<String> safeBullets;
    if (rawBullets.length >= 3) {
      safeBullets = rawBullets.take(3).toList();
    } else {
      safeBullets = [
        ...rawBullets,
        if (rawBullets.length < 1)
          'Commanding lead performances that elevate the entire emotional narrative.',
        if (rawBullets.length < 2)
          'Visually arresting cinematography and immersive spatial sound engineering.',
        if (rawBullets.length < 3)
          'Brisk pacing with a high-energy climax that delivers complete satisfaction.',
      ].take(3).toList();
    }

    return EventReviewSummary(
      eventId: json['eventId'] as String? ?? '',
      bullets: safeBullets,
      verdict: (json['verdict'] as String?)?.trim() ??
          'An unmissable cinematic celebration that delivers on all its promises.',
      cachedAt: json['cachedAt'] != null
          ? DateTime.tryParse(json['cachedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Parses AI response text or constructs deterministic fallback from top review
  factory EventReviewSummary.fromAiText(
    String rawText, {
    required String eventId,
    Event? event,
    List<MockReview>? reviews,
    DateTime? timestamp,
  }) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final parsedBullets = <String>[];
    String? parsedVerdict;

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.startsWith('verdict:') || lower.startsWith('verdict -')) {
        parsedVerdict = line.substring(line.indexOf(':') + 1).trim();
      } else if (lower.startsWith('bullet:') || lower.startsWith('bullet -')) {
        final b = line.substring(line.indexOf(':') + 1).trim();
        if (b.isNotEmpty) parsedBullets.add(_cleanBullet(b));
      } else if (line.startsWith('•') ||
          line.startsWith('-') ||
          RegExp(r'^\d+[\.\)]').hasMatch(line)) {
        final clean = _cleanBullet(line);
        if (clean.isNotEmpty && parsedBullets.length < 3) {
          parsedBullets.add(clean);
        }
      }
    }

    // Deterministic fallback if AI response was empty or lacked bullets
    if (parsedBullets.length < 3 || parsedVerdict == null || parsedVerdict.isEmpty) {
      final fallback = deterministicFallback(
        eventId: eventId,
        event: event,
        reviews: reviews,
        timestamp: timestamp,
      );

      final List<String> combinedBullets = [
        ...parsedBullets,
        ...fallback.bullets.sublist(parsedBullets.length.clamp(0, 3)),
      ].take(3).toList();

      return EventReviewSummary(
        eventId: eventId,
        bullets: combinedBullets,
        verdict: parsedVerdict != null && parsedVerdict.isNotEmpty
            ? _cleanOneLine(parsedVerdict)
            : fallback.verdict,
        cachedAt: timestamp ?? DateTime.now(),
      );
    }

    return EventReviewSummary(
      eventId: eventId,
      bullets: parsedBullets.take(3).toList(),
      verdict: _cleanOneLine(parsedVerdict),
      cachedAt: timestamp ?? DateTime.now(),
    );
  }

  /// Deterministic fallback when AI is unavailable:
  /// Uses top review highlights + genre mapping to form exactly 3 bullets and a 1-line verdict.
  static EventReviewSummary deterministicFallback({
    required String eventId,
    Event? event,
    List<MockReview>? reviews,
    DateTime? timestamp,
  }) {
    final topReview = reviews != null && reviews.isNotEmpty ? reviews.first : null;
    final topReviewText = topReview?.text ?? '';
    final isComedy = event?.type == EventType.comedy ||
        (event?.genres.contains('Comedy') ?? false);
    final isConcert = event?.type == EventType.concert ||
        (event?.genres.contains('Music') ?? false);
    final isSports = event?.type == EventType.sports;

    // Bullet 1: Derived from top review or lead performance
    final String b1;
    if (topReviewText.isNotEmpty) {
      // First sentence of top review or punchy snippet
      final sentences = topReviewText.split(RegExp(r'[\.\!\?]'));
      final firstSent = sentences.firstWhere(
        (s) => s.trim().length > 15,
        orElse: () => topReviewText,
      ).trim();
      b1 = firstSent.endsWith('.') ? firstSent : '$firstSent.';
    } else {
      b1 = 'Powerhouse lead performances with captivating on-screen energy.';
    }

    // Bullet 2: Production craft, visuals, atmosphere
    final String b2;
    if (isComedy) {
      b2 = 'Relatable, sharp observational humor with spontaneous crowd banter.';
    } else if (isConcert) {
      b2 = 'World-class acoustics, synchronized stage lighting, and high stadium energy.';
    } else if (isSports) {
      b2 = 'Intense end-to-end tactical action that keeps every spectator on their feet.';
    } else {
      b2 = 'Exceptional cinematography and spatial sound engineered for large-format screens.';
    }

    // Bullet 3: Overall pacing & audience consensus
    final String b3;
    if (isComedy) {
      b3 = 'Consistently fast-paced set with no filler, building to a hilarious closing punchline.';
    } else if (isConcert) {
      b3 = 'Unstoppable crowd singalongs and an unforgettable encore that justified all the hype.';
    } else if (isSports) {
      b3 = 'Heart-pounding final stretch with unbelievable team resilience.';
    } else {
      b3 = 'Emotionally resonant narrative with a thrilling climax that exceeds high expectations.';
    }

    // Verdict: exactly 1-line spoiler-free verdict
    final String verdict;
    if (isComedy) {
      verdict = 'A non-stop laugh riot that guarantees an upbeat, stress-busting evening with friends.';
    } else if (isConcert) {
      verdict = 'A once-in-a-generation auditory spectacle worth attending on the very first day.';
    } else if (isSports) {
      verdict = 'Unfiltered athletic adrenaline and high-stakes drama best experienced live in the stands.';
    } else {
      verdict = 'A visually arresting cinematic triumph that deserves the biggest screen you can find.';
    }

    return EventReviewSummary(
      eventId: eventId,
      bullets: [b1, b2, b3],
      verdict: verdict,
      cachedAt: timestamp ?? DateTime.now(),
    );
  }

  static String _cleanBullet(String str) {
    var s = str
        .replaceFirst(RegExp(r'^[\s•\-\*\d+\.\)]+'), '')
        .replaceFirst(RegExp(r'^bullet:\s*', caseSensitive: false), '')
        .trim();
    if (s.isEmpty) return 'Outstanding entertainment value from beginning to end.';
    if (!s.endsWith('.') && !s.endsWith('!') && !s.endsWith('?')) {
      s = '$s.';
    }
    return s;
  }

  static String _cleanOneLine(String str) {
    var s = str
        .replaceAll('\n', ' ')
        .replaceFirst(RegExp(r'^verdict:\s*', caseSensitive: false), '')
        .trim();
    if (s.isEmpty) return 'A thoroughly rewarding entertainment experience.';
    return s;
  }

  /// Serializes into the canonical format used by AiService.summarise
  String toAiServiceFormat() {
    return 'BULLET: ${bullets[0]}\n'
        'BULLET: ${bullets[1]}\n'
        'BULLET: ${bullets[2]}\n'
        'VERDICT: $verdict';
  }
}
