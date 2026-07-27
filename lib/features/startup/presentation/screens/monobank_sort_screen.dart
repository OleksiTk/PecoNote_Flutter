import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';

class _Category {
  const _Category(this.emoji, this.label);

  final String emoji;
  final String label;
}

const _categories = [
  _Category('🍔', 'Food'),
  _Category('🚕', 'Transport'),
  _Category('🛍️', 'Shopping'),
  _Category('🎮', 'Entertainment'),
  _Category('🧾', 'Bills'),
  _Category('❓', 'Other'),
];

class _PaymentGroup {
  const _PaymentGroup({
    required this.merchant,
    required this.merchantEmoji,
    required this.paymentsCount,
    required this.card,
    required this.amount,
    required this.guess,
  });

  final String merchant;
  final String merchantEmoji;
  final int paymentsCount;
  final String card;
  final int amount;
  final _Category guess;
}

const _groups = [
  _PaymentGroup(
    merchant: 'SILPO',
    merchantEmoji: '📦',
    paymentsCount: 4,
    card: 'Black •4421',
    amount: 1944,
    guess: _Category('🍞', 'Food'),
  ),
  _PaymentGroup(
    merchant: 'Steam',
    merchantEmoji: '🎮',
    paymentsCount: 2,
    card: 'Black •4421',
    amount: 799,
    guess: _Category('🎮', 'Entertainment'),
  ),
  _PaymentGroup(
    merchant: 'Uklon',
    merchantEmoji: '🚕',
    paymentsCount: 6,
    card: 'White •8830',
    amount: 612,
    guess: _Category('🚕', 'Transport'),
  ),
  _PaymentGroup(
    merchant: 'Rozetka',
    merchantEmoji: '🛍️',
    paymentsCount: 3,
    card: 'White •8830',
    amount: 3280,
    guess: _Category('🛍️', 'Shopping'),
  ),
  _PaymentGroup(
    merchant: 'Kyivstar',
    merchantEmoji: '📶',
    paymentsCount: 1,
    card: 'FOP •2201',
    amount: 300,
    guess: _Category('🧾', 'Bills'),
  ),
  _PaymentGroup(
    merchant: "McDonald's",
    merchantEmoji: '🍔',
    paymentsCount: 5,
    card: 'Black •4421',
    amount: 860,
    guess: _Category('🍔', 'Food'),
  ),
  _PaymentGroup(
    merchant: 'Netflix',
    merchantEmoji: '🎬',
    paymentsCount: 1,
    card: 'White •8830',
    amount: 149,
    guess: _Category('🎬', 'Entertainment'),
  ),
  _PaymentGroup(
    merchant: 'ATB',
    merchantEmoji: '🛒',
    paymentsCount: 2,
    card: 'Black •4421',
    amount: 540,
    guess: _Category('🍞', 'Food'),
  ),
  _PaymentGroup(
    merchant: 'Unknown transfer',
    merchantEmoji: '❓',
    paymentsCount: 2,
    card: 'FOP •2201',
    amount: 1200,
    guess: _Category('❓', 'Other'),
  ),
];

class MonobankSortScreen extends StatefulWidget {
  const MonobankSortScreen({super.key});

  @override
  State<MonobankSortScreen> createState() => _MonobankSortScreenState();
}

class _MonobankSortScreenState extends State<MonobankSortScreen> {
  int _index = 0;
  bool _remember = true;

  void _advance() {
    if (_index == _groups.length - 1) {
      context.goNamed(AppRoute.monobankRulesCreated.name);
      return;
    }
    setState(() {
      _index++;
      _remember = true;
    });
  }

  Future<void> _pickOther() async {
    final chosen = await showModalBottomSheet<_Category>(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (context) => _CategoryPickerSheet(current: _groups[_index].guess),
    );
    if (chosen != null) _advance();
  }

  @override
  Widget build(BuildContext context) {
    final group = _groups[_index];
    final isLast = _index == _groups.length - 1;
    final next = isLast ? null : _groups[_index + 1];

    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  GlassBackButton(onPressed: () => context.pop()),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Sort payments',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
              const SizedBox(height: 14),
              _GroupProgressBar(step: _index + 1, total: _groups.length),
              const SizedBox(height: 10),
              Text(
                'group ${_index + 1} of ${_groups.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grayText,
                ),
              ),
              const SizedBox(height: 18),
              _PaymentCard(
                key: ValueKey(_index),
                group: group,
                remember: _remember,
                onToggleRemember: () =>
                    setState(() => _remember = !_remember),
                onConfirmGuess: _advance,
                onOther: _pickOther,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _advance,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Skip this group',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.grayTextLight,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (next != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      child: Text(
                        '${next.merchantEmoji}  next: ${next.merchant}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grayText,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupProgressBar extends StatelessWidget {
  const _GroupProgressBar({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i < step;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
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

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    super.key,
    required this.group,
    required this.remember,
    required this.onToggleRemember,
    required this.onConfirmGuess,
    required this.onOther,
  });

  final _PaymentGroup group;
  final bool remember;
  final VoidCallback onToggleRemember;
  final VoidCallback onConfirmGuess;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBlue.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  group.merchantEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                group.merchant,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${group.paymentsCount} payments · ${group.card}',
                style: const TextStyle(fontSize: 13, color: AppColors.grayText),
              ),
              const SizedBox(height: 16),
              Text(
                '−₴${group.amount}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.searchFieldBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Peco guesses: ',
                      style: TextStyle(fontSize: 13, color: AppColors.grayText),
                    ),
                    Text(
                      '${group.guess.emoji} ${group.guess.label}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ChoiceButton(
                      label: '✓ ${group.guess.label}',
                      selected: true,
                      onTap: onConfirmGuess,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ChoiceButton(
                      label: 'Other…',
                      selected: false,
                      onTap: onOther,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onToggleRemember,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      remember
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 16,
                      color: remember
                          ? AppColors.success
                          : AppColors.grayTextLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Remember for future payments',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: remember
                            ? AppColors.success
                            : AppColors.grayTextLight,
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

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.chipSelectedBg : AppColors.white.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: selected
                ? null
                : Border.all(color: AppColors.subChipBorder),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected ? AppColors.success : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({required this.current});

  final _Category current;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: BoxDecoration(
            color: AppColors.scaffoldVivid.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.dotInactive,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Choose a category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              for (final category in _categories)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  title: Text(
                    category.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  trailing: category.label == current.label
                      ? const Icon(Icons.check, color: AppColors.success)
                      : null,
                  onTap: () => Navigator.of(context).pop(category),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
