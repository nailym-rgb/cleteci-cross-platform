/// Entidad de dominio para el perfil de usuario
/// Representa los datos básicos del usuario sin dependencias externas
class UserProfileEntity {
  static const _sentinel = Object();
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileEntity({
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

  /// Crear copia con campos actualizados
  UserProfileEntity copyWith({
    String? firstName,
    String? lastName,
    Object? avatarUrl = _sentinel,
    DateTime? updatedAt,
  }) {
    return UserProfileEntity(
      uid: uid,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: identical(avatarUrl, _sentinel) ? this.avatarUrl : avatarUrl as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfileEntity &&
        other.uid == uid &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.avatarUrl == avatarUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        uid,
        email,
        firstName,
        lastName,
        avatarUrl,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'UserProfileEntity(uid: $uid, email: $email, firstName: $firstName, '
      'lastName: $lastName, avatarUrl: $avatarUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}