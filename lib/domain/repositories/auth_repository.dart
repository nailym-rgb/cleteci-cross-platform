import '../entities/user_profile_entity.dart';

/// Interfaz de repositorio para operaciones de autenticación
/// Define el contrato para autenticación sin dependencias de implementación
/// Retorna tipos de dominio propios — sin Firebase
abstract class AuthRepository {
  /// Stream de cambios de estado de autenticación
  /// Emite null cuando el usuario cierra sesión
  Stream<UserProfileEntity?> get authStateChanges;

  /// Usuario actualmente autenticado, null si no hay sesión
  UserProfileEntity? get currentUser;

  /// Cerrar sesión del usuario actual
  Future<void> signOut();

  /// Iniciar sesión con email y contraseña
  /// Retorna el perfil del usuario autenticado
  Future<UserProfileEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Crear usuario con email y contraseña
  /// Retorna el perfil del usuario recién creado
  Future<UserProfileEntity> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Enviar email de restablecimiento de contraseña
  Future<void> sendPasswordResetEmail(String email);

  /// Recargar información del usuario actual desde el proveedor de identidad
  Future<void> reload();
}
