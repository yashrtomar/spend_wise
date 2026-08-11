import 'package:flutter/material.dart';

class AppThemeColors {
  final Color primary;

  final Color backgroundScreen;
  final Color backgroundCard;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textInverse;
  final Color textTint;

  final Color border;

  final Color error;
  final Color success;
  final Color warning;
  final Color alert;

  final Color white;
  final Color black;

  const AppThemeColors({
    required this.primary,
    required this.backgroundScreen,
    required this.backgroundCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textInverse,
    required this.textTint,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
    required this.alert,
    required this.white,
    required this.black
  });
}

const lightColors = AppThemeColors(
  primary: Color(0xFF0062FF),
  backgroundScreen: Color(0xFFF1F5F9), // Slate 100 for better contrast against white cards
  backgroundCard: Color(0xFFFFFFFF),
  textPrimary: Color(0xFF000000),
  textSecondary: Color(0xFF666666),
  textMuted: Color(0x66000000),
  textInverse: Color(0xFF000000),
  textTint: Color(0xFFE0F2FE),
  border: Color(0xFFCED2D7),
  error: Color(0xFFFF4444),
  success: Color(0xFF009E15),
  warning: Color(0xFFF59E0B),
  alert: Color(0xFFF97316),
  white: Color(0xFFFFFFFF),
  black: Color(0x00000000)
);

const darkColors = AppThemeColors(
  primary: Color(0xFF0062FF),
  backgroundScreen: Color(0xFF05080E),
  backgroundCard: Color(0xFF131924),
  textPrimary: Color(0xFFF8FAFC),
  textSecondary: Color(0xFF94A3B8),
  textMuted: Color(0x66FFFFFF),
  textInverse: Color(0xFFFFFFFF),
  textTint: Color(0xFF1E3A8A),
  border: Color(0xFF334155),
  error: Color(0xFFFF4444),
  success: Color(0xFF007D11),
  warning: Color(0xFFF59E0B),
  alert: Color(0xFFF97316),
  white: Color(0xFFFFFFFF),
  black: Color(0x00000000)
);

extension ThemeExtension on BuildContext {
  AppThemeColors get colors {
    return Theme.of(this).brightness == Brightness.dark
        ? darkColors
        : lightColors;
  }
}

class AppShadows {
  static const card = [
    BoxShadow(
      blurRadius: 12,
      offset: Offset(0, 6),
      color: Colors.black12,
    ),
  ];
}