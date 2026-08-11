import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/utils/string_extensions.dart';

class GreetHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final Widget? trailing;

  const GreetHeader({
    super.key,
    this.greeting = "Greetings",
    required this.name,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      // decoration: BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(
      //       color: colors.border,
      //     ),
      //   ),
      // ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTypography.sm.copyWith(
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  name.toTitleCase(),
                  style: AppTypography.lg.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          ?trailing,
        ],
      ),
    );
  }
}