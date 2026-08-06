import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class BudgetCard extends StatelessWidget {
  final double budget;
  final double remaining;

  const BudgetCard({
    super.key,
    required this.budget,
    required this.remaining,
  });

  Color _progressColor(AppThemeColors colors, double percentage) {
    if (percentage < .5) return colors.success;
    if (percentage < .7) return colors.warning;
    if (percentage < .8) return colors.alert;
    return colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    final spent = budget - remaining;

    final progress =
        budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadows.card
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Monthly Budget",
            style: AppTypography.xs.copyWith(
              color: colors.textTint,
              fontWeight: FontWeight.w500,
              letterSpacing: .5,
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            "\$${budget.toStringAsFixed(0)}",
            style: AppTypography.lg.copyWith(
              color: colors.textInverse,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          ClipRRect(
            borderRadius: AppRadius.full,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(
                _progressColor(colors, progress),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Remaining Balance",
                style: AppTypography.xs.copyWith(
                  color: colors.textTint,
                ),
              ),

              Text(
                "\$${remaining.toStringAsFixed(0)} / \$${budget.toStringAsFixed(0)}",
                style: AppTypography.xs.copyWith(
                  color: colors.textInverse,
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