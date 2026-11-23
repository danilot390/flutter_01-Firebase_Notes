import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_01_firebase_notes/features/auth/domain/entities/app_user.dart';
import 'package:flutter_01_firebase_notes/features/auth/presentation/auth_gate.dart';
import 'package:flutter_01_firebase_notes/features/auth/presentation/providers/auth_dependencies.dart';

void main() {
  late StreamController<AppUser?> authStateController;

  setUp(() {
    authStateController = StreamController<AppUser?>();
  });

  tearDown(() async {
    await authStateController.close();
  });

  Widget createWidget() {
    return ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => authStateController.stream),
      ],
      child: const MaterialApp(home: AuthGate()),
    );
  }

  testWidgets('shows loading indicator initially', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows sign-in screen when user is null', (tester) async {
    await tester.pumpWidget(createWidget());

    authStateController.add(null);

    await tester.pump();
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('shows authenticated screen when user exists', (tester) async {
    final user = AppUser(
      id: 'test-user-123',
      name: 'user-123',
      email: 'test@example.com',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await tester.pumpWidget(createWidget());

    authStateController.add(user);

    await tester.pump();
    await tester.pump();

    expect(find.text('Welcome: test-user-123'), findsOneWidget);
  });
}
