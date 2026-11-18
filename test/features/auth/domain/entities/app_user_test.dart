import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_01_firebase_notes/features/auth/domain/entities/app_user.dart';

void main() {
  final testDate = DateTime.now();

  group('AppUser', () {
    test('supports value equality', () {
      final first = AppUser(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final second = AppUser(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('different users are not equal', () {
      final first = AppUser(
        id: 'user-1',
        email: 'test1@example.com',
        name: 'User One',
        createdAt: testDate,
        updatedAt: testDate,
      );
      final second = AppUser(
        id: 'user-2',
        email: 'test2@example.com',
        name: 'User Two',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(first, isNot(second));
    });

    test('stores user properties accurately', () {
      final user = AppUser(
        id: 'user-1',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(user.id, 'user-1');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.createdAt, testDate);
      expect(user.updatedAt, testDate);
    });
  });
}
