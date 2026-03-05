import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cleteci_cross_platform/domain/entities/user_profile_entity.dart';
import 'package:cleteci_cross_platform/shared/infrastructure/repositories/firebase_user_profile_repository_impl.dart';

// ---------------------------------------------------------------------------
// Manual Mockito mocks — no code generation required
// ---------------------------------------------------------------------------

// Fallback collection reference used as a return value when Mockito has no stub.
class _FakeCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {}

// Fallback document reference used as a return value when Mockito has no stub.
class _FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

// Fallback document snapshot used as a return value when Mockito has no stub.
class _FakeDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      super.noSuchMethod(
        Invocation.method(#collection, [collectionPath]),
        returnValue: _FakeCollectionReference(),
        returnValueForMissingStub: _FakeCollectionReference(),
      );
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      super.noSuchMethod(
        Invocation.method(#doc, [path]),
        returnValue: _FakeDocumentReference(),
        returnValueForMissingStub: _FakeDocumentReference(),
      );
}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> set(Object? data, [SetOptions? options]) => super.noSuchMethod(
    Invocation.method(#set, [data, options]),
    returnValue: Future<void>.value(),
    returnValueForMissingStub: Future<void>.value(),
  );

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) =>
      super.noSuchMethod(
        Invocation.method(#get, [options]),
        returnValue: Future.value(_FakeDocumentSnapshot()),
        returnValueForMissingStub: Future.value(_FakeDocumentSnapshot()),
      );

  @override
  Future<void> delete() => super.noSuchMethod(
    Invocation.method(#delete, []),
    returnValue: Future<void>.value(),
    returnValueForMissingStub: Future<void>.value(),
  );

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => super.noSuchMethod(
    Invocation.method(#snapshots, [], {
      #includeMetadataChanges: includeMetadataChanges,
      #source: source,
    }),
    returnValue: const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty(),
    returnValueForMissingStub:
        const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty(),
  );
}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  bool get exists => super.noSuchMethod(
    Invocation.getter(#exists),
    returnValue: false,
    returnValueForMissingStub: false,
  );

  @override
  String get id => super.noSuchMethod(
    Invocation.getter(#id),
    returnValue: '',
    returnValueForMissingStub: '',
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _uid = 'user-001';
const _email = 'ana@example.com';
const _firstName = 'Ana';
const _lastName = 'Garcia';
final _testDate = DateTime(2024, 6, 1);

UserProfileEntity _makeEntity({String uid = _uid, String? avatarUrl}) =>
    UserProfileEntity(
      uid: uid,
      email: _email,
      firstName: _firstName,
      lastName: _lastName,
      avatarUrl: avatarUrl,
      createdAt: _testDate,
      updatedAt: _testDate,
    );

Map<String, dynamic> _makeFirestoreData({String? avatarUrl}) => {
  'email': _email,
  'firstName': _firstName,
  'lastName': _lastName,
  'avatarUrl': avatarUrl,
  'createdAt': Timestamp.fromDate(_testDate),
  'updatedAt': Timestamp.fromDate(_testDate),
};

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockSnapshot;
  late FirebaseUserProfileRepositoryImpl repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    when(mockFirestore.collection('users')).thenReturn(mockCollection);

    repository = FirebaseUserProfileRepositoryImpl(mockFirestore, mockAuth);
  });

  // -----------------------------------------------------------------------
  // getProfile
  // -----------------------------------------------------------------------

  group('getProfile', () {
    test('returns UserProfileEntity when document exists', () async {
      // Arrange
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.id).thenReturn(_uid);
      when(mockSnapshot.data()).thenReturn(_makeFirestoreData());

      // Act
      final result = await repository.getProfile(_uid);

      // Assert
      expect(result, isNotNull);
      expect(result!.uid, equals(_uid));
      expect(result.email, equals(_email));
      expect(result.firstName, equals(_firstName));
      expect(result.lastName, equals(_lastName));
      expect(result.avatarUrl, isNull);
    });

    test('returns null when document does not exist', () async {
      // Arrange
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.getProfile(_uid);

      // Assert
      expect(result, isNull);
    });

    test('returns entity with avatarUrl when present', () async {
      // Arrange
      const avatarUrl = 'https://example.com/avatar.jpg';
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.id).thenReturn(_uid);
      when(
        mockSnapshot.data(),
      ).thenReturn(_makeFirestoreData(avatarUrl: avatarUrl));

      // Act
      final result = await repository.getProfile(_uid);

      // Assert
      expect(result, isNotNull);
      expect(result!.avatarUrl, equals(avatarUrl));
    });

    test('throws Exception when Firestore call fails', () async {
      // Arrange
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(mockDocRef.get()).thenThrow(Exception('network error'));

      // Act & Assert
      expect(() => repository.getProfile(_uid), throwsA(isA<Exception>()));
    });
  });

  // -----------------------------------------------------------------------
  // updateProfile
  // -----------------------------------------------------------------------

  group('updateProfile', () {
    test('calls Firestore set with merge option', () async {
      // Arrange
      final entity = _makeEntity();
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(mockDocRef.set(any, any)).thenAnswer((_) async {});

      // Act
      await repository.updateProfile(entity);

      // Assert
      verify(mockDocRef.set(any, any)).called(1);
    });

    test('throws Exception when Firestore set fails', () async {
      // Arrange
      final entity = _makeEntity();
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(mockDocRef.set(any, any)).thenThrow(Exception('write error'));

      // Act & Assert
      expect(() => repository.updateProfile(entity), throwsA(isA<Exception>()));
    });
  });

  // -----------------------------------------------------------------------
  // deleteProfile
  // -----------------------------------------------------------------------

  group('deleteProfile', () {
    test('calls Firestore delete on correct document', () async {
      // Arrange
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenAnswer((_) async {});

      // Act
      await repository.deleteProfile(_uid);

      // Assert
      verify(mockDocRef.delete()).called(1);
    });

    test('throws Exception when Firestore delete fails', () async {
      // Arrange
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenThrow(Exception('delete error'));

      // Act & Assert
      expect(() => repository.deleteProfile(_uid), throwsA(isA<Exception>()));
    });
  });

  // -----------------------------------------------------------------------
  // watchProfile
  // -----------------------------------------------------------------------

  group('watchProfile', () {
    test('emits UserProfileEntity when document exists', () {
      // Arrange
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.id).thenReturn(_uid);
      when(mockSnapshot.data()).thenReturn(_makeFirestoreData());
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(
        mockDocRef.snapshots(),
      ).thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final stream = repository.watchProfile(_uid);

      // Assert
      expect(stream, emits(isA<UserProfileEntity>()));
    });

    test('emits null when document does not exist', () {
      // Arrange
      when(mockSnapshot.exists).thenReturn(false);
      when(mockCollection.doc(_uid)).thenReturn(mockDocRef);
      when(
        mockDocRef.snapshots(),
      ).thenAnswer((_) => Stream.value(mockSnapshot));

      // Act
      final stream = repository.watchProfile(_uid);

      // Assert
      expect(stream, emits(isNull));
    });
  });
}
