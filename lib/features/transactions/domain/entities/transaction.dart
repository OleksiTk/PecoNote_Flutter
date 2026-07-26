import '../../../../core/sync/sync_metadata.dart';

enum TransactionType { income, expense }

enum TransactionSource { manual, bankImport, sync }

class Transaction {
  const Transaction({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.type,
    required this.occurredAt,
    required this.source,
    required this.sync,
    this.categoryId,
    this.projectId,
    this.currency = 'UAH',
    this.description,
    this.merchantName,
  });

  final String id;
  final String accountId;
  final String? categoryId;
  final String? projectId;
  final int amount;
  final String currency;
  final TransactionType type;
  final String? description;
  final String? merchantName;
  final DateTime occurredAt;
  final TransactionSource source;
  final SyncMetadata sync;
}
