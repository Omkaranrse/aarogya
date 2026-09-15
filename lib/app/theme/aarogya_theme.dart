import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';

class AarogyaTheme {
  AarogyaTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AarogyaColors.darkBg,
      primaryColor: AarogyaColors.primaryCyan,
      colorScheme: const ColorScheme.dark(
        primary: AarogyaColors.primaryCyan,
        secondary: AarogyaColors.accentIndigo,
        surface: AarogyaColors.darkSurface,
        background: AarogyaColors.darkBg,
        error: AarogyaColors.critical,
        onPrimary: Colors.white,
        onSurface: AarogyaColors.textDarkPrimary,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AarogyaColors.textDarkPrimary,
        displayColor: AarogyaColors.textDarkPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AarogyaColors.textDarkPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: AarogyaColors.darkGlassBorderSubtle,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AarogyaColors.darkGlassCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AarogyaRadius.radiusLg,
          side: const BorderSide(color: AarogyaColors.darkGlassBorderSubtle),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AarogyaColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AarogyaColors.lightBg,
      primaryColor: AarogyaColors.primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: AarogyaColors.primaryBlue,
        secondary: AarogyaColors.primaryCyan,
        surface: AarogyaColors.lightSurface,
        background: AarogyaColors.lightBg,
        error: AarogyaColors.critical,
        onPrimary: Colors.white,
        onSurface: AarogyaColors.textLightPrimary,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AarogyaColors.textLightPrimary,
        displayColor: AarogyaColors.textLightPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AarogyaColors.textLightPrimary),
      ),
      dividerTheme: const DividerThemeData(
        color: AarogyaColors.lightGlassBorderSubtle,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AarogyaColors.lightGlassCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AarogyaRadius.radiusLg,
          side: const BorderSide(color: AarogyaColors.lightGlassBorderSubtle),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AarogyaColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
    );
  }
}
