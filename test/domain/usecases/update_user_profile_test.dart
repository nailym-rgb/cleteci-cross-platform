import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/domain/repositories/user_profile_repository.dart';
import 'package:cleteci_cross_platform/domain/usecases/user_profile/update_user_profile.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {
  @override
  Stream<UserProfileEntity?> watchProfile(String uid) => Stream.value(null);

  @override
  Future<void> updateProfile(UserProfileEntity profile) =>
      super.noSuchMethod(
            Invocation.method(#updateProfile, [profile]),
            returnValue: Future<void>.value(),
          )
          as Future<void>;
}

void main() {
  late MockUserProfileRepository mockRepository;
  late UpdateUserProfile useCase;
  final testDate = DateTime(2024, 1, 15);

  UserProfileEntity makeEntity({
    String uid = 'uid-123',
    String firstName = 'John',
    String lastName = 'Doe',
    String? avatarUrl,
  }) {
    return UserProfileEntity(
      uid: uid,
      email: 'test@example.com',
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      createdAt: testDate,
      updatedAt: testDate,
    );
  }

  setUp(() {
    mockRepository = MockUserProfileRepository();
    useCase = UpdateUserProfile(mockRepository);
  });

  group('UpdateUserProfile use case', () {
    test('calls repository updateProfile with the provided entity', () async {
      final entity = makeEntity();
      when(mockRepository.updateProfile(entity)).thenAnswer((_) async {});

      await useCase(entity);

      verify(mockRepository.updateProfile(entity)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('completes successfully when repository succeeds', () async {
      final entity = makeEntity();
      when(mockRepository.updateProfile(entity)).thenAnswer((_) async {});

      await expectLater(useCase(entity), completes);
    });

    test('propagates repository exceptions', () async {
      final entity = makeEntity();
      when(
        mockRepository.updateProfile(entity),
      ).thenThrow(Exception('write error'));

      expect(() => useCase(entity), throwsException);
    });

    test('passes updated entity fields to repository', () async {
      final original = makeEntity();
      final updated = original.copyWith(
        firstName: 'Jane',
        avatarUrl: 'https://example.com/new.jpg',
      );
      when(mockRepository.updateProfile(updated)).thenAnswer((_) async {});

      await useCase(updated);

      verify(mockRepository.updateProfile(updated)).called(1);
      // Verify the entity fields directly since we know which entity was passed
      expect(updated.firstName, 'Jane');
      expect(updated.avatarUrl, 'https://example.com/new.jpg');
      expect(updated.uid, 'uid-123');
    });
  });
}
