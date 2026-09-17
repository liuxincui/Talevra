import 'package:flutter/material.dart';

/// Shared visual language for the consumer app.
class AppPalette {
  const AppPalette._();

  static const ink = Color(0xFF08030F);
  static const nav = Color(0xFF1B0035);
  static const purple = Color(0xFF8F00E9);
  static const blue = Color(0xFF075078);
  static const pink = Color(0xFFFF00B8);
  static const yellow = Color(0xFFFFC72C);
  static const card = Color(0xFF26252A);
  static const muted = Color(0xFFAAA4B5);
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B00DC), Color(0xFF07527A), Color(0xFF17002C)],
    stops: [0, .56, 1],
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() => dark();

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppPalette.pink,
      secondary: AppPalette.yellow,
      surface: AppPalette.ink,
      surfaceContainer: AppPalette.card,
      surfaceContainerHighest: Color(0xFF35333A),
      onPrimary: Colors.white,
      onSecondary: Color(0xFF241700),
      onSurface: Colors.white,
      outline: Color(0xFF625C6C),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.ink,
      fontFamily: 'Roboto',
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 76,
        backgroundColor: AppPalette.nav,
        indicatorColor: AppPalette.pink,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: AppPalette.pink,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppPalette.yellow,
        linearTrackColor: Color(0xFF555259),
      ),
    );
  }
}
