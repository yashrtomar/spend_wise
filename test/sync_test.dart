import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spend_wise/services/sync_store.dart';
import 'package:spend_wise/services/sync_remote.dart';
import 'package:spend_wise/services/sync_service.dart';
import 'package:spend_wise/utils/database_helper.dart';
import 'package:spend_wise/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:spend_wise/features/expenses/data/models/expense_model.dart';

typedef Row = Map<String, Object?>;
Map<String, List<Row>> snapshot({
  List<Row> expenses = const [],
  List<Row> categories = const [],
  List<Row> profiles = const [],
}) => {
  'expenses': [...expenses],
  'categories': [...categories],
  'user_profiles': [...profiles],
};
Row expense(
  String id, {
  String user = 'a',
  String category = 'food',
  String name = 'Lunch',
}) => {
  'id': id,
  'user_id': user,
  'name': name,
  'amount': 12.0,
  'category': category,
  'note': null,
  'created_at': '2026-10-01T12:00:00.000Z',
  'updated_at': '2026-10-01T12:00:00.000Z',
};
Row category(String id, {String? user = 'a', String name = 'Food'}) => {
  'id': id,
  'user_id': user,
  'name': name,
  'created_at': null,
  'updated_at': null,
};

class FakeRemote implements SyncRemote {
  Map<String, List<Row>> data = snapshot();
  final List<String> operations = [];
  Future<void> Function(String, Row)? beforePush;
  Future<void> Function()? beforePull;
  bool failPull = false;
  bool failPush = false;
  int inFlight = 0;
  int maxInFlight = 0;
  int pulls = 0;
  @override
  Future<bool> push(String table, Row row) async {
    operations.add('$table:${row['sync_status']}:${row['id']}');
    await beforePush?.call(table, row);
    if (failPush) throw StateError('Server rejected this mutation');
    final rows = data[table]!;
    if (row['sync_status'] == SyncStatus.pendingDelete) {
      rows.removeWhere((item) => item['id'] == row['id']);
      return false;
    }
    final old = rows.where((item) => item['id'] == row['id']).firstOrNull;
    if (old == null &&
        row['sync_status'] == SyncStatus.pendingUpdate &&
        table != 'user_profiles') {
      return false;
    }
    rows.removeWhere((item) => item['id'] == row['id']);
    rows.add(
      Map<String, Object?>.from(row)
        ..remove('revision')
        ..remove('sync_status')
        ..remove('delete_mode')
        ..remove('replacement_id'),
    );
    return true;
  }

  @override
  Future<Map<String, List<Row>>> pull() async {
    inFlight++;
    maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
    pulls++;
    try {
      await beforePull?.call();
      if (failPull) throw const SocketException('offline');
      return {
        for (final entry in data.entries)
          entry.key: entry.value.map((row) => Row.from(row)).toList(),
      };
    } finally {
      inFlight--;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory directory;
  late Database db;
  late SyncStore store;
  final services = <SyncService>[];

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('spendwise-sync-test');
    await databaseFactory.setDatabasesPath(directory.path);
    db = await DatabaseHelper.instance.database;
    store = SyncStore('a', database: () async => db);
  });
  tearDown(() async {
    for (final service in services) {
      service.dispose();
    }
    services.clear();
    await DatabaseHelper.instance.close();
    await directory.delete(recursive: true);
  });
  SyncService engine(
    FakeRemote remote, {
    bool Function()? active,
    Future<void> Function()? committed,
  }) {
    final service = SyncService(
      store,
      remote,
      isActive: active ?? () => true,
      onCommitted: committed,
    );
    services.add(service);
    return service;
  }

  test(
    'a fresh account is unhydrated until a complete empty snapshot commits',
    () async {
      expect(await store.isHydrated(), false);
      await store.merge(snapshot());
      expect(await store.isHydrated(), true);
      expect(
        await SyncStore('b', database: () async => db).isHydrated(),
        false,
      );
    },
  );

