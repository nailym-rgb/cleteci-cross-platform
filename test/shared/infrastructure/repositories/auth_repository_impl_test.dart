import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/shared/infrastructure/repositories/auth_repository_impl.dart';

// ---------------------------------------------------------------------------
// Manual Mockito mocks — override non-nullable return types for null safety
// ---------------------------------------------------------------------------

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#signInWithEmailAndPassword, [], {#email: email, #password: password}),
        returnValue: Future.value(_FakeUserCredential()),
      ) as Future<UserCredential>;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      super.noSuchMethod(
        Invocation.method(#createUserWithEmailAndPassword, [], {#email: email, #password: password}),
        returnValue: Future.value(_FakeUserCredential()),
      ) as Future<UserCredential>;

  @override
  Future<void> signOut() =>
      super.noSuchMethod(
        Invocation.method(#signOut, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) =>
      super.noSuchMethod(
        Invocation.method(#sendPasswordResetEmail, [], {#email: email, #actionCodeSettings: actionCodeSettings}),
        returnValue: Future<void>.value(),
      ) as Future<void>;

  @override
  Stream<User?> authStateChanges() =>
      super.noSuchMethod(
        Invocation.method(#authStateChanges, []),
        returnValue: Stream<User?>.value(null),
      ) as Stream<User?>;
}

class MockUser extends Mock implements User {
  @override
  String get uid =>
      super.noSuchMethod(
        Invocation.getter(#uid),
        returnValue: '',
      ) as String;

  @override
  UserMetadata get metadata =>
      super.noSuchMethod(
        Invocation.getter(#metadata),
        returnValue: _FakeUserMetadata(),
      ) as UserMetadata;

  @override
  Future<void> reload() =>
      super.noSuchMethod(
        Invocation.method(#reload, []),
        returnValue: Future<void>.value(),
      ) as Future<void>;
}

class MockUserCredential extends Mock implements UserCredential {}

class _FakeUserCredential extends Fake implements UserCredential {}

class _FakeUserMetadata extends Fake implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime(2024);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _uid = 'user-001';
const _email = 'ana@example.com';
const _displayName = 'Ana Garcia';
const _photoUrl = 'https://example.com/avatar.jpg';
final _creationTime = DateTime(2024, 6, 1);

MockUser _makeMockUser({
  String uid = _uid,
  String? email = _email,
  String? displayName = _displayName,
  String? photoUrl = _photoUrl,
  DateTime? creationTime,
}) {
  final mockUser = MockUser();

  when(mockUser.uid).thenReturn(uid);
  when(mockUser.email).thenReturn(email);
  when(mockUser.displayName).thenReturn(displayName);
  when(mockUser.photoURL).thenReturn(photoUrl);

  // Create a fake metadata that returns the right creationTime
  final metadata = _TestUserMetadata(creationTime ?? _creationTime);
  when(mockUser.metadata).thenReturn(metadata);

  return mockUser;
}

class _TestUserMetadata extends Fake implements UserMetadata {
  final DateTime? _creationTime;
  _TestUserMetadata(this._creationTime);

  @override
  DateTime? get creationTime => _creationTime;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    repository = AuthRepositoryImpl(mockFirebaseAuth);
  });

  // -----------------------------------------------------------------------
  // signInWithEmailAndPassword
  // -----------------------------------------------------------------------

  group('signInWithEmailAndPassword', () {
    test('returns UserProfileEntity on successful sign in', () async {
      // Arrange
      final mockUser = _makeMockUser();
      final mockCredential = MockUserCredential();
      when(mockCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: _email,
        password: 'password123',
      )).thenAnswer((_) async => mockCredential);

      // Act
      final result = await repository.signInWithEmailAndPassword(
        email: _email,
        password: 'password123',
      );

      // Assert
      expect(result, isA<UserProfileEntity>());
      expect(result.uid, equals(_uid));
      expect(result.email, equals(_email));
      expect(result.firstName, equals('Ana'));
      expect(result.lastName, equals('Garcia'));
      expect(result.avatarUrl, equals(_photoUrl));
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: _email,
        password: 'password123',
      )).called(1);
    });

    test('throws when FirebaseAuth fails', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: _email,
        password: 'wrong',
      )).thenThrow(Exception('wrong-password'));

      // Act & Assert
      expect(
        () => repository.signInWithEmailAndPassword(
          email: _email,
          password: 'wrong',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  // -----------------------------------------------------------------------
  // signOut
  // -----------------------------------------------------------------------

  group('signOut', () {
    test('delegates to FirebaseAuth signOut', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      await repository.signOut();

      // Assert
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('throws when FirebaseAuth signOut fails', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenThrow(Exception('sign out error'));

      // Act & Assert
      expect(
        () => repository.signOut(),
        throwsA(isA<Exception>()),
      );
    });
  });

  // -----------------------------------------------------------------------
  // createUserWithEmailAndPassword
  // -----------------------------------------------------------------------

  group('createUserWithEmailAndPassword', () {
    test('returns UserProfileEntity on successful creation', () async {
      // Arrange
      final mockUser = _makeMockUser(uid: 'new-uid');
      final mockCredential = MockUserCredential();
      when(mockCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: _email,
        password: 'password123',
      )).thenAnswer((_) async => mockCredential);

      // Act
      final result = await repository.createUserWithEmailAndPassword(
        email: _email,
        password: 'password123',
      );

      // Assert
      expect(result, isA<UserProfileEntity>());
      expect(result.uid, equals('new-uid'));
      expect(result.email, equals(_email));
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: _email,
        password: 'password123',
      )).called(1);
    });

    test('throws when FirebaseAuth fails', () async {
      // Arrange
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: _email,
        password: 'pass',
      )).thenThrow(Exception('email-already-in-use'));

      // Act & Assert
      expect(
        () => repository.createUserWithEmailAndPassword(
          email: _email,
          password: 'pass',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  // -----------------------------------------------------------------------
  // authStateChanges
  // -----------------------------------------------------------------------

  group('authStateChanges', () {
    test('emits UserProfileEntity when user is authenticated', () {
      // Arrange
      final mockUser = _makeMockUser();
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));

      // Act
      final stream = repository.authStateChanges;

      // Assert
      expect(stream, emits(isA<UserProfileEntity>()));
    });

    test('emits null when user is not authenticated', () {
      // Arrange
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(null));

      // Act
      final stream = repository.authStateChanges;

      // Assert
      expect(stream, emits(isNull));
    });

    test('maps user fields correctly in stream', () async {
      // Arrange
      final mockUser = _makeMockUser();
      when(mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.value(mockUser));

      // Act
      final result = await repository.authStateChanges.first;

      // Assert
      expect(result, isNotNull);
      expect(result!.uid, equals(_uid));
      expect(result.email, equals(_email));
      expect(result.firstName, equals('Ana'));
      expect(result.lastName, equals('Garcia'));
    });
  });

  // -----------------------------------------------------------------------
  // reload
  // -----------------------------------------------------------------------

  group('reload', () {
    test('calls reload on current user', () async {
      // Arrange
      final mockUser = _makeMockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.reload()).thenAnswer((_) async {});

      // Act
      await repository.reload();

      // Assert
      verify(mockUser.reload()).called(1);
    });

    test('does nothing when current user is null', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert — should not throw
      await expectLater(repository.reload(), completes);
    });
  });

  // -----------------------------------------------------------------------
  // sendPasswordResetEmail
  // -----------------------------------------------------------------------

  group('sendPasswordResetEmail', () {
    test('delegates to FirebaseAuth', () async {
      // Arrange
      when(mockFirebaseAuth.sendPasswordResetEmail(email: _email))
          .thenAnswer((_) async {});

      // Act
      await repository.sendPasswordResetEmail(_email);

      // Assert
      verify(mockFirebaseAuth.sendPasswordResetEmail(email: _email)).called(1);
    });

    test('throws when FirebaseAuth fails', () async {
      // Arrange
      when(mockFirebaseAuth.sendPasswordResetEmail(email: _email))
          .thenThrow(Exception('user-not-found'));

      // Act & Assert
      expect(
        () => repository.sendPasswordResetEmail(_email),
        throwsA(isA<Exception>()),
      );
    });
  });

  // -----------------------------------------------------------------------
  // currentUser
  // -----------------------------------------------------------------------

  group('currentUser', () {
    test('returns UserProfileEntity when user is authenticated', () {
      // Arrange
      final mockUser = _makeMockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = repository.currentUser;

      // Assert
      expect(result, isNotNull);
      expect(result!.uid, equals(_uid));
      expect(result.email, equals(_email));
      expect(result.firstName, equals('Ana'));
      expect(result.lastName, equals('Garcia'));
      expect(result.avatarUrl, equals(_photoUrl));
    });

    test('returns null when no user is authenticated', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = repository.currentUser;

      // Assert
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------------
  // _toEntity conversion
  // -----------------------------------------------------------------------

  group('_toEntity conversion (via currentUser)', () {
    test('splits displayName into firstName and lastName', () {
      // Arrange
      final mockUser = _makeMockUser(displayName: 'Maria Jose Lopez');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = repository.currentUser!;

      // Assert
      expect(result.firstName, equals('Maria'));
      expect(result.lastName, equals('Jose Lopez'));
    });

    test('handles single-word displayName', () {
      // Arrange
      final mockUser = _makeMockUser(displayName: 'Ana');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = repository.currentUser!;

      // Assert
      expect(result.firstName, equals('Ana'));
      expect(result.lastName, equals(''));
    });

    test('handles null displayName', () {
      // Arrange
      final mockUser = _makeMockUser(displayName: null);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = repository.currentUser!;

      // Assert
      expect(result.firstName, equals(''));
      expect(result.lastName, equals(''));
    });

    test('handles null email', () {
      // Arrange
      final mockUser = _makeMockUser(email: null);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = repository.currentUser!;

      // Assert
      expect(result.email, equals(''));
    });

    test('handles null photoURL', () {
      // Arrange
      final mockUser = _makeMockUser(photoUrl: null);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = repository.currentUser!;

      // Assert
      expect(result.avatarUrl, isNull);
    });

    test('uses creationTime from metadata', () {
      // Arrange
      final specificDate = DateTime(2023, 3, 15);
      final mockUser = _makeMockUser(creationTime: specificDate);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final result = repository.currentUser!;

      // Assert
      expect(result.createdAt, equals(specificDate));
    });

    test('uses DateTime.now when creationTime is null', () {
      // Arrange
      final mockUser = _makeMockUser();
      // Override metadata to return null creationTime
      final nullMetadata = _TestUserMetadata(null);
      when(mockUser.metadata).thenReturn(nullMetadata);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final before = DateTime.now();
      final result = repository.currentUser!;
      final after = DateTime.now();

      // Assert — createdAt should be approximately now
      expect(result.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(result.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });
}
