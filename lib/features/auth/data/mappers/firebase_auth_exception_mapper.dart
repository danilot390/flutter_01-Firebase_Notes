import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/errors/auth_failure.dart';

abstract final class FirebaseAuthExceptionMapper {
  static AuthFailure toFailure(FirebaseAuthException exception) {
    final code = switch (exception.code) {
      'email-already-in-use' => AuthFailureCode.emailAlreadyInUse,
      'invalid-email' => AuthFailureCode.invalidEmail,
      'weak-password' => AuthFailureCode.weakPassword,
      'user-not-found' => AuthFailureCode.userNotFound,
      'wrong-password' => AuthFailureCode.wrongPassword,
      'invalid-credential' => AuthFailureCode.invalidCredential,
      'user-disabled' => AuthFailureCode.userDisabled,
      'too-many-requests' => AuthFailureCode.tooManyRequests,
      'network-request-failed' => AuthFailureCode.network,
      'operation-not-allowed' => AuthFailureCode.operationNotAllowed,
      _ => AuthFailureCode.unexpected,
    };

    return AuthFailure(code);
  }
}
