import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/labeled_field.dart';
import '../../../accounts/application/providers/accounts_providers.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../transactions/application/providers/transactions_providers.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/models/transaction_draft.dart'
    show formatCurrencyAmount;

/// Єдиний горизонтальний відступ екрана: 390 − 22×2 = 346 (ширина картки з макета).
const double _hPad = 15;

/// Висота картки в каруселі (з макета).
const double _cardHeight = 186;

const int _accountNameMaxLength = 64;
const int _accountDescriptionMaxLength = 256;

/// Домашній екран PecoNote: карусель рахунків підтягується з GET /accounts/,
/// а стрічка "Recent transactions" — з GET /transactions/. Створення й
/// видалення обох йдуть через ту саму API.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.startOnAddAccount = false});

  /// Відкрити карусель одразу на картці "Add an account". Насправді це вже
  /// поведінка за замовчуванням для щойно зареєстрованого користувача — у
  /// нього просто ще немає жодного рахунку, тож картка "Add an account"
  /// і так стоїть першою (index 0).
  final bool startOnAddAccount;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _accountsPage = 0;
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

  void _onAccountsPageChanged(int page, int addAccountIndex) {
    if (page != addAccountIndex && _cardFlipped) {
      _flipController.reverse();
    }
    setState(() {
      _accountsPage = page;
      if (page != addAccountIndex) _cardFlipped = false;
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

  Future<void> _deleteAccount(Account account) async {
    await ref.read(accountsProvider.notifier).delete(account.id);
    if (mounted) _toggleCardFlip();
  }

  Future<void> _updateAccount(
    Account account, {
    required String name,
    String? description,
  }) {
    return ref
        .read(accountsProvider.notifier)
        .updateAccount(
          id: account.id,
          name: name,
          description: description,
          currencyId: account.currencyId,
        );
  }

  void _handleMissingAccount() {
    if (_cardFlipped) _toggleCardFlip();
    ref.invalidate(accountsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This account no longer exists.')),
    );
  }

  Future<void> _deleteTransaction(Transaction transaction) {
    return ref.read(transactionsProvider.notifier).trash(transaction.id);
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);
    final accounts = accountsAsync.value ?? const <Account>[];
    final isLoaded = accountsAsync.hasValue;
    final addAccountIndex = isLoaded ? accounts.length : 0;
    final pageCount = isLoaded ? accounts.length + 1 : 1;
    final showEditSheet = _cardFlipped && _accountsPage < accounts.length;
    final transactionsAsync = ref.watch(transactionsProvider);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

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
                Offstage(
                  offstage: keyboardOpen,
                  child: _AccountsCarousel(
                    // Новий ключ на кожну зміну кількості сторінок — це
                    // перестворює PageController з правильним initialPage,
                    // коли список рахунків щойно завантажився.
                    key: ValueKey('accounts-$pageCount'),
                    accounts: accounts,
                    pageCount: pageCount,
                    addAccountIndex: addAccountIndex,
                    isLoading:
                        accountsAsync.isLoading && !accountsAsync.hasValue,
                    hasError: accountsAsync.hasError,
                    onRetry: () => ref.invalidate(accountsProvider),
                    onPageChanged: (page) =>
                        _onAccountsPageChanged(page, addAccountIndex),
                    flipController: _flipController,
                    onCardTap: _toggleCardFlip,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _hPad),
                    child: showEditSheet
                        ? _EditCardSheet(
                            account: accounts[_accountsPage],
                            onSave: (name, description) => _updateAccount(
                              accounts[_accountsPage],
                              name: name,
                              description: description,
                            ),
                            onDone: _toggleCardFlip,
                            onAccountMissing: _handleMissingAccount,
                            onDelete: () =>
                                _deleteAccount(accounts[_accountsPage]),
                          )
                        : _TransactionsSheet(
                            hasAccounts: _accountsPage < accounts.length,
                            transactionsAsync: transactionsAsync,
                            onRetry: () => ref.invalidate(transactionsProvider),
                            onDelete: _deleteTransaction,
                          ),
                  ),
                ),
              ],
            ),
          ),

          if (!keyboardOpen)
            Positioned(
              right: 32,
              bottom: 118,
              child: GestureDetector(
                onTap: () => context.pushNamed(AppRoute.newTransaction.name),
                child: const _AddButton(),
              ),
            ),

          if (!keyboardOpen)
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
    super.key,
    required this.accounts,
    required this.pageCount,
    required this.addAccountIndex,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
    required this.onPageChanged,
    required this.flipController,
    required this.onCardTap,
  });

  final List<Account> accounts;
  final int pageCount;
  final int addAccountIndex;
  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;
  final ValueChanged<int> onPageChanged;
  final AnimationController flipController;
  final VoidCallback onCardTap;

  @override
  State<_AccountsCarousel> createState() => _AccountsCarouselState();
}

