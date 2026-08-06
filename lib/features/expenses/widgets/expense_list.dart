import 'package:flutter/material.dart';
import 'package:spend_wise/features/expenses/widgets/expense_list_item.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/theme/app_spacing.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final ValueChanged<Expense> onExpensePressed;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.onExpensePressed,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));

    final recentExpenses = expenses.where((expense) {
      if (expense.createdAt == null) return true;
      return expense.createdAt!.isAfter(sevenDaysAgo) || expense.createdAt!.isAtSameMomentAs(sevenDaysAgo);
    }).toList();

    if (recentExpenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Text("No expenses in the last 7 days"),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < recentExpenses.length; i++) ...[
          ExpenseListItem(
            expense: recentExpenses[i],
            onPressed: () => onExpensePressed(recentExpenses[i]),
          ),
          if (i != recentExpenses.length - 1)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}