import '../../repositories/auth_repository.dart';

/// Caso de uso: cerrar sesión del usuario actual
class SignOutUseCase {
  final AuthRepository _authRepository;

  const SignOutUseCase(this._authRepository);

  Future<void> call() {
    return _authRepository.signOut();
  }
}
