import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final appLockServiceProvider = Provider<AppLockService>((ref) {
  return AppLockService(LocalAuthentication());
});

class AppLockService {
  const AppLockService(this._localAuthentication);

  final LocalAuthentication _localAuthentication;

  Future<bool> canUseBiometrics() {
    return _localAuthentication.canCheckBiometrics;
  }

  Future<bool> unlock() {
    return _localAuthentication.authenticate(
      localizedReason: 'Unlock PecoNote',
      options: const AuthenticationOptions(biometricOnly: false),
    );
  }
}
