import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/preferences_provider.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/auth_state.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_palette.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/localization/locale_provider.dart';
import 'package:showscape/core/providers/accessibility_providers.dart';
import 'package:showscape/core/providers/demo_mode_provider.dart';
import 'package:showscape/core/utils/app_haptics.dart';
import 'package:showscape/core/widgets/gold_badge.dart';
import 'package:showscape/features/auth/domain/models/app_user.dart';
import 'package:showscape/features/auth/presentation/onboarding_options.dart';
import 'package:showscape/features/notifications/presentation/providers/notification_providers.dart';
import 'package:showscape/features/notifications/presentation/widgets/notification_preferences_sheet.dart';
import 'package:showscape/features/payment/presentation/providers/saved_payment_methods_provider.dart';
import 'package:showscape/features/payment/presentation/widgets/payment_method_picker.dart';

/// Full-featured Profile screen with VIP status, Notification Centre link,
/// and in-place toggles for 24h, 3h, 45m, and Smart Leave-Now reminders.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final prefs = ref.watch(notificationPreferencesProvider);
    final prefsNotifier = ref.read(notificationPreferencesProvider.notifier);
    final unreadNotifications = ref.watch(unreadNotificationsCountProvider);
    final palette = AppPalette.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final hapticsOn = ref.watch(hapticsEnabledProvider);
    final themeMode = ref.watch(themeModeProvider);
    final user = userAsync.asData?.value;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        foregroundColor: palette.text,
        title: Text(
          'Profile & Settings',
          style: AppTypography.heading20(color: palette.text).copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Notification Centre',
                icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                onPressed: () => context.push(AppRoutes.notifications),
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        '$unreadNotifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileIdentityCard(palette: palette, user: user, fallbackName: auth.state.displayName),
            AppSpacing.vertical16,
            _ProfileGoldCard(isGold: user?.isGoldMember ?? false, goldExpiry: user?.goldExpiry),
            AppSpacing.vertical16,
            _ProfileTastesCard(palette: palette, user: user),
            AppSpacing.vertical16,
            const _ProfilePaymentsCard(),

            AppSpacing.vertical20,

            // Quick Access to Notification Centre
            InkWell(
              borderRadius: AppRadius.border16,
              onTap: () => context.push(AppRoutes.notifications),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(45),
                      AppColors.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.border16,
                  border: Border.all(color: AppColors.primary.withAlpha(90)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Notification Centre',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (unreadNotifications > 0) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$unreadNotifications new',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Past reminders, transit alerts & interactive deep links',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),

            AppSpacing.vertical24,

            // Showtime Reminder Preferences Toggles (User can toggle each in Profile)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BOOKING REMINDER SETTINGS',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const NotificationPreferencesSheet(),
                    );
                  },
                  child: const Text('Customize'),
                ),
              ],
            ),
            AppSpacing.vertical8,

            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.border16,
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      '24 Hours Before Showtime',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Day-before reminder with venue directions & show overview',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    value: prefs.remind24h,
                    activeThumbColor: AppColors.primary,
                    onChanged: prefsNotifier.toggle24h,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text(
                      '3 Hours Before Showtime',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'F&B reminder to pre-order snacks and skip interval lines',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    value: prefs.remind3h,
                    activeThumbColor: AppColors.primary,
                    onChanged: prefsNotifier.toggle3h,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Text(
                      '45 Minutes Before Showtime',
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Doors opening reminder with 1-tap QR ticket pass action',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    value: prefs.remind45m,
                    activeThumbColor: AppColors.primary,
                    onChanged: prefsNotifier.toggle45m,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    title: Row(
                      children: [
                        Text(
                          'Smart Leave-Now Reminder',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.amber),
                      ],
                    ),
                    subtitle: Text(
                      'Calculates commute to venue (Distance Matrix / straight-line 20 km/h) & alerts at showtime − travel time − 15 min',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    value: prefs.smartLeaveNow,
                    activeThumbColor: Colors.amber.shade700,
                    onChanged: prefsNotifier.toggleSmartLeaveNow,
                  ),
                ],
              ),
            ),

            AppSpacing.vertical24,

            // Preferences & Accessibility
            Text(
              'PREFERENCES & ACCESSIBILITY',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vertical8,

            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.border16,
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  // Language Switcher
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.spotlightCoral),
                    title: const Text('Language / भाषा'),
                    subtitle: Text(AppLocales.getDisplayName(ref.watch(localeProvider))),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.spotlightCoral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.spotlightCoral.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        ref.watch(localeProvider).languageCode == 'en' ? 'EN' : 'HI',
                        style: const TextStyle(
                          color: AppColors.spotlightCoral,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      AppHaptics.selection();
                      ref.read(localeProvider.notifier).toggleLanguage();
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Large text & simple mode Toggle
                  SwitchListTile(
                    secondary: const Icon(Icons.accessibility_new_rounded, color: AppColors.marqueeAmber),
                    title: const Text('Large text & simple mode'),
                    subtitle: const Text('Enlarges text by 135% and activates simplified Home view'),
                    value: ref.watch(simpleModeProvider),
                    activeThumbColor: AppColors.marqueeAmber,
                    onChanged: (val) {
                      AppHaptics.selection();
                      ref.read(simpleModeProvider.notifier).setEnabled(val);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Dark / Light Theme Toggle
                  SwitchListTile(
                    secondary: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: palette.text,
                    ),
                    title: const Text('Dark Theme'),
                    subtitle: const Text('Switch between immersive dark and high-contrast light mode'),
                    value: themeMode == ThemeMode.dark,
                    activeThumbColor: AppColors.spotlightCoral,
                    onChanged: (val) {
                      setThemeMode(ref, val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration_rounded, color: AppColors.spotlightCoral),
                    title: const Text('Haptics'),
                    subtitle: const Text('Taps and confirmations vibrate on this device'),
                    value: hapticsOn,
                    activeThumbColor: AppColors.spotlightCoral,
                    onChanged: (val) => setHapticsEnabled(ref, val),
                  ),
                ],
              ),
            ),

            AppSpacing.vertical24,

            // VIP Membership & Staff Options
            Text(
              'MEMBERSHIP & TOOLS',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.vertical8,

            Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.border16,
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_rounded, color: Colors.amber),
                    title: const Text('ShowScape Gold VIP Hub'),
                    subtitle: const Text('Zero convenience fees & free ticket transfers'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => context.push(AppRoutes.gold),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.psychology_rounded, color: AppColors.spotlightCoral),
                    title: const Text('AI Summaries & Mood Debugger'),
                    subtitle: const Text('Inspect Hive daily cache & regenerate summaries'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => context.push(AppRoutes.aiDebug),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                    title: const Text('Staff Gate Scanner'),
                    subtitle: const Text('Verify attendee digital tickets & passes'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => context.push(AppRoutes.staffScanner),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(
                      auth.isAuthenticated ? Icons.logout_rounded : Icons.login_rounded,
                      color: auth.isAuthenticated ? AppColors.error : AppColors.success,
                    ),
                    title: Text(
                      auth.isAuthenticated ? 'Sign Out' : 'Sign In',
                      style: TextStyle(
                        color: auth.isAuthenticated ? AppColors.error : AppColors.success,
                      ),
                    ),
                    onTap: () {
                      AppHaptics.medium();
                      if (auth.isAuthenticated) {
                        ref.read(authNotifierProvider).logout();
                      } else {
                        context.go(AppRoutes.login);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Hidden Demo Mode Logo Trigger
            const _DemoLogoFooter(),
          ],
        ),
      ),
    );
  }
}

