import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cleteci_cross_platform/models/user_profile.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('UserProfile', () {
    final testDate = DateTime(2023, 1, 1, 12, 0, 0);

    test('should create UserProfile with required parameters', () {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(profile.uid, 'test-uid');
      expect(profile.email, 'test@example.com');
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.avatarUrl, isNull);
      expect(profile.createdAt, testDate);
      expect(profile.updatedAt, testDate);
    });

    test('should create UserProfile with optional avatarUrl', () {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('fullName should return firstName + lastName', () {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(profile.fullName, 'John Doe');
    });

    test('initials should return first letters of firstName and lastName', () {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(profile.initials, 'JD');
    });

    test('initials should handle empty names', () {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: '',
        lastName: '',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(profile.initials, '');
    });

    test('initials should handle single character names', () {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'A',
        lastName: 'B',
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(profile.initials, 'AB');
    });

    test('fromFirestore should create UserProfile from DocumentSnapshot', () {
      final timestamp = Timestamp.fromDate(testDate);
      final docData = {
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      final doc = MockDocumentSnapshot(docData);

      final profile = UserProfile.fromFirestore(doc);

      expect(profile.uid, 'test-doc-id');
      expect(profile.email, 'test@example.com');
      expect(profile.firstName, 'John');
      expect(profile.lastName, 'Doe');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.createdAt, testDate);
      expect(profile.updatedAt, testDate);
    });

    test('fromFirestore should handle null avatarUrl', () {
      final timestamp = Timestamp.fromDate(testDate);
      final docData = {
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      final doc = MockDocumentSnapshot(docData);

      final profile = UserProfile.fromFirestore(doc);

      expect(profile.avatarUrl, isNull);
    });

    test('fromFirestore should handle null timestamps', () {
      final docData = {
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
      };

      final doc = MockDocumentSnapshot(docData);

      final profile = UserProfile.fromFirestore(doc);

      expect(profile.createdAt, isNotNull);
      expect(profile.updatedAt, isNotNull);
    });

    test('toFirestore should convert UserProfile to Map', () {
      final profile = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final map = profile.toFirestore();

      expect(map['email'], 'test@example.com');
      expect(map['firstName'], 'John');
      expect(map['lastName'], 'Doe');
      expect(map['avatarUrl'], 'https://example.com/avatar.jpg');
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['updatedAt'], isA<Timestamp>());
    });

    test('copyWith should create new instance with updated fields', () {
      final original = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final updated = original.copyWith(
        firstName: 'Jane',
        lastName: 'Smith',
      );

      expect(updated.uid, 'test-uid');
      expect(updated.email, 'test@example.com');
      expect(updated.firstName, 'Jane');
      expect(updated.lastName, 'Smith');
      expect(updated.avatarUrl, 'https://example.com/avatar.jpg'); // Should preserve original
      expect(updated.createdAt, testDate);
      expect(updated.updatedAt, isNot(testDate)); // Should be updated to now
    });

    test('copyWith should preserve original values when not specified', () {
      final original = UserProfile(
        uid: 'test-uid',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: testDate,
        updatedAt: testDate,
      );

      final updated = original.copyWith(firstName: 'Jane');

      expect(updated.firstName, 'Jane');
      expect(updated.lastName, 'Doe');
      expect(updated.avatarUrl, 'https://example.com/avatar.jpg');
    });
  });
}

// Mock DocumentSnapshot for testing
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  String get id => 'test-doc-id';

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;

  @override
  dynamic operator [](Object field) => _data[field];

  @override
  dynamic get(Object field) => _data[field];
}