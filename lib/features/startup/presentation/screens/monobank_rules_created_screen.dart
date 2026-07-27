import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';

const _paymentsImported = 214;
const _sortedByYou = 31;
const _rulesCreated = 8;

class MonobankRulesCreatedScreen extends StatelessWidget {
  const MonobankRulesCreatedScreen({super.key});

  void _goToDashboard(BuildContext context) {
    context.goNamed(AppRoute.home.name);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBlue.withValues(alpha: 0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text('🌿', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 22),
              const Text(
                'Rules created',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Every payment is sorted, and PecoNote learned your '
                'habits. Similar payments will be classified '
                'automatically from now on.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grayText,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Row(
                      children: [
                        _StatColumn(
                          value: '$_paymentsImported',
                          label: 'payments\nimported',
                          color: AppColors.textDark,
                        ),
                        _StatDivider(),
                        _StatColumn(
                          value: '$_sortedByYou',
                          label: 'sorted\nby you',
                          color: AppColors.textDark,
                        ),
                        _StatDivider(),
                        _StatColumn(
                          value: '$_rulesCreated',
                          label: 'rules\ncreated',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              PillButton(
                label: 'Go to dashboard',
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
                onPressed: () => _goToDashboard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppColors.subChipBorder);
  }
}
