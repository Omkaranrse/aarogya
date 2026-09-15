import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum AarogyaButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
}

enum AarogyaButtonSize {
  sm,
  md,
  lg,
}

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    double height;
    EdgeInsets padding;
    TextStyle textStyle;
    double iconSize;

    switch (widget.size) {
      case AarogyaButtonSize.sm:
        height = 36.0;
        padding = const EdgeInsets.symmetric(horizontal: 12.0);
        textStyle = AarogyaTypography.caption(Colors.white);
        iconSize = 14.0;
        break;
      case AarogyaButtonSize.lg:
        height = 52.0;
        padding = const EdgeInsets.symmetric(horizontal: 24.0);
        textStyle = AarogyaTypography.title(Colors.white);
        iconSize = 20.0;
        break;
      case AarogyaButtonSize.md:
      default:
        height = 44.0;
        padding = const EdgeInsets.symmetric(horizontal: 18.0);
        textStyle = AarogyaTypography.label(Colors.white);
        iconSize = 16.0;
    }

    BoxDecoration decoration;
    Color textColor;

    switch (widget.variant) {
      case AarogyaButtonVariant.primary:
        textColor = Colors.white;
        decoration = BoxDecoration(
          gradient: isEnabled
              ? AarogyaColors.primaryGradient
              : LinearGradient(
                  colors: [Colors.grey.shade600, Colors.grey.shade700],
                ),
          borderRadius: AarogyaRadius.radiusMd,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AarogyaColors.primaryCyan.withOpacity(_isHovered ? 0.45 : 0.25),
                    blurRadius: _isHovered ? 18 : 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        );
        break;

      case AarogyaButtonVariant.secondary:
        textColor = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
        decoration = BoxDecoration(
          color: isDark ? const Color(0x331E293B) : const Color(0x1F0284C7),
          borderRadius: AarogyaRadius.radiusMd,
          border: Border.all(
            color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
          ),
        );
        break;

      case AarogyaButtonVariant.outline:
        textColor = isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue;
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: AarogyaRadius.radiusMd,
          border: Border.all(
            color: _isHovered ? textColor : textColor.withOpacity(0.5),
            width: 1.5,
          ),
        );
        break;

      case AarogyaButtonVariant.destructive:
        textColor = Colors.white;
        decoration = BoxDecoration(
          color: AarogyaColors.critical,
          borderRadius: AarogyaRadius.radiusMd,
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AarogyaColors.critical.withOpacity(_isHovered ? 0.4 : 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        );
        break;

      case AarogyaButtonVariant.ghost:
        textColor = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;
        decoration = BoxDecoration(
          color: _isHovered
              ? (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05))
              : Colors.transparent,
          borderRadius: AarogyaRadius.radiusMd,
        );
        break;
    }

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      width: widget.fullWidth ? double.infinity : widget.width,
      padding: padding,
      decoration: decoration,
      child: Center(
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: iconSize, color: textColor),
                    const SizedBox(width: AarogyaSpacing.sm),
                  ],
                  Text(
                    widget.label,
                    style: textStyle.copyWith(color: textColor),
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
        child: content,
      ),
    );
  }
}
