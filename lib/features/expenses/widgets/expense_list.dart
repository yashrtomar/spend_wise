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
    return ListView.separated(
      padding: EdgeInsets.zero,

      itemCount: expenses.length,

      separatorBuilder: (_, __) =>
          const SizedBox(height: AppSpacing.sm),

      itemBuilder: (context, index) {
        final expense = expenses[index];

        return ExpenseListItem(
          expense: expense,
          onPressed: () => onExpensePressed(expense),
        );
      },
    );
  }
}