import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../models/operations_filters.dart';

/// Opens the date filter bottom sheet and resolves with the newly applied
/// [DateFilter], or null if the sheet was dismissed without applying.
Future<DateFilter?> showDateFilterSheet(
  BuildContext context, {
  required DateFilter initial,
}) {
  return showModalBottomSheet<DateFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (context) => _DateFilterSheet(initial: initial),
  );
}

class _DateFilterSheet extends StatefulWidget {
  const _DateFilterSheet({required this.initial});

  final DateFilter initial;

  @override
  State<_DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<_DateFilterSheet> {
  late DateQuickRange? _quick = widget.initial.quick;
  late DateTime? _from = widget.initial.from;
  late DateTime? _to = widget.initial.to;
  late DateTime _monthCursor = _initialMonthCursor();

  DateTime _initialMonthCursor() {
    final resolved = widget.initial.resolve();
    final now = DateTime.now();
    if (resolved == null) return DateTime(now.year, now.month);
    return DateTime(resolved.start.year, resolved.start.month);
  }

  void _selectQuick(DateQuickRange quick) {
    setState(() {
      _quick = quick;
      final range = DateFilter(quick: quick).resolve();
      _from = range?.start;
      _to = range?.end;
      final cursorBase = range?.start ?? DateTime.now();
      _monthCursor = DateTime(cursorBase.year, cursorBase.month);
    });
  }

  void _shiftMonth(int delta) {
    setState(() {
      _monthCursor = DateTime(_monthCursor.year, _monthCursor.month + delta);
      final range = DateFilter.monthRange(_monthCursor.year, _monthCursor.month);
      _quick = null;
      _from = range.start;
      _to = range.end;
    });
  }

  Future<void> _pickCustomDate({required bool isFrom}) async {
    final initialDate = (isFrom ? _from : _to) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _quick = null;
      if (isFrom) {
        _from = picked;
        if (_to != null && _to!.isBefore(picked)) _to = picked;
      } else {
        _to = picked;
        if (_from != null && _from!.isAfter(picked)) _from = picked;
      }
    });
  }

  void _reset() {
    setState(() {
      _quick = DateQuickRange.allTime;
      _from = null;
      _to = null;
      _monthCursor = DateTime(DateTime.now().year, DateTime.now().month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.scaffoldVivid,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(child: _DragHandle()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Date filter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _reset,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentBlueMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('QUICK RANGES'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final quick in DateQuickRange.values)
                            _ChoiceChip(
                              label: DateFilter(quick: quick).label(),
                              selected: _quick == quick,
                              onTap: () => _selectQuick(quick),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const _SectionLabel('MONTH & YEAR'),
                      const SizedBox(height: 10),
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.subChipBorder),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => _shiftMonth(-1),
                              icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.accentBlue,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  DateFormat('MMMM yyyy').format(_monthCursor),
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _shiftMonth(1),
                              icon: const Icon(
                                Icons.chevron_right,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _SectionLabel('CUSTOM RANGE'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'FROM',
                              date: _from,
                              onTap: () => _pickCustomDate(isFrom: true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DateField(
                              label: 'TO',
                              date: _to,
                              onTap: () => _pickCustomDate(isFrom: false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
                child: PillButton(
                  label: 'Apply',
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: AppColors.white,
                  borderColor: AppColors.accentBlue,
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(DateFilter(quick: _quick, from: _from, to: _to)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.dotInactive,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.labelGray,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentBlue : AppColors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? AppColors.accentBlue : AppColors.subChipBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.date, required this.onTap});

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.subChipBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.labelGray,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              date != null ? DateFormat('d MMM yyyy').format(date!) : 'Not set',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
