import 'package:flutter/material.dart';

/// App-wide theme: blood-red seed, bundled Bangla font, large touch targets.
abstract final class AppTheme {
  static const _seed = Color(0xFFC62828);
  static const _fontFamily = 'NotoSansBengali';

  /// Minimum height for primary actions; above the 48dp floor for shaky hands.
  static const _buttonMinSize = Size(64, 56);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: _seed);
    return ThemeData(
      colorScheme: scheme,
      fontFamily: _fontFamily,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: _buttonMinSize,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: _buttonMinSize,
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
