import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aarogya_button.dart';

class AarogyaErrorState extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;

  const AarogyaErrorState({
    super.key,
    this.title,
    this.message = 'Unable to connect to medical records service. Please check your network and try again.',
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
        padding: AarogyaSpacing.paddingXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AarogyaColors.critical.withValues(alpha: 0.12),
                border: Border.all(
                  color: AarogyaColors.critical.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AarogyaColors.critical,
              ),
            ),
            const SizedBox(height: AarogyaSpacing.lg),
            Text(
              title ?? 'Something Went Wrong',
              style: AarogyaTypography.headingMedium(primaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AarogyaSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                message,
                style: AarogyaTypography.bodyMedium(secondaryText),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AarogyaSpacing.lg),
              AarogyaButton(
                label: 'Try Again',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                size: AarogyaButtonSize.sm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
