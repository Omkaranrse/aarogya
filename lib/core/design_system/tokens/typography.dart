import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AarogyaTypography {
  AarogyaTypography._();

  static TextStyle displayLarge(Color color) => GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: color,
  );

  static TextStyle displayMedium(Color color) => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: color,
  );

  static TextStyle headingLarge(Color color) => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: color,
  );

  static TextStyle headingMedium(Color color) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    color: color,
  );

  static TextStyle title(Color color) => GoogleFonts.poppins(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: color,
  );

  static TextStyle bodyLarge(Color color) => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: color,
  );

  static TextStyle bodyMedium(Color color) => GoogleFonts.poppins(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: color,
  );

  static TextStyle bodySmall(Color color) => GoogleFonts.poppins(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    height: 1.35,
    color: color,
  );

  static TextStyle label(Color color) => GoogleFonts.poppins(
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    color: color,
  );

  static TextStyle caption(Color color) => GoogleFonts.poppins(
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: color,
  );

  static TextStyle code(Color color) => GoogleFonts.poppins(
    fontSize: 11.5,
    fontWeight: FontWeight.w500,
    color: color,
  );

  // Precision Telemetry & Medical Instrument Styles
  static TextStyle metricDisplay(Color color) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle metricNumber(Color color) => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle microHeader(Color color) => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    color: color,
  );
}
