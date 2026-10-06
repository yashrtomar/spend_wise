import 'package:spend_wise/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/models/expense_model.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:spend_wise/features/expenses/domain/repositories/expense_repository.dart';
import 'dart:async';
import 'package:spend_wise/services/sync_service.dart';
import 'package:uuid/uuid.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final SyncService _sync;
  final ExpenseLocalDataSource _localDataSource;
  final _uuid = const Uuid();

  ExpenseRepositoryImpl(this._localDataSource, this._sync);

  @override
  Future<Expense> addExpense(Expense expense) async {
    // Generate UUID if offline and ID is null
    final id = expense.id ?? _uuid.v4();
    final userId = _localDataSource.store.userId;

    final expenseWithId = expense.copyWith(
      id: id,
      userId: expense.userId ?? userId,
      createdAt: expense.createdAt ?? DateTime.now(),
      updatedAt: expense.updatedAt ?? DateTime.now(),
    );
    final model = ExpenseModel.fromEntity(expenseWithId);

    // Save locally first
    await _localDataSource.insertExpense(model);

    unawaited(_sync.syncNow());

    return model;
  }

  @override
  Future<void> deleteExpense(String id) async {
    // Save locally first
    await _localDataSource.deleteExpense(id);

    unawaited(_sync.syncNow());
  }

  @override
  Future<List<Expense>> getExpenses({
    int? limit,
    int? offset,
    String? searchQuery,
    ExpenseFilter? filter,
    ExpenseSort? sort,
  }) async {
    return await _localDataSource.getExpenses(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      filter: filter,
      sort: sort,
    );
  }

  @override
  Future<Map<String, double>> getExpensesByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
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

    await _localDataSource.updateExpense(model);

    unawaited(_sync.syncNow());
  }
}
