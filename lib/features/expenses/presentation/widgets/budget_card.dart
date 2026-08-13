import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class BudgetCard extends StatelessWidget {
  final double budget;
  final double spent;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.spent,
  });

  Color _progressColor(AppThemeColors colors, double percentage) {
    if (percentage < .5) return colors.success;
    if (percentage < .7) return colors.warning;
    if (percentage < .8) return colors.alert;
    return colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final isOverBudget = spent > budget;
    final overBudgetAmount = spent - budget;
    final remaining = isOverBudget ? 0.0 : budget - spent;

    final progress =
        budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.card(context),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.08)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Monthly Budget",
            style: AppTypography.xs.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
              letterSpacing: .5,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            budget.toStringAsFixed(0),
            style: AppTypography.xxl.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          ClipRRect(
            borderRadius: AppRadius.full,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.textPrimary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(
                _progressColor(colors, progress),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOverBudget ? "Over Budget by" : "Remaining Balance",
                style: AppTypography.xs.copyWith(
                  color: colors.textPrimary,
                ),
              ),

              Text(
                isOverBudget 
                    ? overBudgetAmount.toStringAsFixed(0)
                    : "${remaining.toStringAsFixed(0)} / ${budget.toStringAsFixed(0)}",
                style: AppTypography.xs.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}