import 'package:spend_wise/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:spend_wise/features/expenses/data/models/expense_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:spend_wise/features/expenses/domain/repositories/expense_repository.dart';
import 'package:spend_wise/utils/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remoteDataSource;
  final ExpenseLocalDataSource _localDataSource;
  final _uuid = const Uuid();

  ExpenseRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Expense> addExpense(Expense expense) async {
    // Generate UUID if offline and ID is null
    final id = expense.id ?? _uuid.v4();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    
    final expenseWithId = expense.copyWith(
      id: id, 
      userId: expense.userId ?? userId,
      createdAt: expense.createdAt ?? DateTime.now(), 
      updatedAt: expense.updatedAt ?? DateTime.now()
    );
    final model = ExpenseModel.fromEntity(expenseWithId);

    // Save locally first
    await _localDataSource.insertExpense(model, syncStatus: SyncStatus.pendingInsert);

    // Fire and forget remote push
    _remoteDataSource.addExpense(model).then((remoteExpense) {
      _localDataSource.updateSyncStatus(remoteExpense.id!, SyncStatus.synced);
    }).catchError((_) {
      // Ignored, SyncService will handle it later
    });

    return model;
  }

  @override
  Future<void> deleteExpense(String id) async {
    // Save locally first
    await _localDataSource.deleteExpense(id, syncStatus: SyncStatus.pendingDelete);

    // Fire and forget remote push
    _remoteDataSource.deleteExpense(id).then((_) {
      _localDataSource.hardDeleteExpense(id);
    }).catchError((_) {
      // Ignored, SyncService will handle it later
    });
  }

  @override
  Future<List<Expense>> getExpenses({
    int? limit,
    int? offset,
    String? searchQuery,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  }) async {
    // Fire and forget remote fetch so UI loads instantly
    _remoteDataSource.getExpenses(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      filter: filter,
      sort: sort,
    ).then((remoteExpenses) async {
      final pendingUpdates = await _localDataSource.getPendingUpdates();
      final pendingInserts = await _localDataSource.getPendingInserts();
      final pendingDeletes = await _localDataSource.getPendingDeletes();
      
      final pendingIds = [
        ...pendingUpdates.map((e) => e.id!),
        ...pendingInserts.map((e) => e.id!),
        ...pendingDeletes,
      ];

      for (var expense in remoteExpenses) {
        if (!pendingIds.contains(expense.id)) {
           await _localDataSource.insertExpense(expense, syncStatus: SyncStatus.synced);
        }
      }
    }).catchError((_) {
      // Ignore remote error
    });

    return await _localDataSource.getExpenses(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      filter: filter,
      sort: sort,
    );
  }

  @override
  Future<Map<String, double>> getExpensesByCategory(DateTime startDate, DateTime endDate) async {
    return await _localDataSource.getExpensesByCategory(startDate, endDate);
  }

  @override
  Future<List<Expense>> getRecentExpenses(int limit) async {
    return await _localDataSource.getRecentExpenses(limit);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final expenseWithDate = expense.copyWith(updatedAt: DateTime.now());
    final model = ExpenseModel.fromEntity(expenseWithDate);

    await _localDataSource.updateExpense(model, syncStatus: SyncStatus.pendingUpdate);

    // Fire and forget remote push
    _remoteDataSource.updateExpense(model).then((_) {
      _localDataSource.updateSyncStatus(model.id!, SyncStatus.synced);
    }).catchError((_) {
      // Ignored, SyncService will handle it later
    });
  }
}
