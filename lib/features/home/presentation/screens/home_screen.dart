import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Домашній екран PecoNote: баланс по всіх рахунках і останні транзакції.
/// Поки що статичний макет на mock-даних.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 18, 22, 0),
                  child: _HomeHeader(),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _BalanceCard(),
                ),
                const SizedBox(height: 12),
                const _CarouselDots(activeIndex: 0, count: 4),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                    child: _TransactionsSheet(),
                  ),
                ),
              ],
            ),
          ),

          Positioned(right: 26, bottom: 110, child: _AddButton()),

          const Positioned(
            left: 0,
            right: 0,
            bottom: -10,
            child: SafeArea(
              top: false,
              child: AppBottomNavBar(activeTab: AppNavTab.home),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accentBlueBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
          ),
          child: const Text(
            'D',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.accentBlue,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.75),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
          ),
          child: const Icon(
            Icons.bar_chart_rounded,
            size: 20,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 186,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.85)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.balanceGradientStart,
            AppColors.balanceGradientMid,
            AppColors.balanceGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'All accounts',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
                child: const Text(
                  '3 linked',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 52),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '₴ 27 970',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '.70',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.balanceCentsText,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Total balance',
            style: TextStyle(fontSize: 13, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? AppColors.accentBlue
                : AppColors.accentBlue.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.add, color: AppColors.accentBlue, size: 26),
    );
  }
}

class _TransactionsSheet extends StatelessWidget {
  _TransactionsSheet();

  final List<_TransactionData> _transactions = const [
    _TransactionData(
      emoji: '🛒',
      title: 'Silpo',
      subtitle: 'Groceries · 18:24',
      amount: '−₴ 642.18',
      isIncome: false,
    ),
    _TransactionData(
      emoji: '💼',
      title: 'Salary',
      subtitle: 'Income · 09:00',
      amount: '+₴ 46 000',
      isIncome: true,
    ),
    _TransactionData(
      emoji: '🚕',
      title: 'Uklon',
      subtitle: 'Transport · Yesterday',
      amount: '−₴ 185.00',
      isIncome: false,
    ),
    _TransactionData(
      emoji: '☕️',
      title: 'Blur Coffee',
      subtitle: 'Cafés · Yesterday',
      amount: '−₴ 238.50',
      isIncome: false,
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
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  child: Row(
                    children: const [
                      Text(
                        'Recent transactions',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 0, 18, 6),
                  child: _SearchField(),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
                    itemCount: _transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                    itemBuilder: (context, index) =>
                        _TransactionTile(data: _transactions[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.75)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.placeholderGray),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'Search transactions…',
                hintStyle: TextStyle(
                  color: AppColors.placeholderGray,
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionData {
  const _TransactionData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              // Витрати — спокійний темний, зелений лише для доходу.
              color: data.isIncome ? AppColors.income : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
