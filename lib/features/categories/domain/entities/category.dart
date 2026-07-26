import '../../../../core/sync/sync_metadata.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.isDefault,
    required this.sync,
  });

  final String id;
  final String name;
  final String iconName;
  final bool isDefault;
  final SyncMetadata sync;
}
