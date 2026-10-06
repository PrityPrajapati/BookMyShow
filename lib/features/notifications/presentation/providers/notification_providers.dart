import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/features/notifications/data/services/notification_service.dart';
import 'package:showscape/features/notifications/domain/models/app_notification.dart';
import 'package:showscape/features/notifications/domain/models/notification_preferences.dart';
import 'package:showscape/features/notifications/domain/services/smart_transit_service.dart';

/// Provider for SmartTransitService
final smartTransitServiceProvider = Provider<SmartTransitService>((ref) {
  return SmartTransitService();
});

/// Global singleton NotificationService provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final transitService = ref.watch(smartTransitServiceProvider);
  final service = NotificationService(smartTransitService: transitService);

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// StateNotifier for managing user notification preferences (24h, 3h, 45m, Smart Leave-Now)
class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(const NotificationPreferences());

  void toggle24h(bool enabled) {
    state = state.copyWith(remind24h: enabled);
  }

  void toggle3h(bool enabled) {
    state = state.copyWith(remind3h: enabled);
  }

  void toggle45m(bool enabled) {
    state = state.copyWith(remind45m: enabled);
  }

  void toggleSmartLeaveNow(bool enabled) {
    state = state.copyWith(smartLeaveNow: enabled);
  }

  void togglePromotions(bool enabled) {
    state = state.copyWith(fcmPromotions: enabled);
  }

  void updateAll(NotificationPreferences newPreferences) {
    state = newPreferences;
  }
}

/// Provider for user notification preferences
final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});

/// Initial demo notifications to populate Notifications Centre for a rich experience
final _demoNotifications = [
  AppNotification(
    id: 'notif_welcome',
    title: 'Welcome to ShowScape VIP! 🎟️',
    body: 'Your intelligent movie & live event companion. Enable notifications for smart departure alerts and fast QR entry.',
    category: NotificationCategory.system,
    timestamp: DateTime.now().subtract(const Duration(hours: 18)),
    isRead: true,
  ),
  AppNotification(
    id: 'notif_transit_demo',
    title: 'Smart Leave-Now: Dune: Part Two 🚗',
    body: 'Heavy traffic on Western Express Highway. Estimated commute: 38 mins. Leave in 5 mins to arrive comfortably.',
    category: NotificationCategory.smartTransit,
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    isRead: false,
    deepLink: '/venue-map/venue_pvr_palladium',
    actions: const [
      NotificationActionItem(
        actionId: NotificationActions.directions,
        title: 'Directions',
        deepLink: '/venue-map/venue_pvr_palladium',
      ),
      NotificationActionItem(
        actionId: NotificationActions.showTicket,
        title: 'Show ticket',
        deepLink: '/ticket/bkg_001',
      ),
    ],
  ),
  AppNotification(
    id: 'notif_reminder_demo',
    title: 'Show Starts in 45 Minutes! ⚡',
    body: 'PVR INOX Phoenix Palladium: Screen 4 doors are now open. Ready your ticket QR code.',
    category: NotificationCategory.reminder,
    timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
    isRead: false,
    deepLink: '/ticket/bkg_001',
    actions: const [
      NotificationActionItem(
        actionId: NotificationActions.showTicket,
        title: 'Show ticket',
        deepLink: '/ticket/bkg_001',
      ),
      NotificationActionItem(
        actionId: NotificationActions.orderFood,
        title: 'Order food',
        deepLink: '/food/draft_demo',
      ),
    ],
  ),
];

/// StateNotifier managing the notifications history in Notifications Centre
class NotificationsHistoryNotifier extends StateNotifier<List<AppNotification>> {
  final NotificationService _service;

  NotificationsHistoryNotifier(this._service) : super(_demoNotifications) {
    // Listen to real notifications dispatched by NotificationService
    _service.notificationsLogStream.listen((logs) {
      if (logs.isNotEmpty) {
        final existingIds = state.map((n) => n.id).toSet();
        final newItems = logs.where((n) => !existingIds.contains(n.id)).toList();
        if (newItems.isNotEmpty) {
          state = [...newItems, ...state];
        }
      }
    });
  }

  void addNotification(AppNotification notification) {
    state = [
      notification,
      ...state.where((n) => n.id != notification.id),
    ];
    _service.recordNotification(notification);
  }

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _service.markAsRead(id);
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
    _service.markAllAsRead();
  }

  void clearAll() {
    state = [];
    _service.clearHistory();
  }

  void removeNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

/// Provider for notification history list
final notificationsHistoryProvider = StateNotifierProvider<
    NotificationsHistoryNotifier, List<AppNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationsHistoryNotifier(service);
});

/// Provider for count of unread notifications (used in badges)
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsHistoryProvider);
  return list.where((n) => !n.isRead).length;
});
