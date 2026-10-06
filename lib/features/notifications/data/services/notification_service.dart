import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:showscape/features/notifications/domain/models/app_notification.dart';
import 'package:showscape/features/notifications/domain/models/notification_preferences.dart';
import 'package:showscape/features/notifications/domain/services/smart_transit_service.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Action identifiers for interactive notification buttons
abstract final class NotificationActions {
  static const String showTicket = 'ACTION_SHOW_TICKET';
  static const String directions = 'ACTION_DIRECTIONS';
  static const String orderFood = 'ACTION_ORDER_FOOD';
}

/// Central notification service managing local notifications, timezone scheduling,
/// action buttons, deep-linking, smart transit alerts, and FCM messaging.
class NotificationService {
  final FlutterLocalNotificationsPlugin _localNotifications;
  final SmartTransitService _smartTransitService;
  final void Function(String deepLink)? _onDeepLink;

  bool _isInitialized = false;
  tz.Location? _kolkataLocation;

  // Stream controller to broadcast received / tapped notifications to UI
  final _notificationActionStreamController =
      StreamController<String>.broadcast();
  Stream<String> get onDeepLinkStream =>
      _notificationActionStreamController.stream;

  // In-memory list of dispatched and logged notifications for Notification Centre
  final List<AppNotification> _notificationsLog = [];
  final _notificationsLogController =
      StreamController<List<AppNotification>>.broadcast();
  Stream<List<AppNotification>> get notificationsLogStream =>
      _notificationsLogController.stream;
  List<AppNotification> get currentNotificationsLog =>
      List.unmodifiable(_notificationsLog);

  NotificationService({
    FlutterLocalNotificationsPlugin? localNotifications,
    SmartTransitService? smartTransitService,
    void Function(String deepLink)? onDeepLink,
  })  : _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _smartTransitService = smartTransitService ?? SmartTransitService(),
        _onDeepLink = onDeepLink;

  /// Initialize Timezones (Asia/Kolkata), Local Notifications channels, actions, and FCM
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize Asia/Kolkata Timezone
    try {
      tz.initializeTimeZones();
      _kolkataLocation = tz.getLocation('Asia/Kolkata');
      tz.setLocalLocation(_kolkataLocation!);
    } catch (e) {
      debugPrint('Timezone initialization notice: $e');
    }

