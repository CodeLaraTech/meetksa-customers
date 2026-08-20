import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_constants.dart';

class MeetKSACustomerTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryColor,
        onPrimary: Colors.white,
        primaryContainer: AppConstants.surfaceContainerHigh,
        onPrimaryContainer: AppConstants.onSurface,
        secondary: AppConstants.secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: AppConstants.surfaceContainerHigh,
        surface: AppConstants.surfaceContainer,
        onSurface: AppConstants.onSurface,
        onSurfaceVariant: AppConstants.onSurfaceVariant,
        outline: AppConstants.outlineColor,
        outlineVariant: AppConstants.outlineVariant,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.64,
          color: AppConstants.onSurface,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: -0.24,
          color: AppConstants.onSurface,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: AppConstants.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppConstants.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
          color: AppConstants.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppConstants.onSurface,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.heading,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
