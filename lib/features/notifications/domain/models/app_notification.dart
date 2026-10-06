import 'dart:convert';

/// Category for grouping and filtering notifications in the Notification Centre
enum NotificationCategory {
  reminder,
  smartTransit,
  ticketTransfer,
  promotion,
  system,
}

/// Action item displayed on a notification or in the notification detail
class NotificationActionItem {
  final String actionId;
  final String title;
  final String deepLink;

  const NotificationActionItem({
    required this.actionId,
    required this.title,
    required this.deepLink,
  });

  Map<String, dynamic> toMap() => {
        'actionId': actionId,
        'title': title,
        'deepLink': deepLink,
      };

  factory NotificationActionItem.fromMap(Map<String, dynamic> map) =>
      NotificationActionItem(
        actionId: map['actionId'] as String,
        title: map['title'] as String,
        deepLink: map['deepLink'] as String,
      );
}

/// In-app notification record displayed in the Notifications Centre
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final DateTime timestamp;
  final String? deepLink;
  final bool isRead;
  final String? bookingId;
  final List<NotificationActionItem> actions;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timestamp,
    this.deepLink,
    this.isRead = false,
    this.bookingId,
    this.actions = const [],
    this.metadata,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationCategory? category,
    DateTime? timestamp,
    String? deepLink,
    bool? isRead,
    String? bookingId,
    List<NotificationActionItem>? actions,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      deepLink: deepLink ?? this.deepLink,
      isRead: isRead ?? this.isRead,
      bookingId: bookingId ?? this.bookingId,
      actions: actions ?? this.actions,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category.name,
        'timestamp': timestamp.toIso8601String(),
        'deepLink': deepLink,
        'isRead': isRead,
        'bookingId': bookingId,
        'actions': actions.map((a) => a.toMap()).toList(),
        'metadata': metadata,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        category: NotificationCategory.values.firstWhere(
          (c) => c.name == map['category'],
          orElse: () => NotificationCategory.system,
        ),
        timestamp: DateTime.parse(map['timestamp'] as String),
        deepLink: map['deepLink'] as String?,
        isRead: map['isRead'] as bool? ?? false,
        bookingId: map['bookingId'] as String?,
        actions: (map['actions'] as List<dynamic>?)
                ?.map((a) => NotificationActionItem.fromMap(a as Map<String, dynamic>))
                .toList() ??
            const [],
        metadata: map['metadata'] as Map<String, dynamic>?,
      );

  String toJson() => jsonEncode(toMap());

  factory AppNotification.fromJson(String source) =>
      AppNotification.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
