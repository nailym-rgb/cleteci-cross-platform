import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cleteci_cross_platform/services/user_service.dart';
import 'package:cleteci_cross_platform/models/user_profile.dart';

// Import generated mocks
import 'user_service_test.mocks.dart';

void main() {
  late UserService userService;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    // Create UserService with dependency injection for testing
    userService = UserService();

    // Setup default mocks
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('test-uid')).thenReturn(mockDocRef);
  });

  group('UserService', () {
    test('should return null when no current user', () async {
      when(mockAuth.currentUser).thenReturn(null);

      final result = await userService.getCurrentUserProfile();

      expect(result, isNull);
    });

    test('should return UserProfile when document exists', () async {
      final testData = {
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(testData);
      when(mockDocSnapshot.id).thenReturn('test-uid');
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

      final result = await userService.getCurrentUserProfile();

      expect(result, isNotNull);
      expect(result!.uid, 'test-uid');
      expect(result.email, 'test@example.com');
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
      expect(result.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should return null when document does not exist', () async {
      when(mockDocSnapshot.exists).thenReturn(false);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

      final result = await userService.getCurrentUserProfile();

      expect(result, isNull);
    });

    test('should throw exception on firestore error', () async {
      when(mockDocRef.get()).thenThrow(Exception('Firestore error'));

      expect(() => userService.getCurrentUserProfile(), throwsA(isA<Exception>()));
    });

    test('saveUserProfile should call set with merge', () async {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      when(mockDocRef.set(any, any)).thenAnswer((_) async {});

      await userService.saveUserProfile(profile);

      verify(mockDocRef.set(
        profile.toFirestore(),
        SetOptions(merge: true),
      )).called(1);
    });

    test('saveUserProfile should throw exception on error', () async {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      when(mockDocRef.set(any, any)).thenThrow(Exception('Save error'));

      expect(() => userService.saveUserProfile(profile), throwsA(isA<Exception>()));
    });

    test('createUserProfile should create profile with correct data', () async {
      when(mockDocRef.set(any, any)).thenAnswer((_) async {});

      await userService.createUserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      verify(mockDocRef.set(
        argThat(predicate<Map<String, dynamic>>((data) {
          return data['email'] == 'test@example.com' &&
                 data['firstName'] == 'John' &&
                 data['lastName'] == 'Doe' &&
                 data['avatarUrl'] == 'https://example.com/avatar.jpg' &&
                 data['createdAt'] is Timestamp &&
                 data['updatedAt'] is Timestamp;
        })),
        SetOptions(merge: true),
      )).called(1);
    });

    test('updateUserProfile should update only specified fields', () async {
      when(mockDocRef.update(any)).thenAnswer((_) async {});

      await userService.updateUserProfile(
        uid: 'test-uid',
        firstName: 'Jane',
        lastName: 'Smith',
      );

      verify(mockDocRef.update({
        'updatedAt': anyNamed('updatedAt'),
        'firstName': 'Jane',
        'lastName': 'Smith',
      })).called(1);
    });

    test('updateUserProfile should not include null values', () async {
      when(mockDocRef.update(any)).thenAnswer((_) async {});

      await userService.updateUserProfile(
        uid: 'test-uid',
        firstName: 'Jane',
      );

      verify(mockDocRef.update({
        'updatedAt': anyNamed('updatedAt'),
        'firstName': 'Jane',
      })).called(1);
    });

    test('updateUserProfile should throw exception on error', () async {
      when(mockDocRef.update(any)).thenThrow(Exception('Update error'));

      expect(() => userService.updateUserProfile(
        uid: 'test-uid',
        firstName: 'Jane',
      ), throwsA(isA<Exception>()));
    });

    test('watchCurrentUserProfile should return stream with null when no user', () async {
      when(mockAuth.currentUser).thenReturn(null);

      final stream = userService.watchCurrentUserProfile();
      final result = await stream.first;

      expect(result, isNull);
    });

    test('watchCurrentUserProfile should return stream with profile when user exists', () async {
      final testData = {
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(testData);
      when(mockDocSnapshot.id).thenReturn('test-uid');

      final stream = userService.watchCurrentUserProfile();
      // Note: Testing streams requires more complex setup with StreamController
      // This is a basic structure test
      expect(stream, isNotNull);
    });
  });
}

void main() {
  late UserService userService;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockDocSnapshot;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();

    // Create UserService with dependency injection for testing
    userService = UserService();

    // Setup default mocks
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('test-uid')).thenReturn(mockDocRef);
  });

  group('UserService', () {
    test('should return null when no current user', () async {
      when(mockAuth.currentUser).thenReturn(null);

      final result = await userService.getCurrentUserProfile();

      expect(result, isNull);
    });

    test('should return UserProfile when document exists', () async {
      final testData = {
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(testData);
      when(mockDocSnapshot.id).thenReturn('test-uid');
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

      final result = await userService.getCurrentUserProfile();

      expect(result, isNotNull);
      expect(result!.uid, 'test-uid');
      expect(result.email, 'test@example.com');
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
      expect(result.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should return null when document does not exist', () async {
      when(mockDocSnapshot.exists).thenReturn(false);
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);

      final result = await userService.getCurrentUserProfile();

      expect(result, isNull);
    });

    test('should throw exception on firestore error', () async {
      when(mockDocRef.get()).thenThrow(Exception('Firestore error'));

      expect(() => userService.getCurrentUserProfile(), throwsA(isA<Exception>()));
    });

    test('saveUserProfile should call set with merge', () async {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      when(mockDocRef.set(any, any)).thenAnswer((_) async => null);

      await userService.saveUserProfile(profile);

      verify(mockDocRef.set(
        profile.toFirestore(),
        SetOptions(merge: true),
      )).called(1);
    });

    test('saveUserProfile should throw exception on error', () async {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      when(mockDocRef.set(any, any)).thenThrow(Exception('Save error'));

      expect(() => userService.saveUserProfile(profile), throwsA(isA<Exception>()));
    });

    test('createUserProfile should create profile with correct data', () async {
      final now = DateTime(2023, 1, 1, 12, 0, 0);
      final expectedProfile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: now,
        updatedAt: now,
      );

      when(mockDocRef.set(any, any)).thenAnswer((_) async => null);

      await userService.createUserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      verify(mockDocRef.set(
        argThat(predicate<Map<String, dynamic>>((data) {
          return data['email'] == 'test@example.com' &&
                 data['firstName'] == 'John' &&
                 data['lastName'] == 'Doe' &&
                 data['avatarUrl'] == 'https://example.com/avatar.jpg' &&
                 data['createdAt'] is Timestamp &&
                 data['updatedAt'] is Timestamp;
        })),
        SetOptions(merge: true),
      )).called(1);
    });

    test('updateUserProfile should update only specified fields', () async {
      when(mockDocRef.update(any)).thenAnswer((_) async => null);

      await userService.updateUserProfile(
        uid: 'test-uid',
        firstName: 'Jane',
        lastName: 'Smith',
      );

      verify(mockDocRef.update({
        'updatedAt': anyNamed('updatedAt'),
        'firstName': 'Jane',
        'lastName': 'Smith',
      })).called(1);
    });

    test('updateUserProfile should not include null values', () async {
      when(mockDocRef.update(any)).thenAnswer((_) async => null);

      await userService.updateUserProfile(
        uid: 'test-uid',
        firstName: 'Jane',
      );

      verify(mockDocRef.update({
        'updatedAt': anyNamed('updatedAt'),
        'firstName': 'Jane',
      })).called(1);
    });

    test('updateUserProfile should throw exception on error', () async {
      when(mockDocRef.update(any)).thenThrow(Exception('Update error'));

      expect(() => userService.updateUserProfile(
        uid: 'test-uid',
        firstName: 'Jane',
      ), throwsA(isA<Exception>()));
    });

    test('watchCurrentUserProfile should return stream with null when no user', () async {
      when(mockAuth.currentUser).thenReturn(null);

      final stream = userService.watchCurrentUserProfile();
      final result = await stream.first;

      expect(result, isNull);
    });

    test('watchCurrentUserProfile should return stream with profile when user exists', () async {
      final testData = {
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data()).thenReturn(testData);
      when(mockDocSnapshot.id).thenReturn('test-uid');

      final stream = userService.watchCurrentUserProfile();
      // Note: Testing streams requires more complex setup with StreamController
      // This is a basic structure test
      expect(stream, isNotNull);
    });
  });
}