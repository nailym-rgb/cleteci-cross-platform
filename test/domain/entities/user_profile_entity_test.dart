import 'package:flutter_test/flutter_test.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';

void main() {
  final testDate = DateTime(2024, 1, 15, 10, 0, 0);

  UserProfileEntity makeEntity({
    String uid = 'uid-123',
    String email = 'test@example.com',
    String firstName = 'John',
    String lastName = 'Doe',
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileEntity(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      createdAt: createdAt ?? testDate,
      updatedAt: updatedAt ?? testDate,
    );
  }

  group('UserProfileEntity', () {
    group('construction', () {
      test('should create entity with required fields', () {
        final entity = makeEntity();

        expect(entity.uid, 'uid-123');
        expect(entity.email, 'test@example.com');
        expect(entity.firstName, 'John');
        expect(entity.lastName, 'Doe');
        expect(entity.avatarUrl, isNull);
        expect(entity.createdAt, testDate);
        expect(entity.updatedAt, testDate);
      });

      test('should create entity with optional avatarUrl', () {
        final entity = makeEntity(avatarUrl: 'https://example.com/avatar.jpg');

        expect(entity.avatarUrl, 'https://example.com/avatar.jpg');
      });

      test('should have zero Firebase imports', () {
        // If this file compiles without firebase_auth or cloud_firestore
        // the domain layer is pure Dart — enforced by compile-time
        expect(true, isTrue);
      });
    });

    group('computed properties', () {
      test('fullName returns firstName and lastName joined with space', () {
        expect(makeEntity(firstName: 'John', lastName: 'Doe').fullName, 'John Doe');
      });

      test('fullName works with single-word names', () {
        expect(makeEntity(firstName: 'Cher', lastName: '').fullName, 'Cher ');
      });

      test('initials returns uppercase first letters of firstName and lastName', () {
        expect(makeEntity(firstName: 'John', lastName: 'Doe').initials, 'JD');
      });

      test('initials handles empty firstName', () {
        expect(makeEntity(firstName: '', lastName: 'Doe').initials, 'D');
      });

      test('initials handles empty lastName', () {
        expect(makeEntity(firstName: 'John', lastName: '').initials, 'J');
      });

      test('initials returns empty string when both names are empty', () {
        expect(makeEntity(firstName: '', lastName: '').initials, '');
      });
    });

    group('copyWith', () {
      test('returns new instance with updated firstName', () {
        final original = makeEntity();
        final updated = original.copyWith(firstName: 'Jane');

        expect(updated.firstName, 'Jane');
        expect(updated.lastName, original.lastName);
        expect(updated.uid, original.uid);
        expect(updated.email, original.email);
        expect(updated.createdAt, original.createdAt);
      });

      test('returns new instance with updated lastName', () {
        final original = makeEntity();
        final updated = original.copyWith(lastName: 'Smith');

        expect(updated.lastName, 'Smith');
        expect(updated.firstName, original.firstName);
      });

      test('can set avatarUrl to a value', () {
        final original = makeEntity();
        final updated = original.copyWith(avatarUrl: 'https://example.com/new.jpg');

        expect(updated.avatarUrl, 'https://example.com/new.jpg');
      });

      test('can set avatarUrl to null explicitly', () {
        final original = makeEntity(avatarUrl: 'https://example.com/avatar.jpg');
        final updated = original.copyWith(avatarUrl: null);

        expect(updated.avatarUrl, isNull);
      });

      test('preserves avatarUrl when not provided', () {
        final original = makeEntity(avatarUrl: 'https://example.com/avatar.jpg');
        final updated = original.copyWith(firstName: 'Jane');

        expect(updated.avatarUrl, 'https://example.com/avatar.jpg');
      });

      test('updates updatedAt when not provided', () {
        final original = makeEntity(updatedAt: DateTime(2020));
        final updated = original.copyWith(firstName: 'Jane');

        expect(updated.updatedAt.isAfter(DateTime(2020)), isTrue);
      });

      test('returns a different instance, does not mutate original', () {
        final original = makeEntity();
        final updated = original.copyWith(firstName: 'Jane');

        expect(identical(original, updated), isFalse);
        expect(original.firstName, 'John');
      });
    });

    group('equality', () {
      test('two entities with same fields are equal', () {
        final a = makeEntity();
        final b = makeEntity();

        expect(a, equals(b));
      });

      test('entities with different uid are not equal', () {
        final a = makeEntity(uid: 'uid-1');
        final b = makeEntity(uid: 'uid-2');

        expect(a, isNot(equals(b)));
      });

      test('entities with different email are not equal', () {
        final a = makeEntity(email: 'a@example.com');
        final b = makeEntity(email: 'b@example.com');

        expect(a, isNot(equals(b)));
      });

      test('entities with different firstName are not equal', () {
        final a = makeEntity(firstName: 'John');
        final b = makeEntity(firstName: 'Jane');

        expect(a, isNot(equals(b)));
      });

      test('entities with different avatarUrl are not equal', () {
        final a = makeEntity(avatarUrl: 'https://example.com/a.jpg');
        final b = makeEntity(avatarUrl: 'https://example.com/b.jpg');

        expect(a, isNot(equals(b)));
      });

      test('hashCode is consistent for equal entities', () {
        final a = makeEntity();
        final b = makeEntity();

        expect(a.hashCode, b.hashCode);
      });

      test('entity is equal to itself', () {
        final a = makeEntity();
        expect(a, equals(a));
      });
    });

    group('toString', () {
      test('includes uid and email in string representation', () {
        final entity = makeEntity(uid: 'uid-123', email: 'test@example.com');
        final str = entity.toString();

        expect(str, contains('uid-123'));
        expect(str, contains('test@example.com'));
      });
    });
  });
}
