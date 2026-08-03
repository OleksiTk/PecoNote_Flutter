import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/labeled_field.dart';

/// Єдиний горизонтальний відступ екрана: 390 − 22×2 = 346 (ширина картки з макета).
const double _hPad = 15;

/// Висота картки в каруселі (з макета).
const double _cardHeight = 186;

/// Домашній екран PecoNote: баланс по всіх рахунках і останні транзакції.
/// Поки що статичний макет на mock-даних.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.startOnAddAccount = false});

  /// Відкрити карусель одразу на картці "Add an account" — коли сюди
  /// прийшли з "Add manually" на екрані вибору старту.
  final bool startOnAddAccount;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int _accountsPage = widget.startOnAddAccount
      ? _AccountsCarousel.addAccountPageIndex
      : 0;
  bool _cardFlipped = false;
  late final AnimationController _flipController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _onAccountsPageChanged(int page) {
    if (page != 0 && _cardFlipped) {
      _flipController.reverse();
    }
    setState(() {
      _accountsPage = page;
      if (page != 0) _cardFlipped = false;
    });
  }

  void _toggleCardFlip() {
    final flipped = !_cardFlipped;
    if (flipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _cardFlipped = flipped);
  }

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
                  padding: EdgeInsets.fromLTRB(_hPad, 18, _hPad, 0),
                  child: _HomeHeader(),
                ),
                _AccountsCarousel(
                  initialPage: _accountsPage,
                  onPageChanged: _onAccountsPageChanged,
                  flipController: _flipController,
                  onCardTap: _toggleCardFlip,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: _cardFlipped
                        ? _EditCardSheet(onDone: _toggleCardFlip)
                        : _TransactionsSheet(
                            isEmpty:
                                _accountsPage ==
                                _AccountsCarousel.addAccountPageIndex,
                          ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 32,
            bottom: 118,
            child: GestureDetector(
              onTap: () => context.pushNamed(AppRoute.newTransaction.name),
              child: const _AddButton(),
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: -5,
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
        GestureDetector(
          onTap: () => context.pushNamed(AppRoute.stats.name),
          child: Container(
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
        ),
      ],
    );
  }
}

class _AccountsCarousel extends StatefulWidget {
  const _AccountsCarousel({
    required this.onPageChanged,
    required this.flipController,
    required this.onCardTap,
    this.initialPage = 0,
  });

  final ValueChanged<int> onPageChanged;
  final AnimationController flipController;
  final VoidCallback onCardTap;
  final int initialPage;

  /// Тільки 2 картки: рахунок і "Add an account" — вона завжди останньою.
  static const pageCount = 2;
  static const addAccountPageIndex = pageCount - 1;

  @override
  State<_AccountsCarousel> createState() => _AccountsCarouselState();
}

class _AccountsCarouselState extends State<_AccountsCarousel> {
  late final PageController _controller = PageController(
    initialPage: widget.initialPage,
  );
  late int _page = widget.initialPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        SizedBox(
          height: _cardHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: _AccountsCarousel.pageCount,
            onPageChanged: (i) {
              setState(() => _page = i);
              widget.onPageChanged(i);
            },
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: _hPad),
              // Тільки перша картка (реальний рахунок) вміє перевертатись на
              // "Card settings" — "Add an account" завжди веде на форму
              // створення нового рахунку напряму.
              child: index == 0
                  ? _FlippableAccountCard(
                      controller: widget.flipController,
                      onTap: widget.onCardTap,
                    )
                  : const _AddAccountCard(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _CarouselDots(activeIndex: _page, count: _AccountsCarousel.pageCount),
      ],
    );
  }
}

class _FlippableAccountCard extends StatelessWidget {
  const _FlippableAccountCard({required this.controller, required this.onTap});

  final AnimationController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final angle = controller.value * math.pi;
          final showBack = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: showBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: const _CardSettingsFace(),
                  )
                : const _BalanceCard(),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _cardHeight,
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
          const Spacer(),
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

