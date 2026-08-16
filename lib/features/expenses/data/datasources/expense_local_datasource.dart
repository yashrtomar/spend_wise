import 'package:spend_wise/features/expenses/data/models/expense_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:spend_wise/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseLocalDataSource {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> insertExpense(ExpenseModel expense, {int syncStatus = SyncStatus.pendingInsert}) async {
    final db = await _dbHelper.database;
    final data = expense.toJson();
    data['sync_status'] = syncStatus;
    
    await db.insert(
      'expenses',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExpense(ExpenseModel expense, {int syncStatus = SyncStatus.pendingUpdate}) async {
    final db = await _dbHelper.database;
    final data = expense.toJson();
    data['sync_status'] = syncStatus;
    
    await db.update(
      'expenses',
      data,
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id, {int syncStatus = SyncStatus.pendingDelete}) async {
    final db = await _dbHelper.database;
    
    // Instead of hard deleting, we might want to soft delete to sync it later if it wasn't already synced.
    // However, for simplicity here, we'll mark it as pending delete. If it's already pending insert, we can just hard delete.
    
    final existing = await db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (existing.isNotEmpty) {
      final status = existing.first['sync_status'] as int;
      if (status == SyncStatus.pendingInsert) {
        // It was never synced, just delete it locally
        await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
      } else {
        // Mark for deletion sync
        await db.update(
          'expenses',
          {'sync_status': syncStatus},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }
  
  // Real delete for when it is successfully synced
  Future<void> hardDeleteExpense(String id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExpenseModel>> getExpenses({
    int? limit,
    int? offset,
    String? searchQuery,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final db = await _dbHelper.database;
    
    String where = 'sync_status != ? AND user_id = ?';
    List<dynamic> whereArgs = [SyncStatus.pendingDelete, userId];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where += ' AND name LIKE ?';
      whereArgs.add('%$searchQuery%');
    }

    if (filter != null) {
      if (filter.startDate != null) {
        where += ' AND created_at >= ?';
        whereArgs.add(filter.startDate!.toIso8601String());
      }
      if (filter.endDate != null) {
        final end = filter.endDate!.add(const Duration(days: 1));
        where += ' AND created_at < ?';
        whereArgs.add(end.toIso8601String());
      }
      if (filter.categories != null && filter.categories!.isNotEmpty) {
        where += ' AND category IN (${List.filled(filter.categories!.length, '?').join(',')})';
        whereArgs.addAll(filter.categories!);
      }
      if (filter.minAmount != null) {
        where += ' AND amount >= ?';
        whereArgs.add(filter.minAmount!);
      }
      if (filter.maxAmount != null) {
        where += ' AND amount <= ?';
        whereArgs.add(filter.maxAmount!);
      }
    }

    String orderBy = 'created_at DESC';
    if (sort != null) {
      switch (sort) {
        case ExpenseSort.newest:
          orderBy = 'created_at DESC';
          break;
        case ExpenseSort.oldest:
          orderBy = 'created_at ASC';
          break;
        case ExpenseSort.amountHighest:
          orderBy = 'amount DESC';
          break;
        case ExpenseSort.amountLowest:
          orderBy = 'amount ASC';
          break;
      }
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return ExpenseModel.fromJson(maps[i]);
    });
  }

  Future<Map<String, double>> getExpensesByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return {};

    final db = await _dbHelper.database;
    final end = endDate.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      columns: ['category', 'SUM(amount) as total'],
      where: 'sync_status != ? AND user_id = ? AND created_at >= ? AND created_at < ?',
      whereArgs: [SyncStatus.pendingDelete, userId, startDate.toIso8601String(), end.toIso8601String()],
      groupBy: 'category',
    );

    final Map<String, double> categoryTotals = {};
    for (var map in maps) {
      final category = map['category'] as String? ?? 'Other';
      final total = (map['total'] as num?)?.toDouble() ?? 0.0;
      categoryTotals[category] = total;
    }
    
    return categoryTotals;
  }

  Future<List<ExpenseModel>> getRecentExpenses(int limit) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'sync_status != ? AND user_id = ?',
      whereArgs: [SyncStatus.pendingDelete, userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return ExpenseModel.fromJson(maps[i]);
    });
  }

  // Sync helpers
  Future<List<ExpenseModel>> getPendingInserts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final db = await _dbHelper.database;
    final maps = await db.query('expenses', where: 'sync_status = ? AND user_id = ?', whereArgs: [SyncStatus.pendingInsert, userId]);
    return maps.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  Future<List<ExpenseModel>> getPendingUpdates() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final db = await _dbHelper.database;
    final maps = await db.query('expenses', where: 'sync_status = ? AND user_id = ?', whereArgs: [SyncStatus.pendingUpdate, userId]);
    return maps.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  Future<List<String>> getPendingDeletes() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];
    final db = await _dbHelper.database;
    final maps = await db.query('expenses', columns: ['id'], where: 'sync_status = ? AND user_id = ?', whereArgs: [SyncStatus.pendingDelete, userId]);
    return maps.map((e) => e['id'] as String).toList();
  }
  
  Future<void> updateSyncStatus(String id, int status) async {
    final db = await _dbHelper.database;
    await db.update(
      'expenses',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
