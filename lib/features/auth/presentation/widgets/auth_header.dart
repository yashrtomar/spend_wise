import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthHeader({
    super.key,
    this.title = "Spendwise",
    this.subtitle = "Track your expenses and stay on top of your finances.",
    this.icon = Icons.account_balance_wallet_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/coins.png',
          height: 64,
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          "Spendwise",
          style: AppTypography.xxl.copyWith(
            // fontSize: 40,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          "Track your expenses and stay on top of your finances",
          style: AppTypography.base.copyWith(
            height: 1.4,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
