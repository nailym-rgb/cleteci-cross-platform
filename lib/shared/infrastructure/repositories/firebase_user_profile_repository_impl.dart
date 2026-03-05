import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/user_profile_entity.dart';
import '../../../domain/repositories/user_profile_repository.dart';

/// Implementación del repositorio de perfil de usuario usando Firebase Firestore
/// Traduce documentos de Firestore a entidades de dominio [UserProfileEntity]
class FirebaseUserProfileRepositoryImpl implements UserProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseUserProfileRepositoryImpl(this._firestore, this._auth);

  /// Colección de usuarios en Firestore
  CollectionReference get _users => _firestore.collection('users');

  /// Convierte un [DocumentSnapshot] de Firestore a [UserProfileEntity] de dominio
  UserProfileEntity _toEntity(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileEntity(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convierte un [UserProfileEntity] a un mapa apto para Firestore
  Map<String, dynamic> _toFirestore(UserProfileEntity profile) {
    return {
      'email': profile.email,
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'avatarUrl': profile.avatarUrl,
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'updatedAt': Timestamp.fromDate(profile.updatedAt),
    };
  }

  @override
  Future<UserProfileEntity?> getProfile(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;
      return _toEntity(doc);
    } catch (e) {
      throw Exception('Error al obtener perfil de usuario: $e');
    }
  }

  @override
  Future<void> updateProfile(UserProfileEntity profile) async {
    try {
      await _users.doc(profile.uid).set(
        _toFirestore(profile),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Error al guardar perfil de usuario: $e');
    }
  }

  @override
  Future<void> deleteProfile(String uid) async {
    try {
      await _users.doc(uid).delete();
    } catch (e) {
      throw Exception('Error al eliminar perfil de usuario: $e');
    }
  }

  @override
  Stream<UserProfileEntity?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return _toEntity(doc);
    });
  }
}
