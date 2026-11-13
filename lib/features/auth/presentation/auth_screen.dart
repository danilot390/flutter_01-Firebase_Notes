import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({required this.authService, super.key});

  final AuthService authService;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistering) {
        await widget.authService.register(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await widget.authService.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      // AuthGate reacts to Firebase's authentication stream.
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _messageFor(error.code);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _messageFor(String code) {
    return switch (code) {
      'email-already-in-use' => 'An account already exists for this email.',
      'invalid-email' => 'Please enter a valid email address.',
      'weak-password' => 'Your password is too weak.',
      'user-not-found' => 'No account was found for this email.',
      'wrong-password' ||
      'invalid-credential' => 'The email or password is incorrect.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'network-request-failed' =>
        'Network error. Check your internet connection.',
      _ => 'Authentication failed. Please try again.',
    };
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

  @override
  Widget build(BuildContext context) {
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
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isRegistering ? 'Register' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isRegistering = !_isRegistering;
                              _errorMessage = null;
                              _formKey.currentState?.reset();
                            });
                          },
                    child: Text(
                      _isRegistering
                          ? 'Already have an account? Sign in'
                          : 'Create an account',
                    ),
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
