import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/app_user.dart';
import 'providers/auth_dependencies.dart';
import 'auth_screen.dart';
import 'controllers/auth_controller.dart';
import 'utils/auth_failure_message.dart';
import '../domain/errors/auth_failure.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Unable to check authentication status.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(authStateProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return const AuthScreen();
        }

        return AuthenticatedScreen(user: user);
      },
    );
  }
}

class AuthenticatedScreen extends ConsumerWidget {
  const AuthenticatedScreen({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(authControllerProvider);

    final errorMessage = actionState.hasError
        ? _messageFor(actionState.error)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Notes'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: actionState.isLoading
                ? null
                : () {
                    ref.read(authControllerProvider.notifier).signOut();
                  },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome: ${user.id}'),
              if (user.email != null) ...[
                const SizedBox(height: 8),
                Text(user.email!),
              ],
              if (actionState.isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _messageFor(Object? error) {
    if (error is AuthFailure) {
      return AuthFailureMessage.fromFailure(error);
    }

    return 'Something went wrong. Please try again.';
  }
}
