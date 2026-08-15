import 'package:spend_wise/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_wise/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:spend_wise/features/profile/data/models/user_profile_model.dart';
import 'package:spend_wise/features/profile/domain/entities/user_profile.dart';
import 'package:spend_wise/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;

  ProfileRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<UserProfile?> getProfile() async {
    // 1. Try local first
    final localProfile = await _localDataSource.getProfile();
    if (localProfile != null) {
      // Return local, sync in background
      _syncProfileInBackground();
      return localProfile;
    }

    // 2. Fallback to remote if local is empty
    final remoteProfile = await _remoteDataSource.getProfile();
    if (remoteProfile != null) {
      await _localDataSource.updateProfile(remoteProfile, isSync: true);
      return remoteProfile;
    }
    
    return null;
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(profile);
    
    // 1. Write to local db instantly
    await _localDataSource.updateProfile(model);
    
    // 2. Sync in background
    _syncProfileInBackground();
  }
  
  Future<void> _syncProfileInBackground() async {
    try {
      final remoteProfile = await _remoteDataSource.getProfile();
      if (remoteProfile != null) {
        await _localDataSource.updateProfile(remoteProfile, isSync: true);
      }
    } catch (e) {
      // Silently fail in background, SyncService will handle it
    }
  }
}
