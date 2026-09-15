import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum AarogyaBadgeVariant {
  success,
  warning,
  critical,
  info,
  neutral,
  cyan,
  purple,
}

class AarogyaBadge extends StatelessWidget {
  final String label;
  final AarogyaBadgeVariant variant;
  final bool showDot;
  final IconData? icon;

  const AarogyaBadge({
    super.key,
    required this.label,
    this.variant = AarogyaBadgeVariant.info,
    this.showDot = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor;

    switch (variant) {
      case AarogyaBadgeVariant.success:
        baseColor = AarogyaColors.success;
        break;
      case AarogyaBadgeVariant.warning:
        baseColor = AarogyaColors.warning;
        break;
      case AarogyaBadgeVariant.critical:
        baseColor = AarogyaColors.critical;
        break;
      case AarogyaBadgeVariant.cyan:
        baseColor = AarogyaColors.primaryCyan;
        break;
      case AarogyaBadgeVariant.purple:
        baseColor = AarogyaColors.accentPurple;
        break;
      case AarogyaBadgeVariant.neutral:
        baseColor = AarogyaColors.neutral;
        break;
      case AarogyaBadgeVariant.info:
      default:
        baseColor = AarogyaColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AarogyaSpacing.sm + 2,
        vertical: AarogyaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.12),
        borderRadius: AarogyaRadius.radiusPill,
        border: Border.all(
          color: baseColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withOpacity(0.8),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AarogyaSpacing.xs + 2),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: baseColor),
            const SizedBox(width: AarogyaSpacing.xs),
          ],
          Text(
            label,
            style: AarogyaTypography.caption(baseColor).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
