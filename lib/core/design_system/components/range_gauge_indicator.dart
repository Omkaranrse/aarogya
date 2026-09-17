import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../../theme/aarogya_theme_tokens.dart';
import 'reference_gauge_painter.dart';

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

        // Semantics-wrapped 3-Zone Graphical Reference Range Visualizer
        Semantics(
          label:
              '${label ?? "Diagnostic measurement"}, ${_formatNum(value)} $unit, ${isNormal ? "normal" : (isLow ? "low" : "high")}, reference range ${_formatNum(minRange)} to ${_formatNum(maxRange)}',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isOverflow = maxRange > 0 && value > (maxRange * 1.35);

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, animProgress, _) {
                  return CustomPaint(
                    size: Size(width, 8),
                    painter: ReferenceGaugePainter(
                      value: value,
                      minRange: minRange,
                      maxRange: maxRange,
                      lowColor: colors.clinicalWarning,
                      normalColor: colors.clinicalStable,
                      highColor: colors.clinicalCritical,
                      pinColor: statusColor,
                      isLow: isLow,
                      isNormal: isNormal,
                      isHigh: isHigh,
                      isOverflow: isOverflow,
                      animationProgress: animProgress,
                    ),
                  );
                },
              );
            },
          ),
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
