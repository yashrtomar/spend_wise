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

class AllExpensesScreen extends ConsumerStatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  ConsumerState<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends ConsumerState<AllExpensesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final expensesAsync = ref.watch(paginatedExpensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final isInitialLoading =
        (expensesAsync.isLoading && !expensesAsync.hasValue) ||
        (categoriesAsync.isLoading && !categoriesAsync.hasValue);
    final hasError =
        (expensesAsync.hasError && !expensesAsync.hasValue) ||
        (categoriesAsync.hasError && !categoriesAsync.hasValue);
    final error = expensesAsync.error ?? categoriesAsync.error;
    final expenses = expensesAsync.value ?? [];

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
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (isInitialLoading)
              SliverPadding(
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
              )
            else if (hasError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Failed to load expenses: $error',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                ),
              )
            else
              ExpenseList(
                expenses: expenses,
                filterRecent: false,
                onExpensePressed: (expense) {
                  _openExpenseSheet(expense: expense);
                },
                onAddExpensePressed: () {
                  _openExpenseSheet();
                },
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
}
