import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_01_firebase_notes/features/auth/data/mappers/firebase_auth_exception_mapper.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/errors/auth_failure.dart';

void main() {
  group('FirebaseAuthExceptionMapper', () {
    final testCases = <(String, AuthFailureCode)>[
      ('email-already-in-use', AuthFailureCode.emailAlreadyInUse),
      ('invalid-email', AuthFailureCode.invalidEmail),
      ('weak-password', AuthFailureCode.weakPassword),
      ('user-not-found', AuthFailureCode.userNotFound),
      ('wrong-password', AuthFailureCode.wrongPassword),
      ('invalid-credential', AuthFailureCode.invalidCredential),
      ('user-disabled', AuthFailureCode.userDisabled),
      ('too-many-requests', AuthFailureCode.tooManyRequests),
      ('network-request-failed', AuthFailureCode.network),
      ('operation-not-allowed', AuthFailureCode.operationNotAllowed),
    ];

    for (final (firebaseCode, expectedFailureCode) in testCases) {
      test('maps $firebaseCode to ${expectedFailureCode.name}', () {
        final exception = FirebaseAuthException(code: firebaseCode);

        final failure = FirebaseAuthExceptionMapper.toFailure(exception);

        expect(failure, isA<AuthFailure>());
        expect(failure.code, expectedFailureCode);
      });
    }

    test('maps an unknown Firebase error code to unexpected', () {
      final exception = FirebaseAuthException(
        code: 'some-future-firebase-error',
      );

      final failure = FirebaseAuthExceptionMapper.toFailure(exception);

      expect(failure.code, AuthFailureCode.unexpected);
    });
  });
}
