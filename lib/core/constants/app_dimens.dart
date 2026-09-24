import 'package:flutter/material.dart';

class AppDimens {
  AppDimens._();

  // Spacing & Padding
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Radius
  static const double radiusXS = 6.0;
  static const double radiusSM = 10.0;
  static const double radiusMD = 14.0;
  static const double radiusLG = 18.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderXS = BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderSM = BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderMD = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderLG = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderXL = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));

  // Elevations & Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
      blurRadius: 20,
      spreadRadius: 1,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> navyShadow = [
    BoxShadow(
      color: const Color(0xFF041126).withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
