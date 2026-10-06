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
import 'package:showscape/features/auth/presentation/auth_field.dart';
import 'package:showscape/features/auth/presentation/auth_validators.dart';
import 'package:showscape/features/auth/presentation/onboarding_options.dart';
import 'package:showscape/features/payment/domain/models/saved_payment_method.dart';
import 'package:showscape/features/payment/presentation/providers/saved_payment_methods_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final Set<String> _genres = <String>{};
  final Set<String> _languages = <String>{};
  String _city = onboardingCities.first;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      AppHaptics.light();
      return;
    }
    if (_genres.isEmpty || _languages.isEmpty) {
      setState(() => _errorMessage = 'Pick at least one genre and one language.');
      AppHaptics.light();
      return;
    }
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
    final user = result.user!;
    ref.read(savedPaymentMethodsProvider.notifier).replaceAll(const <SavedPaymentMethod>[]);
    ref.read(authNotifierProvider).login(
          email: user.email,
          displayName: user.name,
          userId: user.id,
        );
    ref.invalidate(currentUserProvider);
    AppHaptics.medium();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: palette.text,
        title: Text('Create account', style: AppTypography.heading20(color: palette.text)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tell us who you are and what you like going out for.',
                  style: AppTypography.body14(color: palette.textMuted),
                ),
                AppSpacing.vertical20,
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
                AppSpacing.vertical20,
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
                  Text(
                    _errorMessage!,
                    style: AppTypography.body14(color: AppColors.error),
                  ),
                ],
                AppSpacing.vertical24,
                PrimaryButton(
                  text: 'Create account',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
