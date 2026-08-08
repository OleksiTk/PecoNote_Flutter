import '../../../../core/sync/sync_metadata.dart';

enum TransactionType { income, expense, transfer }

class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.accountId,
    required this.amount,
    required this.total,
    required this.currencyId,
    required this.counterpartyId,
    required this.occurredAt,
    required this.isTrashed,
    required this.sync,
    this.tagIds = const [],
    this.destinationAccountId,
    this.description,
  });

  final String id;
  final TransactionType type;
  final String accountId;
  final String? destinationAccountId;
  final double amount;
  final double total;
  final int currencyId;
  final int counterpartyId;
  final String? description;
  final List<int> tagIds;
  final DateTime occurredAt;
  final bool isTrashed;
  final SyncMetadata sync;
}
