import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class SettingsTile extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String? trailingText;
  final bool showChevron;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 20,
        ),
        child: Row(
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 18,
                color: colors.primary,
              )
            else
              FaIcon(
                icon,
                size: 18,
                color: colors.primary,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.base.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AppTypography.sm.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (showChevron) const SizedBox(width: 8),
            ],
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colors.textPrimary,
              ),
          ],
        ),
      ),
    );
  }
}