    // 2. Initialize Local Notifications Plugin
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'BOOKING_REMINDER_CATEGORY',
            actions: [
              DarwinNotificationAction.plain(
                NotificationActions.showTicket,
                'Show ticket',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                NotificationActions.directions,
                'Directions',
                options: {DarwinNotificationActionOption.foreground},
              ),
              DarwinNotificationAction.plain(
                NotificationActions.orderFood,
                'Order food',
                options: {DarwinNotificationActionOption.foreground},
              ),
            ],
            options: {DarwinNotificationCategoryOption.customDismissAction},
          ),
        ],
      );

      final initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Create Android Notification Channel
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation = _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          await androidImplementation.createNotificationChannel(
            const AndroidNotificationChannel(
              'showscape_reminders_channel',
              'ShowScape Reminders & Transit',
              description:
                  'Timely reminders for upcoming shows, tickets, directions, and smart leave-now transit alerts.',
              importance: Importance.max,
              enableVibration: true,
              playSound: true,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Local notifications init exception (headless or web): $e');
    }

    // 3. Initialize Firebase Messaging
    await _initFirebaseMessaging();

    _isInitialized = true;
  }

  /// Request iOS / Android 13+ Notification permissions
  Future<bool> requestPermissions() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidImpl = _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await androidImpl?.requestNotificationsPermission() ?? false;
        return granted;
      } else if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        final iosImpl = _localNotifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImpl?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
        return granted;
      }
    } catch (e) {
      debugPrint('Request permissions notice: $e');
    }
    return true;
  }

  /// Setup Firebase Messaging listeners safely
  Future<void> _initFirebaseMessaging() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        final messaging = FirebaseMessaging.instance;
        await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final title = message.notification?.title ?? 'ShowScape Alert';
          final body = message.notification?.body ?? '';
          final deepLink = message.data['deepLink'] as String?;

          recordNotification(
            AppNotification(
              id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
              title: title,
              body: body,
              category: NotificationCategory.promotion,
              timestamp: DateTime.now(),
              deepLink: deepLink,
            ),
          );
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          final deepLink = message.data['deepLink'] as String?;
          if (deepLink != null) {
            handleDeepLink(deepLink);
          }
        });
      }
    } catch (e) {
      debugPrint('Firebase messaging notice (mock or test environment): $e');
    }
  }

  /// Handle interaction with notification action or tap
  void _handleNotificationResponse(NotificationResponse response) {
    final payloadString = response.payload;
    if (payloadString == null || payloadString.isEmpty) return;

    try {
      final payload = jsonDecode(payloadString) as Map<String, dynamic>;
      final actionId = response.actionId;

      String? targetRoute;
      if (actionId == NotificationActions.showTicket) {
        targetRoute = payload['ticketRoute'] as String?;
      } else if (actionId == NotificationActions.directions) {
        targetRoute = payload['directionsRoute'] as String?;
      } else if (actionId == NotificationActions.orderFood) {
        targetRoute = payload['foodRoute'] as String?;
      } else {
        targetRoute = payload['defaultRoute'] as String?;
      }

      if (targetRoute != null && targetRoute.isNotEmpty) {
        handleDeepLink(targetRoute);
      }
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }

  /// Trigger deep link navigation
  void handleDeepLink(String deepLink) {
    _notificationActionStreamController.add(deepLink);
    _onDeepLink?.call(deepLink);
  }

  /// Schedules all reminders for a confirmed booking:
  /// - 24 hours before showtime (if enabled)
  /// - 3 hours before showtime (if enabled)
  /// - 45 minutes before showtime (if enabled)
  /// - Smart 'Leave-Now' reminder (if enabled)
  Future<void> scheduleBookingReminders({
    required Booking booking,
    required NotificationPreferences preferences,
    double? userLat,
    double? userLng,
    double? venueLat,
    double? venueLng,
  }) async {
    final showTime = booking.showTime;
    final now = DateTime.now();

    final ticketRoute = '/ticket/${booking.id}';
    final directionsRoute = '/venue-map/${booking.venueId}';
    final foodRoute = '/food/${booking.id}';

    final payloadMap = {
      'bookingId': booking.id,
      'defaultRoute': ticketRoute,
      'ticketRoute': ticketRoute,
      'directionsRoute': directionsRoute,
      'foodRoute': foodRoute,
    };
    final payloadJson = jsonEncode(payloadMap);

    final eventTitle = booking.eventTitle ?? 'Upcoming Show';
    final venueName = booking.venueName ?? 'Cinema';

    final notificationActions = [
      NotificationActionItem(
        actionId: NotificationActions.showTicket,
        title: 'Show ticket',
        deepLink: ticketRoute,
      ),
      NotificationActionItem(
        actionId: NotificationActions.directions,
        title: 'Directions',
        deepLink: directionsRoute,
      ),
      NotificationActionItem(
        actionId: NotificationActions.orderFood,
        title: 'Order food',
        deepLink: foodRoute,
      ),
    ];

    // Notification Base ID formula (keeps unique ID per trigger per booking)
    final baseId = booking.id.hashCode.abs() % 100000;

    // 1. Reminder at 24 hours before showtime
    if (preferences.remind24h) {
      final trigger24h = showTime.subtract(const Duration(hours: 24));
      if (trigger24h.isAfter(now)) {
        await _scheduleSingleNotification(
          id: baseId * 10 + 1,
          title: '24 Hours to Showtime! 🎟️',
          body: 'Get ready for $eventTitle at $venueName tomorrow. Tap to view tickets or get directions.',
          scheduledDate: trigger24h,
          payload: payloadJson,
        );

        recordNotification(
          AppNotification(
            id: 'reminder_24h_${booking.id}',
            title: 'Tomorrow: $eventTitle 🎬',
            body: 'Showtime is in 24 hours at $venueName. Prepare your tickets & directions.',
            category: NotificationCategory.reminder,
            timestamp: trigger24h,
            bookingId: booking.id,
            deepLink: ticketRoute,
            actions: notificationActions,
          ),
        );
      }
    }

    // 2. Reminder at 3 hours before showtime
    if (preferences.remind3h) {
      final trigger3h = showTime.subtract(const Duration(hours: 3));
      if (trigger3h.isAfter(now)) {
        await _scheduleSingleNotification(
          id: baseId * 10 + 2,
          title: '3 Hours Remaining! 🍿',
          body: '$eventTitle starts in 3 hours at $venueName. Pre-order your snacks to skip the line!',
          scheduledDate: trigger3h,
          payload: payloadJson,
        );

        recordNotification(
          AppNotification(
            id: 'reminder_3h_${booking.id}',
            title: '3 Hours to Go: $eventTitle 🍿',
            body: 'Beat the rush! Pre-order your popcorn & snacks now for $venueName.',
            category: NotificationCategory.reminder,
            timestamp: trigger3h,
            bookingId: booking.id,
            deepLink: foodRoute,
            actions: notificationActions,
          ),
        );
      }
    }

    // 3. Reminder at 45 minutes before showtime
    if (preferences.remind45m) {
      final trigger45m = showTime.subtract(const Duration(minutes: 45));
      if (trigger45m.isAfter(now)) {
        await _scheduleSingleNotification(
          id: baseId * 10 + 3,
          title: 'Show Starts in 45 Minutes! ⚡',
          body: 'Doors are opening at $venueName for $eventTitle. Have your ticket pass ready.',
          scheduledDate: trigger45m,
          payload: payloadJson,
        );

        recordNotification(
          AppNotification(
            id: 'reminder_45m_${booking.id}',
            title: 'Starting Soon: $eventTitle (45m)',
            body: 'Doors are open at $venueName. Tap "Show ticket" for rapid QR entry.',
            category: NotificationCategory.reminder,
            timestamp: trigger45m,
            bookingId: booking.id,
            deepLink: ticketRoute,
            actions: notificationActions,
          ),
        );
      }
    }

    // 4. Smart 'Leave-Now' Reminder
    if (preferences.smartLeaveNow) {
      // Default to Mumbai BKC / South Mumbai coordinates if not passed
      final effectiveUserLat = userLat ?? 19.0760;
      final effectiveUserLng = userLng ?? 72.8777;
      final effectiveVenueLat = venueLat ?? 19.0657;
      final effectiveVenueLng = venueLng ?? 72.8684;

      final travelEstimate = await _smartTransitService.estimateTravelTime(
        userLat: effectiveUserLat,
        userLng: effectiveUserLng,
        venueLat: effectiveVenueLat,
        venueLng: effectiveVenueLng,
      );

      final leaveNowTime = _smartTransitService.calculateLeaveNowTime(
        showTime: showTime,
        travelTimeMinutes: travelEstimate.durationMinutes,
        bufferMinutes: 15,
      );

      if (leaveNowTime.isAfter(now)) {
        final travelMins = travelEstimate.durationMinutes.round();
        await _scheduleSingleNotification(
          id: baseId * 10 + 4,
          title: 'Smart Leave-Now Alert 🚗',
          body:
              'Time to depart! Est. travel to $venueName is $travelMins mins (+ 15 min buffer). Tap for directions.',
          scheduledDate: leaveNowTime,
          payload: payloadJson,
        );

        recordNotification(
          AppNotification(
            id: 'leave_now_${booking.id}',
            title: 'Smart Leave-Now: $eventTitle 🚗',
            body:
                'Estimated commute: $travelMins mins (${travelEstimate.distanceKm.toStringAsFixed(1)} km). Leave now to arrive 15 mins before showtime!',
            category: NotificationCategory.smartTransit,
            timestamp: leaveNowTime,
            bookingId: booking.id,
            deepLink: directionsRoute,
            actions: notificationActions,
            metadata: {
              'travelMinutes': travelMins,
              'distanceKm': travelEstimate.distanceKm,
              'isFromApi': travelEstimate.isFromApi,
            },
          ),
        );
      }
    }
  }

  /// Schedule a single notification with Asia/Kolkata timezone and action buttons
  Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    try {
      final kolkata = _kolkataLocation ?? tz.getLocation('Asia/Kolkata');
      final tzDateTime = tz.TZDateTime.from(scheduledDate, kolkata);

      const androidDetails = AndroidNotificationDetails(
        'showscape_reminders_channel',
        'ShowScape Reminders & Transit',
        channelDescription: 'Timely reminders for upcoming bookings and transit',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            NotificationActions.showTicket,
            'Show ticket',
            showsUserInterface: true,
            cancelNotification: false,
          ),
          AndroidNotificationAction(
            NotificationActions.directions,
            'Directions',
            showsUserInterface: true,
            cancelNotification: false,
          ),
          AndroidNotificationAction(
            NotificationActions.orderFood,
            'Order food',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      );

      const darwinDetails = DarwinNotificationDetails(
        categoryIdentifier: 'BOOKING_REMINDER_CATEGORY',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Local notifications zonedSchedule error (mock/headless): $e');
    }
  }

  /// Reschedule reminders for all upcoming active bookings
  /// (Called on App Start and after Android RECEIVE_BOOT_COMPLETED)
  Future<void> rescheduleAllUpcomingReminders({
    required List<Booking> upcomingBookings,
    required NotificationPreferences preferences,
    double? userLat,
    double? userLng,
  }) async {
    final now = DateTime.now();
    for (final booking in upcomingBookings) {
      if (booking.showTime.isAfter(now)) {
        await scheduleBookingReminders(
          booking: booking,
          preferences: preferences,
          userLat: userLat,
          userLng: userLng,
        );
      }
    }
  }

  /// Cancel all scheduled reminders for a specific booking
  Future<void> cancelBookingReminders(String bookingId) async {
    final baseId = bookingId.hashCode.abs() % 100000;
    try {
      await _localNotifications.cancel(baseId * 10 + 1);
      await _localNotifications.cancel(baseId * 10 + 2);
      await _localNotifications.cancel(baseId * 10 + 3);
      await _localNotifications.cancel(baseId * 10 + 4);
    } catch (e) {
      debugPrint('Cancel notification error: $e');
    }
  }

  /// Cancel all pending notifications
  Future<void> cancelAll() async {
    try {
      await _localNotifications.cancelAll();
    } catch (e) {
      debugPrint('Cancel all notifications error: $e');
    }
  }

  /// Record notification into history log for Notification Centre
  void recordNotification(AppNotification notification) {
    // Avoid duplicate IDs
    _notificationsLog.removeWhere((n) => n.id == notification.id);
    _notificationsLog.insert(0, notification);
    _notificationsLogController.add(List.unmodifiable(_notificationsLog));
  }

  /// Mark notification as read
  void markAsRead(String id) {
    final index = _notificationsLog.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notificationsLog[index] = _notificationsLog[index].copyWith(isRead: true);
      _notificationsLogController.add(List.unmodifiable(_notificationsLog));
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (var i = 0; i < _notificationsLog.length; i++) {
      _notificationsLog[i] = _notificationsLog[i].copyWith(isRead: true);
    }
    _notificationsLogController.add(List.unmodifiable(_notificationsLog));
  }

  /// Clear all notifications from history
  void clearHistory() {
    _notificationsLog.clear();
    _notificationsLogController.add(List.unmodifiable(_notificationsLog));
  }

  /// Schedule demo notification to fire in [delaySeconds] (default 10s)
  Future<void> scheduleDemoReminder({int delaySeconds = 10}) async {
    try {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds));
      const androidDetails = AndroidNotificationDetails(
        'booking_reminders',
        'Booking Reminders',
        channelDescription: 'Time-sensitive showtime and transit reminders',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'Demo Showtime Alert',
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _localNotifications.zonedSchedule(
        9999,
        '🍿 ShowScape Demo: Showtime Alert!',
        'Your show starts in 15 minutes! Audi 1, IMAX Laser. Tap to view your mobile ticket.',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: jsonEncode({'defaultRoute': '/tickets'}),
      );
    } catch (e) {
      debugPrint('Demo notification zonedSchedule error (mock/headless): $e');
    }

    recordNotification(
      AppNotification(
        id: 'demo_notif_${DateTime.now().millisecondsSinceEpoch}',
        title: '🍿 ShowScape Demo: Showtime Alert!',
        body: 'Your show starts in 15 minutes! Audi 1, IMAX Laser. Tap to view your mobile ticket.',
        timestamp: DateTime.now().add(Duration(seconds: delaySeconds)),
        category: NotificationCategory.reminder,
        deepLink: '/tickets',
        isRead: false,
      ),
    );
  }

  void dispose() {
    _notificationActionStreamController.close();
    _notificationsLogController.close();
  }
}
