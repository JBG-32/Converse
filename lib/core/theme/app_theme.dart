import 'package:flutter/material.dart';

class AppTheme {
    AppTheme._();

    // Colors
    static const Color primaryColor = Color(0xFF6366F1);
    static const Color primaryColorDark = Color(0xFF4F46E5);
    static const Color accentColor = Color(0xFF10B981);
    static const Color errorColor = Color(0xFFEF4444);
    static const Color warningColor = Color(0xFFF59E0B);

    // Light Theme Colors
    static const Color lightBackground = Color(0xFFF8FAFC);
    static const Color lightSurface = Color(0xFFFFFFFF);
    static const Color lightTextPrimary = Color(0xFF1E293B);
    static const Color lightTextSecondary = Color(0xFF64748B);

    // Dark Theme Colors
    static const Color darkBackground = Color(0xFF0F172A);
    static const Color darkSurface = Color(0xFF1E293B);
    static const Color darkTextPrimary = Color(0xFFF1F5F9);
    static const Color darkTextSecondary = Color(0xFF94A3B8);

    // Light Theme
    static ThemeData lightTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(
                  primary: primaryColor,
                  secondary: accentColor,
                  surface: lightSurface,
                  error: errorColor,
                ),
          scaffoldBackgroundColor: lightBackground,
          appBarTheme: const AppBarTheme(
                  backgroundColor: lightSurface,
                  foregroundColor: lightTextPrimary,
                  elevation: 0,
                  centerTitle: true,
                ),
          cardTheme: CardTheme(
                  color: lightSurface,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                ),
          inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: lightSurface,
                  border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                  enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                  focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                          ),
                ),
          elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                          ),
                ),
          textTheme: const TextTheme(
                  headlineLarge: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: lightTextPrimary,
                          ),
                  headlineMedium: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: lightTextPrimary,
                          ),
                  bodyLarge: TextStyle(
                            fontSize: 16,
                            color: lightTextPrimary,
                          ),
                  bodyMedium: TextStyle(
                            fontSize: 14,
                            color: lightTextSecondary,
                          ),
                ),
        );

    // Dark Theme
    static ThemeData darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
                  primary: primaryColor,
                  secondary: accentColor,
                  surface: darkSurface,
                  error: errorColor,
                ),
          scaffoldBackgroundColor: darkBackground,
          appBarTheme: const AppBarTheme(
                  backgroundColor: darkSurface,
                  foregroundColor: darkTextPrimary,
                  elevation: 0,
                  centerTitle: true,
                ),
          cardTheme: CardTheme(
                  color: darkSurface,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                ),
          inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: darkSurface,
                  border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                  enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                  focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor, width: 2),
                          ),
                ),
          elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                          ),
                ),
          textTheme: const TextTheme(
                  headlineLarge: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: darkTextPrimary,
                          ),
                  headlineMedium: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: darkTextPrimary,
                          ),
                  bodyLarge: TextStyle(
                            fontSize: 16,
                            color: darkTextPrimary,
                          ),
                  bodyMedium: TextStyle(
                            fontSize: 14,
                            color: darkTextSecondary,
                          ),
                ),
        );
}
