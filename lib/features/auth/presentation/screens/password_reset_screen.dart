import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../application/providers/auth_providers.dart';

const _textColor = Color(0xFF3B4358);
const _grayText = Color(0xFF7C86A0);

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email address.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(email: email);
      if (mounted) setState(() => _sent = true);
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoute.login.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: _sent ? _SentContent(email: _email.text, onBack: _back) : _form(),
      ),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          GlassBackButton(onPressed: _back),
          const SizedBox(height: 34),
          const Text(
            'Reset password',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your email and we'll send you a reset link.",
            style: TextStyle(fontSize: 13, height: 1.6, color: _grayText),
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: 'EMAIL',
            controller: _email,
            hintText: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            enabled: !_loading,
            textInputAction: TextInputAction.done,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFB3261E), fontSize: 13),
            ),
          ],
          const SizedBox(height: 26),
          PillButton(
            label: _loading ? 'Sending…' : 'Send link',
            onPressed: _loading ? null : () => unawaited(_send()),
          ),
          const SizedBox(height: 16),
          PlainLinkText(label: 'Back to sign in', onTap: _back),
        ],
      ),
    );
  }
}

class _SentContent extends StatelessWidget {
  const _SentContent({required this.email, required this.onBack});

  final String email;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
              ),
              child: const Text('✉️', style: TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 22),
            const Text(
              'Check your mail',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a reset link to $email. If it is not there, check Spam.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, height: 1.6, color: _grayText),
            ),
            const SizedBox(height: 30),
            PillButton(label: 'Back to sign in', onPressed: onBack),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.uid,
    required this.token,
  });

  final String uid;
  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _changed = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_password.text.length < 8) {
      setState(() => _error = 'Password must contain at least 8 characters.');
      return;
    }
    if (_password.text != _confirmPassword.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (widget.uid.isEmpty || widget.token.isEmpty) {
      setState(() => _error = 'This reset link is invalid.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).resetPassword(
        uid: widget.uid,
        token: widget.token,
        password: _password.text,
        confirmPassword: _confirmPassword.text,
      );
      if (mounted) setState(() => _changed = true);
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } finally {
      if (mounted) setState(() => _loading = false);
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
              GlassBackButton(
                onPressed: () => context.goNamed(AppRoute.login.name),
              ),
              const SizedBox(height: 34),
              Text(
                _changed ? 'Password changed' : 'Create new password',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _changed
                    ? 'You can now sign in with your new password.'
                    : 'Use at least 8 characters for your new password.',
                style: const TextStyle(fontSize: 13, height: 1.6, color: _grayText),
              ),
              const SizedBox(height: 28),
              if (!_changed) ...[
                AppTextField(
                  label: 'NEW PASSWORD',
                  controller: _password,
                  obscurable: true,
                  enabled: !_loading,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'CONFIRM PASSWORD',
                  controller: _confirmPassword,
                  obscurable: true,
                  enabled: !_loading,
                  textInputAction: TextInputAction.done,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFB3261E),
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                PillButton(
                  label: _loading ? 'Saving…' : 'Set new password',
                  onPressed: _loading ? null : () => unawaited(_reset()),
                ),
              ] else
                PillButton(
                  label: 'Back to sign in',
                  onPressed: () => context.goNamed(AppRoute.login.name),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
