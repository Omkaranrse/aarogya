import 'package:flutter/material.dart';

import '../tokens/radius.dart';
import '../../theme/aarogya_theme_tokens.dart';

/// Unified Clinical Timeline Entry Card with Icon Rail and Structured Entry Surface.
/// Provides visual and architectural continuity across Billing, EHR Timeline, and Prescriptions.
class TimelineEntryCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final bool isLast;
  final String title;
  final String? subtitle;
  final String? timestamp;
  final Widget? statusBadge;
  final Widget? body;
  final Widget? trailingHeader;
  final List<Widget>? actions;
  final VoidCallback? onTap;

  const TimelineEntryCard({
    super.key,
    required this.icon,
    this.iconColor,
    this.isLast = false,
    required this.title,
    this.subtitle,
    this.timestamp,
    this.statusBadge,
    this.body,
    this.trailingHeader,
    this.actions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;
    final activeIconColor = iconColor ?? colors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Rail: Continuous timeline indicator node & vertical connector
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: activeIconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: activeIconColor.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(icon, size: 14, color: activeIconColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: colors.borderHairline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right Card: 1px hairline border, flat informational surface
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Material(
                color: colors.surfaceInformational,
                shape: RoundedRectangleBorder(
                  borderRadius: AarogyaRadius.radius12,
                  side: BorderSide(
                    color: colors.borderHairline,
                    width: 1.0,
                  ),
                ),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: AarogyaRadius.radius12,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        // Header Row: Title & Date / Status
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: typography.subtitle.copyWith(
                                      color: colors.neutrals.gray900,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (subtitle != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle!,
                                      style: typography.caption.copyWith(
                                        color: colors.neutrals.gray600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (trailingHeader != null)
                              trailingHeader!
                            else if (timestamp != null)
                              Text(
                                timestamp!,
                                style: typography.caption.copyWith(
                                  fontSize: 10.5,
                                  color: colors.neutrals.gray500,
                                ),
                              ),
                          ],
                        ),

                        // Status Badge Row if provided
                        if (statusBadge != null) ...[
                          const SizedBox(height: 8),
                          statusBadge!,
                        ],

                        // Main Body Slot
                        if (body != null) ...[
                          const SizedBox(height: 10),
                          body!,
                        ],

                        // Footer Actions
                        if (actions != null && actions!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Divider(
                            color: colors.borderHairline,
                            height: 1,
                            thickness: 1,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 6,
                            children: actions!,
                          ),
                        ],
                      ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
