
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_01_firebase_notes/firebase_options.dart';
import 'package:flutter_01_firebase_notes/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:flutter_01_firebase_notes/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/repositories/auth_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseAuth firebaseAuth;
  late AuthRepository repository;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebaseAuth = FirebaseAuth.instance;

    const emulatorHost = String.fromEnvironment(
      'FIREBASE_AUTH_EMULATOR_HOST',
      defaultValue: '127.0.0.1',
    );

    await firebaseAuth.useAuthEmulator(emulatorHost, 9099);

    repository = AuthRepositoryImpl(
      dataSource: FirebaseAuthDataSource(firebaseAuth: firebaseAuth),
    );
  });

  tearDown(() async {
    await firebaseAuth.signOut();
  });

  testWidgets(
    'registers, restores auth state, signs in and signs out',
    (tester) async {
      final email = 'integration-${DateTime.now().microsecondsSinceEpoch}@example.com';
      const password = 'StrongPassword123!';

      // Subscribe before registration so the auth-state event is observed.
      final signedInEvent = repository
          .watchAuthState()
          .firstWhere((user) => user != null);

      final registeredUser = await repository.register(
        email: email,
        password: password,
      );

      expect(registeredUser.email, email);
      expect(registeredUser.id, isNotEmpty);

      final emittedUser = await signedInEvent;
      expect(emittedUser?.id, registeredUser.id);
      expect(firebaseAuth.currentUser?.uid, registeredUser.id);

      // Confirm the SDK exposes the authenticated user as its current user.
      await firebaseAuth.currentUser!.reload();
      expect(firebaseAuth.currentUser?.email, email);

      // Sign out and verify the auth-state stream emits null.
      final signedOutEvent = repository
          .watchAuthState()
          .firstWhere((user) => user == null);

      await repository.signOut();

      await signedOutEvent;
      expect(firebaseAuth.currentUser, isNull);

      // Sign in again with the same credentials.
      final signedInUser = await repository.signIn(
        email: email,
        password: password,
      );

      expect(signedInUser.id, registeredUser.id);
      expect(firebaseAuth.currentUser?.uid, registeredUser.id);

      // Clean up the emulator account.
      await firebaseAuth.currentUser!.delete();

      expect(firebaseAuth.currentUser, isNull);
    },
  );
}
