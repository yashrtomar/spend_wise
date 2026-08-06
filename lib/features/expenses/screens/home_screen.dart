import 'package:flutter/material.dart';
import 'package:spend_wise/features/expenses/screens/all_expenses_screen.dart';
import 'package:spend_wise/features/expenses/widgets/add_expense_button.dart';
import 'package:spend_wise/features/expenses/widgets/budget_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spend_wise/features/expenses/widgets/expense_bottom_sheet.dart';
import 'package:spend_wise/features/expenses/widgets/expense_list.dart';
import 'package:spend_wise/features/expenses/widgets/expense_list_item.dart';
import 'package:spend_wise/features/expenses/widgets/greet_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/providers/categories_provider.dart';
import 'package:spend_wise/features/expenses/providers/expenses_provider.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/widgets/section_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    // temporary
    const budget = 5000.0;
    const remaining = 3250.0;
    final colors = context.colors;
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    final isInitialLoading = (expensesAsync.isLoading && !expensesAsync.hasValue) ||
        (categoriesAsync.isLoading && !categoriesAsync.hasValue);
    final hasError = (expensesAsync.hasError && !expensesAsync.hasValue) ||
        (categoriesAsync.hasError && !categoriesAsync.hasValue);
    final error = expensesAsync.error ?? categoriesAsync.error;
    final expenses = expensesAsync.value ?? [];
    final hasExpenses = expenses.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            ref.invalidate(expensesProvider);
            ref.invalidate(paginatedExpensesProvider);
            ref.invalidate(categoriesProvider);
            try {
              await Future.wait([
                ref.read(expensesProvider.future),
                ref.read(categoriesProvider.future),
              ]);
            } catch (_) {}
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: GreetHeader(
                  name: "Yash",
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: BudgetCard(budget: budget, remaining: remaining),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: ExpenseSectionHeader(
                    title: "Recent Expenses",
                    trailing: hasExpenses
                        ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllExpensesScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text("View All"),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              if (isInitialLoading)
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 80,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Skeletonizer(
                      enabled: true,
                      child: Column(
                        children: List.generate(
                          3,
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
                        'Failed to load data: $error',
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  ),
                )
              else
                ExpenseList(
                  expenses: expenses,
                  onExpensePressed: (expense) {
                    _openExpenseSheet(expense: expense);
                  },
                  onAddExpensePressed: () {
                    _openExpenseSheet();
                  },
                ),
            ],
          ),
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
