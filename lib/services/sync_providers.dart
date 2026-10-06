import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spend_wise/features/auth/presentation/providers/auth_di_providers.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:spend_wise/features/expenses/presentation/providers/categories_provider.dart';
import 'package:spend_wise/features/profile/presentation/providers/profile_provider.dart';
import 'package:spend_wise/services/sync_remote.dart';
import 'package:spend_wise/services/sync_service.dart';
import 'package:spend_wise/services/sync_store.dart';

final activeUserIdProvider = Provider<String?>(
  (ref) =>
      ref.watch(authStateProvider.select((value) => value.valueOrNull?.id)),
);

final syncStoreProvider = Provider<SyncStore>((ref) {
  final id = ref.watch(activeUserIdProvider);
  if (id == null) throw StateError('Sign in to access your data.');
  return SyncStore(id);
});

final sessionIsCurrentProvider = Provider<bool Function()>((ref) {
  final id = ref.watch(activeUserIdProvider);
  return () => Supabase.instance.client.auth.currentUser?.id == id;
});

final reconnectEventsProvider = Provider<Stream<Object?>>(
  (ref) => Connectivity().onConnectivityChanged.where(
    (results) => results.any((result) => result != ConnectivityResult.none),
  ),
);

final syncRemoteProvider = Provider<SyncRemote>(
  (ref) => SupabaseSyncRemote(
    Supabase.instance.client,
    ref.watch(syncStoreProvider).userId,
    ref.watch(sessionIsCurrentProvider),
  ),
);

final syncServiceProvider = ChangeNotifierProvider<SyncService>((ref) {
  final store = ref.watch(syncStoreProvider);
  final sessionIsCurrent = ref.watch(sessionIsCurrentProvider);
  final remote = ref.watch(syncRemoteProvider);
  var disposed = false;
  ref.onDispose(() {
    disposed = true;
  });
  return SyncService(
    store,
    remote,
    isActive: () => !disposed && sessionIsCurrent(),
  );
});

/// The presentation coordinator depends on the sync engine, never vice versa.
/// This keeps read providers and their refresh callbacks out of a Riverpod cycle.
final syncLifecycleProvider = Provider<void>((ref) {
  final service = ref.watch(syncServiceProvider.notifier);
  final reconnects = ref.watch(reconnectEventsProvider);
  var disposed = false;
  void invalidateData() {
    if (disposed) return;
    ref.invalidate(expensesProvider);
    ref.invalidate(paginatedExpensesProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(profileProvider);
  }

  service.onFirstRetry = invalidateData;
  service.onCommitted = () async {
    if (disposed) return;
    invalidateData();
    await Future.wait([
      ref.read(expensesProvider.future),
      ref.read(paginatedExpensesProvider.future),
      ref.read(categoriesProvider.future),
      ref.read(profileProvider.future),
    ]);
  };
  ref.onDispose(() {
    disposed = true;
  });
  scheduleMicrotask(() async {
    if (disposed) return;
    try {
      await service.initialize(reconnects: reconnects);
    } catch (_) {
      // The data providers surface local database initialization errors.
    }
  });
});
