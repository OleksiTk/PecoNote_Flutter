import '../../../../core/sync/sync_metadata.dart';

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.currencyId,
    required this.sync,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final int currencyId;
  final SyncMetadata sync;
}