class _ProfileIdentityCard extends ConsumerWidget {
  const _ProfileIdentityCard({
    required this.palette,
    required this.user,
    required this.fallbackName,
  });

  final AppPalette palette;
  final AppUser? user;
  final String? fallbackName;

  void _openProfileEditor(BuildContext context, WidgetRef ref) {
    AppHaptics.selection();
    final currentUser = user ??
        AppUser(
          id: 'usr_guest',
          name: fallbackName ?? 'Guest User',
          email: 'guest@showscape.ai',
          phone: '+91 98765 43210',
          preferredCities: const ['Mumbai'],
          favoriteGenres: const ['Action', 'Sci-Fi'],
          favoriteLanguages: const ['English', 'Hindi'],
          isGoldMember: true,
        );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProfileEditorSheet(user: currentUser),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user?.name ?? fallbackName ?? 'Guest User';
    final email = user?.email ?? 'Sign in to personalize ShowScape';
    final phone = user?.phone ?? '+91 98765 43210';
    final avatarUrl = user?.avatarUrl;
    final isGold = user?.isGoldMember ?? false;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: AppRadius.border16,
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withAlpha(50),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: avatarUrl == null || avatarUrl.isEmpty
                    ? const Icon(Icons.person_rounded, size: 36, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.heading18(color: palette.text).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, size: 22, color: AppColors.primary),
                          tooltip: 'Edit Profile',
                          onPressed: () => _openProfileEditor(context, ref),
                        ),
                      ],
                    ),
                    Text(email, style: AppTypography.body14(color: palette.textMuted)),
                    if (phone.isNotEmpty)
                      Text(phone, style: AppTypography.caption12(color: palette.textMuted)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (isGold)
                          const GoldBadge(
                            text: 'GOLD VIP',
                            showIcon: true,
                            fontSize: 8,
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          ),
                        Text(
                          'ID: ${user?.id ?? 'usr_guest'}',
                          style: AppTypography.caption12(color: palette.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vertical12,
        _ProfileStatsWidget(palette: palette),
      ],
    );
  }
}

