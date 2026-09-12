import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1677F2);
  static const Color primaryDark = Color(0xFF103B7A);

  static const Color secondary = Color(0xFFFFB000);

  static const Color background = Color(0xFFF8FBFF);

  static const Color textDark = Color(0xFF0D3475);
  static const Color textGrey = Color(0xFF6B83A9);

  static const Color border = Color(0xFFDCEBFC);

  static const Color quickBlue = Color(0xFFEAF4FF);
  static const Color quickGreen = Color(0xFFEAFBF8);
  static const Color quickYellow = Color(0xFFFFF7E2);
  static const Color quickPurple = Color(0xFFF1EDFF);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor:
    AppColors.background,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),

    fontFamily: 'Roboto',

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),

      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      ),

      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),

      bodyLarge: TextStyle(
        fontSize: 17,
        color: AppColors.textGrey,
      ),

      bodyMedium: TextStyle(
        fontSize: 15,
        color: AppColors.textGrey,
      ),
    ),
  );
}