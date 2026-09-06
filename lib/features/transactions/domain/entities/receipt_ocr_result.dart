/// Parsed response from POST /transactions/ocr/ — never a Transaction,
/// just what the backend's GPT vision call could read off the receipt.
class ReceiptOcrResult {
  const ReceiptOcrResult({
    this.merchantName,
    this.amount,
    this.currencyCode,
    this.date,
  });

  factory ReceiptOcrResult.fromJson(Map<String, dynamic> json) {
    return ReceiptOcrResult(
      merchantName: json['merchant_name'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currencyCode: json['currency_code'] as String?,
      date: DateTime.tryParse(json['date'] as String? ?? ''),
    );
  }

  final String? merchantName;
  final double? amount;

  /// Parsed but intentionally unused by the UI: the app is single-currency
  /// per account today, so there's nothing to reconcile it against yet.
  final String? currencyCode;
  final DateTime? date;
}
