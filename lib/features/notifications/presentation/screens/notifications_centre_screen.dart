import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/theme/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/notifications/domain/models/app_notification.dart';
import 'package:showscape/features/notifications/presentation/providers/notification_providers.dart';
import 'package:showscape/features/notifications/presentation/widgets/notification_preferences_sheet.dart';

/// Notifications Centre screen displaying past notifications, filter tabs,
/// deep-link action triggers, and quick access to reminder preferences.
class NotificationsCentreScreen extends ConsumerStatefulWidget {
  const NotificationsCentreScreen({super.key});

  @override
  ConsumerState<NotificationsCentreScreen> createState() =>
      _NotificationsCentreScreenState();
}

class _NotificationsCentreScreenState
    extends ConsumerState<NotificationsCentreScreen> {
  NotificationCategory? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsHistoryProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final filteredList = _selectedFilter == null
        ? notifications
        : notifications
            .where((n) => n.category == _selectedFilter)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Text(
              'Notification Centre',
              style: AppTypography.heading20().copyWith(fontWeight: FontWeight.bold),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Reminder Settings',
            icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
            onPressed: () => _openPreferencesSheet(context),
          ),
          if (notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.border12),
              onSelected: (value) {
                if (value == 'mark_read') {
                  ref.read(notificationsHistoryProvider.notifier).markAllAsRead();
                } else if (value == 'clear') {
                  ref.read(notificationsHistoryProvider.notifier).clearAll();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Clear all notifications'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(),

          // Main Notifications List or Empty State
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => AppSpacing.vertical12,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _NotificationCard(
                        notification: item,
                        onTap: () => _onNotificationCardTap(item),
                        onActionTap: (action) => _onActionTap(action),
                        onDismissed: () {
                          ref
                              .read(notificationsHistoryProvider.notifier)
                              .removeNotification(item.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSettingsBanner(context),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'label': 'All', 'category': null},
      {'label': 'Reminders', 'category': NotificationCategory.reminder},
      {'label': 'Smart Transit', 'category': NotificationCategory.smartTransit},
      {'label': 'System & Promos', 'category': NotificationCategory.system},
    ];

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _selectedFilter == f['category'];
            final category = f['category'] as NotificationCategory?;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(f['label'] as String),
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.surfaceVariant,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                  ),
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = category;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSettingsBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceVariant.withOpacity(0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: InkWell(
          borderRadius: AppRadius.border12,
          onTap: () => _openPreferencesSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reminder Alerts: 24h, 3h, 45m & Transit',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Configure showtime alerts & leave-now estimates',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 54,
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vertical20,
            Text(
              "You're all caught up!",
              style: AppTypography.heading18().copyWith(color: AppColors.textPrimary),
            ),
            AppSpacing.vertical8,
            Text(
              'Reminders for your upcoming bookings and smart leave-now transit notifications will appear here.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNotificationCardTap(AppNotification notification) {
    ref.read(notificationsHistoryProvider.notifier).markAsRead(notification.id);
    if (notification.deepLink != null) {
      context.push(notification.deepLink!);
    }
  }

  void _onActionTap(NotificationActionItem action) {
    context.push(action.deepLink);
  }

  void _openPreferencesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationPreferencesSheet(),
    );
  }
}

/// Notification Item Card with category icon, unread indicator, and action chips
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final ValueChanged<NotificationActionItem> onActionTap;
  final VoidCallback onDismissed;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onActionTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, bgGradient) = _getCategoryVisuals(notification.category);
    final timeStr = _formatTimestamp(notification.timestamp);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.85),
          borderRadius: AppRadius.border16,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.border16,
        child: Container(
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.surface : AppColors.surfaceVariant,
            borderRadius: AppRadius.border16,
            border: Border.all(
              color: notification.isRead
                  ? AppColors.surfaceVariant.withOpacity(0.4)
                  : AppColors.primary.withOpacity(0.4),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: notification.isRead
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Icon Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: bgGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Title & Timestamp
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeStr,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.vertical8,
              // Notification Body
              Padding(
                padding: const EdgeInsets.only(left: 54),
                child: Text(
                  notification.body,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),

              // Action Buttons (Show Ticket, Directions, Order Food)
              if (notification.actions.isNotEmpty) ...[
                AppSpacing.vertical12,
                Padding(
                  padding: const EdgeInsets.only(left: 54),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: notification.actions.map((action) {
                      final actionIcon = _getActionIcon(action.actionId);
                      return ActionChip(
                        avatar: Icon(actionIcon, size: 14, color: AppColors.primary),
                        label: Text(
                          action.title,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        side: BorderSide(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onPressed: () => onActionTap(action),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color, LinearGradient) _getCategoryVisuals(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.smartTransit:
        return (
          Icons.directions_car_filled_rounded,
          Colors.amber.shade400,
          LinearGradient(
            colors: [Colors.amber.shade900.withOpacity(0.4), Colors.amber.shade700.withOpacity(0.2)],
          ),
        );
      case NotificationCategory.reminder:
        return (
          Icons.confirmation_number_rounded,
          AppColors.primary,
          LinearGradient(
            colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.1)],
          ),
        );
      case NotificationCategory.ticketTransfer:
        return (
          Icons.send_rounded,
          Colors.blue.shade400,
          LinearGradient(
            colors: [Colors.blue.shade900.withOpacity(0.3), Colors.blue.shade700.withOpacity(0.1)],
          ),
        );
      case NotificationCategory.promotion:
        return (
          Icons.local_offer_rounded,
          Colors.purple.shade400,
          LinearGradient(
            colors: [Colors.purple.shade900.withOpacity(0.3), Colors.purple.shade700.withOpacity(0.1)],
          ),
        );
      case NotificationCategory.system:
        return (
          Icons.info_outline_rounded,
          AppColors.textSecondary,
          LinearGradient(
            colors: [AppColors.surfaceVariant, AppColors.surface],
          ),
        );
    }
  }

  IconData _getActionIcon(String actionId) {
    if (actionId.contains('SHOW_TICKET')) return Icons.qr_code_rounded;
    if (actionId.contains('DIRECTIONS')) return Icons.navigation_rounded;
    if (actionId.contains('ORDER_FOOD')) return Icons.fastfood_rounded;
    return Icons.arrow_forward_rounded;
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.isNegative) {
      // Future scheduled item
      final until = dt.difference(now);
      if (until.inHours > 0) return 'In ${until.inHours}h';
      return 'In ${until.inMinutes}m';
    }

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    return DateFormat('d MMM, h:mm a').format(dt);
  }
}