  test(
    'pending edits and tombstones survive pull; clean remote deletions disappear',
    () async {
      await store.merge(
        snapshot(
          expenses: [expense('edit'), expense('delete'), expense('gone')],
        ),
      );
      await store.save('expenses', expense('edit', name: 'Offline edit'));
      await store.deleteExpense('delete');
      await store.merge(
        snapshot(expenses: [expense('edit'), expense('delete')]),
      );
      final rows = await db.query('expenses');
      expect(rows.map((e) => e['id']), unorderedEquals(['edit', 'delete']));
      expect(rows.firstWhere((e) => e['id'] == 'edit')['name'], 'Offline edit');
      expect(
        rows.firstWhere((e) => e['id'] == 'delete')['sync_status'],
        SyncStatus.pendingDelete,
      );
    },
  );

  test(
    'editing a never-uploaded expense retains insert and immutable fields',
    () async {
      await store.save('expenses', expense('new'), insert: true);
      await ExpenseLocalDataSource(store).updateExpense(
        const ExpenseModel(
          id: 'new',
          name: 'Edited',
          amount: 30,
          category: 'food',
        ),
      );
      final row = (await store.pending('expenses')).single;
      expect(row['sync_status'], SyncStatus.pendingInsert);
      expect(row['user_id'], 'a');
      expect(row['created_at'], expense('new')['created_at']);
      expect(row['revision'], 2);
    },
  );

  test(
    'an old upload acknowledgement cannot erase a newer edit or deletion',
    () async {
      await store.save('expenses', expense('new'), insert: true);
      final sent = (await store.pending('expenses')).single;
      await store.save('expenses', expense('new', name: 'Newer edit'));
      await store.acknowledge('expenses', sent);
      expect((await store.pending('expenses')).single['name'], 'Newer edit');
      await store.deleteExpense('new');
      await store.acknowledge('expenses', sent);
      expect(
        (await store.pending('expenses')).single['sync_status'],
        SyncStatus.pendingDelete,
      );
    },
  );

  test(
    'deleting a pending insert leaves a durable tombstone across restart',
    () async {
      await store.save('expenses', expense('new'), insert: true);
      await store.deleteExpense('new');
      await DatabaseHelper.instance.close();
      db = await DatabaseHelper.instance.database;
      expect(
        (await store.pending('expenses')).single['sync_status'],
        SyncStatus.pendingDelete,
      );
    },
  );

  test(
    'move-category deletion uses IDs, durable fallback and account scope',
    () async {
      await store.merge(
        snapshot(categories: [category('food')], expenses: [expense('e')]),
      );
      await store.save('expenses', expense('new'), insert: true);
      final otherStore = SyncStore('b', database: () async => db);
      await otherStore.save(
        'expenses',
        expense('b-e', user: 'b'),
        insert: true,
      );
      await store.deleteCategory('food', deleteExpenses: false);
      final rows = await store.pending('categories');
      final deleted = rows.firstWhere((row) => row['id'] == 'food');
      final fallback = rows.firstWhere((row) => row['name'] == 'Other');
      expect(deleted['replacement_id'], fallback['id']);
      expect(deleted['delete_mode'], 'move');
      for (final row in await store.pending('expenses')) {
        expect(row['category'], fallback['id']);
      }
      expect((await otherStore.pending('expenses')).single['category'], 'food');
      expect(
        (await store.pending(
          'expenses',
        )).firstWhere((row) => row['id'] == 'new')['sync_status'],
        SyncStatus.pendingInsert,
      );
    },
  );

  test(
    'delete-category-and-expenses queues deletion rather than moving',
    () async {
      await store.merge(
        snapshot(categories: [category('food')], expenses: [expense('e')]),
      );
      await store.deleteCategory('food', deleteExpenses: true);
      expect(
        (await store.pending('categories')).single['delete_mode'],
        'delete',
      );
      expect(
        (await store.pending('expenses')).single['sync_status'],
        SyncStatus.pendingDelete,
      );
      expect(await ExpenseLocalDataSource(store).getExpenses(), isEmpty);
    },
  );

