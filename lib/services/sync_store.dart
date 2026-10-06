import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:spend_wise/utils/database_helper.dart';

/// SQLite is both the UI cache and a durable outbox. Every local write increments
/// revision so a network acknowledgement cannot clear a newer edit or delete.
class SyncStore {
  final String userId;
  final Future<Database> Function() openDatabase;
  SyncStore(this.userId, {Future<Database> Function()? database})
    : openDatabase = database ?? (() => DatabaseHelper.instance.database);

  String ownerColumn(String table) =>
      table == 'user_profiles' ? 'id' : 'user_id';

  /// Old versions did not persist category-deletion intent. Their actual
  /// behavior was move-to-Other, so retain that behavior when upgrading.
  Future<void> repairLegacyDeletes() async {
    final db = await openDatabase();
    final rows = await db.query(
      'categories',
      where: 'user_id = ? AND sync_status = ? AND delete_mode IS NULL',
      whereArgs: [userId, SyncStatus.pendingDelete],
    );
    for (final row in rows) {
      // Reuse the same transactional mutation logic, including durable fallback.
      await deleteCategory(
        row['id'] as String,
        deleteExpenses: false,
        repairLegacy: true,
      );
    }
  }

  Future<bool> isHydrated() async {
    final db = await openDatabase();
    return (await db.query(
      'sync_metadata',
      where: 'user_id = ?',
      whereArgs: [userId],
    )).isNotEmpty;
  }

  Future<List<Map<String, Object?>>> pending(String table) async {
    final db = await openDatabase();
    return db.query(
      table,
      where: '${ownerColumn(table)} = ? AND sync_status != ?',
      whereArgs: [userId, SyncStatus.synced],
    );
  }

  Future<bool> hasPending() async {
    for (final table in ['categories', 'expenses', 'user_profiles']) {
      if ((await pending(table)).isNotEmpty) return true;
    }
    return false;
  }

