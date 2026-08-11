import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spend_wise/features/expenses/providers/categories_provider.dart';
import 'package:spend_wise/features/expenses/providers/expenses_provider.dart';
import 'package:spend_wise/features/expenses/widgets/add_expense_button.dart';
import 'package:spend_wise/features/expenses/widgets/expense_bottom_sheet.dart';
import 'package:spend_wise/features/expenses/widgets/expense_list.dart';
import 'package:spend_wise/features/expenses/widgets/expense_list_item.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/widgets/error_state.dart';
import 'package:spend_wise/widgets/text_input.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/features/expenses/widgets/expenses_filter_bottom_sheet.dart';
import 'package:spend_wise/features/expenses/widgets/expenses_sort_bottom_sheet.dart';
import 'package:spend_wise/models/expense_filter.dart';

class AllExpensesScreen extends ConsumerStatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  ConsumerState<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends ConsumerState<AllExpensesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(expenseSearchQueryProvider.notifier).state = query;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(paginatedExpensesProvider.notifier);
      if (notifier.hasMore && !notifier.isFetchingMore && !_isLoadingMore) {
        setState(() => _isLoadingMore = true);
        notifier.fetchMore().then((_) {
          if (mounted) setState(() => _isLoadingMore = false);
        });
      }
    }
  }

  Future<void> _openExpenseSheet({Expense? expense}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: context.colors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ExpenseBottomSheet(expense: expense),
    );
    ref.invalidate(expensesProvider);
    ref.invalidate(paginatedExpensesProvider);
  }

  Widget _buildSkeletonLoader() {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 80),
      sliver: SliverToBoxAdapter(
        child: Skeletonizer(
          enabled: true,
          child: Column(
            children: List.generate(
              6,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ExpenseListItem(
                  expense: const Expense(
                    name: "Groceries & Supermarket",
                    amount: 145.50,
                    category: "Food & Dining",
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorState(
        message: 'Failed to load expenses: $error',
        onRetry: () {
          ref.invalidate(paginatedExpensesProvider);
          ref.invalidate(categoriesProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final expensesAsync = ref.watch(paginatedExpensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final searchQuery = ref.watch(expenseSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Expenses",
          style: AppTypography.lg.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        backgroundColor: colors.backgroundScreen,
        elevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        actions: [
          _buildFilterButton(context, ref, colors),
          const SizedBox(width: 8),
          _buildSortButton(context, ref, colors),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: TextInput(
              controller: _searchController,
              hintText: 'Search expenses...',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 12.0),
                child: Align(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 16,
                    color: colors.textMuted,
                  ),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: colors.primary,
        onRefresh: () async {
          ref.invalidate(paginatedExpensesProvider);
          ref.invalidate(categoriesProvider);
          try {
            await Future.wait([
              ref.read(paginatedExpensesProvider.future),
              ref.read(categoriesProvider.future),
            ]);
          } catch (_) {}
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            expensesAsync.when(
              skipLoadingOnReload: true,
              data: (expensesList) {
                if (categoriesAsync.isLoading) {
                  return _buildSkeletonLoader();
                }
                if (categoriesAsync.hasError) {
                  return _buildErrorState(categoriesAsync.error!);
                }
                return ExpenseList(
                  expenses: expensesList,
                  filterRecent: false,
                  searchQuery: searchQuery,
                  onExpensePressed: (expense) {
                    _openExpenseSheet(expense: expense);
                  },
                  onAddExpensePressed: () {
                    _openExpenseSheet();
                  },
                );
              },
              loading: () => _buildSkeletonLoader(),
              error: (error, stack) => _buildErrorState(error),
            ),
            if (_isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 90, top: 8),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: AddExpenseButton(
        onPressed: () {
          _openExpenseSheet();
        },
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, WidgetRef ref, AppThemeColors colors) {
    final filter = ref.watch(expenseFilterProvider);
    final isActive = !filter.isEmpty;

    return Stack(
      children: [
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const ExpensesFilterBottomSheet(),
            );
          },
          icon: FaIcon(
            FontAwesomeIcons.filter,
            size: 20,
            color: isActive ? colors.primary : colors.textPrimary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: isActive ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(8),
          ),
        ),
        if (isActive)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSortButton(BuildContext context, WidgetRef ref, AppThemeColors colors) {
    final sort = ref.watch(expenseSortProvider);
    final isActive = sort != ExpenseSort.newest;

    return Stack(
      children: [
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const ExpensesSortBottomSheet(),
            );
          },
          icon: FaIcon(
            FontAwesomeIcons.sort,
            size: 20,
            color: isActive ? colors.primary : colors.textPrimary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: isActive ? colors.primary.withValues(alpha: 0.1) : colors.backgroundCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isActive ? colors.primary : colors.border),
            ),
            padding: const EdgeInsets.all(12),
          ),
        ),
        if (isActive)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