/// Задня грань картки рахунку — показує "Card settings" замість балансу,
/// поки картка перевернута (див. [_FlippableAccountCard]).
class _CardSettingsFace extends StatelessWidget {
  const _CardSettingsFace();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _cardHeight,
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mono Black  •4421',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
            ),
          ),
          Spacer(),
          Text(
            'Card settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAccountCard extends StatelessWidget {
  const _AddAccountCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => context.pushNamed(AppRoute.newAccount.name),
        child: CustomPaint(
          foregroundPainter: _DashedRRectBorderPainter(
            radius: 28,
            color: AppColors.white.withValues(alpha: 0.85),
          ),
          child: Container(
            width: double.infinity,
            height: _cardHeight,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.balanceGradientStart,
                  AppColors.balanceGradientMid,
                  AppColors.balanceGradientEnd,
                ],
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AddButton(),
                SizedBox(height: 14),
                Text(
                  'Add an account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cash, a card or Monobank',
                  style: TextStyle(fontSize: 13, color: AppColors.grayText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Малює переривисту рамку по заокругленому прямокутнику — у Flutter немає
/// вбудованого dashed-border, тож рамка "Add an account" рендериться вручну.
class _DashedRRectBorderPainter extends CustomPainter {
  const _DashedRRectBorderPainter({
    required this.radius,
    required this.color,
    this.strokeWidth = 1.4,
    this.dashWidth = 6,
    this.gapWidth = 5,
  });

  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
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
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
      child: const Icon(Icons.add, color: AppColors.balanceCentsText, size: 26),
    );
  }
}

class _TransactionsSheet extends StatelessWidget {
  const _TransactionsSheet({required this.isEmpty});

  /// Показує заглушку "Once you create a card…" замість списку транзакцій,
  /// коли в каруселі вибрана картка "Add an account".
  final bool isEmpty;

  static const List<_TransactionData> _transactions = [
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
    return _GlassSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Row(
              children: [
                const Text(
                  'Recent transactions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                if (!isEmpty)
                  const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlueMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (isEmpty)
            const Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 110),
                child: Center(
                  child: Text(
                    'Once you create a card, your transactions will be '
                    'visible here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: AppColors.grayText),
                  ),
                ),
              ),
            )
          else ...[
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
        ],
      ),
    );
  }
}

class _GlassSheet extends StatelessWidget {
  const _GlassSheet({required this.child});

  final Widget child;

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
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _EditCardSheet extends StatefulWidget {
  const _EditCardSheet({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_EditCardSheet> createState() => _EditCardSheetState();
}

class _EditCardSheetState extends State<_EditCardSheet> {
  final _name = TextEditingController(text: 'Mono Black');
  final _description = TextEditingController(
    text: 'Everyday spending, salary lands here',
  );
  final _balance = TextEditingController(text: '24 850.70');
  int _designIndex = 0;

  static const _designColors = [
    Color(0xFF262B3D),
    AppColors.accentBlueSoft,
    AppColors.success,
    Color(0xFFE8916A),
    Color(0xFFB98CD9),
  ];

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this card?'),
        content: const Text(
          'This removes the card and its transaction history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return _GlassSheet(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Edit card',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onDone,
                  behavior: HitTestBehavior.opaque,
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: 'NAME',
              child: TextField(
                controller: _name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'DESCRIPTION',
              child: TextField(
                controller: _description,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'BALANCE',
              child: Row(
                children: [
                  const Text(
                    '₴',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grayText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _balance,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    child: const Text(
                      'UAH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'DESIGN',
              child: Row(
                children: [
                  for (var i = 0; i < _designColors.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => setState(() => _designIndex = i),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _designColors[i],
                          shape: BoxShape.circle,
                          border: _designIndex == i
                              ? Border.all(color: AppColors.textDark, width: 2)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.75),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rules & categories',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '4 rules apply to this card',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grayText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.grayTextLight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _confirmDelete,
              behavior: HitTestBehavior.opaque,
              child: const Text(
                'Delete card',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 108),
          ],
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
      child: const Row(
        children: [
          Icon(Icons.search, size: 20, color: AppColors.placeholderGray),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: 'Search transactions…',
                hintStyle: TextStyle(
                  color: AppColors.placeholderGray,
                  fontSize: 14,
                ),
              ),
              style: TextStyle(color: AppColors.textDark, fontSize: 14),
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
              color: data.isIncome ? AppColors.income : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
