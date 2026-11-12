import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_01_firebase_notes/core/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late AuthService authService;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    authService = AuthService(firebaseAuth: firebaseAuth);
  });

  group('AuthService', () {
    test('Registers a user eith trimmed email', () async {
      final credential = MockUserCredential();

      when(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: 'pablin@clavin.com',
          password: 'Password2026',
        ),
      ).thenAnswer((_) async => credential);

      final result = await authService.register(
        email: 'pablin@clavin.com',
        password: 'Password2026',
      );

      expect(result, credential);
      verify(
        () => firebaseAuth.createUserWithEmailAndPassword(
          email: 'pablin@clavin.com',
          password: 'Password2026',
        ),
      ).called(1);
    });

    test('signs in an existing user', () async {
      final credential = MockUserCredential();

      when(
        () => firebaseAuth.signInWithEmailAndPassword(
          email: 'pablin@clavin.com',
          password: 'Password2026',
        ),
      ).thenAnswer((_) async => credential);

      final result = await authService.signIn(
        email: 'pablin@clavin.com',
        password: 'Password2026',
      );

      expect(result, credential);
    });

    test('signs out the current user', () async {
      when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => firebaseAuth.signOut()).called(1);
    });
  });
}
