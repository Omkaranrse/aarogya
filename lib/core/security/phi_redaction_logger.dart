import 'package:flutter/foundation.dart';

/// Clinical Logger Filter that automatically redacts Protected Health Information (PHI)
/// in compliance with the Digital Personal Data Protection (DPDP) Act 2023.
class ClinicalLogger {
  static final RegExp _abhaNumberRegex = RegExp(r'\b\d{2}-\d{4}-\d{4}-\d{4}\b');
  static final RegExp _abhaAddressRegex = RegExp(r'\b[\w.]+@(abdm|aarogya|sbx|sbxabdm)\b', caseSensitive: false);
  static final RegExp _phoneWithCountryRegex = RegExp(r'\+91[\-\s]?[6-9]\d{9}\b');
  static final RegExp _phoneLocalRegex = RegExp(r'\b0?[6-9]\d{9}\b');
  static final RegExp _aadhaarRegex = RegExp(r'\b\d{4}\s\d{4}\s\d{4}\b');
  static final RegExp _emailRegex = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b');
  static final RegExp _mrnRegex = RegExp(r'\b(?:MRN|UHID)[-:\s]*[A-Z0-9-]+\b', caseSensitive: false);

  /// Sanitize a string by stripping all recognizable PHI patterns.
  static String redact(String input) {
    var sanitized = input;
    sanitized = sanitized.replaceAllMapped(_abhaNumberRegex, (_) => '[REDACTED_ABHA]');
    sanitized = sanitized.replaceAllMapped(_abhaAddressRegex, (_) => '[REDACTED_ABHA_ADDR]');
    sanitized = sanitized.replaceAllMapped(_phoneWithCountryRegex, (_) => '[REDACTED_PHONE]');
    sanitized = sanitized.replaceAllMapped(_phoneLocalRegex, (_) => '[REDACTED_PHONE]');
    sanitized = sanitized.replaceAllMapped(_aadhaarRegex, (_) => '[REDACTED_AADHAAR]');
    sanitized = sanitized.replaceAllMapped(_emailRegex, (_) => '[REDACTED_EMAIL]');
    sanitized = sanitized.replaceAllMapped(_mrnRegex, (_) => '[REDACTED_MRN]');
    return sanitized;
  }

  /// Safe logging method that ensures all output is sanitized before printing to debug console.
  static void log(String message, {String tag = 'AarogyaClinical'}) {
    final clean = redact(message);
    debugPrint('[$tag] $clean');
  }

  /// Safe warning logger
  static void warn(String message, {String tag = 'AarogyaClinical'}) {
    final clean = redact(message);
    debugPrint('[$tag:WARN] $clean');
  }

  /// Safe error logger
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    final clean = redact(message);
    final errorClean = error != null ? redact(error.toString()) : null;
    debugPrint('[AarogyaClinical:ERROR] $clean ${errorClean ?? ""}');
  }
}
