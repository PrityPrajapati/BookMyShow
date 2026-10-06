import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/theme/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/notifications/data/services/notification_service.dart';
import 'package:showscape/features/notifications/domain/models/app_notification.dart';
import 'package:showscape/features/notifications/presentation/providers/notification_providers.dart';

/// Bottom sheet allowing users to customize showtime reminders and smart leave-now notifications
class NotificationPreferencesSheet extends ConsumerWidget {
  const NotificationPreferencesSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.vertical16,

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notification Preferences',
                      style: AppTypography.heading18().copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Manage reminder intervals and smart transit alerts',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vertical20,

          // Showtime Reminders Section
          Text(
            'SHOWTIME REMINDERS',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vertical8,

          _SwitchTile(
            title: '24 Hours Before Showtime',
            subtitle: 'Day-before prep, ticket verification & venue details',
            value: prefs.remind24h,
            onChanged: notifier.toggle24h,
          ),
          _SwitchTile(
            title: '3 Hours Before Showtime',
            subtitle: 'F&B pre-order reminder to skip the snack queue',
            value: prefs.remind3h,
            onChanged: notifier.toggle3h,
          ),
          _SwitchTile(
            title: '45 Minutes Before Showtime',
            subtitle: 'Door-opening alert & immediate QR entry pass',
            value: prefs.remind45m,
            onChanged: notifier.toggle45m,
          ),

          AppSpacing.vertical16,
          // Smart Transit Section
          Text(
            'SMART TRANSIT & COMMUTE',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.vertical8,

          _SwitchTile(
            title: 'Smart Leave-Now Reminder',
            subtitle:
                'Calculates live commute time from your location + 15 min buffer (Distance Matrix or straight-line 20 km/h)',
            value: prefs.smartLeaveNow,
            onChanged: notifier.toggleSmartLeaveNow,
            highlightColor: Colors.amber.shade700,
          ),

          AppSpacing.vertical16,
          // Test Notification Trigger
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.5),
              borderRadius: AppRadius.border12,
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Simulate a booking reminder with action buttons:',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final testNotif = AppNotification(
                      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
                      title: 'Show in 45m: Interstellar IMAX 🎬',
                      body: 'Tap an action below to test instant deep linking to ticket, directions, or food.',
                      category: NotificationCategory.reminder,
                      timestamp: DateTime.now(),
                      bookingId: 'bkg_demo_1',
                      deepLink: '/ticket/bkg_001',
                      actions: const [
                        NotificationActionItem(
                          actionId: NotificationActions.showTicket,
                          title: 'Show ticket',
                          deepLink: '/ticket/bkg_001',
                        ),
                        NotificationActionItem(
                          actionId: NotificationActions.directions,
                          title: 'Directions',
                          deepLink: '/venue-map/venue_pvr_palladium',
                        ),
                        NotificationActionItem(
                          actionId: NotificationActions.orderFood,
                          title: 'Order food',
                          deepLink: '/food/draft_demo',
                        ),
                      ],
                    );
                    ref.read(notificationsHistoryProvider.notifier).addNotification(testNotif);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulated reminder added to Notification Centre!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Test Alert'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? highlightColor;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: AppRadius.border12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: highlightColor ?? AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
