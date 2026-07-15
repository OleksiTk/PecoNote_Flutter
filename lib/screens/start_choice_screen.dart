import 'package:flutter/material.dart';

import '../widgets/gradient_background.dart';

const _textColor = Color(0xFF3B4358);
const _grayText = Color(0xFF7A8296);
const _accentBlue = Color(0xFF3D6FE5);

class StartChoiceScreen extends StatelessWidget {
  const StartChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),
              const Text(
                'How do you want to start?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pick one — you can change this later.',
                style: TextStyle(fontSize: 14, color: _grayText),
              ),
              const SizedBox(height: 28),
              _StartOption(
                iconBg: const Color(0xFFD6E6FF),
                icon: Icons.account_balance_outlined,
                iconColor: const Color(0xFF3D6FE5),
                title: 'Connect Monobank',
                subtitle: 'Import payments automatically — 2 minutes.',
                badge: 'popular',
                onTap: () => _selectAndContinue(context, 'Connect Monobank'),
              ),
              const SizedBox(height: 14),
              _StartOption(
                iconBg: const Color(0xFFFFE7CE),
                icon: Icons.edit_outlined,
                iconColor: const Color(0xFFC17A2E),
                title: 'Add manually',
                subtitle: 'Create an account and track operations yourself.',
                onTap: () => _selectAndContinue(context, 'Add manually'),
              ),
              const SizedBox(height: 14),
              _StartOption(
                iconBg: const Color(0xFFFFE0D6),
                icon: Icons.visibility_off_outlined,
                iconColor: const Color(0xFFC1602E),
                title: 'Try the demo',
                subtitle: 'Look around with sample data first.',
                onTap: () => _selectAndContinue(context, 'Try the demo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAndContinue(BuildContext context, String option) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => _ReadyScreen(option: option)),
    );
  }
}

class _StartOption extends StatelessWidget {
  const _StartOption({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: _textColor,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _accentBlue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12.5, color: _grayText, height: 1.3),
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

/// Мінімальний екран-заглушка після вибору способу старту (поза межами
/// спеки §3.2–3.10 — головний дашборд будується окремо).
class _ReadyScreen extends StatelessWidget {
  const _ReadyScreen({required this.option});

  final String option;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      vivid: true,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "You're all set",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  option,
                  style: const TextStyle(fontSize: 14, color: _grayText),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
