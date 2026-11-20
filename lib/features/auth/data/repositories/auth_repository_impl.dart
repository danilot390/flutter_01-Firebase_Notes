import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/errors/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../mappers/firebase_auth_exception_mapper.dart';
import '../mappers/firebase_auth_user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this._dataSource});

  final FirebaseAuthDataSource _dataSource;

  @override
  AppUser? get currentUser {
    try {
      final user = _dataSource.currentUser;

      if (user == null) return null;

      return FirebaseAuthUserMapper.toDomain(user);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapFailure(error), stackTrace);
    }
  }

  @override
  Future<AppUser> register({required String email, required String password}) {
    return _guard(() async {
      final user = await _dataSource.register(email: email, password: password);

      return FirebaseAuthUserMapper.toDomain(user);
    });
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return _guard(() async {
      final user = await _dataSource.signIn(email: email, password: password);

      return FirebaseAuthUserMapper.toDomain(user);
    });
  }

  @override
  Future<void> signOut() {
    return _guard(() => _dataSource.signOut());
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _guard(() => _dataSource.sendPasswordResetEmail(email: email));
  }

  @override
  Stream<AppUser?> watchAuthState() {
    final userStream = _dataSource.authStateChanges.map((user) {
      if (user == null) return null;

      return FirebaseAuthUserMapper.toDomain(user);
    });

    return userStream.transform(
      StreamTransformer<AppUser?, AppUser?>.fromHandlers(
        handleError: (error, stackTrace, sink) {
          sink.addError(_mapFailure(error), stackTrace);
        },
      ),
    );
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(_mapFailure(error), stackTrace);
    }
  }

  AuthFailure _mapFailure(Object error) {
    if (error is FirebaseAuthException) {
      return FirebaseAuthExceptionMapper.toFailure(error);
    }

    return const AuthFailure(AuthFailureCode.unexpected);
  }
}
