import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/domain/repositories/auth_repository.dart';
import 'package:cleteci_cross_platform/domain/usecases/auth/sign_out_use_case.dart';

// ---------------------------------------------------------------------------
// Manual Mockito mock — override non-nullable return types
// ---------------------------------------------------------------------------

final _fallbackEntity = UserProfileEntity(
  uid: '',
  email: '',
  firstName: '',
  lastName: '',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class MockAuthRepository extends Mock implements AuthRepository {
  @override
  Stream<UserProfileEntity?> get authStateChanges =>
      super.noSuchMethod(
        Invocation.getter(#authStateChanges),
        returnValue: Stream<UserProfileEntity?>.value(null),
      ) as Stream<UserProfileEntity?>;

  @override
  Future<UserProfileEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#signInWithEmailAndPassword, [], {#email: email, #password: password}),
        returnValue: Future.value(_fallbackEntity),
      ) as Future<UserProfileEntity>;

  @override
  Future<UserProfileEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#createUserWithEmailAndPassword, [], {#email: email, #password: password}),
        returnValue: Future.value(_fallbackEntity),
      ) as Future<UserProfileEntity>;

  @override
  Future<void> signOut() =>
      super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      super.noSuchMethod(
        Invocation.method(#sendPasswordResetEmail, [email]),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> reload() =>
      super.noSuchMethod(
        Invocation.method(#reload, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}

void main() {
  late MockAuthRepository mockRepository;
  late SignOutUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignOutUseCase(mockRepository);
  });

  group('SignOutUseCase', () {
    test('calls repository signOut', () async {
      // Arrange
      when(mockRepository.signOut()).thenAnswer((_) async {});

      // Act
      await useCase();

      // Assert
      verify(mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('completes successfully when repository succeeds', () async {
      // Arrange
      when(mockRepository.signOut()).thenAnswer((_) async {});

      // Act & Assert
      await expectLater(useCase(), completes);
    });

    test('propagates repository exceptions', () async {
      // Arrange
      when(mockRepository.signOut()).thenThrow(Exception('sign out error'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
