import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key, AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

if (snapshot.hasError) {
  debugPrint('AUTH STREAM ERROR: ${snapshot.error}');
  debugPrint('AUTH STREAM STACK: ${snapshot.stackTrace}');

  return Scaffold(
    body: Center(
      child: SelectableText(
        'Authentication error: ${snapshot.error}\n\n'
        '${snapshot.stackTrace}',
        textAlign: TextAlign.center,
      ),
    ),
  );
}

        final user = snapshot.data;

        if (user == null) {
          return AuthScreen(authService: _authService);
        }

        return AuthenticatedScreen(user: user, authService: _authService);
      },
    );
  }
}

class AuthenticatedScreen extends StatelessWidget {
  const AuthenticatedScreen({
    required this.user,
    required this.authService,
    super.key,
  });

  final User user;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Notes'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              try {
                await authService.signOut();
              } catch (_) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to sign out.')),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(child: Text('Welcome: ${user.uid}')),
    );
  }
}
