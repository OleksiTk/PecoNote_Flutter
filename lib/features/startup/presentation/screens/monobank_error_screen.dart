import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Shown when a Monobank token turns out to be invalid/revoked while
/// connecting or syncing. Not wired into the router yet — hook it up
/// wherever the token exchange/sync call can fail.
class MonobankErrorScreen extends StatelessWidget {
  const MonobankErrorScreen({
    super.key,
    this.onChangeToken,
    this.onTryAgain,
    this.onLater,
  });

  final VoidCallback? onChangeToken;
  final VoidCallback? onTryAgain;
  final VoidCallback? onLater;

  static const _tips = [
    'Generate a fresh token at api.monobank.ua',
    'Check your internet connection',
    'Try again in a few minutes',
  ];

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.iconBgRed,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBlue.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.expense,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                "Couldn't connect Monobank",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "The token didn't work — it may have been revoked or "
                'mistyped. Your data is safe; nothing was imported.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grayText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                // Плоский колір замість BackdropFilter — під анімованим
                // фоном лише плями градієнта без деталей, тож блюр не
                // додає нічого візуально.
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WHAT TO TRY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.labelGray,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final tip in _tips)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '· $tip',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grayText,
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              PillButton(
                label: 'Change token',
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
                onPressed: onChangeToken ?? () {},
              ),
              const SizedBox(height: 14),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: onTryAgain ?? () {},
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        'Try again',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: onLater ?? () {},
                      behavior: HitTestBehavior.opaque,
                      child: const Text(
                        'Later',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grayTextLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
