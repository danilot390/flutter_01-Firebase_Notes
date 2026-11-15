import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_user.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../mappers/firebase_auth_user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._dataSource});

  final FirebaseAuthDataSource _dataSource;

  @override
  AppUser? get currentUser {
    final user = _dataSource.currentUser;

    if (user == null) return null;

    return FirebaseAuthUserMapper.toDomain(user);
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    final user = await _dataSource.register(email: email, password: password);

    return FirebaseAuthUserMapper.toDomain(user);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _dataSource.signIn(email: email, password: password);

    return FirebaseAuthUserMapper.toDomain(user);
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Stream<AppUser?> watchAuthState() {
    return _dataSource.authStateChanges.map((user) {
      if (user == null) return null;

      return FirebaseAuthUserMapper.toDomain(user);
    });
  }
}
