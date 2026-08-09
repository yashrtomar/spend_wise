import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/models/expense_filter.dart';
import 'package:spend_wise/services/expenses_service.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

final expensesProvider = FutureProvider<List<Expense>>((ref) async {
  final expenseService = ref.watch(expenseServiceProvider);
  return expenseService.getExpenses();
});

final expenseSearchQueryProvider = StateProvider<String>((ref) => '');

final expenseFilterProvider = StateProvider<ExpenseFilter>((ref) => const ExpenseFilter());

final expenseSortProvider = StateProvider<ExpenseSort>((ref) => ExpenseSort.newest);

class PaginatedExpensesNotifier
    extends AutoDisposeAsyncNotifier<List<Expense>> {
  int _offset = 0;
  final int _limit = 15;
  bool hasMore = true;
  bool isFetchingMore = false;

  @override
  Future<List<Expense>> build() async {
    _offset = 0;
    hasMore = true;
    isFetchingMore = false;
    final service = ref.watch(expenseServiceProvider);
    final searchQuery = ref.watch(expenseSearchQueryProvider);
    final filter = ref.watch(expenseFilterProvider);
    final sort = ref.watch(expenseSortProvider);
    
    final initialList = await service.getExpenses(
      limit: _limit,
      offset: _offset,
      searchQuery: searchQuery,
      filter: filter,
      sort: sort,
    );
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

    isFetchingMore = true;
    try {
      final service = ref.read(expenseServiceProvider);
      final searchQuery = ref.read(expenseSearchQueryProvider);
      final filter = ref.read(expenseFilterProvider);
      final sort = ref.read(expenseSortProvider);
      
      final nextList = await service.getExpenses(
        limit: _limit,
        offset: _offset,
        searchQuery: searchQuery,
        filter: filter,
        sort: sort,
      );

      if (nextList.length < _limit) {
        hasMore = false;
      }
      _offset += nextList.length;

      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, ...nextList]);
    } catch (_) {
      // Ignore pagination fetch error to keep existing list displayed
    } finally {
      isFetchingMore = false;
    }
  }
}

final paginatedExpensesProvider = AutoDisposeAsyncNotifierProvider<
    PaginatedExpensesNotifier, List<Expense>>(
  () => PaginatedExpensesNotifier(),
);
