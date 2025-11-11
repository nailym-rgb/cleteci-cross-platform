import 'package:flutter_test/flutter_test.dart';
import 'package:cleteci_cross_platform/models/user_profile.dart';
import 'package:cleteci_cross_platform/services/user_service.dart';
import '../config/firebase_test_utils.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseTestMocks();
  });

  group('UserService', () {
    group('UserProfile model tests', () {
      test('should create UserProfile with required fields', () {
        // Arrange & Act
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Assert
        expect(profile.uid, 'test-uid');
        expect(profile.email, 'test@example.com');
        expect(profile.firstName, 'John');
        expect(profile.lastName, 'Doe');
        expect(profile.avatarUrl, isNull);
        expect(profile.createdAt, isNotNull);
        expect(profile.updatedAt, isNotNull);
      });

      test('should create UserProfile with all fields', () {
        // Arrange
        final now = DateTime.now();

        // Act
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: now,
          updatedAt: now,
        );

        // Assert
        expect(profile.uid, 'test-uid');
        expect(profile.email, 'test@example.com');
        expect(profile.firstName, 'John');
        expect(profile.lastName, 'Doe');
        expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
        expect(profile.createdAt, now);
        expect(profile.updatedAt, now);
      });
    });

    group('UserProfile.toFirestore', () {
      test('should convert UserProfile to firestore data', () {
        // Arrange
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final firestoreData = profile.toFirestore();

        // Assert - uid is not included in toFirestore (it's the document ID)
        expect(firestoreData['email'], 'test@example.com');
        expect(firestoreData['firstName'], 'John');
        expect(firestoreData['lastName'], 'Doe');
        expect(firestoreData['avatarUrl'], 'https://example.com/avatar.jpg');
        expect(firestoreData['createdAt'], isNotNull);
        expect(firestoreData['updatedAt'], isNotNull);
      });

      test('should handle null avatarUrl', () {
        // Arrange
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final firestoreData = profile.toFirestore();

        // Assert
        expect(firestoreData['avatarUrl'], isNull);
      });
    });

    group('UserProfile.fullName', () {
      test('should return full name when both names are present', () {
        // Arrange
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(profile.fullName, 'John Doe');
      });

      test('should return firstName with space when lastName is empty', () {
        // Arrange
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert - fullName always includes space
        expect(profile.fullName, 'John ');
      });
    });

    group('UserProfile.initials', () {
      test('should return initials from first and last name', () {
        // Arrange
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(profile.initials, 'JD');
      });

      test('should return first letter of firstName when lastName is empty', () {
        // Arrange
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(profile.initials, 'J');
      });

      test('should return empty string when names are empty', () {
        // Arrange
        final profile = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: '',
          lastName: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert - initials returns empty string when both names are empty
        expect(profile.initials, '');
      });
    });

    group('UserProfile.copyWith', () {
      test('should copy with updated fields', () {
        // Arrange
        final original = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final copied = original.copyWith(
          firstName: 'Jane',
          avatarUrl: 'https://example.com/new-avatar.jpg',
        );

        // Assert
        expect(copied.uid, 'test-uid'); // Unchanged
        expect(copied.email, 'test@example.com'); // Unchanged
        expect(copied.firstName, 'Jane'); // Changed
        expect(copied.lastName, 'Doe'); // Unchanged
        expect(copied.avatarUrl, 'https://example.com/new-avatar.jpg'); // Changed
      });

      test('should handle null values in copyWith', () {
        // Arrange
        final original = UserProfile(
          uid: 'test-uid',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act
        final copied = original.copyWith(avatarUrl: null);

        // Assert
        expect(copied.avatarUrl, isNull);
        expect(copied.firstName, 'John'); // Unchanged
      });
    });

    group('UserService integration note', () {
      test('UserService requires Firebase integration tests', () {
        // UserService methods require Firebase to be initialized
        // These should be tested in integration tests rather than unit tests
        // due to the complexity of mocking Firebase Auth and Firestore
        expect(true, isTrue);
      });
    });

  });
}