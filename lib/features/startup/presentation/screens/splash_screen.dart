import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../application/controllers/startup_controller.dart';
import '../../application/providers/startup_providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(startupControllerProvider, (previous, next) {
      next.whenData((destination) {
        if (!context.mounted) return;

        switch (destination) {
          case StartupDestination.onboarding:
            context.goNamed(AppRoute.onboarding.name);
          case StartupDestination.auth:
            context.goNamed(AppRoute.auth.name);
          case StartupDestination.main:
            context.goNamed(AppRoute.startChoice.name);
        }
      });
    });

    return const GradientBackground(vivid: true, child: _SplashContent());
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const AppLogoMark(size: 76, fontSize: 34),
            const SizedBox(height: 24),
            const AppWordmark(fontSize: 36),
            const SizedBox(height: 10),
            const Text(
              'FINANCE, SOFTLY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.grayTextLight,
                letterSpacing: 2.5,
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 56),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  width: 120,
                  height: 4,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.white.withValues(alpha: 0.7),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.progressBlue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
