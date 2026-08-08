import '../entities/transaction.dart';

abstract interface class TransactionsRepository {
  Future<List<Transaction>> getTransactions();

  Future<Transaction> create({
    required TransactionType type,
    required String accountId,
    required double amount,
    required int currencyId,
    required String counterpartyName,
    required DateTime occurredAt,
    String? destinationAccountId,
    String? description,
    List<int> tagIds = const [],
  });

  Future<Transaction> updateTags({
    required String id,
    required List<int> tagIds,
  });

  Future<void> trash(String id);
}
