import '../../entities/user_profile_entity.dart';
import '../../repositories/user_profile_repository.dart';

/// Caso de uso: actualizar el perfil de un usuario
class UpdateUserProfile {
  final UserProfileRepository _userProfileRepository;

  const UpdateUserProfile(this._userProfileRepository);

  Future<void> call(UserProfileEntity profile) {
    return _userProfileRepository.updateProfile(profile);
  }
}
