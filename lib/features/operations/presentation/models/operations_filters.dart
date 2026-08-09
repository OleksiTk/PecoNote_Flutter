import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateQuickRange { thisMonth, lastMonth, last3Months, thisYear, allTime }

/// Draft/applied state for the operations date filter. [quick] is null when
/// the user picked an explicit month or custom range instead of one of the
/// quick-range chips.
class DateFilter {
  const DateFilter({this.quick = DateQuickRange.allTime, this.from, this.to});

  final DateQuickRange? quick;
  final DateTime? from;
  final DateTime? to;

  bool get isAllTime => quick == DateQuickRange.allTime;

  DateFilter copyWith({
    DateQuickRange? quick,
    bool clearQuick = false,
    DateTime? from,
    DateTime? to,
  }) {
    return DateFilter(
      quick: clearQuick ? null : (quick ?? this.quick),
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  static DateTimeRange monthRange(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(
      year,
      month + 1,
      1,
    ).subtract(const Duration(seconds: 1));
    return DateTimeRange(start: start, end: end);
  }

  /// The resolved [DateTimeRange] to filter transactions by, or null for
  /// "all time" (no lower/upper bound).
  DateTimeRange? resolve() {
    final now = DateTime.now();
    switch (quick) {
      case DateQuickRange.thisMonth:
        return monthRange(now.year, now.month);
      case DateQuickRange.lastMonth:
        final m = DateTime(now.year, now.month - 1);
        return monthRange(m.year, m.month);
      case DateQuickRange.last3Months:
        final start = DateTime(now.year, now.month - 2, 1);
        return DateTimeRange(start: start, end: monthRange(now.year, now.month).end);
      case DateQuickRange.thisYear:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
      case DateQuickRange.allTime:
        return null;
      case null:
        if (from != null && to != null) {
          return DateTimeRange(
            start: DateTime(from!.year, from!.month, from!.day),
            end: DateTime(to!.year, to!.month, to!.day, 23, 59, 59),
          );
        }
        return null;
    }
  }

  String label() {
    switch (quick) {
      case DateQuickRange.thisMonth:
        return 'This month';
      case DateQuickRange.lastMonth:
        return 'Last month';
      case DateQuickRange.last3Months:
        return 'Last 3 months';
      case DateQuickRange.thisYear:
        return 'This year';
      case DateQuickRange.allTime:
        return 'All time';
      case null:
        if (from != null && to != null) {
          return '${DateFormat('d MMM').format(from!)} – '
              '${DateFormat('d MMM yyyy').format(to!)}';
        }
        return 'All time';
    }
  }
}
