import 'package:coaching_fit_coach/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextStyle heading1 = GoogleFonts.syne(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle heading2 = GoogleFonts.syne(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle heading3 = GoogleFonts.syne(
    color: AppColors.textPrimary,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle bodyL = GoogleFonts.dmSans(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyM = GoogleFonts.dmSans(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyS = GoogleFonts.dmSans(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle button = GoogleFonts.dmSans(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}