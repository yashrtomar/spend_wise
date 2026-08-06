import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_typography.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: AppTypography.xs.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
