import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Headings
  static TextStyle displayLarge = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium = GoogleFonts.outfit(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static TextStyle headingLarge = GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static TextStyle headingMedium = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle headingSmall = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Subtitles & Titles
  static TextStyle titleMedium = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static TextStyle titleSmall = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Body
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.4,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Captions & Badges
  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static TextStyle button = GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static TextStyle priceTag = GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.navyPrimary,
  );
}
