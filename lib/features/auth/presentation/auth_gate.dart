
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  AuthGate({
    super.key,
    AuthService? authService,
  }) : _authService = authService ?? AuthService();

  final AuthService _authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to check authentication state.'),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const UnauthenticatedScreen();
        }

        return AuthenticatedScreen(user: user);
      },
    );
  }
}

class UnauthenticatedScreen extends StatelessWidget {
  const UnauthenticatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Please sign in'),
      ),
    );
  }
}

class AuthenticatedScreen extends StatelessWidget {
  const AuthenticatedScreen({
    required this.user,
    super.key,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome: ${user.uid}'),
      ),
    );
  }
}
