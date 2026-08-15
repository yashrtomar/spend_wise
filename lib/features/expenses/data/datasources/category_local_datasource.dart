import 'package:spend_wise/features/expenses/data/models/category_model.dart';
import 'package:spend_wise/utils/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';

class CategoryLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<CategoryModel>> getCategories() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ? AND sync_status != ?',
      whereArgs: [userId, SyncStatus.pendingDelete],
      orderBy: 'name ASC',
    );

    return maps.map((map) => CategoryModel.fromJson(map)).toList();
  }

  Future<CategoryModel> addCategory(CategoryModel category, {bool isSync = false}) async {
    final db = await _dbHelper.database;
    final status = isSync ? SyncStatus.synced : SyncStatus.pendingInsert;
    
    final userId = Supabase.instance.client.auth.currentUser?.id;
    
    final data = category.toJson();
    data['sync_status'] = status;
    data['user_id'] = userId;
    
    await db.insert(
      'categories',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return category;
  }

  Future<void> updateCategory(CategoryModel category, {bool isSync = false}) async {
    final db = await _dbHelper.database;
    final status = isSync ? SyncStatus.synced : SyncStatus.pendingUpdate;
    
    final data = category.toJson();
    data['sync_status'] = status;
    
    await db.update(
      'categories',
      data,
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      {'sync_status': SyncStatus.pendingDelete},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> hardDeleteCategory(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSyncStatus(String id, int status) async {
    final db = await _dbHelper.database;
    await db.update(
      'categories',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getPendingInserts() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pendingInsert],
    );
    return maps.map((map) => CategoryModel.fromJson(map)).toList();
  }

  Future<List<CategoryModel>> getPendingUpdates() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pendingUpdate],
    );
    return maps.map((map) => CategoryModel.fromJson(map)).toList();
  }

  Future<List<String>> getPendingDeletes() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'categories',
      columns: ['id'],
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pendingDelete],
    );
    return maps.map((map) => map['id'] as String).toList();
  }
}
