import '../../../../core/sync/sync_metadata.dart';

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.currencyId,
    required this.sync,
    this.description,
    this.balance = 0,
  });

  final String id;
  final String name;
  final String? description;
  final int currencyId;
  final SyncMetadata sync;

  /// Current balance, computed server-side from the account's transaction
  /// history (see accounts.AccountSerializer.get_balance on the backend).
  final double balance;
}
