import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

abstract class FirebaseAuthUserMapper {
  static AppUser toDomain(User user) {
    final now = DateTime.now();

    return AppUser(
      id: user.uid,
      email: user.email,
      name: user.displayName,
      createdAt: user.metadata.creationTime ?? now,
      updatedAt: user.metadata.lastSignInTime ?? now,
    );
  }
}
