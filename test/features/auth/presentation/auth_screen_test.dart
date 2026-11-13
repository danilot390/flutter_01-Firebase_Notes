import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_01_firebase_notes/core/services/auth_service.dart';
import 'package:flutter_01_firebase_notes/features/auth/presentation/auth_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
  });

  Widget createWidget() {
    return MaterialApp(home: AuthScreen(authService: authService));
  }

  testWidgets('displays login form initially', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('switches to registration mode', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('validates required fields', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required.'), findsOneWidget);
    expect(find.text('Password is required.'), findsOneWidget);

    verifyNever(
      () => authService.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });
}
