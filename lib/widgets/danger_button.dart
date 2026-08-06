import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/theme/app_spacing.dart';

class DangerButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final dynamic icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const DangerButton({
    super.key,
    required this.title,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
          side: BorderSide(
            color: colors.error,
          ),
        ),
        child: InkWell(
          borderRadius: AppRadius.md,
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ] else if (icon != null) ...[
                  if (icon is IconData)
                    Icon(
                      icon,
                      size: 18,
                      color: colors.error,
                    )
                  else
                    FaIcon(
                      icon,
                      size: 18,
                      color: colors.error,
                    ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(
                  title,
                  style: AppTypography.base.copyWith(
                    color: colors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
