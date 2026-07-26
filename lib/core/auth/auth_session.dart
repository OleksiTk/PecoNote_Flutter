import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/secure_token_storage.dart';

final authSessionProvider = Provider<AuthSession>((ref) {
  final session = AuthSession(
    tokenStorage: ref.watch(secureTokenStorageProvider),
  );
  ref.onDispose(session.dispose);
  return session;
});

class AuthSession extends ChangeNotifier {
  AuthSession({required SecureTokenStorage tokenStorage})
    : _tokenStorage = tokenStorage;

  final SecureTokenStorage _tokenStorage;
  bool _authenticated = false;

  bool get authenticated => _authenticated;

  Future<bool> isAuthenticated() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();
    _authenticated =
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
    return _authenticated;
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _tokenStorage.saveAccessToken(accessToken);
    _authenticated = true;
    notifyListeners();
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    _authenticated = true;
    notifyListeners();
  }

  Future<void> clear() async {
    await _tokenStorage.clearTokens();
    _authenticated = false;
    notifyListeners();
  }
}
