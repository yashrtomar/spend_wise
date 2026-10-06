import 'package:spend_wise/features/expenses/data/models/expense_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:spend_wise/services/sync_store.dart';
import 'package:spend_wise/utils/database_helper.dart';

class ExpenseLocalDataSource {
  final SyncStore store;
  ExpenseLocalDataSource(this.store);

  Future<void> insertExpense(ExpenseModel expense) =>
      store.save('expenses', expense.toJson(), insert: true);
  Future<void> updateExpense(ExpenseModel expense) async {
    final data = expense.toJson()
      ..remove('user_id')
      ..remove('created_at');
    await store.save('expenses', data);
  }

  Future<void> deleteExpense(String id) => store.deleteExpense(id);

  Future<List<ExpenseModel>> getExpenses({
    int? limit,
    int? offset,
    String? searchQuery,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  }) async {
    final userId = store.userId;

    final db = await store.openDatabase();

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
        where +=
            ' AND category IN (${List.filled(filter.categories!.length, '?').join(',')})';
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
      orderBy: '$orderBy, id ASC',
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
    final userId = store.userId;

    final db = await store.openDatabase();
    final end = endDate.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      columns: ['category', 'SUM(amount) as total'],
      where:
          'sync_status != ? AND user_id = ? AND created_at >= ? AND created_at < ?',
      whereArgs: [
        SyncStatus.pendingDelete,
        userId,
        startDate.toIso8601String(),
        end.toIso8601String(),
      ],
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
    final userId = store.userId;

    final db = await store.openDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'sync_status != ? AND user_id = ?',
      whereArgs: [SyncStatus.pendingDelete, userId],
      orderBy: 'created_at DESC, id ASC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return ExpenseModel.fromJson(maps[i]);
    });
  }
}
