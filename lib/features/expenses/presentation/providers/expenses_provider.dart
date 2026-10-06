import 'package:spend_wise/services/sync_providers.dart';
import 'package:spend_wise/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense_filter.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expense_di_providers.dart';

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final getExpensesUseCase = ref.watch(getExpensesUseCaseProvider);
  final sync = ref.watch(syncServiceProvider.notifier);
  await sync.readyForRead();
  final rows = await getExpensesUseCase.execute();
  if (rows.isEmpty && !sync.hydrated) throw const FirstSyncException();
  return rows;
});

final expenseSearchQueryProvider = StateProvider<String>((ref) {
  ref.watch(activeUserIdProvider);
  return '';
});

final expenseFilterProvider = StateProvider<ExpenseFilter>((ref) {
  ref.watch(activeUserIdProvider);
  return const ExpenseFilter();
});

final expenseSortProvider = StateProvider<ExpenseSort>((ref) {
  ref.watch(activeUserIdProvider);
  return ExpenseSort.newest;
});

class PaginatedExpensesNotifier
    extends AutoDisposeAsyncNotifier<List<Expense>> {
  int _generation = 0;
  int _offset = 0;
  final int _limit = 15;
  bool hasMore = true;
  bool isFetchingMore = false;

  @override
  Future<List<Expense>> build() async {
    final generation = ++_generation;
    ref.onDispose(() {
      _generation++;
    });
    _offset = 0;
    hasMore = true;
    isFetchingMore = false;
    final getExpensesUseCase = ref.watch(getExpensesUseCaseProvider);
    final searchQuery = ref.watch(expenseSearchQueryProvider);
    final filter = ref.watch(expenseFilterProvider);
    final sort = ref.watch(expenseSortProvider);

    final sync = ref.watch(syncServiceProvider.notifier);
    await sync.readyForRead();
    final initialList = await getExpensesUseCase.execute(
      limit: _limit,
      offset: _offset,
      searchQuery: searchQuery,
      filter: filter,
      sort: sort,
    );
    if (generation != _generation) return initialList;
    if (initialList.isEmpty && !sync.hydrated) throw const FirstSyncException();
    if (initialList.length < _limit) {
      hasMore = false;
    } else {
      _offset += _limit;
    }
    return initialList;
  }

  Future<void> fetchMore() async {
    if (!hasMore || isFetchingMore || state.isLoading || state.hasError) {
      return;
    }

    final generation = _generation;
    isFetchingMore = true;
    try {
      final getExpensesUseCase = ref.read(getExpensesUseCaseProvider);
      final searchQuery = ref.read(expenseSearchQueryProvider);
      final filter = ref.read(expenseFilterProvider);
      final sort = ref.read(expenseSortProvider);

      final nextList = await getExpensesUseCase.execute(
        limit: _limit,
        offset: _offset,
        searchQuery: searchQuery,
        filter: filter,
        sort: sort,
      );

      if (generation != _generation) return;
      if (nextList.length < _limit) {
        hasMore = false;
      }
      _offset += nextList.length;

      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, ...nextList]);
    } catch (_) {
      // Ignore pagination fetch error to keep existing list displayed
    } finally {
      if (generation == _generation) isFetchingMore = false;
    }
  }
}

final paginatedExpensesProvider =
    AutoDisposeAsyncNotifierProvider<PaginatedExpensesNotifier, List<Expense>>(
      () => PaginatedExpensesNotifier(),
    );
