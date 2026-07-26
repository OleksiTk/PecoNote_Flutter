import 'sync_status.dart';

enum SyncOperationType { create, update, delete }

class SyncOperation {
  const SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityLocalId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.lastAttemptAt,
    this.errorMessage,
  });

  final String id;
  final String entityType;
  final String entityLocalId;
  final SyncOperationType type;
  final SyncStatus status;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final String? errorMessage;
}
