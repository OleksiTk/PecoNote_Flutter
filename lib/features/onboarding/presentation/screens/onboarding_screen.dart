import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/storage/app_settings_repository.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/gradient_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  static const _pageCount = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(appSettingsRepositoryProvider).setOnboardingCompleted(true);
    if (!mounted) return;
    context.goNamed(AppRoute.auth.name);
  }

  void _goToLogin() {
    context.pushNamed(AppRoute.login.name);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppWordmark(fontSize: 16),
                  TextButton(
                    onPressed: () => unawaited(_finish()),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.grayText,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _ValuePage(
                    illustration: _CategoriesIllustration(),
                    headline: 'Know where money goes',
                    subtext:
                        "Every expense lands in a clear category — you answer a quick question only when Peco isn't sure.",
                  ),
                  _ValuePage(
                    illustration: _SyncIllustration(),
                    headline: 'It learns, you relax',
                    subtext:
                        'Bank sync brings payments in; your rules sort them automatically. Peco asks only about the unclear ones.',
                  ),
                ],
              ),
            ),
            _Dots(count: _pageCount, index: _page),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: PillButton(
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
                label: _page == _pageCount - 1 ? 'Get started' : 'Next',
                onPressed: () {
                  if (_page == _pageCount - 1) {
                    unawaited(_finish());
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 14),
            PlainLinkText(
              label: 'I already have an account',
              onTap: _goToLogin,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ValuePage extends StatelessWidget {
  const _ValuePage({
    required this.illustration,
    required this.headline,
    required this.subtext,
  });

  final Widget illustration;
  final String headline;
  final String subtext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          SizedBox(height: 400, child: illustration),
          const SizedBox(height: 12),
          const Spacer(),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.grayText,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.accentBlueMuted : AppColors.dotInactive,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _CategoriesIllustration extends StatelessWidget {
  const _CategoriesIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          right: 10,
          top: 0,
          child: _Chip(emoji: '🎮', label: 'Fun'),
        ),
        const Positioned(
          left: 0,
          top: 60,
          child: _Chip(emoji: '🚕', label: 'Transport'),
        ),
        Positioned(left: 0, right: 0, top: 130, child: _TransactionCard()),
        const Positioned(
          right: 20,
          top: 320,
          child: _Chip(emoji: '☕️', label: 'Cafés'),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({this.icon, this.emoji, required this.label})
    : assert(icon != null || emoji != null, 'Потрібен icon або emoji');

  final IconData? icon;
  final String? emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.70),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (emoji != null)
                  Text(emoji!, style: const TextStyle(fontSize: 16))
                else
                  Icon(icon, size: 16, color: AppColors.textDark),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
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

class _TransactionCard extends StatelessWidget {
  const _TransactionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.65),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      child: const Text('🍞', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SILPO',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'yesterday',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '−₴ 486',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    _SubChip(label: 'Food', selected: true),
                    SizedBox(width: 8),
                    _SubChip(label: 'Cafés'),
                    SizedBox(width: 8),
                    _SubChip(label: 'Other…'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubChip extends StatelessWidget {
  const _SubChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.chipSelectedBg
            : AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(99),
        border: selected ? null : Border.all(color: AppColors.subChipBorder),
      ),
      child: Text(
        selected ? '✓ $label' : label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.success : AppColors.grayText,
        ),
      ),
    );
  }
}

class _SyncIllustration extends StatelessWidget {
  const _SyncIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FlowCard(
          iconBg: AppColors.accentBlueBg,
          emoji: '🏦',
          title: 'Monobank',
          subtitle: '14 new payments',
          trailing: const Text(
            'auto',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.success,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const _FlowArrow(length: 28),
        _FlowCard(
          iconBg: AppColors.iconBgMintLight,
          emoji: '⚙️',
          title: 'Your rules',
          subtitle: '"SILPO → Food", 11 more',
          trailing: const Text(
            '✓13',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ),
        const _FlowArrow(length: 28),
        _FlowCard(
          iconBg: AppColors.iconBgOrange,
          emoji: '🏷️',
          title: 'Asks you',
          subtitle: 'only 1 unclear payment',
          cardTint: AppColors.blobOrange,
          subtitleColor: AppColors.iconFgOrange,
        ),
      ],
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({
    required this.iconBg,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.subtitleColor,
    this.cardTint,
  });

  final Color iconBg;
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? subtitleColor;
  final Color? cardTint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: (cardTint ?? AppColors.white).withValues(alpha: 0.45),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.65),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor ?? AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowArrow extends StatelessWidget {
  const _FlowArrow({this.length = 40});

  final double length;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(16, length), painter: _ArrowPainter());
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.balanceCentsText
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;

    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), paint);

    const head = 6.0;
    canvas.drawLine(
      Offset(cx - head, size.height - head),
      Offset(cx, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(cx + head, size.height - head),
      Offset(cx, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
