import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para el perfil de usuario en Firestore
class UserProfile {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Nombre completo del usuario
  String get fullName => '$firstName $lastName';

  /// Iniciales del usuario para avatar por defecto
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();

  /// Crear instancia desde un documento de Firestore
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convertir a mapa para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Crear copia con campos actualizados
  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}