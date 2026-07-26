class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final int income;
  final int expense;

  int get balance => income - expense;
}
