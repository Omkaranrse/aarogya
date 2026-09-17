import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../../theme/aarogya_theme_tokens.dart';

enum MetricCardTier { primary, secondary }

enum MetricClinicalStatus { stable, warning, critical, normal }

/// Clinical-grade telemetry MetricCard with Primary (display-scale + pulse waveform)
/// and Secondary (compact) tiers.
class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String? delta;
  final MetricClinicalStatus status;
  final MetricCardTier tier;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.delta,
    this.status = MetricClinicalStatus.normal,
    this.tier = MetricCardTier.primary,
    this.onTap,
  });

  Color _getStatusColor(AarogyaColorTokens colors) {
    switch (status) {
      case MetricClinicalStatus.critical:
        return colors.clinicalCritical;
      case MetricClinicalStatus.warning:
        return colors.clinicalWarning;
      case MetricClinicalStatus.stable:
      case MetricClinicalStatus.normal:
        return colors.clinicalStable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;
    final statusColor = _getStatusColor(colors);

    return InkWell(
      onTap: onTap,
      borderRadius: AarogyaRadius.radius12,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceInformational,
          borderRadius: AarogyaRadius.radius12,
          border: Border.all(
            color: colors.borderHairline,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: tier == MetricCardTier.primary
            ? _buildPrimaryTier(context, colors, typography, statusColor)
            : _buildSecondaryTier(context, colors, typography, statusColor),
      ),
    );
  }

  Widget _buildPrimaryTier(
    BuildContext context,
    AarogyaColorTokens colors,
    AarogyaTypographyTokens typography,
    Color statusColor,
  ) {
    return Stack(
      children: [
        // Integrated micro-visualization: Subtle clinical waveform/pulse behind the value
        Positioned.fill(
          child: CustomPaint(
            painter: _PulseWaveformPainter(
              waveColor: statusColor.withValues(alpha: 0.10),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top row: Label + Telemetry Status dot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: typography.caption.copyWith(
                      letterSpacing: 0.8,
                      color: colors.neutrals.gray500,
                    ),
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Hero Display Value + Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: typography.display.copyWith(
                      color: colors.neutrals.gray900,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: typography.caption.copyWith(
                        color: colors.neutrals.gray500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Delta / Reference Info
              if (delta != null)
                Text(
                  delta!,
                  style: typography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryTier(
    BuildContext context,
    AarogyaColorTokens colors,
    AarogyaTypographyTokens typography,
    Color statusColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: typography.caption.copyWith(
                    fontSize: 10.0,
                    letterSpacing: 0.6,
                    color: colors.neutrals.gray500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: typography.subtitle.copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontWeight: FontWeight.w700,
                        color: colors.neutrals.gray900,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 3),
                      Text(
                        unit,
                        style: typography.caption.copyWith(
                          fontSize: 10.0,
                          color: colors.neutrals.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: AarogyaRadius.radius4,
              color: statusColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for subtle clinical rhythm waveform behind hero numbers
class _PulseWaveformPainter extends CustomPainter {
  final Color waveColor;

  _PulseWaveformPainter({required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final h = size.height;
    final w = size.width;
    final midY = h * 0.68;

    path.moveTo(0, midY);
    path.lineTo(w * 0.28, midY);
    // P wave
    path.quadraticBezierTo(w * 0.32, midY - 6, w * 0.36, midY);
    path.lineTo(w * 0.42, midY);
    // Q wave
    path.lineTo(w * 0.45, midY + 4);
    // R peak
    path.lineTo(w * 0.52, midY - 26);
    // S drop
    path.lineTo(w * 0.58, midY + 12);
    // baseline
    path.lineTo(w * 0.64, midY);
    // T wave
    path.quadraticBezierTo(w * 0.72, midY - 10, w * 0.80, midY);
    path.lineTo(w, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseWaveformPainter oldDelegate) =>
      oldDelegate.waveColor != waveColor;
}
