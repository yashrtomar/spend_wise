import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Divider(
      height: 1,
      thickness: 1,
      color: colors.textSecondary.withValues(alpha: 0.08),
    );
  }
}
