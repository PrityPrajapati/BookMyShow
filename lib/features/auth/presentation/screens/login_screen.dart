import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:showscape/features/payment/presentation/providers/saved_payment_methods_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _quickFillDemo() {
    AppHaptics.selection();
    setState(() {
      _emailController.text = 'prity@showscape.ai';
      _passwordController.text = 'showscape';
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      AppHaptics.light();
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final result = await ref.read(userRepositoryProvider).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (!result.isSuccess || result.user == null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = result.errorMessage;
      });
      AppHaptics.heavy();
      return;
    }
    final user = result.user!;
    if (user.email == 'prity@showscape.ai') {
      ref.read(savedPaymentMethodsProvider.notifier).seedDemoMethods();
    }
    ref.read(authNotifierProvider).login(
          email: user.email,
          displayName: user.name,
          userId: user.id,
        );
    ref.invalidate(currentUserProvider);
    AppHaptics.medium();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            AppHaptics.selection();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sign In', style: AppTypography.heading24(color: palette.text)),
                AppSpacing.vertical8,
                Text(
                  'Access your passes, Gold membership, and personalized Scout suggestions.',
                  style: AppTypography.body14(color: palette.textMuted),
                ),
                AppSpacing.vertical24,
                
                // Quick Demo Auto-fill Banner
                InkWell(
                  onTap: _quickFillDemo,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: palette.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 20, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tap to auto-fill Demo Account',
                                style: AppTypography.caption12(color: palette.text).copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'prity@showscape.ai  ·  showscape',
                                style: AppTypography.caption12(color: palette.textMuted),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.touch_app_rounded, size: 18, color: Color(0xFFF59E0B)),
                      ],
                    ),
                  ),
                ),
                AppSpacing.vertical20,

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const <String>[AutofillHints.email],
                  decoration: authInputDecoration(
                    palette: palette,
                    label: 'Email',
                    icon: Icons.mail_outline_rounded,
                  ),
                  validator: AuthValidators.email,
                ),
                AppSpacing.vertical16,
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const <String>[AutofillHints.password],
                  decoration: authInputDecoration(
                    palette: palette,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: palette.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: AuthValidators.password,
                  onFieldSubmitted: (_) => _submit(),
                ),
                if (_errorMessage != null) ...[
                  AppSpacing.vertical12,
                  Text(
                    _errorMessage!,
                    style: AppTypography.body14(color: const Color(0xFFEF4444)),
                  ),
                ],
                AppSpacing.vertical24,
                PrimaryButton(
                  text: 'Sign In',
                  isLoading: _isSubmitting,
                  icon: const Icon(Icons.login_rounded, size: 20),
                  onPressed: _isSubmitting ? null : _submit,
                ),
                AppSpacing.vertical12,
                SecondaryButton(
                  text: 'Create an account',
                  icon: const Icon(Icons.person_add_alt_rounded, size: 20),
                  onPressed: () => context.push(AppRoutes.signup),
                ),

                AppSpacing.vertical24,
                Row(
                  children: [
                    Expanded(child: Divider(color: palette.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR CONTINUE WITH', style: AppTypography.caption12(color: palette.textMuted)),
                    ),
                    Expanded(child: Divider(color: palette.border)),
                  ],
                ),
                AppSpacing.vertical16,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: palette.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _quickFillDemo,
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 24, color: Color(0xFFEA4335)),
                        label: Text('Google', style: TextStyle(color: palette.text)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: palette.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _quickFillDemo,
                        icon: Icon(Icons.apple, size: 20, color: palette.text),
                        label: Text('Apple', style: TextStyle(color: palette.text)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
