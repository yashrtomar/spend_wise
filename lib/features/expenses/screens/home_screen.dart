import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/features/expenses/widgets/add_expense_button.dart';
import 'package:spend_wise/features/expenses/widgets/budget_card.dart';
import 'package:spend_wise/features/expenses/widgets/expense_bottom_sheet.dart';
import 'package:spend_wise/features/expenses/widgets/expense_list.dart';
import 'package:spend_wise/features/expenses/widgets/greet_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/providers/expenses_provider.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/services/auth_service.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/widgets/section_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _authService = AuthService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading;
  }


  Future<void> _logout() async {
    setState(() {
      _loading = true;
    });
    try {
      await _authService.logout();
      if (!mounted) return;
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
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
      builder: (_) => ExpenseBottomSheet(expense: expense),
    );
    ref.invalidate(expensesProvider);
  }

  @override
  Widget build(BuildContext context) {
    // temporary
    const budget = 5000.0;
    const remaining = 3250.0;
    final colors = context.colors;
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GreetHeader(
              name: "Yash",
              trailing: IconButton(
                onPressed: _logout,
                icon: FaIcon(
                  FontAwesomeIcons.arrowRightFromBracket,
                  size: 24,
                  color: colors.error,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                children: [
                  BudgetCard(budget: budget, remaining: remaining),
                  ExpenseSectionHeader(
                    title: "Recent Expenses",
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text("View All"),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                  expensesAsync.when(
                    data: (expenses) => ExpenseList(
                      expenses: expenses,
                      onExpensePressed: (expense) {
                        _openExpenseSheet(expense: expense);
                      },
                    ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Failed to load expenses: $error',
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ),
                  ),
                ],
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
