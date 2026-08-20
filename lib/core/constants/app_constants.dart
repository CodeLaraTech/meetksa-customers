import 'package:flutter/material.dart';
import 'app_strings.dart';

class AppFonts {
  static const String body = 'Inter';
  static const String heading = 'Geist';
}

class AppConstants {
  static const String appName = AppStrings.appName;
  static const String appTagline = AppStrings.appTagline;
  static const String appFooter = AppStrings.appFooter;

  // Primary & Secondary Brand Colors from Stitch Specification
  static const Color primaryColor = Color(0xFF234997);
  static const Color secondaryColor = Color(0xFF009CA3);
  static const Color secondaryAccent = Color(0xFF009CA3);

  // Surface Hierarchy
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF8FAFC);
  static const Color surfaceContainerLow = Color(0xFFF8FAFC);
  static const Color surfaceContainer = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFF1F5F9);
  static const Color surfaceContainerHighest = Color(0xFFE2E8F0);

  // Text Colors
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF334155);
  static const Color outlineColor = Color(0xFF64748B);
  static const Color outlineVariant = Color(0xFFCBD5E1);

  // Spacing Standards
  static const double safeMargin = 20.0;
  static const double gutter = 12.0;
  static const double stackSm = 8.0;
  static const double stackMd = 16.0;
  static const double stackLg = 24.0;
  static const double unit = 4.0;

  // Design Metrics
  static const double borderRadiusSm = 12.0;
  static const double borderRadiusMd = 16.0;
  static const double borderRadiusLg = 24.0;
  static const double borderRadiusPill = 20.0;

  // Animation & Network Durations
  static const Duration splashDuration = Duration(milliseconds: 1200);
  static const Duration animDurationFast = Duration(milliseconds: 250);
  static const Duration animDurationStandard = Duration(milliseconds: 400);
  static const Duration webViewTimeout = Duration(seconds: 20);
}

