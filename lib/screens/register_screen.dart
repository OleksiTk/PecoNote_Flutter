import 'package:flutter/material.dart';

import '../widgets/app_buttons.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_background.dart';
import 'login_screen.dart';
import 'start_choice_screen.dart';

const _textColor = Color(0xFF3B4358);
const _grayText = Color(0xFF7A8296);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _has8Chars = false;
  bool _hasNumber = false;

  @override
  void initState() {
    super.initState();
    _password.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    final value = _password.text;
    setState(() {
      _has8Chars = value.length >= 8;
      _hasNumber = value.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  void dispose() {
    _password.removeListener(_onPasswordChanged);
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _continue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StartChoiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              GlassBackButton(onPressed: () => Navigator.of(context).pop()),
              const SizedBox(height: 28),
              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A minute of setup, years of calm.',
                style: TextStyle(fontSize: 14, color: _grayText),
              ),
              const SizedBox(height: 28),
              AppTextField(
                label: 'EMAIL',
                controller: _email,
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'PASSWORD',
                controller: _password,
                obscurable: true,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CheckHint(label: '8+ characters', met: _has8Chars),
                  const SizedBox(width: 16),
                  _CheckHint(label: 'contains a number', met: _hasNumber),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'CONFIRM PASSWORD',
                controller: _confirm,
                obscurable: true,
              ),
              const SizedBox(height: 24),
              PillButton(label: 'Continue', onPressed: _continue),
              const SizedBox(height: 16),
              TextLinkRow(
                prefix: 'Already registered?',
                linkLabel: 'Sign in',
                onTap: _goToLogin,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckHint extends StatelessWidget {
  const _CheckHint({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? const Color(0xFF2E8B57) : _grayText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
