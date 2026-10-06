import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:showscape/features/checkout/domain/models/price_breakdown.dart';
import 'package:showscape/features/notifications/data/services/notification_service.dart';
import 'package:showscape/features/notifications/domain/models/app_notification.dart';
import 'package:showscape/features/notifications/domain/models/notification_preferences.dart';
import 'package:showscape/features/notifications/domain/services/smart_transit_service.dart';
import 'package:showscape/features/notifications/presentation/screens/notifications_centre_screen.dart';
import 'package:showscape/features/profile/presentation/screens/profile_screen.dart';
import 'package:showscape/features/tickets/domain/models/booking.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    final kolkata = tz.getLocation('Asia/Kolkata');
    tz.setLocalLocation(kolkata);
  });

  group('SmartTransitService & Commute Calculation Tests', () {
    late SmartTransitService transitService;

    setUp(() {
      transitService = SmartTransitService();
    });

    test('Haversine distance calculation is accurate within geographic bounds', () {
      // Mumbai CST (18.9401, 72.8354) to BKC (19.0657, 72.8684) ~ 14.5 km straight-line
      final distanceKm = transitService.calculateHaversineDistanceKm(
        startLat: 18.9401,
        startLng: 72.8354,
        endLat: 19.0657,
        endLng: 72.8684,
      );

      expect(distanceKm, greaterThan(13.0));
      expect(distanceKm, lessThan(16.0));
    });

    test('Fallback travel time uses straight-line distance / 20 km/h correctly', () {
      // 10 km at 20 km/h = 0.5 hours = 30 minutes
      final minutes = transitService.calculateFallbackTravelTimeMinutes(10.0);
      expect(minutes, closeTo(30.0, 0.01));

      // 20 km at 20 km/h = 1.0 hour = 60 minutes
      final minutes20 = transitService.calculateFallbackTravelTimeMinutes(20.0);
      expect(minutes20, closeTo(60.0, 0.01));
    });

    test('Smart Leave-Now calculation subtracts travel time and 15 min buffer from showtime', () {
      final showTime = DateTime(2026, 10, 15, 20, 0); // 8:00 PM
      const travelTimeMinutes = 45.0; // 45 min commute

      // Expected: 8:00 PM - 45 min travel - 15 min buffer = 7:00 PM
      final leaveNowTime = transitService.calculateLeaveNowTime(
        showTime: showTime,
        travelTimeMinutes: travelTimeMinutes,
        bufferMinutes: 15,
      );

      expect(leaveNowTime.year, 2026);
      expect(leaveNowTime.month, 10);
      expect(leaveNowTime.day, 15);
      expect(leaveNowTime.hour, 19);
      expect(leaveNowTime.minute, 0);
    });

    test('estimateTravelTime falls back seamlessly to straight-line when API key is omitted', () async {
      final estimate = await transitService.estimateTravelTime(
        userLat: 19.0760,
        userLng: 72.8777,
        venueLat: 19.0657,
        venueLng: 72.8684,
      );

      expect(estimate.isFromApi, isFalse);
      expect(estimate.distanceKm, greaterThan(0.5));
      expect(estimate.durationMinutes, greaterThan(1.0));
      expect(estimate.description, contains('20 km/h'));
    });
  });

  group('NotificationPreferences Tests', () {
    test('Default values have all reminders enabled', () {
      const prefs = NotificationPreferences();
      expect(prefs.remind24h, isTrue);
      expect(prefs.remind3h, isTrue);
      expect(prefs.remind45m, isTrue);
      expect(prefs.smartLeaveNow, isTrue);
      expect(prefs.fcmPromotions, isTrue);
    });

    test('copyWith and JSON serialization preserve custom toggles', () {
      const prefs = NotificationPreferences();
      final customized = prefs.copyWith(
        remind24h: false,
        remind45m: false,
        smartLeaveNow: true,
      );

      expect(customized.remind24h, isFalse);
      expect(customized.remind3h, isTrue);
      expect(customized.remind45m, isFalse);

      final json = customized.toJson();
      final restored = NotificationPreferences.fromJson(json);

      expect(restored.remind24h, isFalse);
      expect(restored.remind3h, isTrue);
      expect(restored.remind45m, isFalse);
      expect(restored.smartLeaveNow, isTrue);
    });
  });

  group('NotificationService Scheduling & History Tests', () {
    late NotificationService notificationService;
    late Booking testBooking;

    setUp(() {
      notificationService = NotificationService();
      // Future showtime in 30 hours to allow all 24h, 3h, 45m & leave-now to trigger
      final futureShowTime = DateTime.now().add(const Duration(hours: 30));

      testBooking = Booking(
        id: 'bkg_unit_test_1',
        bookingNumber: 'SS-99999',
        userId: 'usr_001',
        eventId: 'evt_dune_2',
        eventTitle: 'Dune: Part Two',
        venueId: 'venue_pvr_palladium',
        venueName: 'PVR INOX Phoenix Palladium',
        showId: 'shw_101',
        showTime: futureShowTime,
        bookingTime: DateTime.now(),
        priceBreakdown: const PriceBreakdown(
          basePrice: 450,
          convenienceFee: 45,
          gst: 8.1,
          grandTotal: 503.1,
        ),
        qrCodeData: 'DUNE-TEST-QR',
      );
    });

    test('scheduleBookingReminders logs all 4 reminders when preferences are all enabled', () async {
      const prefs = NotificationPreferences(
        remind24h: true,
        remind3h: true,
        remind45m: true,
        smartLeaveNow: true,
      );

      await notificationService.scheduleBookingReminders(
        booking: testBooking,
        preferences: prefs,
        userLat: 19.0760,
        userLng: 72.8777,
        venueLat: 19.0657,
        venueLng: 72.8684,
      );

      final log = notificationService.currentNotificationsLog;
      expect(log.length, 4);

      // Verify actions exist on reminders: 'Show ticket', 'Directions', 'Order food'
      final reminder = log.first;
      expect(reminder.actions.length, 3);
      expect(
        reminder.actions.any((a) => a.actionId == NotificationActions.showTicket),
        isTrue,
      );
      expect(
        reminder.actions.any((a) => a.actionId == NotificationActions.directions),
        isTrue,
      );
      expect(
        reminder.actions.any((a) => a.actionId == NotificationActions.orderFood),
        isTrue,
      );

      // Verify deep-links point to ticket, venue-map, and food
      final showTicketAction = reminder.actions
          .firstWhere((a) => a.actionId == NotificationActions.showTicket);
      expect(showTicketAction.deepLink, '/ticket/bkg_unit_test_1');

      final directionsAction = reminder.actions
          .firstWhere((a) => a.actionId == NotificationActions.directions);
      expect(directionsAction.deepLink, '/venue-map/venue_pvr_palladium');
    });

    test('scheduleBookingReminders respects user preference toggles', () async {
      const prefs = NotificationPreferences(
        remind24h: false,
        remind3h: false,
        remind45m: true,
        smartLeaveNow: false,
      );

      await notificationService.scheduleBookingReminders(
        booking: testBooking,
        preferences: prefs,
      );

      final log = notificationService.currentNotificationsLog;
      // Only 45m reminder should be scheduled
      expect(log.length, 1);
      expect(log.first.id, 'reminder_45m_${testBooking.id}');
    });

    test('Notification history allows markAsRead, markAllAsRead, and clear', () {
      final notif1 = AppNotification(
        id: 'n1',
        title: 'Title 1',
        body: 'Body 1',
        category: NotificationCategory.reminder,
        timestamp: DateTime.now(),
        isRead: false,
      );
      final notif2 = AppNotification(
        id: 'n2',
        title: 'Title 2',
        body: 'Body 2',
        category: NotificationCategory.smartTransit,
        timestamp: DateTime.now(),
        isRead: false,
      );

      notificationService.recordNotification(notif1);
      notificationService.recordNotification(notif2);

      expect(notificationService.currentNotificationsLog.length, 2);
      expect(notificationService.currentNotificationsLog[0].isRead, isFalse);

      notificationService.markAsRead('n1');
      expect(
        notificationService.currentNotificationsLog.firstWhere((n) => n.id == 'n1').isRead,
        isTrue,
      );

      notificationService.markAllAsRead();
      expect(
        notificationService.currentNotificationsLog.every((n) => n.isRead),
        isTrue,
      );

      notificationService.clearHistory();
      expect(notificationService.currentNotificationsLog, isEmpty);
    });
  });

  group('NotificationsCentreScreen UI Tests', () {
    testWidgets('Renders Notification Centre title, filter chips, and notifications list',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationsCentreScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notification Centre'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Reminders'), findsOneWidget);
      expect(find.text('Smart Transit'), findsOneWidget);
      expect(find.text('System & Promos'), findsOneWidget);

      // Verify Action Chips exist
      expect(find.text('Show ticket'), findsWidgets);
      expect(find.text('Directions'), findsWidgets);

      // Verify bottom settings banner
      expect(find.textContaining('Reminder Alerts: 24h, 3h, 45m & Transit'), findsOneWidget);
    });

    testWidgets('Tapping Reminder Settings opens NotificationPreferencesSheet',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationsCentreScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the settings icon in AppBar
      final settingsIcon = find.byTooltip('Reminder Settings');
      expect(settingsIcon, findsOneWidget);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      expect(find.text('Notification Preferences'), findsOneWidget);
      expect(find.text('24 Hours Before Showtime'), findsOneWidget);
      expect(find.text('3 Hours Before Showtime'), findsOneWidget);
      expect(find.text('45 Minutes Before Showtime'), findsOneWidget);
      expect(find.text('Smart Leave-Now Reminder'), findsOneWidget);
    });
  });

  group('ProfileScreen Notification Settings Integration Tests', () {
    testWidgets('ProfileScreen contains booking reminder switches and Notification Centre link',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => Future.value(null)),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Notification Centre'), findsOneWidget);
      expect(find.text('BOOKING REMINDER SETTINGS'), findsOneWidget);
      expect(find.text('24 Hours Before Showtime'), findsOneWidget);
      expect(find.text('3 Hours Before Showtime'), findsOneWidget);
      expect(find.text('45 Minutes Before Showtime'), findsOneWidget);
      expect(find.text('Smart Leave-Now Reminder'), findsOneWidget);

      // Toggle 24h reminder switch
      final switches = find.byType(Switch);
      expect(switches, findsAtLeastNWidgets(4));

      await tester.tap(switches.first);
      await tester.pumpAndSettle();
    });
  });
}
