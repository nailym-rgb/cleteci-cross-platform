import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/domain/repositories/auth_repository.dart';

/// Mock manual de AuthRepository para verificar que la interfaz
/// compila sin ninguna dependencia de Firebase.
/// Uses noSuchMethod overrides so Mockito's when()/verify() can intercept calls.
class MockAuthRepository extends Mock implements AuthRepository {
  // Getters need noSuchMethod overrides because they return non-nullable types.
  // Without this, Mock.noSuchMethod returns null which causes type cast errors.
  @override
  Stream<UserProfileEntity?> get authStateChanges =>
      super.noSuchMethod(
            Invocation.getter(#authStateChanges),
            returnValue: Stream<UserProfileEntity?>.value(null),
          )
          as Stream<UserProfileEntity?>;

  @override
  UserProfileEntity? get currentUser =>
      super.noSuchMethod(Invocation.getter(#currentUser), returnValue: null)
          as UserProfileEntity?;

  @override
  Future<UserProfileEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
            Invocation.method(#signInWithEmailAndPassword, [], {
              #email: email,
              #password: password,
            }),
            returnValue: Future<UserProfileEntity>.value(
              UserProfileEntity(
                uid: '',
                email: '',
                firstName: '',
                lastName: '',
                createdAt: DateTime(2024),
                updatedAt: DateTime(2024),
              ),
            ),
          )
          as Future<UserProfileEntity>;

  @override
  Future<UserProfileEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
            Invocation.method(#createUserWithEmailAndPassword, [], {
              #email: email,
              #password: password,
            }),
            returnValue: Future<UserProfileEntity>.value(
              UserProfileEntity(
                uid: '',
                email: '',
                firstName: '',
                lastName: '',
                createdAt: DateTime(2024),
                updatedAt: DateTime(2024),
              ),
            ),
          )
          as Future<UserProfileEntity>;

  @override
  Future<void> signOut() =>
      super.noSuchMethod(
            Invocation.method(#signOut, []),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      super.noSuchMethod(
            Invocation.method(#sendPasswordResetEmail, [email]),
            returnValue: Future<void>.value(),
          )
          as Future<void>;

  @override
  Future<void> reload() =>
      super.noSuchMethod(
            Invocation.method(#reload, []),
            returnValue: Future<void>.value(),
          )
          as Future<void>;
}

void main() {
  late MockAuthRepository mockAuthRepository;
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
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthRepository interface', () {
    test('interface compiles without Firebase imports', () {
      // El hecho de que este test compila y corre prueba que
      // AuthRepository no tiene dependencias de Firebase en su contrato
      expect(mockAuthRepository, isA<AuthRepository>());
    });

    test(
      'authStateChanges returns stream of nullable UserProfileEntity',
      () async {
        final entity = makeEntity();
        when(
          mockAuthRepository.authStateChanges,
        ).thenAnswer((_) => Stream.value(entity));

        final result = await mockAuthRepository.authStateChanges.first;

        expect(result, equals(entity));
      },
    );

    test('authStateChanges can emit null when logged out', () async {
      when(
        mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => Stream.value(null));

      final result = await mockAuthRepository.authStateChanges.first;

      expect(result, isNull);
    });

    test('currentUser returns null when not authenticated', () {
      when(mockAuthRepository.currentUser).thenReturn(null);

      expect(mockAuthRepository.currentUser, isNull);
    });

    test('currentUser returns UserProfileEntity when authenticated', () {
      final entity = makeEntity();
      when(mockAuthRepository.currentUser).thenReturn(entity);

      expect(mockAuthRepository.currentUser, equals(entity));
    });

    test('signInWithEmailAndPassword returns UserProfileEntity', () async {
      final entity = makeEntity();
      when(
        mockAuthRepository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => entity);

      final result = await mockAuthRepository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, equals(entity));
    });

    test('createUserWithEmailAndPassword returns UserProfileEntity', () async {
      final entity = makeEntity(uid: 'new-uid');
      when(
        mockAuthRepository.createUserWithEmailAndPassword(
          email: 'new@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => entity);

      final result = await mockAuthRepository.createUserWithEmailAndPassword(
        email: 'new@example.com',
        password: 'password123',
      );

      expect(result, equals(entity));
    });

    test('signOut completes without error', () async {
      when(mockAuthRepository.signOut()).thenAnswer((_) async {});

      await expectLater(mockAuthRepository.signOut(), completes);
    });

    test('sendPasswordResetEmail completes without error', () async {
      when(
        mockAuthRepository.sendPasswordResetEmail('test@example.com'),
      ).thenAnswer((_) async {});

      await expectLater(
        mockAuthRepository.sendPasswordResetEmail('test@example.com'),
        completes,
      );
    });

    test('reload completes without error', () async {
      when(mockAuthRepository.reload()).thenAnswer((_) async {});

      await expectLater(mockAuthRepository.reload(), completes);
    });
  });
}
