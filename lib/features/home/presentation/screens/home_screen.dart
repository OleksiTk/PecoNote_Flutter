import 'package:flutter/material.dart';

import '../../../../shared/widgets/gradient_background.dart';

const _textColor = Color(0xFF3B4358);
const _grayText = Color(0xFF7A8296);
const _accentBlue = Color(0xFF3D6FE5);

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
            const _BottomNavBar(activeIndex: 0),
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
            color: const Color(0xFFD6E6FF),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          ),
          child: const Text(
            'D',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _accentBlue,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          ),
          child: const Icon(
            Icons.bar_chart_rounded,
            size: 20,
            color: _textColor,
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF2FF), Color(0xFFFCEFE6), Color(0xFFF6F8FC)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E87B4).withValues(alpha: 0.14),
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
                  color: _textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                child: const Text(
                  '3 linked',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
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
                    color: _textColor,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '.70',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7690),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Total balance',
            style: TextStyle(fontSize: 13, color: _grayText),
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
                ? _accentBlue
                : _accentBlue.withValues(alpha: 0.25),
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
      iconBg: const Color(0xFFE0F3E6),
      iconColor: const Color(0xFF3F9463),
      title: 'Silpo',
      subtitle: 'Groceries · 18:24',
      amount: '−₴ 642.18',
      isIncome: false,
    ),
    _TransactionData(
      icon: Icons.work_outline,
      iconBg: const Color(0xFFF7E1E4),
      iconColor: const Color(0xFF9C3B49),
      title: 'Salary',
      subtitle: 'Income · 09:00',
      amount: '+₴ 46 000',
      isIncome: true,
    ),
    _TransactionData(
      icon: Icons.directions_car_outlined,
      iconBg: const Color(0xFFFBEFD9),
      iconColor: const Color(0xFFB9862E),
      title: 'Uklon',
      subtitle: 'Transport · Yesterday',
      amount: '−₴ 185.00',
      isIncome: false,
    ),
    _TransactionData(
      icon: Icons.local_cafe_outlined,
      iconBg: const Color(0xFFEFE2D8),
      iconColor: const Color(0xFF8C6A4E),
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
            color: Colors.white,
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
                        color: _textColor,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _accentBlue,
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
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6E87B4).withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: _accentBlue, size: 26),
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
        color: const Color(0xFFF3F4F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: Color(0xFF9AA2B5)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search transactions…',
                hintStyle: TextStyle(color: Color(0xFF9AA2B5), fontSize: 14),
              ),
              style: const TextStyle(color: _textColor, fontSize: 14),
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
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: const TextStyle(fontSize: 12, color: _grayText),
                ),
              ],
            ),
          ),
          Text(
            data.amount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: data.isIncome
                  ? const Color(0xFF2FA36B)
                  : const Color(0xFFD1445B),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.activeIndex});

  final int activeIndex;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.list_alt_outlined, label: 'Ops'),
    (icon: Icons.inbox_outlined, label: 'Inbox'),
    (icon: Icons.bar_chart_rounded, label: 'Stats'),
    (icon: Icons.tune_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final active = i == activeIndex;
          final color = active ? _accentBlue : const Color(0xFF9AA2B5);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(item.icon, size: 22, color: color),
                  if (item.label == 'Inbox')
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0525F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
