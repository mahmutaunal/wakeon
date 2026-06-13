import 'package:flutter/material.dart';

/// Centralized application theme definitions for light and dark modes.
final class AppTheme {
  const AppTheme._();

  /// Builds the light theme configuration.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );

    return _base(colorScheme);
  }

  /// Builds the dark theme configuration.
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF60A5FA),
      brightness: Brightness.dark,
    );

    return _base(colorScheme);
  }

  // Shared theme configuration used by both light and dark themes.
  static ThemeData _base(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