class _AccountsCarouselState extends State<_AccountsCarousel> {
  late final PageController _controller = PageController();
  int _page = 0;

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
            clipBehavior: Clip.none,
            itemCount: widget.pageCount,
            onPageChanged: (i) {
              setState(() => _page = i);
              widget.onPageChanged(i);
            },
            itemBuilder: (context, index) {
              late final Widget child;
              if (widget.hasError) {
                child = _AccountsErrorCard(onRetry: widget.onRetry);
              } else if (widget.isLoading) {
                child = const _AccountsLoadingCard();
              } else if (index == widget.addAccountIndex) {
                child = const _AddAccountCard();
              } else {
                child = _FlippableAccountCard(
                  account: widget.accounts[index],
                  totalLinked: widget.accounts.length,
                  controller: widget.flipController,
                  onTap: widget.onCardTap,
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: _hPad),
                child: child,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _CarouselDots(activeIndex: _page, count: widget.pageCount),
      ],
    );
  }
}

class _AccountsLoadingCard extends StatelessWidget {
  const _AccountsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _cardHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.85)),
        color: AppColors.white.withValues(alpha: 0.5),
      ),
      child: const CircularProgressIndicator(
        strokeWidth: 2.4,
        color: AppColors.accentBlue,
      ),
    );
  }
}

class _AccountsErrorCard extends StatelessWidget {
  const _AccountsErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _cardHeight,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.85)),
        color: AppColors.white.withValues(alpha: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Could not load your accounts.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppColors.grayText),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onRetry,
            behavior: HitTestBehavior.opaque,
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlippableAccountCard extends StatelessWidget {
  const _FlippableAccountCard({
    required this.account,
    required this.totalLinked,
    required this.controller,
    required this.onTap,
  });

  final Account account;
  final int totalLinked;
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
                    child: _CardSettingsFace(account: account),
                  )
                : _BalanceCard(account: account, totalLinked: totalLinked),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.account, required this.totalLinked});

  final Account account;
  final int totalLinked;

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
              Expanded(
                child: Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
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
                child: Text(
                  '$totalLinked linked',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Бекенд поки не має ендпоінта балансу по рахунку (лише зведений
          // /balances/ звіт) — показуємо чесний нуль, а не вигадане число.
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '₴ 0',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '.00',
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
  const _CardSettingsFace({required this.account});

  final Account account;

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
          Text(
            account.description?.isNotEmpty == true
                ? account.description!
                : account.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.grayText,
            ),
          ),
          const Spacer(),
          const Text(
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
  const _TransactionsSheet({
    required this.hasAccounts,
    required this.transactionsAsync,
    required this.onRetry,
    required this.onDelete,
  });

  /// Показує заглушку "Once you create a card…" замість списку транзакцій,
  /// коли в каруселі вибрана картка "Add an account" (або рахунків ще нема).
  final bool hasAccounts;
  final AsyncValue<List<Transaction>> transactionsAsync;
  final VoidCallback onRetry;
  final Future<void> Function(Transaction transaction) onDelete;

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
                if (hasAccounts)
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
          if (!hasAccounts)
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
          else
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) => transactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(32, 0, 32, 110),
                        child: Center(
                          child: Text(
                            'No transactions yet. Tap the + button to add one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.grayText,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(18, 0, 18, 6),
                            child: _SearchField(),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                18,
                                6,
                                18,
                                110,
                              ),
                              itemCount: transactions.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 2),
                              itemBuilder: (context, index) => _TransactionTile(
                                data: transactions[index],
                                onDelete: () => onDelete(transactions[index]),
                              ),
                            ),
                          ),
                        ],
                      ),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.accentBlue,
                  ),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 110),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Could not load your transactions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.grayText,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: onRetry,
                          behavior: HitTestBehavior.opaque,
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _formatTransactionTime(DateTime occurredAt) {
  final local = occurredAt.toLocal();
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final time = DateFormat('HH:mm').format(local);
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  if (isSameDay(local, now)) return 'Today · $time';
  if (isSameDay(local, yesterday)) return 'Yesterday · $time';
  return '${DateFormat('d MMM').format(local)} · $time';
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
  const _EditCardSheet({
    required this.account,
    required this.onSave,
    required this.onDone,
    required this.onAccountMissing,
    required this.onDelete,
  });

  final Account account;
  final Future<void> Function(String name, String? description) onSave;
  final VoidCallback onDone;
  final VoidCallback onAccountMissing;
  final Future<void> Function() onDelete;

  @override
  State<_EditCardSheet> createState() => _EditCardSheetState();
}

