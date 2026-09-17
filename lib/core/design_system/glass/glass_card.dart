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
  final Color? backgroundColor;

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
    this.backgroundColor,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = widget.borderRadius ?? AarogyaRadius.radiusLg;
    final hasCustomGlow = widget.glowColor != null;
    final activeGlow = widget.glowColor;

    final border =
        widget.customBorder ??
        Border.all(
          color: _isHovered
              ? (hasCustomGlow
                    ? activeGlow!.withValues(alpha: 0.45)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.22)
                          : Colors.black.withValues(alpha: 0.16)))
              : (hasCustomGlow
                    ? activeGlow!.withValues(alpha: isDark ? 0.22 : 0.18)
                    : (isDark
                          ? AarogyaColors.darkGlassBorderSubtle
                          : AarogyaColors.lightGlassBorderSubtle)),
          width: 1.0,
        );

    final shadows = [
      BoxShadow(
        color: hasCustomGlow && _isHovered
            ? activeGlow!.withValues(alpha: isDark ? 0.22 : 0.12)
            : (isDark
                  ? Colors.black.withValues(alpha: _isHovered ? 0.4 : 0.22)
                  : Colors.blueGrey.withValues(
                      alpha: _isHovered ? 0.12 : 0.05,
                    )),
        blurRadius: _isHovered ? 16 : 8,
        offset: Offset(0, _isHovered ? 4 : 2),
      ),
    ];

    Widget content = AnimatedScale(
      scale: _isPressed && widget.onTap != null ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutQuad,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: _isHovered && widget.enableHover && !_isPressed
            ? Matrix4.translationValues(0.0, -2.5, 0.0)
            : Matrix4.identity(),
        child: GlassContainer(
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? AarogyaSpacing.paddingLg,
          margin: widget.margin,
          borderRadius: radius,
          backgroundColor: widget.backgroundColor,
          border: border,
          shadows: shadows,
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null || widget.enableHover) {
      content = MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) {
          if (widget.enableHover && mounted) setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (widget.enableHover && mounted) setState(() => _isHovered = false);
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: widget.onTap != null
              ? (_) => setState(() => _isPressed = true)
              : null,
          onTapUp: widget.onTap != null
              ? (_) => setState(() => _isPressed = false)
              : null,
          onTapCancel: widget.onTap != null
              ? () => setState(() => _isPressed = false)
              : null,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return content;
  }
}
