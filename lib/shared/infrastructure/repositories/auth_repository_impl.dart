import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../../domain/repositories/auth_repository.dart';

/// Implementación del repositorio de autenticación usando Firebase Auth
/// Traduce tipos de Firebase a entidades de dominio
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl(this._firebaseAuth);

  /// Convierte un [User] de Firebase a [UserProfileEntity] de dominio
  UserProfileEntity _toEntity(User user) {
    final now = DateTime.now();
    return UserProfileEntity(
      uid: user.uid,
      email: user.email ?? '',
      firstName: user.displayName?.split(' ').first ?? '',
      lastName: user.displayName != null && user.displayName!.contains(' ')
          ? user.displayName!.split(' ').skip(1).join(' ')
          : '',
      avatarUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? now,
      updatedAt: now,
    );
  }

  @override
  Stream<UserProfileEntity?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(
            (user) => user != null ? _toEntity(user) : null,
          );

  @override
  UserProfileEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? _toEntity(user) : null;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserProfileEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toEntity(credential.user!);
  }

  @override
  Future<UserProfileEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _toEntity(credential.user!);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> reload() async {
    await _firebaseAuth.currentUser?.reload();
  }
}