class _ProfileStatsWidget extends ConsumerWidget {
  const _ProfileStatsWidget({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(allUserBookingsProvider);
    final bookings = bookingsAsync.asData?.value ?? [];
    final activeCount = bookings.where((b) => b.showTime.isAfter(DateTime.now())).length;
    final totalCount = bookings.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surfaceElevated,
        borderRadius: AppRadius.border16,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(
            label: 'Active Passes',
            value: '$activeCount',
            icon: Icons.confirmation_number_outlined,
            color: AppColors.primary,
            palette: palette,
          ),
          Container(width: 1, height: 32, color: palette.border),
          _StatColumn(
            label: 'Total Outings',
            value: '$totalCount',
            icon: Icons.local_activity_outlined,
            color: AppColors.spotlightCoral,
            palette: palette,
          ),
          Container(width: 1, height: 32, color: palette.border),
          _StatColumn(
            label: 'Gold Savings',
            value: '₹340',
            icon: Icons.savings_outlined,
            color: Colors.amber,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.palette,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(color: palette.text, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption12(color: palette.textMuted),
        ),
      ],
    );
  }
}

class _ProfileEditorSheet extends ConsumerStatefulWidget {
  const _ProfileEditorSheet({required this.user});

  final AppUser user;

  @override
  ConsumerState<_ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends ConsumerState<_ProfileEditorSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late String _selectedAvatar;
  bool _isSaving = false;

