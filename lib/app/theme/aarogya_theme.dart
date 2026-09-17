import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/radius.dart';
import '../../core/theme/aarogya_theme_tokens.dart';

class AarogyaTheme {
  AarogyaTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: AarogyaColorTokens.dark.scaffoldBg,
      primaryColor: AarogyaColorTokens.dark.primary,
      colorScheme: ColorScheme.dark(
        primary: AarogyaColorTokens.dark.primary,
        secondary: AarogyaColorTokens.dark.accentAction,
        surface: AarogyaColorTokens.dark.surfaceInformational,
        error: AarogyaColorTokens.dark.clinicalCritical,
        onPrimary: AarogyaColorTokens.dark.onPrimary,
        onSurface: AarogyaColorTokens.dark.neutrals.gray900,
      ),
      extensions: [
        AarogyaColorTokens.dark,
        AarogyaTypographyTokens.dark(AarogyaColorTokens.dark),
      ],
      textTheme: baseTextTheme.apply(
        bodyColor: AarogyaColorTokens.dark.neutrals.gray900,
        displayColor: AarogyaColorTokens.dark.neutrals.gray900,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AarogyaColorTokens.dark.neutrals.gray900),
      ),
      dividerTheme: DividerThemeData(
        color: AarogyaColorTokens.dark.borderHairline,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AarogyaColorTokens.dark.surfaceInformational,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AarogyaRadius.radiusMd,
          side: BorderSide(color: AarogyaColorTokens.dark.borderHairline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AarogyaColorTokens.dark.surfaceInformational,
        shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusMd),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.poppins().fontFamily,
      scaffoldBackgroundColor: AarogyaColorTokens.light.scaffoldBg,
      primaryColor: AarogyaColorTokens.light.primary,
      colorScheme: ColorScheme.light(
        primary: AarogyaColorTokens.light.primary,
        secondary: AarogyaColorTokens.light.accentAction,
        surface: AarogyaColorTokens.light.surfaceInformational,
        error: AarogyaColorTokens.light.clinicalCritical,
        onPrimary: AarogyaColorTokens.light.onPrimary,
        onSurface: AarogyaColorTokens.light.neutrals.gray900,
      ),
      extensions: [
        AarogyaColorTokens.light,
        AarogyaTypographyTokens.light(AarogyaColorTokens.light),
      ],
      textTheme: baseTextTheme.apply(
        bodyColor: AarogyaColorTokens.light.neutrals.gray900,
        displayColor: AarogyaColorTokens.light.neutrals.gray900,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AarogyaColorTokens.light.neutrals.gray900),
      ),
      dividerTheme: DividerThemeData(
        color: AarogyaColorTokens.light.borderHairline,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: AarogyaColorTokens.light.surfaceInformational,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AarogyaRadius.radiusMd,
          side: BorderSide(color: AarogyaColorTokens.light.borderHairline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AarogyaColorTokens.light.surfaceInformational,
        shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusMd),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
      ),
    );
  }
}
