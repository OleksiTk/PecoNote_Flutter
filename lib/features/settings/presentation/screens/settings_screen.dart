import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../application/providers/settings_providers.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/user_profile.dart';

/// Екран налаштувань PecoNote: профіль і валюта підтягуються з
/// GET /profile/ та GET /currencies/, решта поки що mock-дані макета.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final currenciesAsync = ref.watch(userCurrenciesProvider);

    return GradientBackground(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
              children: [
                _ProfileRow(profileAsync: profileAsync),
                const SizedBox(height: 20),
                const _StatsRow(),
                const SizedBox(height: 26),

                const _SectionLabel('PREFERENCES'),
                const SizedBox(height: 8),
                _GlassSection(
                  rows: [
                    const _SettingsRowData(
                      emoji: '🌐',
                      label: 'Language',
                      value: 'English',
                    ),
                    _SettingsRowData(
                      emoji: '💱',
                      label: 'Default currency',
                      value: _currencyLabel(currenciesAsync),
                    ),
                    const _SettingsRowData(
                      emoji: '🎨',
                      label: 'Theme',
                      value: 'Light',
                    ),
                    const _SettingsRowData(
                      emoji: '🔔',
                      label: 'Notifications',
                      trailing: _NotificationsSwitch(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const _SectionLabel('DATA & MEMORY'),
                const SizedBox(height: 8),
                const _GlassSection(
                  rows: [
                    _SettingsRowData(emoji: '🧹', label: 'Clear card history'),
                    _SettingsRowData(
                      emoji: '📤',
                      label: 'Export data',
                      value: 'CSV',
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                const _DangerSection(),
              ],
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: AppBottomNavBar(activeTab: AppNavTab.settings),
            ),
          ),
        ],
      ),
    );
  }

  static String _currencyLabel(AsyncValue<List<Currency>> currenciesAsync) {
    return currenciesAsync.when(
      data: (currencies) => currencies.isEmpty
          ? 'Not set'
          : '${currencies.first.code} ${currencies.first.symbol}',
      loading: () => '…',
      error: (_, _) => '—',
    );
  }
}

/// Аватар + ім'я та email. Без картки — просто на градієнті.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.profileAsync});

  final AsyncValue<UserProfile> profileAsync;

  @override
  Widget build(BuildContext context) {
    final initial = profileAsync.when(
      data: (profile) => profile.initial,
      loading: () => '…',
      error: (_, _) => '?',
    );
    final name = profileAsync.when(
      data: (profile) => profile.username,
      loading: () => 'Loading…',
      error: (_, _) => 'Your account',
    );
    final email = profileAsync.when(
      data: (profile) => profile.email,
      loading: () => '',
      error: (_, _) => 'Could not load profile',
    );

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white.withValues(alpha: 0.9)),
          ),
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.accentBlue,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                email,
                style: const TextStyle(fontSize: 13, color: AppColors.grayText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatChip(value: '214', label: 'Days\nwith us'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatChip(value: '3 482', label: 'Total\ntransactions'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatChip(value: '4', label: 'Active\naccounts'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatChip(value: '12', label: 'Rules\ncreated'),
        ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      // Плоский колір замість BackdropFilter: 4 такі чіпи одночасно на екрані.
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: AppColors.grayText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.grayText,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsRowData {
  const _SettingsRowData({
    required this.emoji,
    required this.label,
    this.value,
    this.trailing,
    this.destructive = false,
    this.iconWidget,
  });

  final String emoji;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool destructive;

  /// Якщо задано — замість емодзі малюється цей віджет (для danger-рядків).
  final Widget? iconWidget;
}

/// Скляна група рядків налаштувань.
class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.rows, this.tint});

  final List<_SettingsRowData> rows;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      // Плоский колір замість BackdropFilter: до 3 таких секцій одночасно
      // на екрані налаштувань.
      child: Container(
        decoration: BoxDecoration(
          color: (tint ?? AppColors.white).withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.7)),
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              _SettingsRow(data: rows[i]),
              if (i != rows.length - 1)
                Divider(
                  height: 1,
                  indent: 54,
                  endIndent: 16,
                  color: AppColors.white.withValues(alpha: 0.55),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.data});

  final _SettingsRowData data;

  @override
  Widget build(BuildContext context) {
    final labelColor = data.destructive
        ? AppColors.notificationDot
        : AppColors.textDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child:
                    data.iconWidget ??
                    Text(data.emoji, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                  ),
                ),
              ),
              if (data.trailing != null)
                data.trailing!
              else ...[
                if (data.value != null)
                  Text(
                    data.value!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: data.destructive
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: data.destructive
                          ? AppColors.notificationDot.withValues(alpha: 0.7)
                          : AppColors.grayText,
                    ),
                  ),
                if (!data.destructive) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.placeholderGray,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Log out + Delete account у теплому рожевому склі.
class _DangerSection extends StatelessWidget {
  const _DangerSection();

  @override
  Widget build(BuildContext context) {
    return const _GlassSection(
      tint: Color(0xFFFFE0DA),
      rows: [
        _SettingsRowData(
          emoji: '',
          label: 'Log out',
          destructive: true,
          iconWidget: Icon(
            Icons.logout,
            size: 18,
            color: AppColors.notificationDot,
          ),
        ),
        _SettingsRowData(
          emoji: '',
          label: 'Delete account',
          value: 'permanent',
          destructive: true,
          iconWidget: Icon(
            Icons.close,
            size: 18,
            color: AppColors.notificationDot,
          ),
        ),
      ],
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
    return GestureDetector(
      onTap: () => setState(() => _enabled = !_enabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        alignment: _enabled ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: _enabled
              ? AppColors.success.withValues(alpha: 0.55)
              : AppColors.placeholderGray.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.white.withValues(alpha: 0.8)),
        ),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlue.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
