import 'package:flutter/material.dart';

class Brand {
  // Colores de marca
  static const green = Color(0xFF22C55E); // Verde energético
  static const blue = Color(0xFF1D4ED8); // Azul tecnológico
  static const yellow = Color(0xFFFACC15); // Amarillo vibrante
  static const orange = Color(0xFFF59E0B); // Naranja deportivo

  static const grayLight = Color(0xFFD1D5DB); // Gris neutro
  static const grayDark = Color(0xFF111827); // Gris oscuro
  static const white = Colors.white;

  static ThemeData theme() {
    const primary = green;
    const secondary = blue;
    const tertiary = yellow;

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      background: white,
      surface: white,
      onPrimary: white,
      onSecondary: white,
      onTertiary: Colors.black,
      onBackground: grayDark,
      onSurface: grayDark,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF6F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: secondary),
      ),
    );
  }
}
