import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/features/expenses/presentation/screens/all_expenses_screen.dart';
import 'package:spend_wise/features/expenses/presentation/widgets/add_expense_button.dart';
import 'package:spend_wise/features/expenses/presentation/widgets/budget_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spend_wise/features/expenses/presentation/widgets/expense_bottom_sheet.dart';
import 'package:spend_wise/features/expenses/presentation/widgets/expense_list.dart';
import 'package:spend_wise/features/expenses/presentation/widgets/expense_list_item.dart';
import 'package:spend_wise/features/expenses/presentation/widgets/greet_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/profile/presentation/providers/profile_provider.dart';
import 'package:spend_wise/features/expenses/presentation/providers/categories_provider.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:spend_wise/features/expenses/domain/entities/expense.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/widgets/section_header.dart';
import 'package:spend_wise/widgets/error_state.dart';

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

  Widget _buildSkeletonLoader() {
    return SliverPadding(
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
    );
  }

  Widget _buildErrorState(Object error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorState(
        message: 'Failed to load data: $error',
        onRetry: () {
          ref.invalidate(expensesProvider);
          ref.invalidate(paginatedExpensesProvider);
          ref.invalidate(categoriesProvider);
          ref.invalidate(profileProvider);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final profileAsync = ref.watch(profileProvider);

    final expenses = expensesAsync.value ?? [];
    final hasExpenses = expenses.isNotEmpty;

    final budget = profileAsync.value?.monthlyBudget ?? 0.0;
    final spent = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    final userName = profileAsync.value?.name ?? "User";

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
                ref.read(profileProvider.future),
              ]);
            } catch (_) {}
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: GreetHeader(
                  name: userName,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: BudgetCard(budget: budget, spent: spent),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("View All", style: TextStyle(color: colors.primary)),
                                const SizedBox(width: 4),
                                FaIcon(FontAwesomeIcons.chevronRight, size: 10, color: colors.primary),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              expensesAsync.when(
                skipLoadingOnReload: true,
                data: (expensesList) {
                  if (categoriesAsync.isLoading || profileAsync.isLoading) {
                    return _buildSkeletonLoader();
                  }
                  if (categoriesAsync.hasError) {
                    return _buildErrorState(categoriesAsync.error!);
                  }
                  if (profileAsync.hasError) {
                    return _buildErrorState(profileAsync.error!);
                  }
                  return ExpenseList(
                    expenses: expensesList,
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
