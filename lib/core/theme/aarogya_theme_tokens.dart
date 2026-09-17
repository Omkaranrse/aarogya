import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------------------
/// STEP 1: Strict Centralized Theme Tokens as ThemeExtension
/// Diagnostic-instrument precision healthcare design system
/// ---------------------------------------------------------------------------

/// 8pt Grid spacing tokens
class AarogyaSpacingTokens {
  AarogyaSpacingTokens._();

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  static const EdgeInsets insets4 = EdgeInsets.all(space4);
  static const EdgeInsets insets8 = EdgeInsets.all(space8);
  static const EdgeInsets insets16 = EdgeInsets.all(space16);
  static const EdgeInsets insets24 = EdgeInsets.all(space24);

  static const EdgeInsets horizontal8 = EdgeInsets.symmetric(horizontal: space8);
  static const EdgeInsets horizontal16 = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets horizontal24 = EdgeInsets.symmetric(horizontal: space24);

  static const EdgeInsets vertical4 = EdgeInsets.symmetric(vertical: space4);
  static const EdgeInsets vertical8 = EdgeInsets.symmetric(vertical: space8);
  static const EdgeInsets vertical16 = EdgeInsets.symmetric(vertical: space16);
}

/// Strict 4/8/12 radius tokens (no soft-SaaS 16-24 radii)
class AarogyaRadiusTokens {
  AarogyaRadiusTokens._();

  static const double r4 = 4.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;

  static final BorderRadius radius4 = BorderRadius.circular(r4);
  static final BorderRadius radius8 = BorderRadius.circular(r8);
  static final BorderRadius radius12 = BorderRadius.circular(r12);
}

/// 9-Step Neutral Grayscale
class AarogyaNeutralScale {
  final Color gray50;
  final Color gray100;
  final Color gray200;
  final Color gray300;
  final Color gray400;
  final Color gray500;
  final Color gray600;
  final Color gray700;
  final Color gray800;
  final Color gray900;

  const AarogyaNeutralScale({
    required this.gray50,
    required this.gray100,
    required this.gray200,
    required this.gray300,
    required this.gray400,
    required this.gray500,
    required this.gray600,
    required this.gray700,
    required this.gray800,
    required this.gray900,
  });

  static AarogyaNeutralScale lerp(
    AarogyaNeutralScale a,
    AarogyaNeutralScale b,
    double t,
  ) {
    return AarogyaNeutralScale(
      gray50: Color.lerp(a.gray50, b.gray50, t)!,
      gray100: Color.lerp(a.gray100, b.gray100, t)!,
      gray200: Color.lerp(a.gray200, b.gray200, t)!,
      gray300: Color.lerp(a.gray300, b.gray300, t)!,
      gray400: Color.lerp(a.gray400, b.gray400, t)!,
      gray500: Color.lerp(a.gray500, b.gray500, t)!,
      gray600: Color.lerp(a.gray600, b.gray600, t)!,
      gray700: Color.lerp(a.gray700, b.gray700, t)!,
      gray800: Color.lerp(a.gray800, b.gray800, t)!,
      gray900: Color.lerp(a.gray900, b.gray900, t)!,
    );
  }
}

/// Color tokens as ThemeExtension
@immutable
class AarogyaColorTokens extends ThemeExtension<AarogyaColorTokens> {
  // One primary brand hue (desaturated, clinical precision, not neon)
  final Color primary;
  final Color onPrimary;

  // One accent reserved ONLY for the single most critical action per screen
  final Color accentAction;
  final Color onAccentAction;

  // 9-step neutral grayscale
  final AarogyaNeutralScale neutrals;

  // Semantic clinical-state colors (distinct from generic Material colors)
  final Color clinicalStable; // e.g. normal range vitals, confirmed tests
  final Color clinicalStableSubtle;
  final Color clinicalWarning; // borderline vitals, pending, awaiting review
  final Color clinicalWarningSubtle;
  final Color clinicalCritical; // abnormal / out of range vitals, emergency
  final Color clinicalCriticalSubtle;

  // Exactly 2 elevation tiers: Informational vs Actionable
  final Color surfaceInformational; // Flat surface, 1px hairline border, no shadow
  final Color surfaceActionable; // Subtle raised state via 1-2% background tint shift
  final Color borderHairline; // 1px hairline border
  final Color borderStrong; // Stronger delimiter

  // Scaffold background
  final Color scaffoldBg;

