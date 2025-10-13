import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryPurple,
        background: AppColors.backgroundWhite,
        surface: AppColors.surfaceLight,
      ),
      fontFamily: 'OpenDyslexic',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        bodyLarge: TextStyle(fontSize: 18, color: AppColors.textDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondaryPurple, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryPurple,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
      ),
      fontFamily: 'OpenDyslexic',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        bodyLarge: TextStyle(fontSize: 18, color: AppColors.textLight),
      ),
    );
  }
}
