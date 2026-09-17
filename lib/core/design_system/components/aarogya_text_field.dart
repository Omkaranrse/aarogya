import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

class AarogyaTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool enabled;
  final bool autofocus;
  final VoidCallback? onClear;
  final bool showClearButton;
  final String? errorText;

  const AarogyaTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.onClear,
    this.showClearButton = false,
    this.errorText,
  });

  @override
  State<AarogyaTextField> createState() => _AarogyaTextFieldState();
}

class _AarogyaTextFieldState extends State<AarogyaTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;
    final mutedText = isDark
        ? AarogyaColors.textDarkMuted
        : AarogyaColors.textLightMuted;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final fill = isDark ? const Color(0x331E293B) : const Color(0xB3FFFFFF);
    final borderDefault = isDark
        ? AarogyaColors.darkGlassBorderSubtle
        : AarogyaColors.lightGlassBorderSubtle;
    final borderActive = hasError
        ? AarogyaColors.critical
        : AarogyaColors.primaryCyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AarogyaTypography.label(secondaryText)),
          const SizedBox(height: AarogyaSpacing.xs),
        ],
        Focus(
          onFocusChange: (focus) => setState(() => _isFocused = focus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: _isFocused
                  ? (isDark ? const Color(0x401E293B) : const Color(0xFAFFFFFF))
                  : fill,
              borderRadius: AarogyaRadius.radiusMd,
              border: Border.all(
                color: hasError
                    ? AarogyaColors.critical
                    : (_isFocused ? borderActive : borderDefault),
                width: hasError || _isFocused ? 1.2 : 1.0,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: borderActive.withValues(
                          alpha: isDark ? 0.22 : 0.15,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              validator: widget.validator,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              style: AarogyaTypography.bodyMedium(primaryText),
              cursorColor: borderActive,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AarogyaTypography.bodyMedium(mutedText),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: hasError
                            ? AarogyaColors.critical
                            : (_isFocused ? borderActive : secondaryText),
                        size: 18,
                      )
                    : null,
                suffixIcon:
                    widget.showClearButton &&
                        widget.controller?.text.isNotEmpty == true
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: mutedText,
                        ),
                        onPressed: () {
                          widget.controller?.clear();
                          if (widget.onClear != null) widget.onClear!();
                          if (widget.onChanged != null) widget.onChanged!('');
                        },
                      )
                    : widget.suffix,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AarogyaSpacing.md,
                  vertical: 14.0,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 13,
                color: AarogyaColors.critical,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AarogyaColors.critical,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
