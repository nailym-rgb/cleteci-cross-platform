import '../../entities/user_profile_entity.dart';
import '../../repositories/auth_repository.dart';

/// Caso de uso: iniciar sesión con email y contraseña
/// Encapsula la lógica de autenticación delegando al repositorio
class SignInUseCase {
  final AuthRepository _authRepository;

  const SignInUseCase(this._authRepository);

  Future<UserProfileEntity> call({
    required String email,
    required String password,
  }) {
    return _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