  const AarogyaColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.accentAction,
    required this.onAccentAction,
    required this.neutrals,
    required this.clinicalStable,
    required this.clinicalStableSubtle,
    required this.clinicalWarning,
    required this.clinicalWarningSubtle,
    required this.clinicalCritical,
    required this.clinicalCriticalSubtle,
    required this.surfaceInformational,
    required this.surfaceActionable,
    required this.borderHairline,
    required this.borderStrong,
    required this.scaffoldBg,
  });

  /// Light Theme Token Definition
  static const AarogyaColorTokens light = AarogyaColorTokens(
    primary: Color(0xFF0E7490), // Desaturated clinical cyan-teal (deep)
    onPrimary: Color(0xFFFFFFFF),
    accentAction: Color(0xFF1D4ED8), // Precision Cobalt for the single primary CTA
    onAccentAction: Color(0xFFFFFFFF),
    neutrals: AarogyaNeutralScale(
      gray50: Color(0xFFF8FAFC),
      gray100: Color(0xFFF1F5F9),
      gray200: Color(0xFFE2E8F0),
      gray300: Color(0xFFCBD5E1),
      gray400: Color(0xFF94A3B8),
      gray500: Color(0xFF64748B),
      gray600: Color(0xFF475569),
      gray700: Color(0xFF334155),
      gray800: Color(0xFF1E293B),
      gray900: Color(0xFF0F172A),
    ),
    clinicalStable: Color(0xFF047857), // Deep clinical emerald (stable)
    clinicalStableSubtle: Color(0xFFECFDF5),
    clinicalWarning: Color(0xFFB45309), // Clinical amber/ochre (borderline)
    clinicalWarningSubtle: Color(0xFFFFFBEB),
    clinicalCritical: Color(0xFFB91C1C), // Clinical crimson (critical)
    clinicalCriticalSubtle: Color(0xFFFEF2F2),
    surfaceInformational: Color(0xFFFFFFFF), // Flat clean surface
    surfaceActionable: Color(0xFFF8FAFC), // 1.5% tint shift for tactile feedback
    borderHairline: Color(0xFFE2E8F0), // 1px hairline border
    borderStrong: Color(0xFFCBD5E1),
    scaffoldBg: Color(0xFFF8FAFC),
  );

  /// Dark Theme Token Definition (Obsidian Clinical Surface)
  static const AarogyaColorTokens dark = AarogyaColorTokens(
    primary: Color(0xFF22D3EE), // Desaturated luminous cyan-teal
    onPrimary: Color(0xFF080C14),
    accentAction: Color(0xFF3B82F6), // Precision Cobalt Action Accent
    onAccentAction: Color(0xFFFFFFFF),
    neutrals: AarogyaNeutralScale(
      gray50: Color(0xFF080C14),
      gray100: Color(0xFF0D1524),
      gray200: Color(0xFF141E32),
      gray300: Color(0xFF1E2B45),
      gray400: Color(0xFF334460),
      gray500: Color(0xFF64748B),
      gray600: Color(0xFF94A3B8),
      gray700: Color(0xFFCBD5E1),
      gray800: Color(0xFFE2E8F0),
      gray900: Color(0xFFF8FAFC),
    ),
    clinicalStable: Color(0xFF10B981), // Diagnostic Emerald
    clinicalStableSubtle: Color(0x1F10B981),
    clinicalWarning: Color(0xFFF59E0B), // Diagnostic Amber
    clinicalWarningSubtle: Color(0x1FF59E0B),
    clinicalCritical: Color(0xFFEF4444), // Diagnostic Crimson
    clinicalCriticalSubtle: Color(0x1FEF4444),
    surfaceInformational: Color(0xFF0D1524), // Flat instrument pane
    surfaceActionable: Color(0xFF141E32), // Raised via subtle 2% background shift
    borderHairline: Color(0xFF1E2B45), // 1px hairline delimiter
    borderStrong: Color(0xFF334460),
    scaffoldBg: Color(0xFF080C14),
  );

  @override
  AarogyaColorTokens copyWith({
    Color? primary,
    Color? onPrimary,
    Color? accentAction,
    Color? onAccentAction,
    AarogyaNeutralScale? neutrals,
    Color? clinicalStable,
    Color? clinicalStableSubtle,
    Color? clinicalWarning,
    Color? clinicalWarningSubtle,
    Color? clinicalCritical,
    Color? clinicalCriticalSubtle,
    Color? surfaceInformational,
    Color? surfaceActionable,
    Color? borderHairline,
    Color? borderStrong,
    Color? scaffoldBg,
  }) {
    return AarogyaColorTokens(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      accentAction: accentAction ?? this.accentAction,
      onAccentAction: onAccentAction ?? this.onAccentAction,
      neutrals: neutrals ?? this.neutrals,
      clinicalStable: clinicalStable ?? this.clinicalStable,
      clinicalStableSubtle: clinicalStableSubtle ?? this.clinicalStableSubtle,
      clinicalWarning: clinicalWarning ?? this.clinicalWarning,
      clinicalWarningSubtle: clinicalWarningSubtle ?? this.clinicalWarningSubtle,
      clinicalCritical: clinicalCritical ?? this.clinicalCritical,
      clinicalCriticalSubtle:
          clinicalCriticalSubtle ?? this.clinicalCriticalSubtle,
      surfaceInformational: surfaceInformational ?? this.surfaceInformational,
      surfaceActionable: surfaceActionable ?? this.surfaceActionable,
      borderHairline: borderHairline ?? this.borderHairline,
      borderStrong: borderStrong ?? this.borderStrong,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
    );
  }

  @override
  AarogyaColorTokens lerp(ThemeExtension<AarogyaColorTokens>? other, double t) {
    if (other is! AarogyaColorTokens) return this;
    return AarogyaColorTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      accentAction: Color.lerp(accentAction, other.accentAction, t)!,
      onAccentAction: Color.lerp(onAccentAction, other.onAccentAction, t)!,
      neutrals: AarogyaNeutralScale.lerp(neutrals, other.neutrals, t),
      clinicalStable: Color.lerp(clinicalStable, other.clinicalStable, t)!,
      clinicalStableSubtle:
          Color.lerp(clinicalStableSubtle, other.clinicalStableSubtle, t)!,
      clinicalWarning: Color.lerp(clinicalWarning, other.clinicalWarning, t)!,
      clinicalWarningSubtle:
          Color.lerp(clinicalWarningSubtle, other.clinicalWarningSubtle, t)!,
      clinicalCritical: Color.lerp(clinicalCritical, other.clinicalCritical, t)!,
      clinicalCriticalSubtle:
          Color.lerp(clinicalCriticalSubtle, other.clinicalCriticalSubtle, t)!,
      surfaceInformational:
          Color.lerp(surfaceInformational, other.surfaceInformational, t)!,
      surfaceActionable:
          Color.lerp(surfaceActionable, other.surfaceActionable, t)!,
      borderHairline: Color.lerp(borderHairline, other.borderHairline, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
    );
  }
}

