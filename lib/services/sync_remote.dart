import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spend_wise/utils/database_helper.dart';

abstract class SyncRemote {
  Future<bool> push(String table, Map<String, Object?> row);
  Future<Map<String, List<Map<String, Object?>>>> pull();
}

/// All requests are scoped to the account captured when this adapter is created.
/// Never substitute the currently signed-in user for a queued mutation's owner.
class SupabaseSyncRemote implements SyncRemote {
  final SupabaseClient client;
  final String userId;
  final bool Function() isActive;
  SupabaseSyncRemote(this.client, this.userId, this.isActive);

  void _checkSession() {
    if (!isActive() || client.auth.currentUser?.id != userId) {
      throw StateError('The account changed during sync.');
    }
  }

  @override
  Future<bool> push(String table, Map<String, Object?> row) async {
    _checkSession();
    final owner = table == 'user_profiles' ? 'id' : 'user_id';
    if (row[owner] != userId) {
      throw StateError('Mutation belongs to another account.');
    }
    final id = row['id'] as String;
    final source = client.schema('spendwise');
    if (row['sync_status'] == SyncStatus.pendingDelete) {
      if (table == 'categories') {
        if (row['delete_mode'] == 'delete') {
          await source
              .from('expenses')
              .delete()
              .eq('user_id', userId)
              .eq('category', id);
        } else {
          final target = row['replacement_id'];
          if (target == null) {
            throw StateError('Category deletion needs a replacement.');
          }
          await source
              .from('expenses')
              .update({'category': target})
              .eq('user_id', userId)
              .eq('category', id);
        }
        _checkSession();
      }
      await source.from(table).delete().eq(owner, userId).eq('id', id);
      return false;
    }
    final data = Map<String, Object?>.from(row)
      ..remove('sync_status')
      ..remove('revision')
      ..remove('delete_mode')
      ..remove('replacement_id');
    if (table == 'user_profiles' && data['preferences'] is String) {
      data['preferences'] = jsonDecode(data['preferences'] as String);
    }
    // Preserve device-generated IDs. Retrying an insert after a lost response
    // must not create a second record. Existing-record edits never resurrect a
    // row that another device deleted (PATCH instead of UPSERT).
    if (row['sync_status'] == SyncStatus.pendingInsert ||
        table == 'user_profiles') {
      await source.from(table).upsert(data).select('id').single();
      return true;
    }
    data.remove('created_at');
    final result = await source
        .from(table)
        .update(data)
        .eq(owner, userId)
        .eq('id', id)
        .select('id');
    return result.isNotEmpty;
  }

  Future<List<Map<String, Object?>>> _all(String table, String columns) async {
    final rows = <Map<String, Object?>>[];
    String? after;
    while (true) {
      _checkSession();
      var query = client.schema('spendwise').from(table).select(columns);
      query = table == 'categories'
          ? query.or('user_id.eq.$userId,user_id.is.null')
          : query.eq(table == 'user_profiles' ? 'id' : 'user_id', userId);
      if (after != null) query = query.gt('id', after);
      final page = await query.order('id').limit(500);
      if (page.isEmpty) break;
      rows.addAll(page.map((row) => Map<String, Object?>.from(row)));
      after = page.last['id'] as String;
      // Continue even after short pages: a server may cap results below 500.
    }
    return rows;
  }

  @override
  Future<Map<String, List<Map<String, Object?>>>> pull() async {
    final categories = await _all(
      'categories',
      'id,name,user_id,created_at,updated_at',
    );
    final expenses = await _all(
      'expenses',
      'id,name,amount,category,note,user_id,created_at,updated_at',
    );
    final profiles = await _all(
      'user_profiles',
      'id,name,monthly_budget,preferences,updated_at',
    );
    _checkSession();
    return {
      'categories': categories,
      'expenses': expenses,
      'user_profiles': profiles,
    };
  }
}
