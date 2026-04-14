import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: kAppBg,
      colorScheme: const ColorScheme.dark(
        primary:   kGold,
        secondary: kGoldLight,
        surface:   kAppSurface,
        error:     kError,
        onPrimary: kAppBg,
        onSecondary: kAppBg,
        onSurface: kTextPrimary,
      ),
      dividerColor: kAppBorder,
      textTheme: _buildTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kGold,
          foregroundColor: kAppBg,
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: kTextPrimary,
          side: const BorderSide(color: kAppBorder, width: 1.5),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kAppSurface2,
        contentTextStyle: GoogleFonts.dmSans(color: kTextPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      cardTheme: CardThemeData(
        color: kAppSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: kAppBorder),
        ),
      ),
      iconTheme: const IconThemeData(color: kTextSecondary),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: kGold),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display – Playfair Display (editorial, regal)
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 72, fontWeight: FontWeight.w800,
        color: kTextPrimary, letterSpacing: -1, height: 1.05,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 48, fontWeight: FontWeight.w700,
        color: kTextPrimary, letterSpacing: -0.5, height: 1.1,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 36, fontWeight: FontWeight.w700,
        color: kTextPrimary, height: 1.15,
      ),

      // Headline – DM Sans semi-bold
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: kTextPrimary, letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 22, fontWeight: FontWeight.w600,
        color: kTextPrimary,
      ),
      headlineSmall: GoogleFonts.dmSans(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: kTextPrimary,
      ),

      // Title
      titleLarge: GoogleFonts.dmSans(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: kTextPrimary,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 14, fontWeight: FontWeight.w500,
        color: kTextSecondary,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: kTextMuted, letterSpacing: 0.6,
      ),

      // Body – DM Sans
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16, color: kTextSecondary, height: 1.65,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14, color: kTextSecondary, height: 1.6,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12, color: kTextMuted, height: 1.5,
      ),

      // Label
      labelLarge: GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: kTextPrimary, letterSpacing: 0.3,
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: kTextMuted, letterSpacing: 0.8,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 10, fontWeight: FontWeight.w400,
        color: kTextMuted, letterSpacing: 1.0,
      ),
    );
  }
}