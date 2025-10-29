import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

/// Servicio para manejar operaciones de usuario en Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Colección de usuarios en Firestore
  CollectionReference get _users => _firestore.collection('users');

  /// Obtener el perfil de usuario actual
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _users.doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener perfil de usuario: $e');
    }
  }

  /// Crear o actualizar perfil de usuario
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _users.doc(profile.uid).set(
        profile.toFirestore(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Error al guardar perfil de usuario: $e');
    }
  }

  /// Crear perfil inicial después del registro
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? avatarUrl,
  }) async {
    final now = DateTime.now();
    final profile = UserProfile(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      createdAt: now,
      updatedAt: now,
    );

    await saveUserProfile(profile);
  }

  /// Actualizar perfil de usuario
  Future<void> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };

      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

      await _users.doc(uid).update(updates);
    } catch (e) {
      throw Exception('Error al actualizar perfil de usuario: $e');
    }
  }

  /// Stream para escuchar cambios en el perfil del usuario actual
  Stream<UserProfile?> watchCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _users.doc(user.uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }
}