import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Домашній екран PecoNote: баланс по всіх рахунках і останні транзакції.
/// Лише статичний макет (mock-дані) — без реальних провайдерів чи навігації.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _HomeHeader(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _BalanceCard(),
            ),
            const SizedBox(height: 10),
            const _CarouselDots(activeIndex: 0, count: 4),
            const SizedBox(height: 16),
            Expanded(child: _TransactionsSheet()),
            const AppBottomNavBar(activeTab: AppNavTab.home),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
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
          const SizedBox(height: 20),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '₴ 27 970',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '.70',
                  style: TextStyle(
                    fontSize: 20,
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

class _TransactionsSheet extends StatelessWidget {
  _TransactionsSheet();

  final List<_TransactionData> _transactions = [
    _TransactionData(
      icon: Icons.shopping_cart_outlined,
      iconBg: AppColors.iconBgGreen,
      iconColor: AppColors.iconFgGreen,
      title: 'Silpo',
      subtitle: 'Groceries · 18:24',
      amount: '−₴ 642.18',
      isIncome: false,
    ),
    _TransactionData(
      icon: Icons.work_outline,
      iconBg: AppColors.iconBgRed,
      iconColor: AppColors.iconFgRed,
      title: 'Salary',
      subtitle: 'Income · 09:00',
      amount: '+₴ 46 000',
      isIncome: true,
    ),
    _TransactionData(
      icon: Icons.directions_car_outlined,
      iconBg: AppColors.iconBgYellow,
      iconColor: AppColors.iconFgYellow,
      title: 'Uklon',
      subtitle: 'Transport · Yesterday',
      amount: '−₴ 185.00',
      isIncome: false,
    ),
    _TransactionData(
      icon: Icons.local_cafe_outlined,
      iconBg: AppColors.iconBgBrown,
      iconColor: AppColors.iconFgBrown,
      title: 'Blur Coffee',
      subtitle: 'Cafés · Yesterday',
      amount: '−₴ 238.50',
      isIncome: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      'Recent transactions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    const Text(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _SearchField(),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 88),
                  itemCount: _transactions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) =>
                      _TransactionTile(data: _transactions[index]),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 24,
          child: Container(
            width: 56,
            height: 56,
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
          ),
        ),
      ],
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
        color: AppColors.searchFieldBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.placeholderGray),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search transactions…',
                hintStyle: TextStyle(color: AppColors.placeholderGray, fontSize: 14),
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
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: data.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, size: 20, color: data.iconColor),
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
                  style: const TextStyle(fontSize: 12, color: AppColors.grayText),
                ),
              ],
            ),
          ),
          Text(
            data.amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: data.isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}
