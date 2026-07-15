import 'package:flutter/material.dart';

import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_background.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'start_choice_screen.dart';

const _textColor = Color(0xFF3B4358);
const _grayText = Color(0xFF7A8296);
const _accentBlue = Color(0xFF3D6FE5);

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _goToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _goToStartChoice(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StartChoiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      vivid: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 4),
              const AppLogoMark(size: 76, fontSize: 34),
              const SizedBox(height: 20),
              const AppWordmark(fontSize: 32),
              const SizedBox(height: 10),
              const Text(
                'Calm control over your money.',
                style: TextStyle(fontSize: 14, color: _grayText),
              ),
              const Spacer(flex: 5),
              PillButton(
                label: 'Continue with Google',
                leading: const Icon(Icons.g_mobiledata, size: 26, color: _textColor),
                onPressed: () => _goToStartChoice(context),
              ),
              const SizedBox(height: 12),
              PillButton(
                label: 'Continue with Apple',
                leading: const Icon(Icons.apple, size: 20, color: _textColor),
                onPressed: () => _goToStartChoice(context),
              ),
              const SizedBox(height: 12),
              PillButton(
                label: 'Continue with Email',
                backgroundColor: const Color(0xFFEDE9FE),
                leading: const Icon(Icons.email_outlined, size: 20, color: _textColor),
                onPressed: () => _goToLogin(context),
              ),
              const SizedBox(height: 16),
              TextLinkRow(
                prefix: 'No account?',
                linkLabel: 'Sign up',
                onTap: () => _goToRegister(context),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(fontSize: 11, color: _grayText, height: 1.4),
                    children: [
                      TextSpan(text: 'By continuing you agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(color: _accentBlue, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: _accentBlue, fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
