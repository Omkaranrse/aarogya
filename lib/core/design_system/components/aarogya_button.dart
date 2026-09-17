import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../../theme/aarogya_theme_tokens.dart';

enum AarogyaButtonVariant { primary, secondary, outline, ghost, destructive }

enum AarogyaButtonSize { sm, md, lg }

/// Precision Clinical CTA Button.
/// Single unified CTA style used app-wide with primary and secondary/destructive variants.
/// Follows strict 2-tier elevation, radius 8, and no ad-hoc neon glow.
class AarogyaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AarogyaButtonVariant variant;
  final AarogyaButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final bool fullWidth;

  const AarogyaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AarogyaButtonVariant.primary,
    this.size = AarogyaButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.width,
    this.fullWidth = false,
  });

  @override
  State<AarogyaButton> createState() => _AarogyaButtonState();
}

class _AarogyaButtonState extends State<AarogyaButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    double height;
    EdgeInsets padding;
    TextStyle textStyle;
    double iconSize;

    switch (widget.size) {
      case AarogyaButtonSize.sm:
        height = 34.0;
        padding = const EdgeInsets.symmetric(horizontal: 12.0);
        textStyle = typography.caption;
        iconSize = 13.0;
        break;
      case AarogyaButtonSize.lg:
        height = 48.0;
        padding = const EdgeInsets.symmetric(horizontal: 24.0);
        textStyle = typography.subtitle;
        iconSize = 18.0;
        break;
      case AarogyaButtonSize.md:
        height = 40.0;
        padding = const EdgeInsets.symmetric(horizontal: 16.0);
        textStyle = typography.body;
        iconSize = 15.0;
        break;
    }

    BoxDecoration decoration;
    Color textColor;

    switch (widget.variant) {
      case AarogyaButtonVariant.primary:
        textColor = colors.onAccentAction;
        final baseBg = isEnabled
            ? (_isHovered
                ? colors.accentAction.withValues(alpha: 0.9)
                : colors.accentAction)
            : colors.neutrals.gray300;

        decoration = BoxDecoration(
          color: baseBg,
          borderRadius: AarogyaRadius.radius8,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1.0,
          ),
        );
        break;

      case AarogyaButtonVariant.secondary:
        textColor = isEnabled ? colors.neutrals.gray900 : colors.neutrals.gray400;
        decoration = BoxDecoration(
          color: _isHovered ? colors.surfaceActionable : colors.surfaceInformational,
          borderRadius: AarogyaRadius.radius8,
          border: Border.all(
            color: colors.borderHairline,
            width: 1.0,
          ),
        );
        break;

      case AarogyaButtonVariant.outline:
        textColor = isEnabled ? colors.primary : colors.neutrals.gray400;
        decoration = BoxDecoration(
          color: _isHovered
              ? colors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: AarogyaRadius.radius8,
          border: Border.all(
            color: isEnabled
                ? (_isHovered ? colors.primary : colors.borderHairline)
                : colors.borderHairline,
            width: 1.0,
          ),
        );
        break;

      case AarogyaButtonVariant.destructive:
        // Clinical carmine destructive action
        textColor = colors.clinicalCritical;
        decoration = BoxDecoration(
          color: _isHovered
              ? colors.clinicalCriticalSubtle
              : colors.clinicalCriticalSubtle.withValues(alpha: 0.5),
          borderRadius: AarogyaRadius.radius8,
          border: Border.all(
            color: colors.clinicalCritical.withValues(alpha: 0.3),
            width: 1.0,
          ),
        );
        break;

      case AarogyaButtonVariant.ghost:
        textColor = isEnabled
            ? (_isHovered ? colors.neutrals.gray900 : colors.neutrals.gray600)
            : colors.neutrals.gray400;
        decoration = BoxDecoration(
          color: _isHovered ? colors.surfaceActionable : Colors.transparent,
          borderRadius: AarogyaRadius.radius8,
        );
        break;
    }

    final content = AnimatedScale(
      scale: _isPressed && isEnabled ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        height: height,
        width: widget.fullWidth ? double.infinity : widget.width,
        padding: padding,
        decoration: decoration,
        alignment: (widget.fullWidth || widget.width != null)
            ? Alignment.center
            : null,
        child: widget.isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisSize: (widget.fullWidth || widget.width != null)
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: iconSize, color: textColor),
                    const SizedBox(width: AarogyaSpacing.sm),
                  ],
                  Text(
                    widget.label,
                    style: textStyle.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: isEnabled ? widget.onPressed : null,
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled
            ? () => setState(() => _isPressed = false)
            : null,
        behavior: HitTestBehavior.opaque,
        child: content,
      ),
    );
  }
}
