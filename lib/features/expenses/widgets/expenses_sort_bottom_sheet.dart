import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/expenses/providers/expenses_provider.dart';
import 'package:spend_wise/models/expense_filter.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class ExpensesSortBottomSheet extends ConsumerWidget {
  const ExpensesSortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currentSort = ref.watch(expenseSortProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundScreen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Sort By",
            style: AppTypography.lg.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRadioTile(
            context,
            ref,
            title: "Newest first",
            value: ExpenseSort.newest,
            groupValue: currentSort,
          ),
          _buildRadioTile(
            context,
            ref,
            title: "Oldest first",
            value: ExpenseSort.oldest,
            groupValue: currentSort,
          ),
          _buildRadioTile(
            context,
            ref,
            title: "Highest amount first",
            value: ExpenseSort.amountHighest,
            groupValue: currentSort,
          ),
          _buildRadioTile(
            context,
            ref,
            title: "Lowest amount first",
            value: ExpenseSort.amountLowest,
            groupValue: currentSort,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required ExpenseSort value,
    required ExpenseSort groupValue,
  }) {
    final colors = context.colors;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () {
        ref.read(expenseSortProvider.notifier).state = value;
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.base.copyWith(
                color: isSelected ? colors.primary : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? colors.primary : colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
