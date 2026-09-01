import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/notifications/push_service.dart';
import '../../../../core/security/secure_token_storage.dart';
import '../../data/remote/notifications_remote_data_source.dart';
import '../device_token_sync.dart';

final pushServiceProvider = Provider<PushService>((ref) => PushService.instance);

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
  return NotificationsRemoteDataSource(ref.watch(dioProvider));
});

final deviceTokenSyncProvider = Provider<DeviceTokenSync>((ref) {
  return DeviceTokenSync(
    pushService: ref.watch(pushServiceProvider),
    remoteDataSource: ref.watch(notificationsRemoteDataSourceProvider),
    storage: ref.watch(flutterSecureStorageProvider),
  );
});
