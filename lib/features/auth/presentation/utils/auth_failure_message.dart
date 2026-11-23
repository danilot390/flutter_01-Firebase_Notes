import '../../domain/errors/auth_failure.dart';

abstract final class AuthFailureMessage {
  static String fromFailure(AuthFailure failure) {
    return switch (failure.code) {
      AuthFailureCode.emailAlreadyInUse =>
        'An account already exists with this email.',
      AuthFailureCode.invalidEmail => 'Please enter a valid email address.',
      AuthFailureCode.weakPassword => 'Your password is too weak.',
      AuthFailureCode.userNotFound =>
        'No account was found with these credentials.',
      AuthFailureCode.wrongPassword => 'The password is incorrect.',
      AuthFailureCode.invalidCredential =>
        'The email or password is incorrect.',
      AuthFailureCode.userDisabled => 'This account has been disabled.',
      AuthFailureCode.tooManyRequests =>
        'Too many attempts. Please try again later.',
      AuthFailureCode.network =>
        'A network error occurred. Check your connection.',
      AuthFailureCode.operationNotAllowed =>
        'This authentication method is not enabled.',
      AuthFailureCode.unexpected => 'Something went wrong. Please try again.',
    };
  }
}
