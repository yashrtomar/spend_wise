import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,

    scaffoldBackgroundColor: lightColors.backgroundScreen,

    colorScheme: const ColorScheme.light().copyWith(
      primary: lightColors.primary,
      error: lightColors.error,
      surface: lightColors.backgroundCard,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: darkColors.backgroundScreen,

    colorScheme: const ColorScheme.dark().copyWith(
      primary: darkColors.primary,
      error: darkColors.error,
      surface: darkColors.backgroundCard,
    ),
  );
}