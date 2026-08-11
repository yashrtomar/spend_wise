import 'package:spend_wise/features/profile/domain/entities/user_profile.dart';
import 'package:spend_wise/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  Future<UserProfile?> execute() {
    return _repository.getProfile();
  }
}

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<void> execute(UserProfile profile) {
    return _repository.updateProfile(profile);
  }
}
