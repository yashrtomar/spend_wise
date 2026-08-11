import 'package:spend_wise/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:spend_wise/features/profile/data/models/user_profile_model.dart';
import 'package:spend_wise/features/profile/domain/entities/user_profile.dart';
import 'package:spend_wise/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserProfile?> getProfile() async {
    return await _remoteDataSource.getProfile();
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(profile);
    await _remoteDataSource.updateProfile(model);
  }
}
