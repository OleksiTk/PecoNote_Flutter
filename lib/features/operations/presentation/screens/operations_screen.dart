import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Екран операцій PecoNote: список транзакцій, згрупованих по днях,
/// з пошуком і фільтрами. Поки що статичний макет на mock-даних.
class OperationsScreen extends StatelessWidget {
  const OperationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradientBackground(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: _OperationsHeader(),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _SearchRow(),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _FilterChipsRow(),
                ),
                SizedBox(height: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                    child: _OperationsSheet(),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: -10,
            child: SafeArea(
              top: false,
              child: AppBottomNavBar(activeTab: AppNavTab.ops),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsHeader extends StatelessWidget {
  const _OperationsHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Operations',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        Spacer(),
        Row(
          children: [
            Text(
              'June 2026',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accentBlue,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AppColors.accentBlue,
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _GlassField(
            height: 50,
            borderRadius: 18,
            child: Row(
              children: [
                SizedBox(width: 14),
                Icon(Icons.search, size: 20, color: AppColors.placeholderGray),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Search merchant, note…',
                      hintStyle: TextStyle(
                        color: AppColors.placeholderGray,
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(color: AppColors.textDark, fontSize: 14),
                  ),
                ),
                SizedBox(width: 14),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        _FilterButton(count: 2),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const _GlassField(
            height: 50,
            borderRadius: 18,
            child: Center(
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({
    required this.height,
    required this.borderRadius,
    required this.child,
  });

  final double height;
  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      // Плоский колір замість BackdropFilter: пошук і фільтр показані
      // одночасно поверх постійно анімованого фону.
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
        ),
        child: child,
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(emoji: '🌮', label: 'Food'),
          SizedBox(width: 8),
          _FilterChip(dotColor: Colors.black, label: 'Black •4421'),
          SizedBox(width: 8),
          _ClearAllChip(),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({this.emoji, this.dotColor, required this.label});

  final String? emoji;
  final Color? dotColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
          ],
          if (dotColor != null) ...[
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.close, size: 15, color: AppColors.grayText),
        ],
      ),
    );
  }
}

class _ClearAllChip extends StatelessWidget {
  const _ClearAllChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: const Text(
        'Clear all',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.grayText,
        ),
      ),
    );
  }
}

class _OperationsSheet extends StatelessWidget {
  const _OperationsSheet();

  static const List<_DaySection> _days = [
    _DaySection(
      label: 'TODAY · 11 JUL',
      total: '−₴ 828',
      transactions: [
        _TransactionData(
          emoji: '🛒',
          title: 'Silpo',
          subtitle: 'Food · 18:24',
          amount: '−₴ 642.18',
        ),
        _TransactionData(
          emoji: '🥐',
          title: 'Lviv Croissants',
          subtitle: 'Food · 13:02',
          amount: '−₴ 186.00',
        ),
      ],
    ),
    _DaySection(
      label: 'YESTERDAY · 10 JUL',
      total: '−₴ 1034',
      transactions: [
        _TransactionData(
          emoji: '🛒',
          title: 'Silpo',
          subtitle: 'Food · 18:47',
          amount: '−₴ 486.00',
        ),
        _TransactionData(
          emoji: '🍎',
          title: 'ATB Market',
          subtitle: 'Food · 12:15',
          amount: '−₴ 312.40',
        ),
        _TransactionData(
          emoji: '🥤',
          title: 'Silpo',
          subtitle: 'Food · 09:31',
          amount: '−₴ 235.60',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        // Плоский колір замість BackdropFilter: цей лист одночасно з
        // навбаром і пошуком блюрив тло на кожен кадр анімації.
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
            children: [
              for (final day in _days) ...[
                _DayHeaderRow(day: day),
                const SizedBox(height: 4),
                for (final tx in day.transactions) _TransactionTile(data: tx),
                const SizedBox(height: 14),
              ],
              const Center(child: _LoadEarlierLink()),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayHeaderRow extends StatelessWidget {
  const _DayHeaderRow({required this.day});

  final _DaySection day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            day.label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.grayText,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Text(
            day.total,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadEarlierLink extends StatelessWidget {
  const _LoadEarlierLink();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'Load earlier days',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.accentBlue,
        ),
      ),
    );
  }
}

class _DaySection {
  const _DaySection({
    required this.label,
    required this.total,
    required this.transactions,
  });

  final String label;
  final String total;
  final List<_TransactionData> transactions;
}

class _TransactionData {
  const _TransactionData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String amount;
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data});

  final _TransactionData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
            ),
            child: Text(data.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grayText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
