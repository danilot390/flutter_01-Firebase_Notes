enum AuthFailureCode {
  emailAlreadyInUse,
  invalidEmail,
  weakPassword,
  userNotFound,
  wrongPassword,
  invalidCredential,
  userDisabled,
  tooManyRequests,
  network,
  operationNotAllowed,
  unexpected,
}

final class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthFailureCode code;

  @override
  String toString() => 'AuthFailure: ${code.name}';
}
