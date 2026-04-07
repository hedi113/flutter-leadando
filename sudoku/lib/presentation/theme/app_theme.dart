// lib/presentation/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFF5B6AF5);
  static const _primaryDark = Color(0xFF7B88FF);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      fontFamily: 'sans-serif',
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }

  // ── Cell colour helpers ──────────────────────────────────────────────────

  static Color cellBackground(
    BuildContext context, {
    required bool isSelected,
    required bool isHighlighted, // same row/col/box
    required bool isSameValue,   // same digit as selected
    required bool isGiven,
    required bool hasConflict,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (hasConflict) return isDark ? const Color(0xFF5C1A1A) : const Color(0xFFFFDDDD);
    if (isSelected) return cs.primary.withOpacity(0.85);
    if (isSameValue) return cs.primary.withOpacity(isDark ? 0.30 : 0.22);
    if (isHighlighted) return cs.primary.withOpacity(isDark ? 0.12 : 0.09);
    if (isGiven) return isDark ? const Color(0xFF1E1E2E) : const Color(0xFFEEEEF8);
    return isDark ? const Color(0xFF1A1A2A) : Colors.white;
  }

  static Color cellTextColor(
    BuildContext context, {
    required bool isSelected,
    required bool isGiven,
    required bool hasConflict,
  }) {
    final cs = Theme.of(context).colorScheme;
    if (hasConflict) return isDarkMode(context) ? const Color(0xFFFF6B6B) : const Color(0xFFD32F2F);
    if (isSelected) return Colors.white;
    if (isGiven) return cs.onSurface;
    return cs.primary;
  }

  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
