import 'package:flutter/material.dart';

import '../widgets/app_buttons.dart';
import '../widgets/app_text_field.dart';
import '../widgets/gradient_background.dart';
import 'register_screen.dart';
import 'start_choice_screen.dart';

const _textColor = Color(0xFF3B4358);
const _grayText = Color(0xFF7A8296);
const _accentBlue = Color(0xFF3D6FE5);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _signIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StartChoiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              GlassBackButton(onPressed: () => Navigator.of(context).pop()),
              const SizedBox(height: 28),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to your PecoNote account.',
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: _accentBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PillButton(
                label: 'Sign in',
                backgroundColor: const Color(0xFF2B3040),
                foregroundColor: Colors.white,
                onPressed: _signIn,
              ),
              const SizedBox(height: 16),
              TextLinkRow(
                prefix: 'New here?',
                linkLabel: 'Create account',
                onTap: _goToRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
