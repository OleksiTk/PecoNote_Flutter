import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class CreateManualTransaction {
  const CreateManualTransaction(this._repository);

  final TransactionsRepository _repository;

  Future<Transaction> call(Transaction transaction) {
    return _repository.createOffline(transaction);
  }
}
