import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../../theme/aarogya_theme_tokens.dart';

/// Clinical Reference Range Gauge Indicator.
/// Visualizes diagnostic values against low / normal / high reference thresholds
/// with an animated precision marker pin.
class RangeGaugeIndicator extends StatelessWidget {
  final String? label;
  final double value;
  final double minRange;
  final double maxRange;
  final String unit;
  final String? statusLabel;
  final bool showHeader;
  final bool showBandLabels;

  const RangeGaugeIndicator({
    super.key,
    this.label,
    required this.value,
    required this.minRange,
    required this.maxRange,
    this.unit = '',
    this.statusLabel,
    this.showHeader = true,
    this.showBandLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;

    final isLow = value < minRange;
    final isHigh = value > maxRange;
    final isNormal = !isLow && !isHigh;

    final Color statusColor = isNormal
        ? colors.clinicalStable
        : (isLow ? colors.clinicalWarning : colors.clinicalCritical);

    final span = (maxRange - minRange).abs();
    final safeSpan = span == 0 ? 1.0 : span;
    final displayMin = (minRange - safeSpan * 0.4).clamp(0.0, double.infinity);
    final displayMax = maxRange + safeSpan * 0.4;
    final totalSpan = (displayMax - displayMin).abs();
    final safeTotalSpan = totalSpan == 0 ? 1.0 : totalSpan;

    final normalStartRatio =
        ((minRange - displayMin) / safeTotalSpan).clamp(0.0, 1.0);
    final normalEndRatio =
        ((maxRange - displayMin) / safeTotalSpan).clamp(0.0, 1.0);
    final valueRatio =
        ((value - displayMin) / safeTotalSpan).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (label != null)
                Expanded(
                  child: Text(
                    label!,
                    style: typography.subtitle.copyWith(
                      color: colors.neutrals.gray900,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    value % 1 == 0 ? value.toInt().toString() : value.toString(),
                    style: typography.subtitle.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 3),
                    Text(
                      unit,
                      style: typography.caption.copyWith(
                        color: colors.neutrals.gray500,
                      ),
                    ),
                  ],
                  if (statusLabel != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: AarogyaRadius.radius4,
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        statusLabel!,
                        style: typography.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // 3-Zone Graphical Reference Range Visualizer (Low / Normal / High Bars)
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final normalLeft = (normalStartRatio * width).clamp(0.0, width);
            final normalWidth =
                ((normalEndRatio - normalStartRatio) * width).clamp(8.0, width);
            final normalRight = (normalLeft + normalWidth).clamp(0.0, width);
            final lowWidth = normalLeft.clamp(0.0, width);
            final highWidth = (width - normalRight).clamp(0.0, width);

            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0.0, end: valueRatio),
              builder: (context, animValueRatio, _) {
                final markerPos =
                    (animValueRatio * width).clamp(6.0, width - 6.0);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Segmented Graphical Bars (Low / Normal / High)
                    ClipRRect(
                      borderRadius: AarogyaRadius.radius4,
                      child: SizedBox(
                        height: 8,
                        width: width,
                        child: Row(
                          children: [
                            // 1. Low Segment Bar
                            if (lowWidth > 0)
                              Container(
                                width: lowWidth,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isLow
                                      ? colors.clinicalWarning.withValues(alpha: 0.85)
                                      : colors.clinicalWarning.withValues(alpha: 0.22),
                                  border: Border(
                                    right: BorderSide(
                                      color: colors.neutrals.gray900.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            // 2. Normal Safe Zone Bar
                            Expanded(
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isNormal
                                      ? colors.clinicalStable.withValues(alpha: 0.85)
                                      : colors.clinicalStable.withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            // 3. High Segment Bar
                            if (highWidth > 0)
                              Container(
                                width: highWidth,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isHigh
                                      ? colors.clinicalCritical.withValues(alpha: 0.85)
                                      : colors.clinicalCritical.withValues(alpha: 0.22),
                                  border: Border(
                                    left: BorderSide(
                                      color: colors.neutrals.gray900.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Active Patient Value Pin with Glow
                    Positioned(
                      left: markerPos - 6,
                      top: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.55),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),

        if (showBandLabels) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Low Band Label
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.clinicalWarning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Low (<${_formatNum(minRange)})',
                    style: typography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: isLow ? FontWeight.w700 : FontWeight.w500,
                      color: isLow
                          ? colors.clinicalWarning
                          : colors.neutrals.gray500,
                    ),
                  ),
                ],
              ),
              // Normal Band Label
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colors.clinicalStable,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Normal (${_formatNum(minRange)} - ${_formatNum(maxRange)}${unit.isNotEmpty ? " $unit" : ""})',
                          style: typography.caption.copyWith(
                            fontSize: 10,
                            fontWeight: isNormal ? FontWeight.w700 : FontWeight.w500,
                            color: isNormal
                                ? colors.clinicalStable
                                : colors.neutrals.gray500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // High Band Label
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colors.clinicalCritical,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'High (>${_formatNum(maxRange)})',
                    style: typography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: isHigh ? FontWeight.w700 : FontWeight.w500,
                      color: isHigh
                          ? colors.clinicalCritical
                          : colors.neutrals.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatNum(double n) {
    if (n >= 100000) {
      final inK = n / 1000;
      return '${inK % 1 == 0 ? inK.toInt() : inK.toStringAsFixed(1)}k';
    }
    if (n % 1 == 0) return n.toInt().toString();
    return n.toString();
  }
}
