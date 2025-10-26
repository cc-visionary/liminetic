// lib/src/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A utility class for defining the application's visual theme.
///
/// It provides centralized definitions for colors, typography, and component styling
/// for both light and dark modes, ensuring a consistent look and feel across the app.
class AppTheme {
  //================================================================================
  // region Color Palette
  //================================================================================

  // --- Light Theme Colors ---
  static const Color primary = Color(
    0xFF0D5C3B,
  ); // Primary brand color (Dark Green)
  static const Color accent = Color(0xFF65B190); // Lighter accent green
  static const Color backgroundLight = Color(
    0xFFF7F7F2,
  ); // Off-White background
  static const Color surfaceLight = Colors.white; // Card and surface color
  static const Color textDark = Color(0xFF232323); // Primary text color
  static const Color textLightGray = Color(
    0xFF6F6F6F,
  ); // Secondary text/icon color
  static const Color glassBorderLight = Color(
    0xFFE0E0E0,
  ); // Subtle border for inputs

  // --- Dark Theme Colors ---
  static const Color backgroundDark = Color(
    0xFF121212,
  ); // Deep, off-black background
  static const Color surfaceDark = Color(
    0xFF1E1E1E,
  ); // Dark Grey for cards and surfaces
  static const Color textWhite = Color(
    0xFFE0E0E0,
  ); // Primary text color for dark mode
  static const Color textGrey = Color(0xFFB0B0B0); // Secondary text/icon color
  static const Color glassBorderDark = Color(
    0xFF424242,
  ); // Subtle border for inputs in dark mode

  // --- Common Colors ---
  static const Color error = Color(0xFFD32F2F); // Standard error color

  //================================================================================
  // endregion
  //================================================================================

  // This object can now be safely reused without causing a circular dependency.
  static final InputDecorationTheme _lightInputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: glassBorderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: glassBorderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: primary, width: 2.0),
        ),
      );

  static final InputDecorationTheme _darkInputDecorationTheme =
      InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: glassBorderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: glassBorderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: accent, width: 2.0),
        ),
      );

  //================================================================================
  // region Light Theme Definition
  //================================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      // --- Core Properties ---
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        background: backgroundLight,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onBackground: textDark,
        onSurface: textDark,
        error: error,
      ),

      // --- Typography ---
      // Uses Google's "Outfit" font, applied to all text styles.
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),

      // --- AppBar Theme ---
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      // --- **INPUT DECORATION THEME (GLASSY & ROUNDED)** ---
      // This is the core of the new input style.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        // The default border style when the input is not focused.
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0), // Fully rounded corners
          borderSide: const BorderSide(color: glassBorderLight, width: 1.5),
        ),
        // Border style when the input is enabled and not focused.
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: glassBorderLight, width: 1.5),
        ),
        // Border style when the user clicks/taps on the input.
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: primary,
            width: 2.0,
          ), // Highlights with primary color
        ),
      ),

      // --- **BUTTON THEMES (GLASSY & ROUNDED)** ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          // Shape matches the rounded input fields.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
      ),

      // --- Component Themes ---
      // Ensures other components match the overall aesthetic.
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: textLightGray,
      ),
      // Styles for Dropdown menus to match the text fields.
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: _lightInputDecorationTheme,
      ),
      // Styles for the Date Picker.
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        headerBackgroundColor: primary,
        headerForegroundColor: Colors.white,
      ),
    );
  }

  //================================================================================
  // endregion
  //================================================================================

  //================================================================================
  // region Dark Theme Definition
  //================================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      // --- Core Properties ---
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: accent, // Use lighter green for better contrast in dark mode
        secondary: accent,
        background: backgroundDark,
        surface: surfaceDark,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onBackground: textWhite,
        onSurface: textWhite,
        error: error,
      ),

      // --- Typography ---
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textWhite,
        displayColor: textWhite,
      ),

      // --- AppBar Theme ---
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      // --- **INPUT DECORATION THEME (GLASSY & ROUNDED)** ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: glassBorderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: glassBorderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(
            color: accent,
            width: 2.0,
          ), // Highlights with accent color
        ),
      ),

      // --- **BUTTON THEMES (GLASSY & ROUNDED)** ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 2,
        ),
      ),

      // --- Component Themes ---
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: accent,
        unselectedItemColor: textGrey,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: _darkInputDecorationTheme,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        headerBackgroundColor: accent,
        headerForegroundColor: Colors.black,
      ),
    );
  }

  //================================================================================
  // endregion
  //================================================================================
}
