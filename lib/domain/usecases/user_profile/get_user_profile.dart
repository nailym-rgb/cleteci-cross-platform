import '../../entities/user_profile_entity.dart';
import '../../repositories/user_profile_repository.dart';

/// Caso de uso: obtener el perfil de un usuario por uid
class GetUserProfile {
  final UserProfileRepository _userProfileRepository;

  const GetUserProfile(this._userProfileRepository);

  Future<UserProfileEntity?> call(String uid) {
    return _userProfileRepository.getProfile(uid);
  }
}
