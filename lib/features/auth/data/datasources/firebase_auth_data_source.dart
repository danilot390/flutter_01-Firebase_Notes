import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource({required this._firebaseAuth});

  final FirebaseAuth _firebaseAuth;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User> register({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw StateError('Firebase returned no user after registration');
    }

    return user;
  }

  Future<User> signIn({required String email, required String password}) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw StateError('Firebase returned no user after sign-in.');
    }

    return user;
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
