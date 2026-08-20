import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(base);
  static const EdgeInsets cardPadding = EdgeInsets.all(base);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);

  static const double sectionGap = xxl;

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconBase = 24;
  static const double iconLg = 28;
  static const double iconXl = 32;
  static const double iconHuge = 48;

  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
  static const double avatarXl = 80;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 999;
}