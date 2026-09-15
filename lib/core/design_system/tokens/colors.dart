import 'package:flutter/material.dart';

class AarogyaColors {
  AarogyaColors._();

  // Dark Theme / Obsidian Glass Foundation
  static const Color darkBg = Color(0xFF0A0E1A);
  static const Color darkSurface = Color(0xFF121829);
  static const Color darkGlassBg = Color(0xCC111827); // 80% opacity
  static const Color darkGlassCard = Color(0x99172033); // 60% opacity
  static const Color darkGlassBorder = Color(0x3338BDF8); // Translucent cyan border
  static const Color darkGlassBorderSubtle = Color(0x1FFFFFFF);

  // Light Theme / Clean Frosted Glass Foundation
  static const Color lightBg = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightGlassBg = Color(0xD9FFFFFF); // 85% opacity
  static const Color lightGlassCard = Color(0xB3FFFFFF); // 70% opacity
  static const Color lightGlassBorder = Color(0x330284C7);
  static const Color lightGlassBorderSubtle = Color(0x1F0F172A);

  // Futuristic Medical Accents
  static const Color primaryCyan = Color(0xFF06B6D4); // Electric Cyan
  static const Color primaryTeal = Color(0xFF00F2FE); // Medical Neon Teal
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Clinical Blue
  static const Color accentIndigo = Color(0xFF6366F1); // Futuristic Indigo
  static const Color accentPurple = Color(0xFF8B5CF6); // Bio-tech Violet

  // Clinical Status Colors
  static const Color success = Color(0xFF10B981); // Emerald (Normal, Confirmed, Paid)
  static const Color warning = Color(0xFFF59E0B); // Amber (Pending, Waiting)
  static const Color critical = Color(0xFFF43F5E); // Rose (Abnormal, High Priority, Urgent)
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
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0x331E293B), Color(0x1A0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xE6FFFFFF), Color(0xB3F8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGlowGradient = LinearGradient(
    colors: [Color(0x3306B6D4), Color(0x1A8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