  static const List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=256&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=256&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedAvatar = widget.user.avatarUrl ?? _avatarPresets.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    AppHaptics.medium();
    setState(() => _isSaving = true);

    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarUrl: _selectedAvatar,
    );

    await ref.read(userRepositoryProvider).updateProfile(updated);
    ref.read(authNotifierProvider).login(
          email: updated.email,
          displayName: updated.name,
          userId: updated.id,
        );
    ref.invalidate(currentUserProvider);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile details updated successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: AppRadius.sheetTop20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Profile Details', style: AppTypography.heading20(color: palette.text)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              AppSpacing.vertical16,
              
              Text('Choose Avatar', style: AppTypography.caption12(color: palette.textMuted)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _avatarPresets.map((url) {
                  final isSelected = _selectedAvatar == url;
                  return GestureDetector(
                    onTap: () {
                      AppHaptics.selection();
                      setState(() => _selectedAvatar = url);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: CachedNetworkImageProvider(url),
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.vertical16,

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              AppSpacing.vertical12,
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              AppSpacing.vertical12,
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              AppSpacing.vertical20,

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(_isSaving ? 'Saving...' : 'Save Profile Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileGoldCard extends StatelessWidget {
  const _ProfileGoldCard({required this.isGold, required this.goldExpiry});

  final bool isGold;
  final DateTime? goldExpiry;

  @override
  Widget build(BuildContext context) {
    final expiryLabel = goldExpiry == null
        ? 'Zero convenience fee, early presales, and VIP lounge perks'
        : 'Active until ${DateFormat('d MMM yyyy').format(goldExpiry!)}';

    return InkWell(
      borderRadius: AppRadius.border16,
      onTap: () {
        AppHaptics.light();
        context.push(AppRoutes.gold);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C1E0A), Color(0xFF1B1405)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.border16,
          border: Border.all(color: AppColors.marqueeAmber.withValues(alpha: 0.8), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: AppColors.midnight, size: 20),
            ),
            AppSpacing.horizontal12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'ShowScape Gold VIP',
                        style: TextStyle(
                          color: AppColors.marqueeAmber,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GoldBadge(
                        text: isGold ? 'ACTIVE' : 'JOIN',
                        showIcon: false,
                        fontSize: 8,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isGold ? expiryLabel : 'Join Gold for zero convenience fees',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.marqueeAmber, size: 14),
          ],
        ),
      ),
    );
  }
}

class _ProfileTastesCard extends ConsumerWidget {
  const _ProfileTastesCard({required this.palette, required this.user});

  final AppPalette palette;
  final AppUser? user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = user?.preferredCities ?? const <String>[];
    final genres = user?.favoriteGenres ?? const <String>[];
    final languages = user?.favoriteLanguages ?? const <String>[];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.border16,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('My tastes', style: AppTypography.heading18(color: palette.text)),
              ),
              TextButton(
                onPressed: user == null ? null : () => _editTastes(context, ref, user!),
                child: const Text('Edit'),
              ),
            ],
          ),
          _TasteRow(label: 'Cities', values: cities, palette: palette),
          _TasteRow(label: 'Genres', values: genres, palette: palette),
          _TasteRow(label: 'Languages', values: languages, palette: palette),
        ],
      ),
    );
  }

  Future<void> _editTastes(BuildContext context, WidgetRef ref, AppUser current) async {
    AppHaptics.selection();
    final updated = await showModalBottomSheet<AppUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _TasteEditorSheet(user: current),
    );
    if (updated == null) return;
    await ref.read(userRepositoryProvider).updateProfile(updated);
    ref.invalidate(currentUserProvider);
    ref.read(authNotifierProvider).login(
          email: updated.email,
          displayName: updated.name,
          userId: updated.id,
        );
  }
}

class _TasteRow extends StatelessWidget {
  const _TasteRow({
    required this.label,
    required this.values,
    required this.palette,
  });

