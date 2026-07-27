import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';

const _importedCount = 214;
const _classifiedCount = 183;
const _needsHelpCount = _importedCount - _classifiedCount;

class MonobankDoneScreen extends StatelessWidget {
  const MonobankDoneScreen({super.key});

  void _sortNow(BuildContext context) {
    context.goNamed(AppRoute.monobankSort.name);
  }

  void _skip(BuildContext context) {
    context.goNamed(AppRoute.home.name);
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
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'STEP 4 OF 4',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _StepProgressBar(step: 4, total: 4),
              const SizedBox(height: 30),
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.iconBgGreen,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 30,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'All done',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your Monobank history is in. Here's how it went:",
                style: TextStyle(fontSize: 14, color: AppColors.grayText),
              ),
              const SizedBox(height: 22),
              const _StatRow(
                emoji: '🎉',
                iconBg: AppColors.accentBlueBg,
                label: 'Payments imported',
                value: '$_importedCount',
                valueColor: AppColors.textDark,
              ),
              const SizedBox(height: 12),
              const _StatRow(
                emoji: '✨',
                iconBg: AppColors.iconBgMintLight,
                label: 'Classified automatically',
                value: '$_classifiedCount',
                valueColor: AppColors.success,
              ),
              const SizedBox(height: 12),
              const _StatRow(
                emoji: '🏷️',
                iconBg: AppColors.iconBgOrange,
                label: 'Need your help',
                value: '$_needsHelpCount',
                valueColor: AppColors.iconFgOrange,
                tint: AppColors.iconBgOrange,
              ),
              const SizedBox(height: 26),
              PillButton(
                label: 'Sort $_needsHelpCount payments · ~2 min',
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
                onPressed: () => _sortNow(context),
              ),
              const SizedBox(height: 12),
              PlainLinkText(
                label: 'Skip for now — keep them in Inbox',
                onTap: () => _skip(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i < step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? AppColors.accentBlueMuted : AppColors.dotInactive,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.emoji,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.valueColor,
    this.tint,
  });

  final String emoji;
  final Color iconBg;
  final String label;
  final String value;
  final Color valueColor;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: (tint ?? AppColors.white).withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.65)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: tint == null
                        ? AppColors.textDark
                        : AppColors.iconFgOrange,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
