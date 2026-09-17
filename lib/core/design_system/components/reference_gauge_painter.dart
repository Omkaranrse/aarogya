import 'package:flutter/material.dart';

/// Custom Painter for clinical reference ranges.
/// Visualizes Low, Normal (Safe Zone), and High bands with threshold ticks,
/// an active value needle/pin, and overflow caret indicator.
class ReferenceGaugePainter extends CustomPainter {
  final double value;
  final double minRange;
  final double maxRange;
  final Color lowColor;
  final Color normalColor;
  final Color highColor;
  final Color pinColor;
  final bool isLow;
  final bool isNormal;
  final bool isHigh;
  final bool isOverflow;
  final double animationProgress; // 0.0 to 1.0

  const ReferenceGaugePainter({
    required this.value,
    required this.minRange,
    required this.maxRange,
    required this.lowColor,
    required this.normalColor,
    required this.highColor,
    required this.pinColor,
    required this.isLow,
    required this.isNormal,
    required this.isHigh,
    this.isOverflow = false,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final trackHeight = size.height;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, trackHeight),
      const Radius.circular(4),
    );

    // Clinical non-linear coordinate mapping:
    // We allocate 25% of bar to Low band, 50% to Normal safe zone, 25% to High band.
    final lowBandWidth = size.width * 0.25;
    final normalBandWidth = size.width * 0.50;
    final highBandWidth = size.width * 0.25;

    final normalStart = lowBandWidth;
    final normalEnd = normalStart + normalBandWidth;

    // Calculate normalized pin position based on clinical piecewise projection
    double targetX;
    if (value < minRange) {
      // In low band: 0 to normalStart
      final span = minRange <= 0 ? 1.0 : minRange;
      final ratio = (value / span).clamp(0.0, 1.0);
      targetX = ratio * normalStart;
    } else if (value <= maxRange) {
      // In normal safe zone: normalStart to normalEnd
      final span = (maxRange - minRange).abs();
      final safeSpan = span == 0 ? 1.0 : span;
      final ratio = ((value - minRange) / safeSpan).clamp(0.0, 1.0);
      targetX = normalStart + ratio * normalBandWidth;
    } else {
      // In high band: normalEnd to width
      final excessSpan = (maxRange * 0.5).clamp(1.0, double.infinity);
      final ratio = ((value - maxRange) / excessSpan).clamp(0.0, 1.0);
      targetX = normalEnd + ratio * highBandWidth;
    }

    final currentX = (targetX * animationProgress).clamp(4.0, size.width - 4.0);

    // Save layer for track clipping
    canvas.save();
    canvas.clipRRect(rrect);

    final trackPaint = Paint()..style = PaintingStyle.fill;

    // 1. Low zone
    trackPaint.color = isLow
        ? lowColor.withValues(alpha: 0.85)
        : lowColor.withValues(alpha: 0.22);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, lowBandWidth, trackHeight),
      trackPaint,
    );

    // 2. Normal zone
    trackPaint.color = isNormal
        ? normalColor.withValues(alpha: 0.85)
        : normalColor.withValues(alpha: 0.35);
    canvas.drawRect(
      Rect.fromLTWH(normalStart, 0, normalBandWidth, trackHeight),
      trackPaint,
    );

    // 3. High zone
    trackPaint.color = isHigh
        ? highColor.withValues(alpha: 0.85)
        : highColor.withValues(alpha: 0.22);
    canvas.drawRect(
      Rect.fromLTWH(normalEnd, 0, highBandWidth, trackHeight),
      trackPaint,
    );

    // Zone divider tick lines
    final tickPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(normalStart, 0),
      Offset(normalStart, trackHeight),
      tickPaint,
    );
    canvas.drawLine(
      Offset(normalEnd, 0),
      Offset(normalEnd, trackHeight),
      tickPaint,
    );

    canvas.restore();

    // 4. Overflow Caret Indicator (if value exceeds far edge)
    if (isOverflow) {
      final caretPaint = Paint()
        ..color = highColor
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(size.width + 1, trackHeight / 2 - 4)
        ..lineTo(size.width + 7, trackHeight / 2)
        ..lineTo(size.width + 1, trackHeight / 2 + 4)
        ..close();
      canvas.drawPath(path, caretPaint);
    }

    // 5. Active Marker Pin
    final pinCenter = Offset(currentX, trackHeight / 2);
    final glowPaint = Paint()
      ..color = pinColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(pinCenter, 7, glowPaint);

    final outerPinPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 6, outerPinPaint);

    final innerPinPaint = Paint()
      ..color = pinColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 4.5, innerPinPaint);

    final centerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 1.5, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant ReferenceGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.minRange != minRange ||
        oldDelegate.maxRange != maxRange ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.pinColor != pinColor ||
        oldDelegate.isOverflow != isOverflow;
  }
}