  final String label;
  final List<String> values;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption12(color: palette.textMuted)),
          const SizedBox(height: 6),
          if (values.isEmpty)
            Text('Not set yet', style: AppTypography.body14(color: palette.textMuted))
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: values
                  .map(
                    (value) => Chip(
                      label: Text(value),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: palette.surfaceElevated,
                      side: BorderSide(color: palette.border),
                      labelStyle: AppTypography.caption12(color: palette.text),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _TasteEditorSheet extends StatefulWidget {
  const _TasteEditorSheet({required this.user});

  final AppUser user;

  @override
  State<_TasteEditorSheet> createState() => _TasteEditorSheetState();
}

class _TasteEditorSheetState extends State<_TasteEditorSheet> {
  late String _city;
  late Set<String> _genres;
  late Set<String> _languages;

  @override
  void initState() {
    super.initState();
    _city = widget.user.preferredCities.isEmpty
        ? onboardingCities.first
        : widget.user.preferredCities.first;
    _genres = widget.user.favoriteGenres.toSet();
    _languages = widget.user.favoriteLanguages.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Material(
        color: palette.surface,
        borderRadius: AppRadius.sheetTop20,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit tastes', style: AppTypography.heading20(color: palette.text)),
              AppSpacing.vertical12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: onboardingCities.map((city) {
                  return ChoiceChip(
                    label: Text(city),
                    selected: _city == city,
                    onSelected: (_) {
                      AppHaptics.selection();
                      setState(() => _city = city);
                    },
                  );
                }).toList(),
              ),
              AppSpacing.vertical12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: onboardingGenres.map((genre) {
                  return FilterChip(
                    label: Text(genre),
                    selected: _genres.contains(genre),
                    onSelected: (selected) {
                      AppHaptics.selection();
                      setState(() {
                        if (selected) {
                          _genres.add(genre);
                        } else {
                          _genres.remove(genre);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              AppSpacing.vertical12,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: onboardingLanguages.map((language) {
                  return FilterChip(
                    label: Text(language),
                    selected: _languages.contains(language),
                    onSelected: (selected) {
                      AppHaptics.selection();
                      setState(() {
                        if (selected) {
                          _languages.add(language);
                        } else {
                          _languages.remove(language);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              AppSpacing.vertical16,
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    AppHaptics.medium();
                    Navigator.of(context).pop(
                      widget.user.copyWith(
                        preferredCities: <String>[_city],
                        favoriteGenres: _genres.toList(),
                        favoriteLanguages: _languages.toList(),
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePaymentsCard extends ConsumerWidget {
  const _ProfilePaymentsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final methods = ref.watch(savedPaymentMethodsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: AppRadius.border16,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Payment methods', style: AppTypography.heading18(color: palette.text)),
              ),
              TextButton(
                onPressed: () {
                  AppHaptics.selection();
                  showAddPaymentMethodSheet(context, ref);
                },
                child: const Text('Add'),
              ),
            ],
          ),
          if (methods.isEmpty)
            Text(
              'No cards, UPI IDs, or wallets saved yet.',
              style: AppTypography.body14(color: palette.textMuted),
            )
          else
            ...methods.map((method) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.payments_outlined, color: AppColors.spotlightCoral),
                title: Text(method.label, style: AppTypography.body14(color: palette.text, fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${method.channelLabel} · ${method.detail}',
                  style: AppTypography.caption12(color: palette.textMuted),
                ),
                trailing: method.isDefault
                    ? Text('Default', style: AppTypography.caption12(color: AppColors.marqueeAmber))
                    : IconButton(
                        tooltip: 'Make default',
                        icon: Icon(Icons.star_outline_rounded, color: palette.textMuted),
                        onPressed: () {
                          AppHaptics.selection();
                          ref.read(savedPaymentMethodsProvider.notifier).makeDefault(method.id);
                        },
                      ),
              );
            }),
        ],
      ),
    );
  }
}

class _DemoLogoFooter extends ConsumerStatefulWidget {
  const _DemoLogoFooter();

  @override
  ConsumerState<_DemoLogoFooter> createState() => _DemoLogoFooterState();
}

class _DemoLogoFooterState extends ConsumerState<_DemoLogoFooter> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _onLogoTap() {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    if (_tapCount >= 5) {
      _tapCount = 0;
      AppHaptics.heavy();
      ref.read(demoModeProvider.notifier).activateDemoMode();
      showDemoModeSheet(context, ref);
    } else if (_tapCount >= 3) {
      AppHaptics.light();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${5 - _tapCount} more taps to unlock Case Study 146 Demo Mode'),
          duration: const Duration(milliseconds: 700),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(demoModeProvider);

    return Column(
      children: [
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _onLogoTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 56,
                  height: 56,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'ShowScape',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (demo.isDemoActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.spotlightCoral, AppColors.electricPurple],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DEMO MODE ON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'v1.0.0 (Case Study 146)',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              const Text(
                'Tap logo 5 times to open Demo Mode',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