/// Strict 5-Step Typography Scale as ThemeExtension
/// display -> title -> subtitle -> body -> caption
@immutable
class AarogyaTypographyTokens extends ThemeExtension<AarogyaTypographyTokens> {
  // 1. Display: For hero numbers like vitals, BP, lab figures (tabular, bold)
  final TextStyle display;

  // 2. Title: Section headers & screen identifiers
  final TextStyle title;

  // 3. Subtitle: Component headers & clinical card titles
  final TextStyle subtitle;

  // 4. Body: Descriptions, doctor bios, medication instructions
  final TextStyle body;

  // 5. Caption: Micro-telemetry, units, reference range boundaries, timestamps
  final TextStyle caption;

  const AarogyaTypographyTokens({
    required this.display,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.caption,
  });

  /// Generate typography for light theme
  static AarogyaTypographyTokens light(AarogyaColorTokens colors) {
    return AarogyaTypographyTokens(
      display: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: colors.neutrals.gray900,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      title: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
        color: colors.neutrals.gray900,
      ),
      subtitle: GoogleFonts.poppins(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: colors.neutrals.gray800,
      ),
      body: GoogleFonts.poppins(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.45,
        color: colors.neutrals.gray600,
      ),
      caption: GoogleFonts.poppins(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.3,
        color: colors.neutrals.gray500,
      ),
    );
  }

  /// Generate typography for dark theme
  static AarogyaTypographyTokens dark(AarogyaColorTokens colors) {
    return AarogyaTypographyTokens(
      display: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: colors.neutrals.gray900,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      title: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
        color: colors.neutrals.gray900,
      ),
      subtitle: GoogleFonts.poppins(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.35,
        color: colors.neutrals.gray800,
      ),
      body: GoogleFonts.poppins(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.45,
        color: colors.neutrals.gray600,
      ),
      caption: GoogleFonts.poppins(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.3,
        color: colors.neutrals.gray500,
      ),
    );
  }

  @override
  AarogyaTypographyTokens copyWith({
    TextStyle? display,
    TextStyle? title,
    TextStyle? subtitle,
    TextStyle? body,
    TextStyle? caption,
  }) {
    return AarogyaTypographyTokens(
      display: display ?? this.display,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      caption: caption ?? this.caption,
    );
  }

  @override
  AarogyaTypographyTokens lerp(
    ThemeExtension<AarogyaTypographyTokens>? other,
    double t,
  ) {
    if (other is! AarogyaTypographyTokens) return this;
    return AarogyaTypographyTokens(
      display: TextStyle.lerp(display, other.display, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      subtitle: TextStyle.lerp(subtitle, other.subtitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}

/// Convenient BuildContext extensions
extension AarogyaThemeExtension on BuildContext {
  AarogyaColorTokens get aarogyaColors =>
      Theme.of(this).extension<AarogyaColorTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AarogyaColorTokens.dark
          : AarogyaColorTokens.light);

  AarogyaTypographyTokens get aarogyaTypography =>
      Theme.of(this).extension<AarogyaTypographyTokens>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AarogyaTypographyTokens.dark(AarogyaColorTokens.dark)
          : AarogyaTypographyTokens.light(AarogyaColorTokens.light));

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
