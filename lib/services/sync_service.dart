import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:spend_wise/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:spend_wise/utils/database_helper.dart';

class SyncService {
  final ExpenseLocalDataSource _localDataSource;
  final ExpenseRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity = Connectivity();

  SyncService(this._localDataSource, this._remoteDataSource);

  void init() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi)) {
        syncNow();
      }
    });
  }

  Future<void> syncNow() async {
    try {
      await _syncDeletes();
      await _syncInserts();
      await _syncUpdates();
    } catch (e) {
      // Sync failed, will try again later
      print('Sync failed: $e');
    }
  }

  Future<void> _syncInserts() async {
    final pendingInserts = await _localDataSource.getPendingInserts();
    for (var expense in pendingInserts) {
      try {
        final synced = await _remoteDataSource.addExpense(expense);
        await _localDataSource.updateSyncStatus(synced.id!, SyncStatus.synced);
      } catch (e) {
        print('Error syncing insert for ${expense.id}: $e');
      }
    }
  }

  Future<void> _syncUpdates() async {
    final pendingUpdates = await _localDataSource.getPendingUpdates();
    for (var expense in pendingUpdates) {
      try {
        await _remoteDataSource.updateExpense(expense);
        await _localDataSource.updateSyncStatus(expense.id!, SyncStatus.synced);
      } catch (e) {
        print('Error syncing update for ${expense.id}: $e');
      }
    }
  }

  Future<void> _syncDeletes() async {
    final pendingDeletes = await _localDataSource.getPendingDeletes();
    for (var id in pendingDeletes) {
      try {
        await _remoteDataSource.deleteExpense(id);
        await _localDataSource.hardDeleteExpense(id);
      } catch (e) {
        print('Error syncing delete for $id: $e');
      }
    }
  }
}
