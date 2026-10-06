import 'dart:async';
import 'package:spend_wise/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_wise/features/profile/data/models/user_profile_model.dart';
import 'package:spend_wise/features/profile/domain/entities/user_profile.dart';
import 'package:spend_wise/features/profile/domain/repositories/profile_repository.dart';
import 'package:spend_wise/services/sync_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _local;
  final SyncService _sync;
  ProfileRepositoryImpl(this._local, this._sync);
  @override
  Future<UserProfile?> getProfile() => _local.getProfile();
  @override
  Future<void> updateProfile(UserProfile profile) async {
    await _local.updateProfile(UserProfileModel.fromEntity(profile));
    unawaited(_sync.syncNow());
  }
}
