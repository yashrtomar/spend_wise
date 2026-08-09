import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spend_wise/features/expenses/providers/categories_provider.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:intl/intl.dart';
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
          boxShadow: AppShadows.card,
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.sm,
                children: [
                  Text(
                    expense.name,
                    style: AppTypography.base.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if ((expense.note != null &&
                          expense.note!.trim().isNotEmpty) ||
                      isSkeleton) ...[
                    Text(
                      isSkeleton ? "Loading note..." : expense.note!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sm.copyWith(color: colors.textMuted),
                    ),
                  ],
                  Text(
                    expense.createdAt != null
                        ? '$categoryName • ${DateFormat('MMM d').format(expense.createdAt!)}'
                        : categoryName,
                    style: AppTypography.sm.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(width: AppSpacing.md),
            Text(
              "\$${expense.amount.toStringAsFixed(2)}",
              style: AppTypography.base.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
