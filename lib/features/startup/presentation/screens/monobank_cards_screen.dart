import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';

class _MonoCard {
  const _MonoCard({
    required this.label,
    required this.last4,
    required this.currency,
    required this.tag,
    required this.isBusiness,
  });

  final String label;
  final String last4;
  final String currency;
  final String tag;
  final bool isBusiness;
}

const _foundCards = [
  _MonoCard(
    label: 'Black',
    last4: '4421',
    currency: 'UAH',
    tag: 'main',
    isBusiness: false,
  ),
  _MonoCard(
    label: 'White',
    last4: '8830',
    currency: 'UAH',
    tag: 'everyday',
    isBusiness: false,
  ),
  _MonoCard(
    label: 'FOP',
    last4: '2201',
    currency: 'UAH',
    tag: 'business',
    isBusiness: true,
  ),
];

class MonobankCardsScreen extends StatefulWidget {
  const MonobankCardsScreen({super.key});

  @override
  State<MonobankCardsScreen> createState() => _MonobankCardsScreenState();
}

class _MonobankCardsScreenState extends State<MonobankCardsScreen> {
  final _selected = {0, 1};

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  void _continue() {
    context.pushNamed(AppRoute.monobankPeriod.name);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassBackButton(onPressed: () => context.pop()),
                  const Text(
                    'STEP 2 OF 4',
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
              const _StepProgressBar(step: 2, total: 4),
              const SizedBox(height: 28),
              const Text(
                'Which cards?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Found ${_foundCards.length} cards. Pick the ones to sync:',
                style: const TextStyle(fontSize: 14, color: AppColors.grayText),
              ),
              const SizedBox(height: 22),
              for (var i = 0; i < _foundCards.length; i++) ...[
                _CardRow(
                  card: _foundCards[i],
                  selected: _selected.contains(i),
                  onTap: () => _toggle(i),
                ),
                if (i != _foundCards.length - 1) const SizedBox(height: 12),
              ],
              const SizedBox(height: 26),
              PillButton(
                label: 'Continue · ${_selected.length} selected',
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
                onPressed: _selected.isEmpty ? null : _continue,
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

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final _MonoCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Material(
          color: AppColors.white.withValues(alpha: 0.4),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                children: [
                  _CardGlyph(isBusiness: card.isBusiness),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${card.label} •${card.last4}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${card.currency} · ${card.tag}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SelectionMark(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardGlyph extends StatelessWidget {
  const _CardGlyph({required this.isBusiness});

  final bool isBusiness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isBusiness
            ? AppColors.iconBgRed
            : AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
      ),
      child: Text(
        isBusiness ? '💼' : '💳',
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? AppColors.success
            : AppColors.white.withValues(alpha: 0.5),
        border: selected
            ? null
            : Border.all(color: AppColors.subChipBorder, width: 1.5),
      ),
      child: selected
          ? const Icon(Icons.check, size: 15, color: AppColors.white)
          : null,
    );
  }
}
