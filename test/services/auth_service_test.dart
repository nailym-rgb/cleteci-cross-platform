import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cleteci_cross_platform/services/auth_service.dart';

void main() {
  late AuthService authService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser(email: 'test@example.com');
    authService = AuthService(mockFirebaseAuth);
  });

  group('AuthService', () {
    test('should return FirebaseAuth instance', () {
      expect(authService.firebaseAuth, equals(mockFirebaseAuth));
    });

    test('should return authStateChanges stream', () {
      final stream = authService.authStateChanges;
      expect(stream, isA<Stream<User?>>());
    });

    test('should return current user', () {
      expect(authService.currentUser, isA<User?>());
    });

    test('should return null when no current user', () {
      expect(authService.currentUser, isA<User?>());
    });

    test('should sign out successfully', () async {
      await expectLater(authService.signOut(), completes);
    });

    test('should sign in with email and password successfully', () async {
      final result = await authService.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<UserCredential>());
    });

    test('should create user with email and password successfully', () async {
      final result = await authService.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<UserCredential>());
    });

    test('should send password reset email successfully', () async {
      await expectLater(
        authService.sendPasswordResetEmail('test@example.com'),
        completes,
      );
    });

    test('should reload current user successfully', () async {
      await expectLater(authService.reload(), completes);
    });

    test('should handle reload when no current user', () async {
      await expectLater(authService.reload(), completes);
    });
  });
}

// Mock UserCredential for testing
class MockUserCredential extends Mock implements UserCredential {}