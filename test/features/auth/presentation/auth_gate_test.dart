import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_01_firebase_notes/core/services/auth_service.dart';
import 'package:flutter_01_firebase_notes/features/auth/presentation/auth_gate.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUser extends Mock implements User {}

void main() {
  late MockAuthService authService;
  late StreamController<User?> authController;

  setUp(() {
    authService = MockAuthService();
    authController = StreamController<User?>();

    when(() => authService.authStateChanges)
        .thenAnswer((_) => authController.stream);
  });

  tearDown(() async {
    await authController.close();
  });

  Widget createWidget() {
    return MaterialApp(home: AuthGate(authService: authService));
  }

  testWidgets('shows loading indicator initially', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows sign-in screen when user is null', (tester) async {
    await tester.pumpWidget(createWidget());

    authController.add(null);

    await tester.pump();
    await tester.pump();

    expect(find.text('Please sign in'), findsOneWidget);
  });

  testWidgets('shows authenticated screen when user exists', (tester) async {
    final user = MockUser();

    when(() => user.uid).thenReturn('test-user-123');

    await tester.pumpWidget(createWidget());

    authController.add(user);
    await tester.pump();
    await tester.pump();

    expect(find.text('Welcome: test-user-123'), findsOneWidget);
  });
}
