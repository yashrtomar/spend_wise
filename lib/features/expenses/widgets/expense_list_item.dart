import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spend_wise/features/expenses/providers/categories_provider.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class ExpenseListItem extends ConsumerWidget {
  final Expense expense;
  final VoidCallback onPressed;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isSkeleton = Skeletonizer.maybeOf(context)?.enabled ?? false;
    final categoriesAsync = ref.watch(categoriesProvider);
    final categoryName = categoriesAsync.maybeWhen(
      data: (categories) {
        final found = categories
            .where(
              (c) => c.id == expense.category || c.name == expense.category,
            )
            .firstOrNull;
        return found?.name ?? expense.category;
      },
      orElse: () => expense.category,
    );

    return InkWell(
      borderRadius: AppRadius.lg,
      onTap: onPressed,

      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),

        decoration: BoxDecoration(
          borderRadius: AppRadius.lg,
          color: colors.backgroundCard,
        ),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    expense.name,
                    style: AppTypography.base.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Row(
                  spacing: AppSpacing.sm,
                  children: [
                    Text(
                      expense.amount.toStringAsFixed(2),
                      style: AppTypography.base.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton.leaf(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.full,
                      border: isSkeleton ? null : Border.all(color: colors.primary),
                      color: isSkeleton ? colors.primary.withValues(alpha: 0.1) : null,
                    ),
                    child: Text(
                      categoryName,
                      style: AppTypography.xs.copyWith(color: colors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
