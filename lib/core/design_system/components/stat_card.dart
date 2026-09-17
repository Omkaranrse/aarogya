import 'package:flutter/material.dart';

import '../glass/glass_card.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/typography.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final double? trendPercent;
  final bool isIncreasePositive;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.accentColor = AarogyaColors.primaryCyan,
    this.trendPercent,
    this.isIncreasePositive = true,
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

    final isPositive = (trendPercent ?? 0) >= 0;
    final isGood = isPositive == isIncreasePositive;
    final trendColor = isGood ? AarogyaColors.success : AarogyaColors.critical;
    final hasBottomRow = trendPercent != null || subtitle != null;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isBounded = constraints.hasBoundedHeight;

          final valueWidget = FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AarogyaTypography.metricDisplay(primaryText).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AarogyaTypography.caption(secondaryText).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.12 : 0.1),
                      borderRadius: AarogyaRadius.radiusSm,
                      border: Border.all(
                        color: accentColor.withValues(
                          alpha: isDark ? 0.28 : 0.22,
                        ),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(icon, size: 14, color: accentColor),
                  ),
                ],
              ),
              if (isBounded)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: valueWidget,
                  ),
                )
              else ...[
                const SizedBox(height: 6),
                valueWidget,
                if (hasBottomRow) const SizedBox(height: 6),
              ],
              if (hasBottomRow)
                Row(
                  children: [
                    if (trendPercent != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: trendColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: trendColor.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 11,
                              color: trendColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${isPositive ? '+' : ''}${trendPercent!.toStringAsFixed(1)}%',
                              style: AarogyaTypography.caption(trendColor)
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle!,
                          style: AarogyaTypography.caption(secondaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
