import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ),

    // Default font for the whole app
    fontFamily: GoogleFonts.manrope().fontFamily,

    textTheme: TextTheme(
      // Headings
      displayLarge: GoogleFonts.dmSerifDisplay(
        color: AppColors.black,
      ),
      displayMedium: GoogleFonts.dmSerifDisplay(
        color: AppColors.black,
      ),
      displaySmall: GoogleFonts.dmSerifDisplay(
        color: AppColors.black,
      ),

      headlineLarge: GoogleFonts.dmSerifDisplay(
        color: AppColors.black,
      ),
      headlineMedium: GoogleFonts.dmSerifDisplay(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
      headlineSmall: GoogleFonts.dmSerifDisplay(
        color: AppColors.black,
      ),

      // Everything else
      titleLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
      titleMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
      titleSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),

      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        color: AppColors.black,
      ),
      bodyMedium: GoogleFonts.manrope(
        color: AppColors.black,
      ),
      bodySmall: GoogleFonts.manrope(
        color: Colors.grey,
      ),

      labelLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.black,
      titleTextStyle: GoogleFonts.dmSerifDisplay(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 55),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,

      hintStyle: GoogleFonts.manrope(
        color: Colors.grey,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
        ),
      ),
    ),
  );
}