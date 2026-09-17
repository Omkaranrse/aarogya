import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/typography.dart';
import 'aarogya_button.dart';

class PatientMismatchErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const PatientMismatchErrorView({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1014) : const Color(0xFFFFF1F2),
              borderRadius: AarogyaRadius.radius12,
              border: Border.all(
                color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Color(0xFFE11D48),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Patient Identity Security Alert',
                  style: AarogyaTypography.headingMedium(primaryText).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ??
                      'A clinical record mismatch was intercepted. The record subject does not match your active patient session. To protect protected health information (PHI), clinical access is blocked.',
                  style: AarogyaTypography.bodyMedium(secondaryText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (onRetry != null)
                  AarogyaButton(
                    label: 'Re-authenticate Session',
                    icon: Icons.refresh_rounded,
                    variant: AarogyaButtonVariant.primary,
                    onPressed: onRetry,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
