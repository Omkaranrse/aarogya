import 'package:flutter/material.dart';

class AarogyaRadius {
  AarogyaRadius._();

  // Strict 8pt Grid radius tokens: 4 / 8 / 12 only
  static const double r4 = 4.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;

  // Legacy mappings pegged to strict 4/8/12 tokens
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 12.0;
  static const double xl = 12.0;
  static const double xxl = 12.0;
  static const double pill = 999.0;

  static BorderRadius get radius4 => BorderRadius.circular(r4);
  static BorderRadius get radius8 => BorderRadius.circular(r8);
  static BorderRadius get radius12 => BorderRadius.circular(r12);

  static BorderRadius get radiusXs => BorderRadius.circular(xs);
  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusXxl => BorderRadius.circular(xxl);
  static BorderRadius get radiusPill => BorderRadius.circular(pill);
}
