import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/gradient_background.dart';

const _totalPayments = 214;
const _blackImported = 96;
const _whiteImported = 42;
const _fopTotal = _totalPayments - _blackImported - _whiteImported;

class MonobankSyncingScreen extends StatefulWidget {
  const MonobankSyncingScreen({super.key});

  @override
  State<MonobankSyncingScreen> createState() => _MonobankSyncingScreenState();
}

class _MonobankSyncingScreenState extends State<MonobankSyncingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              context.goNamed(AppRoute.monobankDone.name);
            }
          });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;
              final current = (progress * _totalPayments).round();
              final percent = (progress * 100).round();
              final fopImported =
                  ((progress.clamp(0.64, 1.0) - 0.64) /
                          (1.0 - 0.64) *
                          _fopTotal)
                      .clamp(0, _fopTotal)
                      .round();
              final fopDone = progress >= 1.0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white.withValues(alpha: 0.55),
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.accentBlueMuted,
                            ),
                            backgroundColor: AppColors.white.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Syncing…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Importing payments from Monobank and classifying '
                    'the obvious ones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.grayText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      height: 6,
                      color: AppColors.dotInactive,
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentBlue,
                                AppColors.incomeAlt,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$current of $_totalPayments payments',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grayText,
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.iconBgMintLight.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SyncRow(
                              done: true,
                              label:
                                  'Black •4421 — $_blackImported '
                                  'payments imported',
                            ),
                            const SizedBox(height: 10),
                            _SyncRow(
                              done: true,
                              label:
                                  'White •8830 — $_whiteImported '
                                  'payments imported',
                            ),
                            const SizedBox(height: 10),
                            _SyncRow(
                              done: fopDone,
                              label: fopDone
                                  ? 'FOP UAH — $fopImported payments imported'
                                  : 'FOP UAH — importing…',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'Continue in background →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  const _SyncRow({required this.done, required this.label});

  final bool done;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          done ? Icons.check_circle : Icons.autorenew_rounded,
          size: 16,
          color: done ? AppColors.success : AppColors.grayText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: done ? AppColors.textDark : AppColors.grayText,
            ),
          ),
        ),
      ],
    );
  }
}
