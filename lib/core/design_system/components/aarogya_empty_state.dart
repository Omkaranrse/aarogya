import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aarogya_button.dart';

class AarogyaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AarogyaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    return Center(
      child: Padding(
        padding: AarogyaSpacing.paddingXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue).withOpacity(0.1),
                border: Border.all(
                  color: (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue).withOpacity(0.25),
                ),
              ),
              child: Icon(
                icon,
                size: 38,
                color: isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AarogyaSpacing.lg),
            Text(
              title,
              style: AarogyaTypography.headingMedium(primaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AarogyaSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                description,
                style: AarogyaTypography.bodyMedium(secondaryText),
                textAlign: TextAlign.center,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AarogyaSpacing.lg),
              AarogyaButton(
                label: actionLabel!,
                onPressed: onAction,
                size: AarogyaButtonSize.sm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