  test(
    'shared categories stay shared and account mutations are isolated',
    () async {
      await store.merge(snapshot(categories: [category('shared', user: null)]));
      await expectLater(
        store.save('categories', category('shared', name: 'No')),
        throwsStateError,
      );
      final otherStore = SyncStore('b', database: () async => db);
      await otherStore.save(
        'categories',
        category('b-cat', user: 'b'),
        insert: true,
      );
      await otherStore.save('user_profiles', {
        'id': 'b',
        'name': 'B',
        'monthly_budget': 300.0,
      });
      expect(await store.pending('categories'), isEmpty);
      expect(await store.pending('user_profiles'), isEmpty);
      await store.merge(snapshot(categories: [category('shared', user: null)]));
      expect(await otherStore.pending('categories'), hasLength(1));
    },
  );

  test('snapshot failure rolls back all tables and hydration marker', () async {
    await expectLater(
      store.merge(
        snapshot(
          categories: [category('food')],
          expenses: [expense('bad', user: 'b')],
        ),
      ),
      throwsStateError,
    );
    expect(await store.isHydrated(), false);
    expect(await db.query('categories'), isEmpty);
  });

  test(
    'first read waits for hydration and success follows UI refresh',
    () async {
      final remote = FakeRemote()
        ..data = snapshot(expenses: [expense('cloud')]);
      final download = Completer<void>();
      remote.beforePull = () => download.future;
      final refresh = Completer<void>();
      final service = engine(remote, committed: () => refresh.future);
      await service.initialize();
      var readDone = false;
      final read = service.readyForRead().then((_) => readDone = true);
      await Future<void>.delayed(Duration.zero);
      expect(readDone, false);
      expect(service.phase, SyncPhase.syncing);
      download.complete();
      await read;
      expect(
        (await ExpenseLocalDataSource(store).getExpenses()).single.id,
        'cloud',
      );
      expect(service.phase, SyncPhase.syncing);
      refresh.complete();
      await service.syncNow();
      expect(service.phase, SyncPhase.success);
    },
  );

  test('offline first download remains unhydrated; retry recovers', () async {
    final remote = FakeRemote()..failPull = true;
    final service = engine(remote);
    await service.initialize();
    await service.readyForRead();
    expect(service.phase, SyncPhase.offline);
    expect(await store.isHydrated(), false);
    remote.failPull = false;
    await service.syncNow();
    expect(await store.isHydrated(), true);
    expect(service.phase, SyncPhase.success);
  });

  test('returning devices can read cache before network finishes', () async {
    await store.merge(snapshot(expenses: [expense('cached')]));
    final remote = FakeRemote();
    final gate = Completer<void>();
    remote.beforePull = () => gate.future;
    final service = engine(remote);
    await service.readyForRead();
    expect(
      (await ExpenseLocalDataSource(store).getExpenses()).single.id,
      'cached',
    );
    gate.complete();
    await service.syncNow();
  });

  test('simultaneous sync requests serialize and coalesce', () async {
    final remote = FakeRemote();
    final gate = Completer<void>();
    remote.beforePull = () => gate.future;
    final service = engine(remote);
    final first = service.syncNow();
    final second = service.syncNow();
    final third = service.syncNow();
    expect(identical(first, second), true);
    expect(identical(first, third), true);
    gate.complete();
    await first;
    expect(remote.maxInFlight, 1);
    expect(remote.pulls, 2);
  });

  test(
    'delete during upload is sent on the next pass without resurrection',
    () async {
      await store.save('expenses', expense('new'), insert: true);
      final remote = FakeRemote();
      var once = false;
      remote.beforePush = (table, row) async {
        if (!once && table == 'expenses') {
          once = true;
          await store.deleteExpense('new');
        }
      };
      final service = engine(remote);
      await service.syncNow();
      expect(await db.query('expenses'), isEmpty);
      expect(remote.data['expenses'], isEmpty);
      expect(service.phase, SyncPhase.success);
    },
  );

  test(
    'failed uploads stay pending while cloud data still downloads',
    () async {
      await store.save('expenses', expense('local'), insert: true);
      final remote = FakeRemote()
        ..failPush = true
        ..data = snapshot(expenses: [expense('cloud')]);
      final service = engine(remote);
      await service.syncNow();
      expect(service.phase, SyncPhase.offline);
      expect(await store.isHydrated(), true);
      expect((await store.pending('expenses')).single['id'], 'local');
      expect(await ExpenseLocalDataSource(store).getExpenses(), hasLength(2));
      remote.failPush = false;
      await service.syncNow();
      expect(await store.pending('expenses'), isEmpty);
      expect(service.phase, SyncPhase.success);
    },
  );

