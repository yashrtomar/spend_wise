import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:spend_wise/services/sync_remote.dart';
import 'package:spend_wise/services/sync_store.dart';
import 'package:spend_wise/utils/database_helper.dart';

enum SyncPhase { idle, syncing, success, offline }

class FirstSyncException implements Exception {
  const FirstSyncException();
  @override
  String toString() =>
      'Your saved data has not been downloaded to this device yet. Connect to the internet and try again.';
}

class SyncService extends ChangeNotifier {
  final SyncStore store;
  final SyncRemote remote;
  final bool Function() isActive;
  Future<void> Function()? onCommitted;
  void Function()? onFirstRetry;
  final Duration requestTimeout;
  SyncService(
    this.store,
    this.remote, {
    required this.isActive,
    this.onCommitted,
    this.onFirstRetry,
    this.requestTimeout = const Duration(seconds: 30),
  });

  SyncPhase phase = SyncPhase.idle;
  bool hydrated = false;
  Object? lastError;
  Future<void>? _running;
  Future<void>? _initializing;
  Completer<void>? _attempt;
  bool _again = false;
  bool _disposed = false;
  Timer? _retry;
  int _failures = 0;
  StreamSubscription<Object?>? _connectionSubscription;
  bool get _active => !_disposed && isActive();

  Future<void> initialize({Stream<Object?>? reconnects}) {
    _connectionSubscription ??= reconnects?.listen((_) => unawaited(syncNow()));
    return _initializing ??= _initialize().onError<Object>((error, stack) {
      _initializing = null;
      lastError = error;
      phase = SyncPhase.offline;
      _notify();
      Error.throwWithStackTrace(error, stack);
    });
  }

  Future<void> _initialize() async {
    await store.repairLegacyDeletes();
    hydrated = await store.isHydrated();
    if (!_active) return;
    unawaited(syncNow());
  }

  /// Returning devices read SQLite immediately; first-use readers stay in the
  /// existing skeleton state until the first full download succeeds or fails.
  Future<void> readyForRead() async {
    await initialize();
    if (!hydrated) await _attempt?.future;
  }

  Future<void> syncNow() {
    if (!_active) return Future.value();
    if (_running != null) {
      _again = true;
      return _running!;
    }
    _retry?.cancel();
    _attempt = Completer<void>();
    final completion = Completer<void>();
    _running = completion.future;
    unawaited(
      _run().whenComplete(() {
        _running = null;
        completion.complete();
      }),
    );
    return completion.future;
  }

  void _notify() {
    if (_active) notifyListeners();
  }

  void _check() {
    if (!_active) throw StateError('Sync session ended.');
  }

  final List<Object> _pushErrors = [];

  Future<void> _push(String table, {bool deletes = false}) async {
    for (final row in await store.pending(table)) {
      if ((row['sync_status'] == SyncStatus.pendingDelete) != deletes) continue;
      _check();
      try {
        final exists = await remote.push(table, row).timeout(requestTimeout);
        _check();
        await store.acknowledge(table, row, deleted: !exists);
      } catch (error) {
        _check();
        // Do not spend one timeout per queued row when the network is down.
        if (error is SocketException || error is TimeoutException) rethrow;
        _pushErrors.add(error);
      }
    }
  }

  Future<void> _run() async {
    phase = SyncPhase.syncing;
    lastError = null;
    _notify();
    try {
      if (!hydrated) onFirstRetry?.call();
      do {
        _again = false;
        _pushErrors.clear();
        // Parent inserts first; dependent expense changes before category deletes.
        await _push('categories');
        await _push('expenses', deletes: true);
        await _push('expenses');
        await _push('categories', deletes: true);
        await _push('user_profiles');
        _check();
        final snapshot = await remote.pull().timeout(requestTimeout);
        _check();
        await store.merge(snapshot);
        _check();
        hydrated = true;
        if (!_attempt!.isCompleted) _attempt!.complete();
        // UI reads are refreshed before announcing success.
        await onCommitted?.call();
        _check();
        if (_pushErrors.isNotEmpty) throw _pushErrors.first;
        _again = _again || await store.hasPending();
      } while (_again && _active);
      _failures = 0;
      phase = SyncPhase.success;
    } catch (error, stack) {
      if (!_active) return;
      lastError = error;
      phase = SyncPhase.offline;
      debugPrint('Sync failed: $error\n$stack');
      // Retry transient server failures even when connectivity never changes.
      final seconds = [5, 15, 30, 60, 120, 300][_failures.clamp(0, 5)];
      _failures++;
      _retry = Timer(Duration(seconds: seconds), () => unawaited(syncNow()));
    } finally {
      if (!(_attempt?.isCompleted ?? true)) _attempt!.complete();
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _retry?.cancel();
    unawaited(_connectionSubscription?.cancel());
    if (!(_attempt?.isCompleted ?? true)) _attempt!.complete();
    super.dispose();
  }
}
