import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Екран вхідних PecoNote: список завдань, що потребують рішення
/// користувача. Поки що статичний макет на mock-даних.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

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
                  child: _InboxHeader(),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: _FilterTabsRow(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    children: const [
                      _InboxCard(
                        emoji: '🔑',
                        iconBg: AppColors.iconBgOrangeSoft,
                        badgeText: '31',
                        badgeColor: AppColors.iconBgOrangeSoft,
                        badgeTextColor: AppColors.iconFgOrangeSoft,
                        dotColor: AppColors.iconFgOrangeSoft,
                        title: '31 payments without a category',
                        description:
                            'Grouped into 9 — SILPO ×4, Steam ×2, Kyivstar ×1…',
                        buttonLabel: 'Review groups',
                      ),
                      SizedBox(height: 14),
                      _InboxCard(
                        emoji: '↔',
                        iconBg: AppColors.accentBlueBg,
                        badgeText: '3',
                        badgeColor: AppColors.accentBlueBg,
                        badgeTextColor: AppColors.accentBlue,
                        dotColor: AppColors.accentBlue,
                        title: '3 transfers look internal',
                        description: "Confirm so they don't count as expenses.",
                        buttonLabel: 'Check',
                      ),
                      SizedBox(height: 14),
                      _InboxCard(
                        emoji: '↩',
                        iconBg: AppColors.iconBgGreen,
                        badgeText: '2',
                        badgeColor: AppColors.iconBgGreen,
                        badgeTextColor: AppColors.iconFgGreen,
                        dotColor: AppColors.income,
                        title: '2 refunds to link with expenses',
                        description: 'Link them so stats stay accurate.',
                        buttonLabel: 'Link refunds',
                      ),
                      SizedBox(height: 14),
                      _InboxCard(
                        emoji: '🔑',
                        iconBg: AppColors.iconBgRed,
                        badgeText: '2d',
                        dotColor: AppColors.notificationDot,
                        title: "Monobank hasn't synced for 2 days",
                        description:
                            'The token may have expired. Reconnect to resume imports.',
                        buttonLabel: 'Reconnect',
                      ),
                      SizedBox(height: 16),
                      _AllClearBanner(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: -10,
            child: SafeArea(
              top: false,
              child: AppBottomNavBar(activeTab: AppNavTab.inbox),
            ),
          ),
        ],
      ),
    );
  }
}

class _InboxHeader extends StatelessWidget {
  const _InboxHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Inbox',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Spacer(),
            Text(
              'Mark all done',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          '4 tasks need your decision',
          style: TextStyle(fontSize: 13.5, color: AppColors.grayText),
        ),
      ],
    );
  }
}

class _FilterTabsRow extends StatelessWidget {
  const _FilterTabsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _FilterTab(label: 'All', selected: true),
        SizedBox(width: 8),
        _FilterTab(label: 'Unread', selected: false),
        SizedBox(width: 8),
        _FilterTab(label: 'Action needed', selected: false),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.white
            : AppColors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(99),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.shadowBlue.withValues(alpha: 0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? AppColors.textDark : AppColors.grayText,
        ),
      ),
    );
  }
}

class _InboxCard extends StatelessWidget {
  const _InboxCard({
    required this.emoji,
    required this.iconBg,
    required this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    required this.dotColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });

  final String emoji;
  final Color iconBg;
  final String badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final Color dotColor;
  final String title;
  final String description;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          // Плоский колір замість BackdropFilter — до 4 таких карток
          // одночасно на екрані, кожна раніше з власним блюром.
          color: AppColors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBlue.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.grayText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PillButton(label: buttonLabel),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (badgeColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: badgeTextColor ?? AppColors.textDark,
                      ),
                    ),
                  )
                else
                  Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayText,
                    ),
                  ),
                const SizedBox(height: 8),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _AllClearBanner extends StatelessWidget {
  const _AllClearBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.iconBgMintLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '🌿  Finish these and your inbox is all clear.',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.grayText,
        ),
      ),
    );
  }
}