  test(
    'network failure stops a large outbox after the first failed request',
    () async {
      for (var i = 0; i < 10; i++) {
        await store.save('expenses', expense('offline-$i'), insert: true);
      }
      final remote = FakeRemote()
        ..beforePush = (_, _) async {
          throw const SocketException('offline');
        };
      final service = engine(remote);
      await service.syncNow();
      expect(service.phase, SyncPhase.offline);
      expect(remote.operations, hasLength(1));
      expect(await store.pending('expenses'), hasLength(10));
    },
  );

  test('legacy category tombstones regain a durable replacement', () async {
    await store.merge(
      snapshot(categories: [category('food')], expenses: [expense('legacy')]),
    );
    await db.update(
      'categories',
      {'sync_status': SyncStatus.pendingDelete},
      where: 'id = ?',
      whereArgs: ['food'],
    );
    await store.repairLegacyDeletes();
    final deleted = (await store.pending(
      'categories',
    )).firstWhere((row) => row['id'] == 'food');
    expect(deleted['delete_mode'], 'move');
    expect(deleted['replacement_id'], isNotNull);
    expect(
      (await store.pending('expenses')).single['category'],
      deleted['replacement_id'],
    );
  });

  test(
    'category parents upload before expenses; deletions occur afterward',
    () async {
      await store.save('categories', category('food'), insert: true);
      await store.save('expenses', expense('new'), insert: true);
      final remote = FakeRemote();
      await engine(remote).syncNow();
      expect(remote.operations.take(2), [
        'categories:1:food',
        'expenses:1:new',
      ]);
    },
  );

  test(
    'switching accounts during a request prevents acknowledgement and pull',
    () async {
      await store.save('expenses', expense('new'), insert: true);
      var active = true;
      final remote = FakeRemote()
        ..beforePush = (_, _) async {
          active = false;
        };
      final service = engine(remote, active: () => active);
      await service.syncNow();
      expect(await store.pending('expenses'), hasLength(1));
      expect(remote.pulls, 0);
      expect(await store.isHydrated(), false);
    },
  );

  test(
    'remote deletion wins over an edit of a previously synced record',
    () async {
      await store.merge(snapshot(expenses: [expense('gone')]));
      await store.save('expenses', expense('gone', name: 'Offline edit'));
      await engine(FakeRemote()).syncNow();
      expect(await db.query('expenses'), isEmpty);
    },
  );

  for (final version in [1, 2]) {
    test('upgrades v$version without losing cached or pending records', () async {
      await DatabaseHelper.instance.close();
      final file = path.join(directory.path, 'spendwise.db');
      await databaseFactory.deleteDatabase(file);
      final old = await databaseFactory.openDatabase(
        file,
        options: OpenDatabaseOptions(
          version: version,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE expenses (id TEXT PRIMARY KEY, name TEXT NOT NULL, amount REAL NOT NULL, category TEXT NOT NULL, note TEXT, user_id TEXT, created_at TEXT, updated_at TEXT, sync_status INTEGER NOT NULL)',
            );
            await db.execute(
              'CREATE TABLE categories (id TEXT PRIMARY KEY, name TEXT NOT NULL, user_id TEXT, created_at TEXT, updated_at TEXT, sync_status INTEGER NOT NULL)',
            );
            if (version == 2) {
              await db.execute(
                'CREATE TABLE user_profiles (id TEXT PRIMARY KEY, name TEXT NOT NULL, monthly_budget REAL NOT NULL, preferences TEXT, created_at TEXT, updated_at TEXT, sync_status INTEGER NOT NULL)',
              );
            }
          },
        ),
      );
      await old.insert('expenses', {
        ...expense('pending'),
        'sync_status': SyncStatus.pendingInsert,
      });
      await old.close();
      db = await DatabaseHelper.instance.database;
      expect(await db.getVersion(), 3);
      expect((await store.pending('expenses')).single['revision'], 0);
      expect(await store.isHydrated(), false);
      expect(await db.query('user_profiles'), isEmpty);
    });
  }
}
