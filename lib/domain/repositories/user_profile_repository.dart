import '../entities/user_profile_entity.dart';

/// Interfaz de repositorio para gestión de perfiles de usuario
/// Define el contrato para operaciones CRUD de perfiles sin dependencias de implementación
abstract class UserProfileRepository {
  /// Obtener el perfil de un usuario por su uid
  Future<UserProfileEntity?> getProfile(String uid);

  /// Guardar o actualizar el perfil de un usuario
  Future<void> updateProfile(UserProfileEntity profile);

  /// Eliminar el perfil de un usuario
  Future<void> deleteProfile(String uid);

  /// Stream para escuchar cambios en el perfil de un usuario
  Stream<UserProfileEntity?> watchProfile(String uid);
}
