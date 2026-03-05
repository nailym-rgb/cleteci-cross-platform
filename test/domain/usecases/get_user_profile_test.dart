import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/domain/repositories/user_profile_repository.dart';
import 'package:cleteci_cross_platform/domain/usecases/user_profile/get_user_profile.dart';

class MockUserProfileRepository extends Mock implements UserProfileRepository {
  @override
  Stream<UserProfileEntity?> watchProfile(String uid) => Stream.value(null);

  @override
  Future<UserProfileEntity?> getProfile(String uid) =>
      super.noSuchMethod(
            Invocation.method(#getProfile, [uid]),
            returnValue: Future<UserProfileEntity?>.value(),
          )
          as Future<UserProfileEntity?>;

  @override
  Future<void> updateProfile(UserProfileEntity profile) =>
      super.noSuchMethod(
            Invocation.method(#updateProfile, [profile]),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<void> deleteProfile(String uid) =>
      super.noSuchMethod(
            Invocation.method(#deleteProfile, [uid]),
            returnValue: Future<void>.value(),
          )
          as Future<void>;
}

void main() {
  late MockUserProfileRepository mockRepository;
  late GetUserProfile useCase;
  final testDate = DateTime(2024, 1, 15);

  UserProfileEntity makeEntity({String uid = 'uid-123'}) {
    return UserProfileEntity(
      uid: uid,
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      createdAt: testDate,
      updatedAt: testDate,
    );
  }

  setUp(() {
    mockRepository = MockUserProfileRepository();
    useCase = GetUserProfile(mockRepository);
  });

  group('GetUserProfile use case', () {
    test('returns UserProfileEntity when profile exists', () async {
      final entity = makeEntity();
      when(
        mockRepository.getProfile('uid-123'),
      ).thenAnswer((_) async => entity);

      final result = await useCase('uid-123');

      expect(result, equals(entity));
      verify(mockRepository.getProfile('uid-123')).called(1);
    });

    test('returns null when profile does not exist', () async {
      when(
        mockRepository.getProfile('uid-unknown'),
      ).thenAnswer((_) async => null);

      final result = await useCase('uid-unknown');

      expect(result, isNull);
      verify(mockRepository.getProfile('uid-unknown')).called(1);
    });

    test('delegates directly to repository with the provided uid', () async {
      when(mockRepository.getProfile('some-uid')).thenAnswer((_) async => null);

      await useCase('some-uid');

      verify(mockRepository.getProfile('some-uid')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('propagates repository exceptions', () async {
      when(
        mockRepository.getProfile('uid-123'),
      ).thenThrow(Exception('storage error'));

      expect(() => useCase('uid-123'), throwsException);
    });
  });
}
