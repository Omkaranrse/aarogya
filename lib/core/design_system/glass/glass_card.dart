import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'glass_container.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? glowColor;
  final bool enableHover;
  final Border? customBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.glowColor,
    this.enableHover = true,
    this.customBorder,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = widget.borderRadius ?? AarogyaRadius.radiusLg;
    final activeGlow = widget.glowColor ?? AarogyaColors.primaryCyan;

    final border = widget.customBorder ??
        Border.all(
          color: _isHovered
              ? activeGlow.withOpacity(0.5)
              : (isDark
                  ? AarogyaColors.darkGlassBorderSubtle
                  : AarogyaColors.lightGlassBorderSubtle),
          width: _isHovered ? 1.5 : 1.0,
        );

    final shadows = [
      BoxShadow(
        color: _isHovered
            ? activeGlow.withOpacity(isDark ? 0.25 : 0.15)
            : (isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.blueGrey.withOpacity(0.06)),
        blurRadius: _isHovered ? 24 : 16,
        offset: Offset(0, _isHovered ? 6 : 8),
      ),
    ];

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      transform: _isHovered && widget.enableHover
          ? (Matrix4.identity()..translate(0, -3, 0))
          : Matrix4.identity(),
      child: GlassContainer(
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? AarogyaSpacing.paddingLg,
        margin: widget.margin,
        borderRadius: radius,
        border: border,
        shadows: shadows,
        child: widget.child,
      ),
    );

    if (widget.onTap != null || widget.enableHover) {
      content = MouseRegion(
        cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (widget.enableHover) setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (widget.enableHover) setState(() => _isHovered = false);
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