class _EditCardSheetState extends State<_EditCardSheet> {
  late final _name = TextEditingController(text: widget.account.name);
  late final _description = TextEditingController(
    text: widget.account.description ?? '',
  );
  bool _saving = false;
  bool _deleting = false;
  Map<String, List<String>> _fieldErrors = const {};
  String? _saveError;
  String? _deleteError;

  String? _fieldError(String field) => _fieldErrors[field]?.join('\n');

  void _clearFieldError(String field) {
    if (!_fieldErrors.containsKey(field)) return;
    setState(() {
      _fieldErrors = Map.of(_fieldErrors)..remove(field);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _deleting) return;

    final name = _name.text.trim();
    final description = _description.text.trim();
    if (name.isEmpty) {
      setState(() {
        _fieldErrors = const {
          'name': ['Enter an account name.'],
        };
        _saveError = null;
      });
      return;
    }

    setState(() {
      _saving = true;
      _fieldErrors = const {};
      _saveError = null;
    });
    try {
      await widget.onSave(name, description.isEmpty ? null : description);
      if (mounted) widget.onDone();
    } on NotFoundFailure {
      if (mounted) widget.onAccountMissing();
    } on ValidationFailure catch (failure) {
      if (mounted) {
        final hasUnboundErrors = failure.fieldErrors.keys.any(
          (field) => field != 'name' && field != 'description',
        );
        setState(() {
          _fieldErrors = failure.fieldErrors;
          _saveError = hasUnboundErrors ? failure.message : null;
        });
      }
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _saveError = failure.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this card?'),
        content: const Text(
          'The account can be deleted only if it has no linked transactions.',
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
    if (confirmed != true || !mounted || _saving) return;

    setState(() {
      _deleting = true;
      _deleteError = null;
    });
    try {
      await widget.onDelete();
    } on AppFailure {
      if (mounted) {
        setState(
          () => _deleteError =
              'Не вдалося видалити рахунок. Перевірте, чи немає '
              'пов’язаних транзакцій.',
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
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
                  onTap: _saving || _deleting ? null : _save,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    _saving ? 'Saving…' : 'Done',
                    style: const TextStyle(
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
                enabled: !_saving && !_deleting,
                maxLength: _accountNameMaxLength,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _clearFieldError('name'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  errorText: _fieldError('name'),
                ),
              ),
            ),
            const SizedBox(height: 14),
            LabeledField(
              label: 'DESCRIPTION',
              child: TextField(
                controller: _description,
                enabled: !_saving && !_deleting,
                maxLength: _accountDescriptionMaxLength,
                buildCounter:
                    (
                      context, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null,
                textInputAction: TextInputAction.done,
                onChanged: (_) => _clearFieldError('description'),
                onSubmitted: (_) => _save(),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  errorText: _fieldError('description'),
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (_saveError != null) ...[
              Text(
                _saveError!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
              const SizedBox(height: 8),
            ],
            if (_deleteError != null) ...[
              Text(
                _deleteError!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
              const SizedBox(height: 8),
            ],
            GestureDetector(
              onTap: _deleting || _saving ? null : _confirmDelete,
              behavior: HitTestBehavior.opaque,
              child: Text(
                _deleting ? 'Deleting…' : 'Delete card',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _deleting || _saving
                      ? AppColors.error.withValues(alpha: 0.5)
                      : AppColors.error,
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data, required this.onDelete});

  final Transaction data;
  final Future<void> Function() onDelete;

  static const _emojiByType = {
    TransactionType.income: '💼',
    TransactionType.expense: '🧾',
    TransactionType.transfer: '🔁',
  };

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this transaction?'),
        content: const Text(
          'It will be moved to trash and removed from your totals.',
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
    if (confirmed != true) return;
    try {
      await onDelete();
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = data.type == TransactionType.income;
    final title = data.description?.isNotEmpty == true
        ? data.description!
        : switch (data.type) {
            TransactionType.income => 'Income',
            TransactionType.expense => 'Expense',
            TransactionType.transfer => 'Transfer',
          };
    final sign = switch (data.type) {
      TransactionType.expense => '−',
      TransactionType.income => '+',
      TransactionType.transfer => '',
    };

    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      behavior: HitTestBehavior.opaque,
      child: Padding(
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
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
              child: Text(
                _emojiByType[data.type] ?? '🧾',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTransactionTime(data.occurredAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$sign₴ ${formatCurrencyAmount(data.total)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.income : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
