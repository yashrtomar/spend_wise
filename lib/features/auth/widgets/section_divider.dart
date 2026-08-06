import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class SectionDivider extends StatelessWidget {
  final String text;

  const SectionDivider({
    super.key,
    this.text = "or continue with",
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colors.border,
            thickness: 1,
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          child: Text(
            text,
            style: AppTypography.sm.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Expanded(
          child: Divider(
            color: colors.border,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}