import 'sync_status.dart';

class SyncMetadata {
  const SyncMetadata({
    required this.localId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.deletedAt,
    this.lastSyncedAt,
  });

  final String localId;
  final String? serverId;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? lastSyncedAt;
}
