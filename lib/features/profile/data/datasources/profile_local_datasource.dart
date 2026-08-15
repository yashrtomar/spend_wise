import 'dart:convert';
import 'package:spend_wise/features/profile/data/models/user_profile_model.dart';
import 'package:spend_wise/utils/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';

class ProfileLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<UserProfileModel?> getProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return _mapToModel(maps.first);
    }
    return null;
  }

  Future<void> updateProfile(UserProfileModel profile, {bool isSync = false}) async {
    final db = await _dbHelper.database;
    
    // If it's a sync from remote, status is synced, else pendingUpdate
    final status = isSync ? SyncStatus.synced : SyncStatus.pendingUpdate;
    
    final data = _modelToMap(profile);
    data['sync_status'] = status;
    
    await db.insert(
      'user_profiles',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserProfileModel>> getPendingUpdates() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profiles',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pendingUpdate],
    );

    return maps.map((map) => _mapToModel(map)).toList();
  }

  Future<void> updateSyncStatus(String id, int status) async {
    final db = await _dbHelper.database;
    await db.update(
      'user_profiles',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  UserProfileModel _mapToModel(Map<String, dynamic> map) {
    Map<String, dynamic> prefs = {};
    if (map['preferences'] != null) {
      prefs = Map<String, dynamic>.from(json.decode(map['preferences'] as String));
    }
    
    return UserProfileModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      monthlyBudget: (map['monthly_budget'] as num).toDouble(),
      preferences: prefs,
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> _modelToMap(UserProfileModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'monthly_budget': model.monthlyBudget,
      'preferences': json.encode(model.preferences),
      'updated_at': model.updatedAt.toIso8601String(),
    };
  }
}
