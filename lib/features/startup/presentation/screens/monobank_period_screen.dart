import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/gradient_background.dart';

class _Period {
  const _Period({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

const _periods = [
  _Period(title: 'Last month', subtitle: 'quick start'),
  _Period(
    title: 'Last 3 months',
    subtitle: 'recommended · enough for good stats',
  ),
  _Period(title: 'Last 6 months', subtitle: 'deeper history'),
  _Period(title: 'Last 12 months', subtitle: 'full picture, slower sync'),
];

class MonobankPeriodScreen extends StatefulWidget {
  const MonobankPeriodScreen({super.key});

  @override
  State<MonobankPeriodScreen> createState() => _MonobankPeriodScreenState();
}

class _MonobankPeriodScreenState extends State<MonobankPeriodScreen> {
  int? _selectedIndex = 1;
  DateTimeRange? _customRange;

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _customRange,
    );
    if (range != null) {
      setState(() {
        _customRange = range;
        _selectedIndex = null;
      });
    }
  }

  void _select(int index) {
    setState(() {
      _selectedIndex = index;
      _customRange = null;
    });
  }

  void _syncNow() {
    context.goNamed(AppRoute.monobankSyncing.name);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM');
    final customLabel = _customRange == null
        ? 'Custom range…'
        : '${dateFormat.format(_customRange!.start)} – '
              '${dateFormat.format(_customRange!.end)}';

    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlassBackButton(onPressed: () => context.pop()),
                  const Text(
                    'STEP 3 OF 4',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _StepProgressBar(step: 3, total: 4),
              const SizedBox(height: 28),
              const Text(
                'Which period?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose how far back to import payments.',
                style: TextStyle(fontSize: 14, color: AppColors.grayText),
              ),
              const SizedBox(height: 22),
              for (var i = 0; i < _periods.length; i++) ...[
                _PeriodRow(
                  period: _periods[i],
                  selected: _selectedIndex == i,
                  onTap: () => _select(i),
                ),
                const SizedBox(height: 10),
              ],
              _CustomRangeRow(
                label: customLabel,
                selected: _customRange != null,
                onTap: _pickCustomRange,
              ),
              const SizedBox(height: 26),
              PillButton(
                label: 'Sync now',
                backgroundColor: AppColors.accentBlueMuted,
                foregroundColor: AppColors.white,
                borderColor: AppColors.accentBlueMuted,
                onPressed: _syncNow,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i < step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? AppColors.accentBlueMuted : AppColors.dotInactive,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.period,
    required this.selected,
    required this.onTap,
  });

  final _Period period;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      // Плоский колір замість BackdropFilter: до 5 таких рядків одночасно
      // на екрані вибору періоду.
      child: Material(
        color: selected
            ? AppColors.accentBlueBg.withValues(alpha: 0.7)
            : AppColors.white.withValues(alpha: 0.6),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? AppColors.accentBlueMuted.withValues(alpha: 0.6)
                    : AppColors.white.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        period.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grayText,
                        ),
                      ),
                    ],
                  ),
                ),
                _RadioMark(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? AppColors.white.withValues(alpha: 0.9)
            : AppColors.white.withValues(
                alpha: 0.55,
              ), // ← заливка й у невибраного
        border: Border.all(
          color: selected
              ? AppColors.accentBlueMuted
              : AppColors.grayText.withValues(alpha: 0.35), // ← видимий сірий
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentBlueMuted,
              ),
            )
          : null,
    );
  }
}

class _CustomRangeRow extends StatelessWidget {
  const _CustomRangeRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      // Плоский колір замість BackdropFilter — див. коментар у _PeriodRow.
      child: Material(
        color: selected
            ? AppColors.accentBlueBg.withValues(alpha: 0.7)
            : AppColors.white.withValues(alpha: 0.6),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? AppColors.accentBlue.withValues(alpha: 0.6)
                    : AppColors.white.withValues(alpha: 0.7),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlueBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Text('📅', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.textDark : AppColors.grayText,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.grayTextLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
