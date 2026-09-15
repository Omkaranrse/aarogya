import 'package:flutter/material.dart';
import '../glass/glass_card.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
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
    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final isPositive = (trendPercent ?? 0) >= 0;
    final isGood = isPositive == isIncreasePositive;
    final trendColor = isGood ? AarogyaColors.success : AarogyaColors.critical;

    return GlassCard(
      glowColor: accentColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AarogyaTypography.label(secondaryText),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: accentColor,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AarogyaTypography.headingLarge(primaryText).copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Row(
            children: [
              if (trendPercent != null) ...[
                Icon(
                  isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 14,
                  color: trendColor,
                ),
                const SizedBox(width: 2),
                Text(
                  '${isPositive ? '+' : ''}${trendPercent!.toStringAsFixed(1)}%',
                  style: AarogyaTypography.caption(trendColor).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
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
      ),
    );
  }
}
