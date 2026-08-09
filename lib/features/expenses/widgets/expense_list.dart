import 'package:flutter/material.dart';
import 'package:spend_wise/features/expenses/widgets/expense_list_item.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/widgets/primary_button.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final ValueChanged<Expense> onExpensePressed;
  final VoidCallback? onAddExpensePressed;
  final bool filterRecent;
  final String? searchQuery;

  const ExpenseList({
    super.key,
    required this.expenses,
    required this.onExpensePressed,
    this.onAddExpensePressed,
    this.filterRecent = true,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final List<Expense> displayedExpenses;

    if (filterRecent) {
      final now = DateTime.now();
      final sevenDaysAgo = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 7));

      displayedExpenses = expenses.where((expense) {
        if (expense.createdAt == null) return true;
        return expense.createdAt!.isAfter(sevenDaysAgo) ||
            expense.createdAt!.isAtSameMomentAs(sevenDaysAgo);
      }).toList();
    } else {
      displayedExpenses = expenses;
    }

    if (displayedExpenses.isEmpty) {
      final colors = context.colors;

      return SliverFillRemaining(
        hasScrollBody: false,
        child: Container(
          alignment: const Alignment(0.0, -0.2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filterRecent
                    ? "No expenses in the last 7 days"
                    : (searchQuery != null && searchQuery!.isNotEmpty)
                        ? "No expenses found for '$searchQuery'"
                        : "No expenses recorded yet",
                style: AppTypography.base.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                title: "Add Expense",
                width: 180,
                onPressed: onAddExpensePressed,
              ),
            ],
          ),
        ),
      );
    }

    final bottomPadding = 80.0 + MediaQuery.of(context).padding.bottom;

    return SliverPadding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: bottomPadding,
      ),
      sliver: SliverList.builder(
        itemCount: displayedExpenses.length,
        itemBuilder: (context, index) {
          final expense = displayedExpenses[index];
          final isLast = index == displayedExpenses.length - 1;

          final itemWidget = Column(
            children: [
              ExpenseListItem(
                expense: expense,
                onPressed: () => onExpensePressed(expense),
              ),
              if (!isLast) const SizedBox(height: AppSpacing.md),
            ],
          );

          return TweenAnimationBuilder<double>(
            key: ValueKey(expense.id ?? index),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 200 + (index * 80).clamp(0, 200)),
            curve: Curves.easeIn,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: itemWidget,
          );
        },
      ),
    );
  }
}