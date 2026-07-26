import '../repositories/auth_repository.dart';

class Register {
  const Register(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return _repository.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }
}
