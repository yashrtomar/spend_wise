import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:spend_wise/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:spend_wise/features/expenses/data/datasources/category_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/datasources/category_remote_datasource.dart';
import 'package:spend_wise/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:spend_wise/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:spend_wise/utils/database_helper.dart';

class SyncService {
  final ExpenseLocalDataSource _expenseLocal;
  final ExpenseRemoteDataSource _expenseRemote;
  final CategoryLocalDataSource _categoryLocal;
  final CategoryRemoteDataSource _categoryRemote;
  final ProfileLocalDataSource _profileLocal;
  final ProfileRemoteDataSource _profileRemote;
  
  final Connectivity _connectivity = Connectivity();

  SyncService(
    this._expenseLocal, 
    this._expenseRemote,
    this._categoryLocal,
    this._categoryRemote,
    this._profileLocal,
    this._profileRemote,
  );

  void init() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        syncNow();
      }
    });
  }

  Future<void> syncNow() async {
    try {
      // Expenses
      await _syncExpenseDeletes();
      await _syncExpenseInserts();
      await _syncExpenseUpdates();
      
      // Categories
      await _syncCategoryDeletes();
      await _syncCategoryInserts();
      await _syncCategoryUpdates();
      
      // Profile
      await _syncProfileUpdates();
      
    } catch (e) {
      debugPrint('Sync failed: \$e');
    }
  }

  // --- Expenses ---
  Future<void> _syncExpenseInserts() async {
    final pendingInserts = await _expenseLocal.getPendingInserts();
    for (var expense in pendingInserts) {
      try {
        final synced = await _expenseRemote.addExpense(expense);
        await _expenseLocal.updateSyncStatus(synced.id!, SyncStatus.synced);
      } catch (e) {
        debugPrint('Error syncing expense insert for \${expense.id}: \$e');
      }
    }
  }

  Future<void> _syncExpenseUpdates() async {
    final pendingUpdates = await _expenseLocal.getPendingUpdates();
    for (var expense in pendingUpdates) {
      try {
        await _expenseRemote.updateExpense(expense);
        await _expenseLocal.updateSyncStatus(expense.id!, SyncStatus.synced);
      } catch (e) {
        debugPrint('Error syncing expense update for \${expense.id}: \$e');
      }
    }
  }

  Future<void> _syncExpenseDeletes() async {
    final pendingDeletes = await _expenseLocal.getPendingDeletes();
    for (var id in pendingDeletes) {
      try {
        await _expenseRemote.deleteExpense(id);
        await _expenseLocal.hardDeleteExpense(id);
      } catch (e) {
        debugPrint('Error syncing expense delete for \$id: \$e');
      }
    }
  }

  // --- Categories ---
  Future<void> _syncCategoryInserts() async {
    final pendingInserts = await _categoryLocal.getPendingInserts();
    for (var cat in pendingInserts) {
      try {
        final synced = await _categoryRemote.addCategory(cat);
        await _categoryLocal.updateSyncStatus(synced.id!, SyncStatus.synced);
      } catch (e) {
        debugPrint('Error syncing category insert for \${cat.id}: \$e');
      }
    }
  }

  Future<void> _syncCategoryUpdates() async {
    final pendingUpdates = await _categoryLocal.getPendingUpdates();
    for (var cat in pendingUpdates) {
      try {
        await _categoryRemote.updateCategory(cat);
        await _categoryLocal.updateSyncStatus(cat.id!, SyncStatus.synced);
      } catch (e) {
        debugPrint('Error syncing category update for \${cat.id}: \$e');
      }
    }
  }

  Future<void> _syncCategoryDeletes() async {
    final pendingDeletes = await _categoryLocal.getPendingDeletes();
    for (var id in pendingDeletes) {
      try {
        // If a category was deleted, we use the move expenses method to fallback to "Other"
        await _categoryRemote.deleteCategoryAndMoveExpenses(id);
        await _categoryLocal.hardDeleteCategory(id);
      } catch (e) {
        debugPrint('Error syncing category delete for \$id: \$e');
      }
    }
  }

  // --- Profile ---
  Future<void> _syncProfileUpdates() async {
    final pendingUpdates = await _profileLocal.getPendingUpdates();
    for (var profile in pendingUpdates) {
      try {
        await _profileRemote.updateProfile(profile);
        await _profileLocal.updateSyncStatus(profile.id!, SyncStatus.synced);
      } catch (e) {
        debugPrint('Error syncing profile update for \${profile.id}: \$e');
      }
    }
  }
}
