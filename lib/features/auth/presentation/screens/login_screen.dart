import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../application/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(signInProvider)(
        email: _email.text,
        password: _password.text,
      );
      if (mounted) context.goNamed(AppRoute.startChoice.name);
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.auth.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              GlassBackButton(onPressed: _goBack),
              const SizedBox(height: 34),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to your PecoNote account.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 26),
              AppTextField(
                label: 'EMAIL',
                controller: _email,
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                enabled: !_loading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'PASSWORD',
                controller: _password,
                obscurable: true,
                enabled: !_loading,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.pushNamed(AppRoute.forgotPassword.name),
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 26),
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlueMuted,
                      ),
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],
              PillButton(
                label: _loading ? 'Signing in…' : 'Sign in',
                onPressed: _loading ? null : () => unawaited(_signIn()),
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
              ),
              const SizedBox(height: 16),

              Container(
                alignment: Alignment.center,
                child: Text.rich(
                  TextSpan(
                    text: 'New here?',
                    style: const TextStyle(
                      color: AppColors.grayText,
                      fontSize: 14,
                    ),
                    children: [
                      const WidgetSpan(child: SizedBox(width: 5)),

                      TextSpan(
                        text: 'Create account',
                        style: const TextStyle(
                          color: AppColors.accentBlueMuted,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              context.goNamed(AppRoute.register.name),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
