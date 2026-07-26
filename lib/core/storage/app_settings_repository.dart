import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../security/secure_token_storage.dart';

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return SecureAppSettingsRepository(ref.watch(flutterSecureStorageProvider));
});

abstract interface class AppSettingsRepository {
  Future<bool> isOnboardingCompleted();

  Future<void> setOnboardingCompleted(bool completed);
}

class SecureAppSettingsRepository implements AppSettingsRepository {
  const SecureAppSettingsRepository(this._storage);

  static const _onboardingCompletedKey = 'settings.onboardingCompleted';

  final FlutterSecureStorage _storage;

  @override
  Future<bool> isOnboardingCompleted() async {
    final value = await _storage.read(key: _onboardingCompletedKey);
    return value == 'true';
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _storage.write(
      key: _onboardingCompletedKey,
      value: completed.toString(),
    );
  }
}
