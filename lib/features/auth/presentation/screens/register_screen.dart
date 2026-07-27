import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../application/providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    _password.addListener(_refreshPasswordHints);
  }

  void _refreshPasswordHints() => setState(() {});

  @override
  void dispose() {
    _password.removeListener(_refreshPasswordHints);
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _fieldError(String field) => _fieldErrors[field]?.join('\n');

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (_password.text != _confirm.text) {
      setState(
        () => _fieldErrors = const {
          'confirm_password': ['Passwords do not match.'],
        },
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _fieldErrors = const {};
    });
    try {
      await ref.read(registerProvider)(
        username: _username.text,
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirm.text,
      );
      if (!mounted) return;
      context.goNamed(AppRoute.startChoice.name);
    } on ValidationFailure catch (failure) {
      if (mounted) {
        setState(() {
          _error = failure.message;
          _fieldErrors = failure.fieldErrors;
        });
      }
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
              const SizedBox(height: 30),
              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A minute of setup, years of calm.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'USERNAME',
                controller: _username,
                errorText: _fieldError('username'),
                enabled: !_loading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'EMAIL',
                controller: _email,
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                errorText: _fieldError('email'),
                enabled: !_loading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'PASSWORD',
                controller: _password,
                obscurable: true,
                errorText: _fieldError('password'),
                enabled: !_loading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              _PasswordHints(password: _password.text),
              const SizedBox(height: 12),
              AppTextField(
                label: 'CONFIRM PASSWORD',
                controller: _confirm,
                obscurable: true,
                errorText: _fieldError('confirm_password'),
                enabled: !_loading,
                textInputAction: TextInputAction.done,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 26),
              PillButton(
                label: _loading ? 'Creating account…' : 'Continue',
                onPressed: _loading ? null : () => unawaited(_register()),
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
              ),
              const SizedBox(height: 16),
              TextLinkRow(
                prefix: 'Already registered?',
                linkLabel: 'Sign in',
                onTap: () => context.goNamed(AppRoute.login.name),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordHints extends StatelessWidget {
  const _PasswordHints({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final hasLength = password.length >= 8;
    final hasNumber = RegExp(r'\d').hasMatch(password);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _PasswordHint(label: '8+ characters', fulfilled: hasLength),
          const SizedBox(width: 8),
          _PasswordHint(label: 'contains a number', fulfilled: hasNumber),
        ],
      ),
    );
  }
}

class _PasswordHint extends StatelessWidget {
  const _PasswordHint({required this.label, required this.fulfilled});

  final String label;
  final bool fulfilled;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${fulfilled ? '✓' : '•'} $label',
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        color: fulfilled ? AppColors.incomeAlt : AppColors.labelGray,
      ),
    );
  }
}
