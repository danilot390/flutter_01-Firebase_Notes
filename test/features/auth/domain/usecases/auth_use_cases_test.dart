import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_01_firebase_notes/features/auth/domain/entities/app_user.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/errors/auth_failure.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/usecases/register_with_email.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/usecases/watch_auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const testEmail = 'test@example.com';
  const testPassword = 'password123';

  final testUser = AppUser(
    id: 'test-user-id',
    email: testEmail,
    name: 'Test User',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = MockAuthRepository();
  });

  group('RegisterWithEmail', () {
    late RegisterWithEmail useCase;

    setUp(() {
      useCase = RegisterWithEmail(repository);
    });

    test('returns the registered user', () async {
      when(() => repository.register(email: testEmail, password: testPassword))
          .thenAnswer((_) async => testUser);

      final result = await useCase(email: testEmail, password: testPassword);

      expect(result, testUser);
      verify(
        () => repository.register(email: testEmail, password: testPassword),
      ).called(1);
    });

    test('propagates registration failure', () async {
      const failure = AuthFailure(AuthFailureCode.emailAlreadyInUse);

      when(() => repository.register(email: testEmail, password: testPassword))
          .thenThrow(failure);

      expect(
        () => useCase(email: testEmail, password: testPassword),
        throwsA(same(failure)),
      );
    });
  });

  group('SignInWithEmail', () {
    late SignInWithEmail useCase;

    setUp(() {
      useCase = SignInWithEmail(repository);
    });

    test('returns the authenticated user', () async {
      when(() => repository.signIn(email: testEmail, password: testPassword))
          .thenAnswer((_) async => testUser);

      final result = await useCase(email: testEmail, password: testPassword);

      expect(result, testUser);
      verify(() => repository.signIn(email: testEmail, password: testPassword))
          .called(1);
    });

    test('propagates sign-in failure', () async {
      const failure = AuthFailure(AuthFailureCode.invalidCredential);

      when(() => repository.signIn(email: testEmail, password: testPassword))
          .thenThrow(failure);

      expect(
        () => useCase(email: testEmail, password: testPassword),
        throwsA(same(failure)),
      );
    });
  });

  group('SignOut', () {
    late SignOut useCase;

    setUp(() {
      useCase = SignOut(repository);
    });

    test('delegates sign-out to the repository', () async {
      when(() => repository.signOut()).thenAnswer((_) async {});

      await useCase();

      verify(() => repository.signOut()).called(1);
    });

    test('propagates sign-out failure', () async {
      const failure = AuthFailure(AuthFailureCode.unexpected);

      when(() => repository.signOut()).thenThrow(failure);

      expect(() => useCase(), throwsA(same(failure)));
    });
  });

  group('WatchAuthState', () {
    late WatchAuthState useCase;

    setUp(() {
      useCase = WatchAuthState(repository);
    });

    test('emits the authenticated user', () async {
      when(() => repository.watchAuthState())
          .thenAnswer((_) => Stream.value(testUser));

      await expectLater(useCase(), emits(testUser));

      verify(() => repository.watchAuthState()).called(1);
    });

    test('emits null when the user is signed out', () async {
      when(() => repository.watchAuthState())
          .thenAnswer((_) => Stream.value(null));

      await expectLater(useCase(), emits(isNull));
    });
  });

  group('SendPasswordResetEmail', () {
    late SendPasswordResetEmail useCase;

    setUp(() {
      useCase = SendPasswordResetEmail(repository);
    });

    test('delegates the email to the repository', () async {
      when(() => repository.sendPasswordResetEmail(email: testEmail))
          .thenAnswer((_) async {});

      await useCase(email: testEmail);

      verify(() => repository.sendPasswordResetEmail(email: testEmail))
          .called(1);
    });

    test('propagates password reset failure', () async {
      const failure = AuthFailure(AuthFailureCode.invalidEmail);

      when(() => repository.sendPasswordResetEmail(email: testEmail))
          .thenThrow(failure);

      expect(() => useCase(email: testEmail), throwsA(same(failure)));
    });
  });
}
