import 'dart:convert';
import 'package:spend_wise/features/profile/data/models/user_profile_model.dart';
import 'package:spend_wise/services/sync_store.dart';

class ProfileLocalDataSource {
  final SyncStore store;
  ProfileLocalDataSource(this.store);
  Future<UserProfileModel?> getProfile() async {
    final db = await store.openDatabase();
    final rows = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [store.userId],
    );
    if (rows.isEmpty) return null;
    final data = Map<String, dynamic>.from(rows.single);
    data['preferences'] = data['preferences'] == null
        ? null
        : jsonDecode(data['preferences'] as String);
    return UserProfileModel.fromJson(data);
  }

  Future<void> updateProfile(UserProfileModel profile) => store.save(
    'user_profiles',
    {...profile.toJson(), 'preferences': jsonEncode(profile.preferences)},
  );
}
