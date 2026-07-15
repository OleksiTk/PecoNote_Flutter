import 'package:flutter/material.dart';

import '../widgets/app_buttons.dart';
import '../widgets/app_logo.dart';
import '../widgets/gradient_background.dart';
import 'auth_choice_screen.dart';
import 'login_screen.dart';

const _textColor = Color(0xFF3B4358);
const _grayText = Color(0xFF7A8296);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  static const _pageCount = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
    );
  }

  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppWordmark(fontSize: 18),
                  TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: _grayText,
                        fontWeight: FontWeight.w500,
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: PillButton(
                label: _page == _pageCount - 1 ? 'Get started' : 'Next',
                onPressed: () {
                  if (_page == _pageCount - 1) {
                    _finish();
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          SizedBox(height: 320, child: illustration),
          const SizedBox(height: 12),
          Text(
            headline,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: _grayText,
            ),
          ),
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
            color: active ? const Color(0xFF6C7BE0) : const Color(0xFFD8DEEA),
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
        Positioned(
          right: 10,
          top: 0,
          child: _Chip(icon: Icons.celebration_outlined, label: 'Fun'),
        ),
        const Positioned(
          left: 0,
          top: 60,
          child: _Chip(icon: Icons.directions_car_outlined, label: 'Transport'),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 130,
          child: _TransactionCard(),
        ),
        const Positioned(
          left: 50,
          top: 290,
          child: _Chip(icon: Icons.local_cafe_outlined, label: 'Cafés'),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E87B4).withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E87B4).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE1CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: Color(0xFFB5651D),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SILPO',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    Text(
                      'yesterday',
                      style: TextStyle(fontSize: 12, color: _grayText),
                    ),
                  ],
                ),
              ),
              const Text(
                '-₴486',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              _SubChip(label: 'Food', selected: true),
              SizedBox(width: 8),
              _SubChip(label: 'Cafés'),
              SizedBox(width: 8),
              _SubChip(label: 'Other…'),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFC9F0DA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: selected ? null : Border.all(color: const Color(0xFFE7EAF2)),
      ),
      child: Text(
        selected ? '✓ $label' : label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: selected ? const Color(0xFF2E8B57) : _grayText,
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
          iconBg: const Color(0xFFD6E6FF),
          icon: Icons.account_balance_outlined,
          iconColor: const Color(0xFF3D6FE5),
          title: 'Monobank',
          subtitle: '14 new payments',
          trailing: const Text(
            'auto',
            style: TextStyle(fontSize: 12, color: _grayText),
          ),
        ),
        const Icon(Icons.arrow_downward, color: _grayText, size: 18),
        _FlowCard(
          iconBg: const Color(0xFFD9F2E3),
          icon: Icons.rule_outlined,
          iconColor: const Color(0xFF2E8B57),
          title: 'Your rules',
          subtitle: '"SILPO → Food", 11 more',
          trailing: const Text(
            '✓13',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E8B57),
            ),
          ),
        ),
        const Icon(Icons.arrow_downward, color: _grayText, size: 18),
        _FlowCard(
          iconBg: const Color(0xFFFFE7CE),
          icon: Icons.lightbulb_outline,
          iconColor: const Color(0xFFC17A2E),
          title: 'Asks you',
          subtitle: 'only 1 unclear payment',
          subtitleColor: const Color(0xFFC17A2E),
        ),
      ],
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.subtitleColor,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E87B4).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor ?? _grayText,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
