import '../../../../core/sync/sync_metadata.dart';
import '../../../transactions/domain/entities/transaction.dart';

class Rule {
  const Rule({
    required this.id,
    required this.name,
    required this.sync,
    this.merchantNameContains,
    this.descriptionContains,
    this.accountId,
    this.minAmount,
    this.maxAmount,
    this.direction,
    this.categoryId,
    this.projectId,
  });

  final String id;
  final String name;
  final String? merchantNameContains;
  final String? descriptionContains;
  final String? accountId;
  final int? minAmount;
  final int? maxAmount;
  final TransactionType? direction;
  final String? categoryId;
  final String? projectId;
  final SyncMetadata sync;
}
