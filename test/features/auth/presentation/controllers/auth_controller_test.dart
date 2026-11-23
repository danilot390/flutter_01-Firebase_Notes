import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_01_firebase_notes/features/auth/domain/entities/app_user.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/errors/auth_failure.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_01_firebase_notes/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_01_firebase_notes/features/auth/presentation/providers/auth_dependencies.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late ProviderContainer container;

  const email = 'test@example.com';
  const password = 'password123';

  final testUser = AppUser(
    id: 'test-user-id',
    email: email,
    name: 'Test User',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = MockAuthRepository();

    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> initializeController() async {
    await container.read(authControllerProvider.future);
  }

  group('register', () {
    test('exposes loading and success states', () async {
      final completer = Completer<AppUser>();

      when(() => repository.register(email: email, password: password))
          .thenAnswer((_) => completer.future);

      await initializeController();

      final action = container
          .read(authControllerProvider.notifier)
          .register(email: email, password: password);

      expect(container.read(authControllerProvider), isA<AsyncLoading<void>>());

      completer.complete(testUser);
      await action;

      expect(container.read(authControllerProvider), isA<AsyncData<void>>());

      verify(() => repository.register(email: email, password: password))
          .called(1);
    });

    test('exposes error state when registration fails', () async {
      const failure = AuthFailure(AuthFailureCode.emailAlreadyInUse);

      when(() => repository.register(email: email, password: password))
          .thenThrow(failure);

      await initializeController();

      await container
          .read(authControllerProvider.notifier)
          .register(email: email, password: password);

      final state = container.read(authControllerProvider);

      expect(state.hasError, isTrue);
      expect(state.error, same(failure));
    });
  });

  group('signIn', () {
    test('exposes loading and success states', () async {
      final completer = Completer<AppUser>();

      when(() => repository.signIn(email: email, password: password))
          .thenAnswer((_) => completer.future);

      await initializeController();

      final action = container
          .read(authControllerProvider.notifier)
          .signIn(email: email, password: password);

      expect(container.read(authControllerProvider), isA<AsyncLoading<void>>());

      completer.complete(testUser);
      await action;

      expect(container.read(authControllerProvider), isA<AsyncData<void>>());

      verify(() => repository.signIn(email: email, password: password))
          .called(1);
    });

    test('exposes error state when sign-in fails', () async {
      const failure = AuthFailure(AuthFailureCode.invalidCredential);

      when(() => repository.signIn(email: email, password: password))
          .thenThrow(failure);

      await initializeController();

      await container
          .read(authControllerProvider.notifier)
          .signIn(email: email, password: password);

      final state = container.read(authControllerProvider);

      expect(state.hasError, isTrue);
      expect(state.error, same(failure));
    });
  });

  group('signOut', () {
    test('exposes loading and success states', () async {
      final completer = Completer<void>();

      when(() => repository.signOut()).thenAnswer((_) => completer.future);

      await initializeController();

      final action = container.read(authControllerProvider.notifier).signOut();

      expect(container.read(authControllerProvider), isA<AsyncLoading<void>>());

      completer.complete();
      await action;

      expect(container.read(authControllerProvider), isA<AsyncData<void>>());

      verify(() => repository.signOut()).called(1);
    });

    test('exposes error state when sign-out fails', () async {
      const failure = AuthFailure(AuthFailureCode.unexpected);

      when(() => repository.signOut()).thenThrow(failure);

      await initializeController();

      await container.read(authControllerProvider.notifier).signOut();

      final state = container.read(authControllerProvider);

      expect(state.hasError, isTrue);
      expect(state.error, same(failure));
    });
  });

  group('sendPasswordResetEmail', () {
    test('exposes loading and success states', () async {
      final completer = Completer<void>();

      when(() => repository.sendPasswordResetEmail(email: email))
          .thenAnswer((_) => completer.future);

      await initializeController();

      final action = container
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(email: email);

      expect(container.read(authControllerProvider), isA<AsyncLoading<void>>());

      completer.complete();
      await action;

      expect(container.read(authControllerProvider), isA<AsyncData<void>>());
    });

    test('exposes error state when password reset fails', () async {
      const failure = AuthFailure(AuthFailureCode.invalidEmail);

      when(() => repository.sendPasswordResetEmail(email: email))
          .thenThrow(failure);

      await initializeController();

      await container
          .read(authControllerProvider.notifier)
          .sendPasswordResetEmail(email: email);

      final state = container.read(authControllerProvider);

      expect(state.hasError, isTrue);
      expect(state.error, same(failure));
    });
  });
}
