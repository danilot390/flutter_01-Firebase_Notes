import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  // Returns the currently authenticated user, or null if there is no user.
  User? get currentUser => _firebaseAuth.currentUser;

  // Emits authentication state changes.
  Stream<User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((user) => user!);

  // Create a new account with the given email and password.
  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Signed in an existing user.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sings out the current user.
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
