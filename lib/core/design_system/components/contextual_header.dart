import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../../theme/aarogya_theme_tokens.dart';

/// Contextual Clinical Screen Header.
/// Replaces generic static AppBars with high-density, screen-specific telemetry
/// (e.g., Patient status summary, "X pending / Y settled", active record counts).
class ContextualHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? statusLabel;
  final Color? statusColor;
  final Widget? statusWidget;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;

  const ContextualHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.statusLabel,
    this.statusColor,
    this.statusWidget,
    this.actions,
    this.showBack = false,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;
    final activeStatusColor = statusColor ?? colors.primary;

    return Container(
      constraints: BoxConstraints(minHeight: preferredSize.height),
      decoration: BoxDecoration(
        color: colors.surfaceInformational,
        border: Border(
          bottom: BorderSide(
            color: colors.borderHairline,
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (showBack) ...[
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: colors.neutrals.gray900,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 8),
          ],

            // Screen Identifier & Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: typography.title.copyWith(
                            color: colors.neutrals.gray900,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (statusWidget != null) ...[
                        const SizedBox(width: 8),
                        Flexible(child: statusWidget!),
                      ] else if (statusLabel != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: activeStatusColor.withValues(alpha: 0.12),
                              borderRadius: AarogyaRadius.radius4,
                              border: Border.all(
                                color: activeStatusColor.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              statusLabel!,
                              style: typography.caption.copyWith(
                                color: activeStatusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: typography.caption.copyWith(
                        color: colors.neutrals.gray500,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Trailing Actions
            ...?actions,
          ],
        ),
    );
  }
}
