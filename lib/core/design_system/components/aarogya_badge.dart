import 'package:flutter/material.dart';

import '../tokens/colors.dart';

/// Distinct badge variants for clinical acuity, status and category labeling.
enum AarogyaBadgeVariant {
  success,
  warning,
  critical,
  info,
  neutral,
  cyan,
  purple,
}

/// A sleek, high-contrast, glassmorphic badge chip used across patient,
/// doctor, and administrative portals.
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

  Color _getColor() {
    switch (variant) {
      case AarogyaBadgeVariant.success:
        return AarogyaColors.success;
      case AarogyaBadgeVariant.warning:
        return AarogyaColors.warning;
      case AarogyaBadgeVariant.critical:
        return AarogyaColors.critical;
      case AarogyaBadgeVariant.info:
        return AarogyaColors.info;
      case AarogyaBadgeVariant.neutral:
        return AarogyaColors.neutral;
      case AarogyaBadgeVariant.cyan:
        return AarogyaColors.primaryCyan;
      case AarogyaBadgeVariant.purple:
        return AarogyaColors.accentPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.38 : 0.28),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ] else if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 3,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4.5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