  Future<void> save(
    String table,
    Map<String, Object?> values, {
    bool insert = false,
  }) async {
    final db = await openDatabase();
    await db.transaction((txn) async {
      final id = values['id'];
      if (id is! String ||
          id.isEmpty ||
          (table == 'user_profiles' && id != userId)) {
        throw StateError('A record needs an ID owned by this account.');
      }
      final existing = await txn.query(table, where: 'id = ?', whereArgs: [id]);
      final old = existing.firstOrNull;
      if (old != null && old[ownerColumn(table)] != userId) {
        throw StateError(
          'This record belongs to another account or is a shared category.',
        );
      }
      if (old?['sync_status'] == SyncStatus.pendingDelete) {
        throw StateError('This record has been deleted.');
      }
      if (!insert && old == null && table != 'user_profiles') {
        throw StateError('This record is no longer available.');
      }
      final data = <String, Object?>{
        ...?old,
        ...values,
        ownerColumn(table): userId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'sync_status':
            old?['sync_status'] == SyncStatus.pendingInsert ||
                (old == null && table != 'user_profiles')
            ? SyncStatus.pendingInsert
            : SyncStatus.pendingUpdate,
        'revision': ((old?['revision'] as int?) ?? 0) + 1,
      };
      if (table != 'user_profiles') {
        data['created_at'] =
            old?['created_at'] ??
            values['created_at'] ??
            DateTime.now().toUtc().toIso8601String();
      }
      await txn.insert(
        table,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> deleteExpense(String id) async {
    final db = await openDatabase();
    // Even a pending insert may already be in flight or have a lost response.
    await db.rawUpdate(
      'UPDATE expenses SET sync_status = ?, revision = revision + 1 WHERE id = ? AND user_id = ?',
      [SyncStatus.pendingDelete, id, userId],
    );
  }

  Future<void> deleteCategory(
    String id, {
    required bool deleteExpenses,
    bool repairLegacy = false,
  }) async {
    final db = await openDatabase();
    await db.transaction((txn) async {
      final rows = await txn.query(
        'categories',
        where: 'id = ? AND user_id = ? AND (sync_status != ? OR ? = 1)',
        whereArgs: [id, userId, SyncStatus.pendingDelete, repairLegacy ? 1 : 0],
      );
      if (rows.isEmpty) throw StateError('This category cannot be deleted.');
      final category = rows.single;
      if ((category['name'] as String).toLowerCase() == 'other') {
        throw StateError('Keep Other as the fallback category.');
      }
      String? target;
      if (!deleteExpenses) {
        final others = await txn.query(
          'categories',
          where:
              'LOWER(name) = ? AND (user_id = ? OR user_id IS NULL) AND sync_status != ?',
          whereArgs: ['other', userId, SyncStatus.pendingDelete],
          orderBy: 'user_id DESC',
          limit: 1,
        );
        target = others.firstOrNull?['id'] as String?;
        if (target == null) {
          target = const Uuid().v4();
          final now = DateTime.now().toUtc().toIso8601String();
          await txn.insert('categories', {
            'id': target,
            'name': 'Other',
            'user_id': userId,
            'created_at': now,
            'updated_at': now,
            'sync_status': SyncStatus.pendingInsert,
            'revision': 1,
          });
        }
      }
      await txn.update(
        'categories',
        {
          'sync_status': SyncStatus.pendingDelete,
          'revision': (category['revision'] as int) + 1,
          'delete_mode': deleteExpenses ? 'delete' : 'move',
          'replacement_id': target,
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      // Older caches sometimes stored the category name instead of its ID.
      final where =
          'user_id = ? AND (category = ? OR category = ?) AND sync_status != ?';
      final args = [userId, id, category['name'], SyncStatus.pendingDelete];
      if (deleteExpenses) {
        await txn.rawUpdate(
          'UPDATE expenses SET sync_status = ?, revision = revision + 1 WHERE $where',
          [SyncStatus.pendingDelete, ...args],
        );
      } else {
        await txn.rawUpdate(
          'UPDATE expenses SET category = ?, updated_at = ?, revision = revision + 1, '
          'sync_status = CASE WHEN sync_status = ? THEN ? ELSE ? END WHERE $where',
          [
            target,
            DateTime.now().toUtc().toIso8601String(),
            SyncStatus.pendingInsert,
            SyncStatus.pendingInsert,
            SyncStatus.pendingUpdate,
            ...args,
          ],
        );
      }
    });
  }

  Future<void> acknowledge(
    String table,
    Map<String, Object?> sent, {
    bool deleted = false,
  }) async {
    final db = await openDatabase();
    final where =
        'id = ? AND ${ownerColumn(table)} = ? AND revision = ? AND sync_status = ?';
    final args = [sent['id'], userId, sent['revision'], sent['sync_status']];
    if (deleted || sent['sync_status'] == SyncStatus.pendingDelete) {
      await db.delete(table, where: where, whereArgs: args);
    } else {
      await db.update(
        table,
        {'sync_status': SyncStatus.synced},
        where: where,
        whereArgs: args,
      );
    }
  }

  /// Apply only a complete remote snapshot, atomically. Pending rows always win
  /// over the cache refresh; missing clean rows represent remote deletions.
  Future<void> merge(Map<String, List<Map<String, Object?>>> snapshot) async {
    final db = await openDatabase();
    await db.transaction((txn) async {
      for (final table in ['categories', 'expenses', 'user_profiles']) {
        final remote = snapshot[table]!;
        final owner = ownerColumn(table);
        final scope = table == 'categories'
            ? '(user_id = ? OR user_id IS NULL)'
            : '$owner = ?';
        final local = await txn.query(table, where: scope, whereArgs: [userId]);
        final byId = {for (final row in local) row['id']: row};
        final remoteIds = remote.map((row) => row['id']).toSet();
        for (final row in local) {
          if (row['sync_status'] == SyncStatus.synced &&
              !remoteIds.contains(row['id'])) {
            await txn.delete(
              table,
              where: 'id = ? AND sync_status = ?',
              whereArgs: [row['id'], SyncStatus.synced],
            );
          }
        }
        for (final row in remote) {
          if (row[owner] != userId &&
              !(table == 'categories' && row[owner] == null)) {
            throw StateError(
              'Remote snapshot contains data from another account.',
            );
          }
          if (byId[row['id']] != null &&
              byId[row['id']]!['sync_status'] != SyncStatus.synced) {
            continue;
          }
          final data = Map<String, Object?>.from(row);
          if (table == 'user_profiles') {
            data['preferences'] = jsonEncode(data['preferences']);
          }
          data['sync_status'] = SyncStatus.synced;
          data['revision'] = byId[row['id']]?['revision'] ?? 0;
          await txn.insert(
            table,
            data,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      await txn.insert('sync_metadata', {
        'user_id': userId,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
