import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/errors/auth_failure.dart';
import 'controllers/auth_controller.dart';
import 'utils/auth_failure_message.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);

    if (_isRegistering) {
      await controller.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await controller.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final emailError = _validateEmail(email);

    if (emailError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(email: email);

    if (!mounted) return;

    final result = ref.read(authControllerProvider);

    if (!result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email is required.';
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 6) {
      return 'Password must contain at least 6 characters.';
    }

    return null;
  }

  String? _errorMessage(Object? error) {
    if (error is AuthFailure) {
      return AuthFailureMessage.fromFailure(error);
    }

    return 'Something went wrong. Please try again.';
  }

  void _toggleMode() {
    ref.invalidate(authControllerProvider);

    setState(() {
      _isRegistering = !_isRegistering;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(authControllerProvider);
    final isLoading = actionState.isLoading;

    final errorMessage = actionState.hasError
        ? _errorMessage(actionState.error)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Create account' : 'Sign in'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _isRegistering ? 'Create your account' : 'Welcome back',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateEmail,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: [
                      _isRegistering
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validatePassword,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isRegistering ? 'Register' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : _toggleMode,
                    child: Text(
                      _isRegistering
                          ? 'Already have an account? Sign in'
                          : 'Create an account',
                    ),
                  ),
                  if (!_isRegistering)
                    TextButton(
                      onPressed: isLoading ? null : _resetPassword,
                      child: const Text('Forgot password?'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
