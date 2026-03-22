import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppThemeColors {
  final Color bg;
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;

  const AppThemeColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
  });

  factory AppThemeColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const AppThemeColors(
        bg: AppColors.darkBg,
        surface: AppColors.darkSurface,
        card: AppColors.darkCard,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textMuted: AppColors.textMuted,
        divider: AppColors.darkCard,
      );
    } else {
      return const AppThemeColors(
        bg: AppColors.lightBg,
        surface: Color(0xFFFFFFFF),
        card: Color(0xFFF1F5F9),
        textPrimary: Color(0xFF0A0E1A),
        textSecondary: Color(0xFF4A5270),
        textMuted: Color(0xFF94A3B8),
        divider: Color(0xFFE2E8F0),
      );
    }
  }
}
