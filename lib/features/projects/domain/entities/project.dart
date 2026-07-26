import '../../../../core/sync/sync_metadata.dart';

class Project {
  const Project({required this.id, required this.name, required this.sync});

  final String id;
  final String name;
  final SyncMetadata sync;
}
