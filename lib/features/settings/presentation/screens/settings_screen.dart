import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';

/// Екран налаштувань PecoNote: профіль, статистика та групи параметрів.
/// Лише статичний макет (mock-дані) — без реальних провайдерів.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _SettingsHeader(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: const [
                  _ProfileCard(),
                  SizedBox(height: 16),
                  _StatsRow(),
                  SizedBox(height: 24),
                  _SettingsSection(
                    title: 'ACCOUNT',
                    rows: [
                      _SettingsRowData(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: 'dmytro@example.com',
                      ),
                      _SettingsRowData(
                        icon: Icons.lock_outline,
                        label: 'Password',
                        value: '••••••••',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _SettingsSection(
                    title: 'PREFERENCES',
                    rows: [
                      _SettingsRowData(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        value: 'English',
                      ),
                      _SettingsRowData(
                        icon: Icons.payments_outlined,
                        label: 'Default currency',
                        value: 'UAH ₴',
                      ),
                      _SettingsRowData(
                        icon: Icons.notifications_outlined,
                        label: 'Push notifications',
                        trailing: _NotificationsSwitch(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _SettingsSection(
                    title: 'DATA & AUTOMATION',
                    rows: [
                      _SettingsRowData(
                        icon: Icons.category_outlined,
                        label: 'Categories',
                      ),
                      _SettingsRowData(
                        icon: Icons.rule_outlined,
                        label: 'Rules',
                      ),
                      _SettingsRowData(
                        icon: Icons.account_balance_outlined,
                        label: 'Bank connections',
                      ),
                      _SettingsRowData(
                        icon: Icons.download_outlined,
                        label: 'Export data',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _SettingsSection(
                    title: 'DANGER ZONE',
                    rows: [
                      _SettingsRowData(
                        icon: Icons.logout,
                        label: 'Log out',
                        destructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const AppBottomNavBar(activeTab: AppNavTab.settings),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Settings',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlue.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentBlueBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
            ),
            child: const Text(
              'D',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.accentBlue,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dmytro K.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'dmytro@example.com',
                  style: TextStyle(fontSize: 13, color: AppColors.grayText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _StatChip(value: '128', label: 'Days with us')),
        SizedBox(width: 10),
        Expanded(child: _StatChip(value: '412', label: 'Transactions')),
        SizedBox(width: 10),
        Expanded(child: _StatChip(value: '3', label: 'Accounts')),
        SizedBox(width: 10),
        Expanded(child: _StatChip(value: '9', label: 'Rules')),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }
}

class _SettingsRowData {
  const _SettingsRowData({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool destructive;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.rows});

  final String title;
  final List<_SettingsRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.grayText,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                _SettingsRow(data: rows[i]),
                if (i != rows.length - 1)
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: AppColors.subChipBorder,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.data});

  final _SettingsRowData data;

  @override
  Widget build(BuildContext context) {
    final labelColor = data.destructive ? AppColors.expense : AppColors.textDark;
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                data.icon,
                size: 20,
                color: data.destructive ? AppColors.expense : AppColors.grayText,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
              ),
              if (data.trailing != null)
                data.trailing!
              else if (data.value != null) ...[
                Text(
                  data.value!,
                  style: const TextStyle(fontSize: 13, color: AppColors.grayText),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.placeholderGray,
                ),
              ] else if (!data.destructive)
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.placeholderGray,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsSwitch extends StatefulWidget {
  const _NotificationsSwitch();

  @override
  State<_NotificationsSwitch> createState() => _NotificationsSwitchState();
}

class _NotificationsSwitchState extends State<_NotificationsSwitch> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _enabled,
      activeThumbColor: AppColors.white,
      activeTrackColor: AppColors.accentBlue,
      onChanged: (value) => setState(() => _enabled = value),
    );
  }
}
