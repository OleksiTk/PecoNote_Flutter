abstract interface class AuthRepository {
  Future<void> signIn({required String email, required String password});

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<void> signOut();

  Future<void> requestPasswordReset({required String email});

  Future<void> resetPassword({
    required String uid,
    required String token,
    required String password,
    required String confirmPassword,
  });
}
