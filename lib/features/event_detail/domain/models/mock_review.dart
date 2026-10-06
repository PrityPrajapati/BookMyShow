import 'package:flutter/foundation.dart';

@immutable
class MockReview {
  final String id;
  final String eventId;
  final String authorName;
  final String? authorAvatar;
  final double rating; // 1.0 - 10.0 scale
  final String text;
  final DateTime createdAt;
  final List<String> tags;

  const MockReview({
    required this.id,
    required this.eventId,
    required this.authorName,
    this.authorAvatar,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'rating': rating,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'tags': tags,
      };

  factory MockReview.fromJson(Map<String, dynamic> json) => MockReview(
        id: json['id'] as String? ?? '',
        eventId: json['eventId'] as String? ?? '',
        authorName: json['authorName'] as String? ?? 'Verified Moviegoer',
        authorAvatar: json['authorAvatar'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 8.0,
        text: json['text'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        tags: ((json['tags'] as List<dynamic>?) ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}
