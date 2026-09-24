import 'package:flutter/material.dart';

/// App-wide Color Palette for VR's Kitchen
/// Deep Navy Blue & Luxury Gold Brand Identity
class AppColors {
  AppColors._();

  // Primary Navy Shades
  static const Color navyPrimary = Color(0xFF071A3D);
  static const Color navyDark = Color(0xFF041126);
  static const Color navyRoyal = Color(0xFF0B2452);
  static const Color navyLight = Color(0xFF13326B);
  static const Color navySurface = Color(0xFF0E2248);

  // Luxury Gold Shades
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4D77A);
  static const Color goldDark = Color(0xFFB88E1D);
  static const Color goldMuted = Color(0xFFE8D49E);
  static const Color goldBackground = Color(0xFFFFF9EC);

  // Backgrounds & Neutral Surfaces
  static const Color backgroundLight = Color(0xFFF8F9FB);
  static const Color backgroundWarm = Color(0xFFFFFDF8);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderGold = Color(0x66D4AF37);
  static const Color divider = Color(0xFFEEEEEE);

  // Typography & Content
  static const Color textDark = Color(0xFF15181E);
  static const Color textBody = Color(0xFF374151);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFD4AF37);

  // Food & Status Accents
  static const Color vegGreen = Color(0xFF1B8A3E);
  static const Color nonVegRed = Color(0xFFC62828);
  static const Color jainYellow = Color(0xFFD97706);
  static const Color spicyRed = Color(0xFFDC2626);
  static const Color mildGreen = Color(0xFF16A34A);

  // Status Colors
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusError = Color(0xFFEF4444);
  static const Color statusInfo = Color(0xFF3B82F6);
  static const Color statusPreparing = Color(0xFFF59E0B);
  static const Color statusOutForDelivery = Color(0xFF3B82F6);
  static const Color statusDelivered = Color(0xFF10B981);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFE5C158), Color(0xFFC59B27)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [Color(0xFFF3D474), Color(0xFFCCA230)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient navyHeroGradient = LinearGradient(
    colors: [Color(0xFF041126), Color(0xFF071A3D), Color(0xFF0B2452)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient navyCardGradient = LinearGradient(
    colors: [Color(0xFF071A3D), Color(0xFF112957)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
