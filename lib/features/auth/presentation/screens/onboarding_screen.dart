import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/providers/providers.dart';
import 'package:showscape/core/router/auth_state.dart';
import 'package:showscape/core/router/route_paths.dart';
import 'package:showscape/core/theme/app_palette.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/core/utils/app_haptics.dart';
import 'package:showscape/core/widgets/primary_button.dart';
import 'package:showscape/core/widgets/secondary_button.dart';
import 'package:showscape/features/auth/presentation/auth_field.dart';
import 'package:showscape/features/auth/presentation/auth_validators.dart';
import 'package:showscape/features/auth/presentation/onboarding_options.dart';
import 'package:showscape/features/payment/domain/models/saved_payment_method.dart';
import 'package:showscape/features/payment/presentation/providers/saved_payment_methods_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final GlobalKey<FormState> _accountFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _paymentDetailController = TextEditingController();

  int _step = 0;
  String _city = onboardingCities.first;
  final Set<String> _genres = <String>{};
  final Set<String> _languages = <String>{};
  PaymentChannel? _paymentChannel;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _paymentDetailController.dispose();
    super.dispose();
  }

  void _nextFromWelcome() {
    AppHaptics.light();
    setState(() => _step = 1);
  }

  void _nextFromAccount() {
    if (_accountFormKey.currentState?.validate() != true) {
      AppHaptics.light();
      return;
    }
    AppHaptics.medium();
    setState(() {
      _errorMessage = null;
      _step = 2;
    });
  }

  void _nextFromPreferences() {
    if (_genres.isEmpty || _languages.isEmpty) {
      setState(() => _errorMessage = 'Pick at least one genre and one language.');
      AppHaptics.light();
      return;
    }
    AppHaptics.medium();
    setState(() {
      _errorMessage = null;
      _step = 3;
    });
  }

  Future<void> _finish() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final result = await ref.read(userRepositoryProvider).signUp(
          name: _nameController.text,
          email: _emailController.text,
          phone: normalizePhone(_phoneController.text),
          password: _passwordController.text,
          preferredCities: <String>[_city],
          favoriteGenres: _genres.toList(),
          favoriteLanguages: _languages.toList(),
        );
    if (!mounted) return;
    if (!result.isSuccess || result.user == null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = result.errorMessage;
      });
      return;
    }

    final detail = _paymentDetailController.text.trim();
    if (_paymentChannel != null && detail.length >= 3) {
      ref.read(savedPaymentMethodsProvider.notifier).replaceAll(<SavedPaymentMethod>[
        SavedPaymentMethod(
          id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
          channel: _paymentChannel!,
          label: _paymentChannel == PaymentChannel.upi ? 'UPI' : 'Payment',
          detail: detail,
          isDefault: true,
        ),
      ]);
    } else {
      ref.read(savedPaymentMethodsProvider.notifier).replaceAll(const <SavedPaymentMethod>[]);
    }

    final user = result.user!;
    ref.read(authNotifierProvider).login(
          email: user.email,
          displayName: user.name,
          userId: user.id,
        );
    ref.invalidate(currentUserProvider);
    AppHaptics.heavy();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: _step == 0
              ? _welcome(palette)
              : Column(
                  children: [
                    _stepHeader(palette),
                    AppSpacing.vertical16,
                    Expanded(child: _stepBody(palette)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _welcome(AppPalette palette) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 20),
        Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.coralGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.spotlightCoral.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 44, color: Colors.white),
            ),
            AppSpacing.vertical24,
            Text(
              'Welcome to ShowScape',
              textAlign: TextAlign.center,
              style: AppTypography.heading24(color: palette.text),
            ),
            AppSpacing.vertical12,
            Text(
              'Discover movies, concerts, stand-up specials, and fine dining with your AI entertainment concierge.',
              textAlign: TextAlign.center,
              style: AppTypography.body16(color: palette.textMuted),
            ),
          ],
        ),
        Column(
          children: [
            PrimaryButton(
              text: 'Get Started',
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              onPressed: _nextFromWelcome,
            ),
            AppSpacing.vertical12,
            SecondaryButton(
              text: 'Sign In to Existing Account',
              icon: const Icon(Icons.login_rounded, size: 20),
              onPressed: () => context.push(AppRoutes.login),
            ),
          ],
        ),
      ],
    );
  }

  Widget _stepHeader(AppPalette palette) {
    const titles = <String>['Your account', 'What you love', 'How you pay'];
    return Row(
      children: [
        IconButton(
          onPressed: () {
            AppHaptics.selection();
            setState(() {
              _errorMessage = null;
              _step -= 1;
            });
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: palette.text, size: 18),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titles[_step - 1], style: AppTypography.heading20(color: palette.text)),
              Text('Step $_step of 3', style: AppTypography.caption12(color: palette.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepBody(AppPalette palette) {
    if (_step == 1) return _accountStep(palette);
    if (_step == 2) return _preferencesStep(palette);
    return _paymentStep(palette);
  }

  Widget _accountStep(AppPalette palette) {
    return SingleChildScrollView(
      child: Form(
        key: _accountFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: authInputDecoration(
                palette: palette,
                label: 'Full name',
                icon: Icons.person_outline_rounded,
              ),
              validator: AuthValidators.name,
            ),
            AppSpacing.vertical12,
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: authInputDecoration(
                palette: palette,
                label: 'Email',
                icon: Icons.mail_outline_rounded,
              ),
              validator: AuthValidators.email,
            ),
            AppSpacing.vertical12,
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: authInputDecoration(
                palette: palette,
                label: 'Mobile number',
                icon: Icons.phone_outlined,
              ),
              validator: AuthValidators.phone,
            ),
            AppSpacing.vertical12,
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: authInputDecoration(
                palette: palette,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
              ),
              validator: AuthValidators.password,
            ),
            AppSpacing.vertical12,
            TextFormField(
              controller: _confirmController,
              obscureText: true,
              decoration: authInputDecoration(
                palette: palette,
                label: 'Confirm password',
                icon: Icons.lock_outline_rounded,
              ),
              validator: (value) => AuthValidators.confirmPassword(
                value,
                _passwordController.text,
              ),
            ),
            AppSpacing.vertical24,
            PrimaryButton(text: 'Continue', onPressed: _nextFromAccount),
          ],
        ),
      ),
    );
  }

  Widget _preferencesStep(AppPalette palette) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('City', style: AppTypography.heading18(color: palette.text)),
          AppSpacing.vertical8,
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
          AppSpacing.vertical16,
          Text('Genres', style: AppTypography.heading18(color: palette.text)),
          AppSpacing.vertical8,
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
          AppSpacing.vertical16,
          Text('Languages', style: AppTypography.heading18(color: palette.text)),
          AppSpacing.vertical8,
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
          if (_errorMessage != null) ...[
            AppSpacing.vertical12,
            Text(_errorMessage!, style: AppTypography.body14(color: AppColors.error)),
          ],
          AppSpacing.vertical24,
          PrimaryButton(text: 'Continue', onPressed: _nextFromPreferences),
        ],
      ),
    );
  }

  Widget _paymentStep(AppPalette palette) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add a way to pay. You can skip this and add one later from Profile.',
            style: AppTypography.body14(color: palette.textMuted),
          ),
          AppSpacing.vertical16,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PaymentChannel.values.map((channel) {
              return ChoiceChip(
                label: Text(_channelName(channel)),
                selected: _paymentChannel == channel,
                onSelected: (_) {
                  AppHaptics.selection();
                  setState(() => _paymentChannel = channel);
                },
              );
            }).toList(),
          ),
          if (_paymentChannel != null) ...[
            AppSpacing.vertical16,
            TextFormField(
              controller: _paymentDetailController,
              decoration: authInputDecoration(
                palette: palette,
                label: _paymentLabel(_paymentChannel!),
                icon: Icons.payments_outlined,
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            AppSpacing.vertical12,
            Text(_errorMessage!, style: AppTypography.body14(color: AppColors.error)),
          ],
          AppSpacing.vertical24,
          PrimaryButton(
            text: 'Finish',
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _finish,
          ),
          AppSpacing.vertical8,
          SecondaryButton(
            text: 'Skip for now',
            onPressed: _isSubmitting
                ? null
                : () {
                    _paymentChannel = null;
                    _paymentDetailController.clear();
                    _finish();
                  },
          ),
        ],
      ),
    );
  }

  String _channelName(PaymentChannel channel) {
    switch (channel) {
      case PaymentChannel.upi:
        return 'UPI';
      case PaymentChannel.card:
        return 'Card';
      case PaymentChannel.netBanking:
        return 'Net banking';
      case PaymentChannel.wallet:
        return 'Wallet';
    }
  }

  String _paymentLabel(PaymentChannel channel) {
    switch (channel) {
      case PaymentChannel.upi:
        return 'UPI ID';
      case PaymentChannel.card:
        return 'Card ending';
      case PaymentChannel.netBanking:
        return 'Bank name';
      case PaymentChannel.wallet:
        return 'Wallet number';
    }
  }
}
