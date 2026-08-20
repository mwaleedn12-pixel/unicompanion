import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand Primary (Deep Indigo) ──
  static const Color primary = Color(0xFF3D5AF1);
  static const Color primaryLight = Color(0xFF6B7FFF);
  static const Color primaryDark = Color(0xFF2A3EB1);
  static const Color primarySurface = Color(0xFFEEF0FF);

  // ── Brand Secondary (Teal) ──
  static const Color secondary = Color(0xFF0ABAB5);
  static const Color secondaryLight = Color(0xFF5CE0DC);
  static const Color secondaryDark = Color(0xFF078F8A);
  static const Color secondarySurface = Color(0xFFE5FAF9);

  // ── Accent (Amber — deadlines, reminders) ──
  static const Color accent = Color(0xFFFFA726);
  static const Color accentLight = Color(0xFFFFCC80);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentSurface = Color(0xFFFFF3E0);

  // ── Semantic ──
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFECFDF5);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // ── Neutral (Light Mode) ──
  static const Color backgroundLight = Color(0xFFF8F9FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color disabledLight = Color(0xFFD1D5DB);

  // ── Neutral (Dark Mode) ──
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color surfaceDark = Color(0xFF1A1D27);
  static const Color cardDark = Color(0xFF222633);
  static const Color dividerDark = Color(0xFF2D3140);
  static const Color textPrimaryDark = Color(0xFFF3F4F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color disabledDark = Color(0xFF4B5563);

  // ── GPA Indicator Colors ──
  static const Color gpaExcellent = Color(0xFF22C55E);
  static const Color gpaGood = Color(0xFF3B82F6);
  static const Color gpaAverage = Color(0xFFF59E0B);
  static const Color gpaBelowAverage = Color(0xFFF97316);
  static const Color gpaPoor = Color(0xFFEF4444);

  static Color gpaColor(double gpa) {
    if (gpa >= 3.5) return gpaExcellent;
    if (gpa >= 3.0) return gpaGood;
    if (gpa >= 2.5) return gpaAverage;
    if (gpa >= 2.0) return gpaBelowAverage;
    return gpaPoor;
  }

  static Color attendanceColor(double percentage) {
    if (percentage >= 85) return success;
    if (percentage >= 75) return warning;
    return error;
  }

  // ── Match Score Colors ──
  static const Color matchHigh = Color(0xFF22C55E);
  static const Color matchMedium = Color(0xFFF59E0B);
  static const Color matchLow = Color(0xFFEF4444);

  static Color matchScoreColor(int score) {
    if (score >= 80) return matchHigh;
    if (score >= 50) return matchMedium;
    return matchLow;
  }
}