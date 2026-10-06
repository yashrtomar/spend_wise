import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:spend_wise/features/expenses/presentation/providers/categories_provider.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expense_di_providers.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense.dart';
import 'package:spend_wise/services/sync_providers.dart';
import 'package:spend_wise/services/sync_service.dart';
import 'package:spend_wise/services/sync_store.dart';
import 'package:spend_wise/theme/app_theme.dart';
import 'package:spend_wise/widgets/sync_status.dart';
import 'package:spend_wise/utils/database_helper.dart';
import 'sync_test.dart' show FakeRemote, snapshot, expense, category;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory directory;
  late Database db;
  late FakeRemote remote;
  late ProviderContainer container;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'spendwise-provider-test',
    );
    await databaseFactory.setDatabasesPath(directory.path);
    db = await DatabaseHelper.instance.database;
    remote = FakeRemote();
    container = ProviderContainer(
      overrides: [
        activeUserIdProvider.overrideWithValue('a'),
        sessionIsCurrentProvider.overrideWithValue(() => true),
        syncStoreProvider.overrideWithValue(
          SyncStore('a', database: () async => db),
        ),
        syncRemoteProvider.overrideWithValue(remote),
        reconnectEventsProvider.overrideWithValue(const Stream.empty()),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await DatabaseHelper.instance.close();
    await directory.delete(recursive: true);
  });

  test(
    'actual provider graph hydrates, refreshes all lists and announces success',
    () async {
      container.read(syncLifecycleProvider);
      remote.data = snapshot(
        expenses: [expense('cloud')],
        categories: [category('food')],
      );
      final listener = container.listen(expensesProvider, (_, _) {});
      addTearDown(listener.close);
      final service = container.read(syncServiceProvider.notifier);
      await service.initialize();
      await service.syncNow().timeout(const Duration(seconds: 5));
      expect(service.phase, SyncPhase.success);
      expect(
        (await container.read(expensesProvider.future)).single.id,
        'cloud',
      );
      expect(
        (await container.read(paginatedExpensesProvider.future)).single.id,
        'cloud',
      );
      expect(
        (await container.read(categoriesProvider.future)).single.id,
        'food',
      );
      remote.data = snapshot(categories: [category('food')]);
      await service.syncNow();
      expect(await container.read(expensesProvider.future), isEmpty);
      expect(await container.read(paginatedExpensesProvider.future), isEmpty);
    },
  );

  test(
    'unhydrated empty cache reports first-download error, then retry refreshes it',
    () async {
      container.read(syncLifecycleProvider);
      remote.failPull = true;
      final listener = container.listen(expensesProvider, (_, _) {});
      addTearDown(listener.close);
      await expectLater(
        container.read(expensesProvider.future),
        throwsA(isA<FirstSyncException>()),
      );
      final service = container.read(syncServiceProvider.notifier);
      expect(service.phase, SyncPhase.offline);
      remote.failPull = false;
      remote.data = snapshot(
        expenses: [expense('cloud')],
        categories: [category('food')],
      );
      await service.syncNow();
      expect(
        (await container.read(expensesProvider.future)).single.id,
        'cloud',
      );
      expect(service.phase, SyncPhase.success);
    },
  );

  test(
    'repository mutations save locally and schedule the shared sync service',
    () async {
      container.read(syncLifecycleProvider);
      remote.data = snapshot(categories: [category('food')]);
      final service = container.read(syncServiceProvider.notifier);
      await service.initialize();
      await service.syncNow();
      final added = await container
          .read(addExpenseUseCaseProvider)
          .execute(
            const Expense(name: 'Local lunch', amount: 20, category: 'food'),
          );
      await service.syncNow();
      expect(
        (await container.read(expensesProvider.future)).single.id,
        added.id,
      );
      expect(service.phase, SyncPhase.success);
      await container.read(deleteExpenseUseCaseProvider).execute(added.id!);
      await service.syncNow();
      expect(await container.read(expensesProvider.future), isEmpty);
    },
  );

  testWidgets('status shows progress, success, offline wording and retry', (
    tester,
  ) async {
    final bannerService = BannerService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [syncServiceProvider.overrideWith((ref) => bannerService)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SyncStatusBanner()),
        ),
      ),
    );
    bannerService.show(SyncPhase.syncing);
    await tester.pump();
    expect(find.text('Syncing…'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    bannerService.show(SyncPhase.success);
    await tester.pump();
    expect(find.text('All changes synced'), findsOneWidget);
    bannerService.lastError = const SocketException('offline');
    bannerService.show(SyncPhase.offline);
    await tester.pump();
    expect(find.text("Couldn't sync — you're working offline"), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(bannerService.retries, 1);
    expect(find.text('Syncing…'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}

class BannerService extends SyncService {
  BannerService() : super(SyncStore('a'), FakeRemote(), isActive: () => true);
  int retries = 0;
  void show(SyncPhase next) {
    phase = next;
    notifyListeners();
  }

  @override
  Future<void> syncNow() async {
    retries++;
    show(SyncPhase.syncing);
  }
}
