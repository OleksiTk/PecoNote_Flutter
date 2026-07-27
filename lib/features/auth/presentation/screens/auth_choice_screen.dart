import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/gradient_background.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  void _goToLogin(BuildContext context) {
    context.pushNamed(AppRoute.login.name);
  }

  void _goToRegister(BuildContext context) {
    context.pushNamed(AppRoute.register.name);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      vivid: true,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 4),
              const AppLogoMark(size: 68, fontSize: 30),
              const SizedBox(height: 12),
              const AppWordmark(fontSize: 28),
              const SizedBox(height: 8),
              const Text(
                'Calm control over your money.',
                style: TextStyle(fontSize: 14, color: AppColors.grayText),
              ),
              const Spacer(flex: 5),
              PillButton(
                label: 'Continue with Google',
                backgroundColor: AppColors.white.withValues(alpha: 0.75),
                leading: const Icon(
                  Icons.g_mobiledata,
                  size: 26,
                  color: AppColors.grayText,
                ),
                borderColor: AppColors.balanceGradientEnd,
                onPressed: () => _goToLogin(context),
              ),
              const SizedBox(height: 12),
              PillButton(
                label: 'Continue with Apple',
                backgroundColor: AppColors.white.withValues(alpha: 0.75),
                borderColor: AppColors.balanceGradientEnd,
                leading: const Icon(
                  Icons.apple,
                  size: 20,
                  color: AppColors.grayText,
                ),

                onPressed: () => _goToLogin(context),
              ),
              const SizedBox(height: 12),
              PillButton(
                label: 'Continue with Email',
                backgroundColor: AppColors.white.withValues(alpha: 0.75),
                borderColor: AppColors.balanceGradientEnd,
                leading: const Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: AppColors.grayText,
                ),
                onPressed: () => _goToLogin(context),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: 'No account? ',
                  style: const TextStyle(
                    color: AppColors.grayText,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: const TextStyle(
                        color: AppColors.accentBlueMuted,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _goToRegister(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grayText,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'By continuing you agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppColors.grayText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.grayText,
                          fontWeight: FontWeight.w600,
                        ),
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
