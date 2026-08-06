import 'package:flutter/material.dart';
import 'package:spend_wise/models/expense.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final VoidCallback onPressed;

  const ExpenseListItem({
    super.key,
    required this.expense,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Material(
      color: colors.backgroundCard,
      borderRadius: AppRadius.lg,

      child: InkWell(
        borderRadius: AppRadius.lg,
        onTap: onPressed,

        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),

          decoration: BoxDecoration(
            borderRadius: AppRadius.lg,
            border: Border.all(
              color: colors.border,
            ),
          ),

          child: Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      expense.name,
                      style: AppTypography.base.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),

                      decoration: BoxDecoration(
                        borderRadius: AppRadius.full,
                        border: Border.all(
                          color: colors.primary,
                        ),
                      ),

                      child: Text(
                        expense.category,
                        style: AppTypography.xs.copyWith(
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [

                  Text(
                    "\$${expense.amount.toStringAsFixed(2)}",
                    style: AppTypography.base.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}