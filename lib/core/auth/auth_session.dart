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
    final authenticated =
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
    final changed = authenticated != _authenticated;
    _authenticated = authenticated;
    // Notify so listeners (router redirect, push registration) react to a
    // session restored from secure storage, not just to explicit login/logout.
    if (changed) notifyListeners();
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
