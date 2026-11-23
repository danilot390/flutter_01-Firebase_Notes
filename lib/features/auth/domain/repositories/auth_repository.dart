import '../entities/app_user.dart';

abstract interface class AuthRepository {
  // Register a new user with email and password
  Future<AppUser> register({required String email, required String password});

  // Sings in an existing user with email and password
  Future<AppUser> signIn({required String email, required String password});

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email});

  // Signs out the current user
  Future<void> signOut();

  // Emits the current authentication state whenever it changes
  Stream<AppUser?> watchAuthState();

  // Returns the currently authenticated user, if any
  AppUser? get currentUser;
}
