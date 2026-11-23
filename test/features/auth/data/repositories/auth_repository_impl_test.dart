import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_01_firebase_notes/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:flutter_01_firebase_notes/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/entities/app_user.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/errors/auth_failure.dart';

class MockFirebaseAuthDataSource extends Mock
    implements FirebaseAuthDataSource {}

class MockFirebaseUser extends Mock implements User {}

class MockUserMetadata extends Mock implements UserMetadata {}

void main() {
  late MockFirebaseAuthDataSource dataSource;
  late MockFirebaseUser firebaseUser;
  late MockUserMetadata userMetadata;
  late AuthRepositoryImpl repository;

  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testUid = 'test-user-id';
  const testName = 'test testing';
  final testCreatedAt = DateTime(2026, 1, 1);
  final testUpdatedAt = DateTime(2026, 1, 1);

  final expectedUser = AppUser(
    id: testUid,
    email: testEmail,
    name: testName,
    createdAt: testCreatedAt,
    updatedAt: testUpdatedAt,
  );

  setUp(() {
    dataSource = MockFirebaseAuthDataSource();
    firebaseUser = MockFirebaseUser();
    userMetadata = MockUserMetadata();

    repository = AuthRepositoryImpl(dataSource: dataSource);

    when(() => firebaseUser.uid).thenReturn(testUid);
    when(() => firebaseUser.email).thenReturn(testEmail);
    when(() => firebaseUser.displayName).thenReturn(testName);
    when(() => firebaseUser.metadata).thenReturn(userMetadata);
    when(() => userMetadata.creationTime).thenReturn(testCreatedAt);
    when(() => userMetadata.lastSignInTime).thenReturn(testUpdatedAt);
  });

  group('register', () {
    test('returns an AppUser when registration succeeds', () async {
      when(() => dataSource.register(email: testEmail, password: testPassword))
          .thenAnswer((_) async => firebaseUser);

      final result = await repository.register(
        email: testEmail,
        password: testPassword,
      );

      expect(result, expectedUser);

      verify(
        () => dataSource.register(email: testEmail, password: testPassword),
      ).called(1);
    });

    test('maps FirebaseAuthException to AuthFailure', () async {
      when(() => dataSource.register(email: testEmail, password: testPassword))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => repository.register(email: testEmail, password: testPassword),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            AuthFailureCode.emailAlreadyInUse,
          ),
        ),
      );
    });

    test('maps unexpected exceptions to AuthFailure', () async {
      when(() => dataSource.register(email: testEmail, password: testPassword))
          .thenThrow(StateError('Unexpected data source error'));

      expect(
        () => repository.register(email: testEmail, password: testPassword),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            AuthFailureCode.unexpected,
          ),
        ),
      );
    });
  });

  group('signIn', () {
    test('returns an AppUser when sign-in succeeds', () async {
      when(() => dataSource.signIn(email: testEmail, password: testPassword))
          .thenAnswer((_) async => firebaseUser);

      final result = await repository.signIn(
        email: testEmail,
        password: testPassword,
      );

      expect(result, expectedUser);

      verify(() => dataSource.signIn(email: testEmail, password: testPassword))
          .called(1);
    });

    test('maps FirebaseAuthException to AuthFailure', () async {
      when(() => dataSource.signIn(email: testEmail, password: testPassword))
          .thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      expect(
        () => repository.signIn(email: testEmail, password: testPassword),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            AuthFailureCode.invalidCredential,
          ),
        ),
      );
    });
  });

  group('watchAuthState', () {
    test('maps Firebase users to AppUser entities', () async {
      when(() => dataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(firebaseUser));

      await expectLater(repository.watchAuthState(), emits(expectedUser));
    });

    test('emits null when the user signs out', () async {
      when(() => dataSource.authStateChanges)
          .thenAnswer((_) => Stream.value(null));

      await expectLater(repository.watchAuthState(), emits(isNull));
    });

    test('maps stream FirebaseAuthException to AuthFailure', () async {
      when(() => dataSource.authStateChanges).thenAnswer(
        (_) => Stream<User?>.error(
          FirebaseAuthException(code: 'too-many-requests'),
        ),
      );

      await expectLater(
        repository.watchAuthState(),
        emitsError(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            AuthFailureCode.tooManyRequests,
          ),
        ),
      );
    });

    test('maps unexpected stream errors to AuthFailure', () async {
      when(() => dataSource.authStateChanges).thenAnswer(
        (_) => Stream<User?>.error(StateError('Unexpected stream error')),
      );

      await expectLater(
        repository.watchAuthState(),
        emitsError(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            AuthFailureCode.unexpected,
          ),
        ),
      );
    });
  });

  group('currentUser', () {
    test('maps the current Firebase user to AppUser', () {
      when(() => dataSource.currentUser).thenReturn(firebaseUser);

      expect(repository.currentUser, expectedUser);
    });

    test('returns null when there is no authenticated user', () {
      when(() => dataSource.currentUser).thenReturn(null);

      expect(repository.currentUser, isNull);
    });
  });

  group('signOut', () {
    test('delegates sign-out to the data source', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => dataSource.signOut()).called(1);
    });
  });

  group('sendPasswordResetEmail', () {
    test('delegates password reset to the data source', () async {
      when(() => dataSource.sendPasswordResetEmail(email: testEmail))
          .thenAnswer((_) async {});

      await repository.sendPasswordResetEmail(email: testEmail);

      verify(() => dataSource.sendPasswordResetEmail(email: testEmail))
          .called(1);
    });

    test('maps FirebaseAuthException to AuthFailure', () async {
      when(() => dataSource.sendPasswordResetEmail(email: testEmail))
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      expect(
        () => repository.sendPasswordResetEmail(email: testEmail),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            AuthFailureCode.invalidEmail,
          ),
        ),
      );
    });
  });
}
