import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/domain/repositories/auth_repository.dart';
import 'package:cleteci_cross_platform/domain/usecases/auth/sign_in_use_case.dart';

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
  late SignInUseCase useCase;
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
    mockRepository = MockAuthRepository();
    useCase = SignInUseCase(mockRepository);
  });

  group('SignInUseCase', () {
    test('returns UserProfileEntity on successful sign in', () async {
      // Arrange
      final entity = makeEntity();
      when(mockRepository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => entity);

      // Act
      final result = await useCase(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, equals(entity));
      verify(mockRepository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('delegates email and password to repository correctly', () async {
      // Arrange
      final entity = makeEntity();
      when(mockRepository.signInWithEmailAndPassword(
        email: 'specific@email.com',
        password: 'specific-pass',
      )).thenAnswer((_) async => entity);

      // Act
      await useCase(
        email: 'specific@email.com',
        password: 'specific-pass',
      );

      // Assert
      verify(mockRepository.signInWithEmailAndPassword(
        email: 'specific@email.com',
        password: 'specific-pass',
      )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('propagates repository exceptions', () async {
      // Arrange
      when(mockRepository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'pass',
      )).thenThrow(Exception('auth error'));

      // Act & Assert
      expect(
        () => useCase(email: 'test@example.com', password: 'pass'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
