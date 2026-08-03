enum TransactionKind { expense, income, transfer }

extension TransactionKindX on TransactionKind {
  String get sign => switch (this) {
    TransactionKind.expense => '−',
    TransactionKind.income => '+',
    TransactionKind.transfer => '',
  };

  String get label => switch (this) {
    TransactionKind.expense => 'Expense',
    TransactionKind.income => 'Income',
    TransactionKind.transfer => 'Transfer',
  };

  String get saveLabel => 'Save ${label.toLowerCase()}';
}

/// Дані, зібрані на кроці 1 (сума, тип, рахунок) і передані на крок 2
/// ("Details") через `extra` роута — ще немає бекенду, щоб зберігати
/// транзакцію між кроками інакше.
class TransactionDraft {
  const TransactionDraft({
    required this.kind,
    required this.wholeAmount,
    required this.decimalAmount,
    required this.accountLabel,
    this.accountId,
  });

  final TransactionKind kind;
  final String wholeAmount;
  final String decimalAmount;
  final String accountLabel;

  /// Null, коли на кроці 1 ще немає жодного реального рахунку (створеного
  /// через /accounts/) — тоді крок 2 не може зберегти транзакцію.
  final String? accountId;

  double get amount => double.tryParse('$wholeAmount.$decimalAmount') ?? 0;
}

/// Форматує суму з групуванням тисяч пробілом: 1486.0 -> "1 486.00".
String formatCurrencyAmount(double value) {
  final fixed = value.toStringAsFixed(2);
  final dotIndex = fixed.indexOf('.');
  final whole = fixed.substring(0, dotIndex);
  final decimal = fixed.substring(dotIndex + 1);

  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    final fromEnd = whole.length - i;
    if (i > 0 && fromEnd % 3 == 0) buffer.write(' ');
    buffer.write(whole[i]);
  }
  buffer
    ..write('.')
    ..write(decimal);
  return buffer.toString();
}
