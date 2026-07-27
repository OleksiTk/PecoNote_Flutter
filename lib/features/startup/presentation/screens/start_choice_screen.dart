import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../../../shared/widgets/gradient_background.dart';

class StartChoiceScreen extends ConsumerStatefulWidget {
  const StartChoiceScreen({super.key});

  @override
  ConsumerState<StartChoiceScreen> createState() => _StartChoiceScreenState();
}

class _StartChoiceScreenState extends ConsumerState<StartChoiceScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() => _signingOut = true);
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) setState(() => _signingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'How do you want to start?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick one — you can change this later.',
                style: TextStyle(fontSize: 14, color: AppColors.grayText),
              ),
              const SizedBox(height: 30),
              _StartOption(
                iconBg: AppColors.accentBlueBg,
                emoji: '🏦',
                title: 'Connect Monobank',
                subtitle: 'Import payments automatically — 2 minutes.',
                badge: 'popular',
                onTap: () => context.pushNamed(AppRoute.connectMonobank.name),
              ),
              const SizedBox(height: 14),
              _StartOption(
                iconBg: AppColors.iconBgOrange,
                emoji: '✍️',
                title: 'Add manually',
                subtitle: 'Create an account and track operations yourself.',
                onTap: () => _selectAndContinue(context, 'Add manually'),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAndContinue(BuildContext context, String option) {
    context.goNamed(AppRoute.ready.name, queryParameters: {'option': option});
  }
}

class _StartOption extends StatelessWidget {
  const _StartOption({
    required this.iconBg,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final Color iconBg;
  final String emoji;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Material(
            color: AppColors.white.withValues(alpha: 0.5),
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              if (badge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBlueBg,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    badge!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.grayText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key, required this.option});

  final String option;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      vivid: true,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "You're all set",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grayText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
