import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static String get _displayFamily => GoogleFonts.plusJakartaSans().fontFamily!;
  static String get _bodyFamily => GoogleFonts.inter().fontFamily!;

  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: TextStyle(
          fontFamily: _displayFamily,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: AppColors.textPrimaryLight,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontFamily: _displayFamily,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.textPrimaryLight,
          height: 1.25,
        ),
        displaySmall: TextStyle(
          fontFamily: _displayFamily,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontFamily: _displayFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: _displayFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
          height: 1.35,
        ),
        headlineSmall: TextStyle(
          fontFamily: _displayFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
          height: 1.35,
        ),
        titleLarge: TextStyle(
          fontFamily: _displayFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: _bodyFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontFamily: _bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontFamily: _bodyFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryLight,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: _bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimaryLight,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: _bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryLight,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: _bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontFamily: _bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondaryLight,
          letterSpacing: 0.2,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontFamily: _bodyFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiaryLight,
          letterSpacing: 0.3,
          height: 1.4,
        ),
      );

  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: lightTextTheme.displayLarge!.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: lightTextTheme.displayMedium!.copyWith(color: AppColors.textPrimaryDark),
        displaySmall: lightTextTheme.displaySmall!.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: lightTextTheme.headlineLarge!.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: lightTextTheme.headlineMedium!.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: lightTextTheme.headlineSmall!.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: lightTextTheme.titleLarge!.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: lightTextTheme.titleMedium!.copyWith(color: AppColors.textPrimaryDark),
        titleSmall: lightTextTheme.titleSmall!.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: lightTextTheme.bodyLarge!.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: lightTextTheme.bodyMedium!.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: lightTextTheme.bodySmall!.copyWith(color: AppColors.textSecondaryDark),
        labelLarge: lightTextTheme.labelLarge!.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: lightTextTheme.labelMedium!.copyWith(color: AppColors.textSecondaryDark),
        labelSmall: lightTextTheme.labelSmall!.copyWith(color: AppColors.textTertiaryDark),
      );
}
