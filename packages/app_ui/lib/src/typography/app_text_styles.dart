import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// {@macro app_text_styles}
/// Modern typography styles using Google Fonts
abstract class AppTextStyles {
  static const _defaultColor = AppColors.textPrimary;

  static final TextStyle _defaultFont = GoogleFonts.inter();

  /// Display Large - For major headings
  static TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: _defaultColor,
  );

  /// Display Medium - For section titles
  static TextStyle displayMedium = GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: _defaultColor,
  );

  /// Display Small - For page titles
  static TextStyle displaySmall = GoogleFonts.plusJakartaSans(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: _defaultColor,
  );

  /// Headline Large - For large headings
  static TextStyle headlineLarge = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
    color: _defaultColor,
  );

  /// Headline Medium - For medium headings
  static TextStyle headlineMedium = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
    color: _defaultColor,
  );

  /// Title Large - For card titles
  static TextStyle titleLarge = _defaultFont.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: _defaultColor,
  );

  /// Title Medium - For section headers
  static TextStyle titleMedium = _defaultFont.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.15,
    color: _defaultColor,
  );

  /// Title Small - For small headers
  static TextStyle titleSmall = _defaultFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: _defaultColor,
  );

  /// Body Large - For emphasized body text
  static TextStyle bodyLarge = _defaultFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: _defaultColor,
  );

  /// Body Medium - For regular body text
  static TextStyle bodyMedium = _defaultFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
    color: _defaultColor,
  );

  /// Body Small - For small body text
  static TextStyle bodySmall = _defaultFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
    color: _defaultColor,
  );

  /// Label Large - For large labels
  static TextStyle labelLarge = _defaultFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: _defaultColor,
  );

  /// Label Medium - For medium labels
  static TextStyle labelMedium = _defaultFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: _defaultColor,
  );

  /// Label Small - For small labels
  static TextStyle labelSmall = _defaultFont.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: _defaultColor,
  );
}
