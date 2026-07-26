sealed class AppFailure {
  const AppFailure(this.message);

  final String message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

class StorageFailure extends AppFailure {
  const StorageFailure(super.message);
}

class AuthenticationFailure extends AppFailure {
  const AuthenticationFailure(super.message);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, this.fieldErrors);

  final Map<String, List<String>> fieldErrors;
}
