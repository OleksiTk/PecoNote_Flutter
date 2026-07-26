import '../../../../core/sync/sync_metadata.dart';

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.sync,
    this.bankName,
  });

  final String id;
  final String name;
  final String? bankName;
  final SyncMetadata sync;
}
