import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/notifications/presentation/providers/notification_providers.dart';

/// State of the hidden Demo Mode
class DemoModeState {
  final bool isDemoActive;
  final bool isTuesdayOverride;
  final bool isGoldOverride;
  final bool useMockAi;
  final bool useMockPayment;
  final int notificationCountdown;

  const DemoModeState({
    this.isDemoActive = false,
    this.isTuesdayOverride = false,
    this.isGoldOverride = false,
    this.useMockAi = true,
    this.useMockPayment = true,
    this.notificationCountdown = 0,
  });

  DemoModeState copyWith({
    bool? isDemoActive,
    bool? isTuesdayOverride,
    bool? isGoldOverride,
    bool? useMockAi,
    bool? useMockPayment,
    int? notificationCountdown,
  }) {
    return DemoModeState(
      isDemoActive: isDemoActive ?? this.isDemoActive,
      isTuesdayOverride: isTuesdayOverride ?? this.isTuesdayOverride,
      isGoldOverride: isGoldOverride ?? this.isGoldOverride,
      useMockAi: useMockAi ?? this.useMockAi,
      useMockPayment: useMockPayment ?? this.useMockPayment,
      notificationCountdown: notificationCountdown ?? this.notificationCountdown,
    );
  }
}

class DemoModeNotifier extends StateNotifier<DemoModeState> {
  DemoModeNotifier(this.ref) : super(const DemoModeState());

  final Ref ref;
  Timer? _countdownTimer;

  void activateDemoMode() {
    state = state.copyWith(
      isDemoActive: true,
      isTuesdayOverride: true,
      isGoldOverride: true,
      useMockAi: true,
      useMockPayment: true,
    );

    // Make demo user Gold
    _applyGoldStatus(true);

    // Schedule live 10-second reminder notification
    triggerTenSecondReminder();
  }

  void toggleDemoMode() {
    if (state.isDemoActive) {
      _countdownTimer?.cancel();
      state = const DemoModeState(isDemoActive: false);
      _applyGoldStatus(false);
    } else {
      activateDemoMode();
    }
  }

  void toggleTuesday(bool value) {
    state = state.copyWith(isTuesdayOverride: value);
  }

  Future<void> toggleGold(bool value) async {
    state = state.copyWith(isGoldOverride: value);
    await _applyGoldStatus(value);
  }

  Future<void> _applyGoldStatus(bool isGold) async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final current = await userRepo.getCurrentUser();
      if (current != null) {
        await userRepo.updateProfile(
          current.copyWith(
            isGoldMember: isGold,
            goldExpiry: isGold ? DateTime.now().add(const Duration(days: 365)) : null,
          ),
        );
        ref.invalidate(currentUserProvider);
      }
    } catch (e) {
      debugPrint('Demo mode update user error: $e');
    }
  }

  void triggerTenSecondReminder() {
    _countdownTimer?.cancel();
    state = state.copyWith(notificationCountdown: 10);

    // Schedule notification via notification service
    final notifService = ref.read(notificationServiceProvider);
    notifService.scheduleDemoReminder(delaySeconds: 10);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.notificationCountdown <= 1) {
        timer.cancel();
        state = state.copyWith(notificationCountdown: 0);
      } else {
        state = state.copyWith(
          notificationCountdown: state.notificationCountdown - 1,
        );
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

final demoModeProvider =
    StateNotifierProvider<DemoModeNotifier, DemoModeState>((ref) {
  return DemoModeNotifier(ref);
});

final isDemoTuesdayProvider = Provider<bool>((ref) {
  final demo = ref.watch(demoModeProvider);
  return demo.isDemoActive && demo.isTuesdayOverride;
});

final isDemoGoldProvider = Provider<bool>((ref) {
  final demo = ref.watch(demoModeProvider);
  return demo.isDemoActive && demo.isGoldOverride;
});

/// Displays the interactive Demo Mode Control Sheet
void showDemoModeSheet(BuildContext context, WidgetRef ref) {
  HapticFeedback.heavyImpact();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _DemoModeSheetContent(),
  );
}

class _DemoModeSheetContent extends ConsumerWidget {
  const _DemoModeSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demo = ref.watch(demoModeProvider);
    final notifier = ref.read(demoModeProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141424) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.spotlightCoral.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.spotlightCoral.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.spotlightCoral, AppColors.electricPurple],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Case Study 146 Demo Mode',
                      style: AppTypography.heading20().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Simulate all key demo states with live countdowns',
                      style: AppTypography.caption12(color: AppColors.lavenderMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Demo Mode Master Switch
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: demo.isDemoActive
                  ? AppColors.spotlightCoral.withValues(alpha: 0.15)
                  : (isDark ? AppColors.surface : Colors.grey.shade100),
              borderRadius: AppRadius.border16,
              border: Border.all(
                color: demo.isDemoActive
                    ? AppColors.spotlightCoral
                    : (isDark ? AppColors.surfaceBorder : Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demo.isDemoActive ? 'Demo Mode Active' : 'Demo Mode Off',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'Uses MockAiService & MockPaymentService',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.lavenderMuted : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: demo.isDemoActive,
                  activeColor: AppColors.spotlightCoral,
                  onChanged: (val) {
                    HapticFeedback.mediumImpact();
                    notifier.toggleDemoMode();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Toggles row: Tuesday Discount & Gold User
          Row(
            children: [
              // Tuesday Discount
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : Colors.grey.shade100,
                    borderRadius: AppRadius.border12,
                    border: Border.all(
                      color: demo.isTuesdayOverride
                          ? AppColors.marqueeAmber
                          : (isDark ? AppColors.surfaceBorder : Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.local_offer_rounded, color: AppColors.marqueeAmber, size: 20),
                          Switch.adaptive(
                            value: demo.isTuesdayOverride,
                            activeColor: AppColors.marqueeAmber,
                            onChanged: demo.isDemoActive ? notifier.toggleTuesday : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Set Today = Tuesday',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Text(
                        'Up to 70% movie deals',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Gold VIP Member Toggle
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surface : Colors.grey.shade100,
                    borderRadius: AppRadius.border12,
                    border: Border.all(
                      color: demo.isGoldOverride
                          ? Colors.amber
                          : (isDark ? AppColors.surfaceBorder : Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20),
                          Switch.adaptive(
                            value: demo.isGoldOverride,
                            activeColor: Colors.amber,
                            onChanged: demo.isDemoActive ? notifier.toggleGold : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'User = Gold VIP',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Text(
                        '₹0 fee & VIP badge',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 10-Second Reminder Notification Trigger CTA
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricPurple.withValues(alpha: 0.2),
                  AppColors.spotlightCoral.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppRadius.border16,
              border: Border.all(color: AppColors.electricPurple.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.electricPurple,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reminder Notification',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        demo.notificationCountdown > 0
                            ? '🔔 Firing in ${demo.notificationCountdown}s...'
                            : 'Triggers local notification in 10s',
                        style: TextStyle(
                          fontSize: 12,
                          color: demo.notificationCountdown > 0
                              ? AppColors.spotlightCoral
                              : AppColors.lavenderMuted,
                          fontWeight: demo.notificationCountdown > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    notifier.triggerTenSecondReminder();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔔 Notification scheduled! Firing in 10 seconds...'),
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Trigger 10s'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
