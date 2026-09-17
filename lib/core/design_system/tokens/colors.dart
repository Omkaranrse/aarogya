import 'package:flutter/material.dart';

class AarogyaColors {
  AarogyaColors._();

  // Dark Theme / Obsidian Glass Foundation
  static const Color darkBg = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF0F1626);
  static const Color darkSurfaceElevated = Color(0xFF151E33);
  static const Color darkCard = Color(0xFF121B2D);
  static const Color darkCardHover = Color(0xFF17233B);
  static const Color darkGlassBg = Color(0xD90D1322); // 85% opacity
  static const Color darkGlassCard = Color(0xBF11192C); // 75% opacity
  static const Color darkGlassBorder = Color(
    0x3338BDF8,
  ); // Translucent cyan border
  static const Color darkGlassBorderSubtle = Color(0x1AFFFFFF);

  // Light Theme / Clean Frosted Glass Foundation
  static const Color lightBg = Color(0xFFF6F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightGlassBg = Color(0xF2FFFFFF); // 95% opacity
  static const Color lightGlassCard = Color(0xE6FFFFFF); // 90% opacity
  static const Color lightGlassBorder = Color(0x260284C7);
  static const Color lightGlassBorderSubtle = Color(0x140F172A);

  // Futuristic Medical Accents
  static const Color primaryCyan = Color(0xFF00D8F6); // Electric Telemetry Cyan
  static const Color primaryTeal = Color(0xFF00F2FE); // Medical Neon Teal
  static const Color primaryBlue = Color(0xFF3B82F6); // Royal Clinical Blue
  static const Color accentIndigo = Color(0xFF6366F1); // Futuristic Indigo
  static const Color accentPurple = Color(0xFF8B5CF6); // Bio-tech Violet

  // Clinical Status Colors
  static const Color success = Color(
    0xFF10B981,
  ); // Emerald (Normal, Confirmed, Paid)
  static const Color warning = Color(0xFFF59E0B); // Amber (Pending, Waiting)
  static const Color critical = Color(
    0xFFF43F5E,
  ); // Rose (Abnormal, High Priority, Urgent)
  static const Color info = Color(0xFF38BDF8); // Sky Blue (Informational)
  static const Color neutral = Color(0xFF64748B); // Slate Grey

  // Text Colors
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color textDarkMuted = Color(0xFF64748B);

  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF475569);
  static const Color textLightMuted = Color(0xFF94A3B8);

  // Glowing Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D8F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0x241E293B), Color(0x140F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xF7F8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGlowGradient = LinearGradient(
    colors: [Color(0x3300D8F6), Color(0x1A8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient specularDarkBorder = LinearGradient(
    colors: [Color(0x4038BDF8), Color(0x12FFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
