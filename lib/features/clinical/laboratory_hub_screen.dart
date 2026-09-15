import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/spacing.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_badge.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/lab_report.dart';
import '../../shared/state/aarogya_providers.dart';

class LaboratoryHubScreen extends ConsumerWidget {
  const LaboratoryHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labReports = ref.watch(labReportsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? AarogyaSpacing.md : AarogyaSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Diagnostic Laboratory Reports', style: AarogyaTypography.headingLarge(primaryText)),
                      Text(
                        'Verified clinical pathology, biochemistry, and hematology results',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AarogyaBadge(
                  label: '${labReports.length} Reports Ready',
                  variant: AarogyaBadgeVariant.cyan,
                ),
              ],
            ),
            const SizedBox(height: AarogyaSpacing.xl),

            Expanded(
              child: labReports.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.biotech_outlined,
                      title: 'No Laboratory Reports',
                      description: 'Ordered diagnostic tests will appear here once specimens are analyzed.',
                    )
                  : ListView.separated(
                      itemCount: labReports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AarogyaSpacing.lg),
                      itemBuilder: (context, index) {
                        final report = labReports[index];
                        return _buildReportCard(context, report, isDark, primaryText, secondaryText);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    LabReport report,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return GlassCard(
      glowColor: report.hasAbnormalResults ? AarogyaColors.critical : AarogyaColors.primaryCyan,
      padding: AarogyaSpacing.paddingXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (report.hasAbnormalResults ? AarogyaColors.critical : AarogyaColors.primaryCyan).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.science_rounded,
                      color: report.hasAbnormalResults ? AarogyaColors.critical : AarogyaColors.primaryCyan,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AarogyaSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.testName, style: AarogyaTypography.headingMedium(primaryText)),
                      Text(
                        'Category: ${report.category} • Ordered by ${report.orderedByDoctor}',
                        style: AarogyaTypography.caption(secondaryText),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  AarogyaBadge(
                    label: report.status.displayName,
                    variant: report.status == ReportStatus.completed
                        ? AarogyaBadgeVariant.success
                        : AarogyaBadgeVariant.warning,
                  ),
                  const SizedBox(width: 8),
                  if (report.hasAbnormalResults)
                    const AarogyaBadge(
                      label: 'Action Required',
                      variant: AarogyaBadgeVariant.critical,
                    ),
                ],
              ),
            ],
          ),
          const Divider(height: 24),

          // Numeric Test Items with Reference Ranges
          Text('Laboratory Test Parameters & Reference Ranges', style: AarogyaTypography.label(primaryText)),
          const SizedBox(height: AarogyaSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: (isDark ? AarogyaColors.darkSurface : AarogyaColors.lightBg).withOpacity(0.5),
              borderRadius: AarogyaRadius.radiusMd,
              border: Border.all(
                color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
              ),
            ),
            child: Column(
              children: report.items.map((item) {
                final isAbnormal = item.status != LabResultStatus.normal;
                final statusColor = item.status == LabResultStatus.normal
                    ? AarogyaColors.success
                    : (item.status == LabResultStatus.critical ? AarogyaColors.critical : AarogyaColors.warning);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(item.testName, style: AarogyaTypography.bodyMedium(primaryText)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Text(
                              '${item.value}',
                              style: AarogyaTypography.title(statusColor).copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 4),
                            Text(item.unit, style: AarogyaTypography.caption(secondaryText)),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Ref: ${item.minRange} - ${item.maxRange} ${item.unit}',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ),
                      AarogyaBadge(
                        label: item.status.label,
                        variant: isAbnormal ? AarogyaBadgeVariant.critical : AarogyaBadgeVariant.success,
                        showDot: isAbnormal,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          if (report.labTechnicianNotes != null) ...[
            const SizedBox(height: AarogyaSpacing.md),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AarogyaColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pathologist Notes: ${report.labTechnicianNotes}',
                    style: AarogyaTypography.caption(secondaryText),
                  ),
                ),
              ],
            ),
          ],

          const Divider(height: 24),

          // Footer with dates and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sample Drawn: ${AarogyaFormatters.dateTime(report.orderDate)}',
                style: AarogyaTypography.caption(secondaryText),
              ),
              Row(
                children: [
                  AarogyaButton(
                    label: 'Share Report',
                    variant: AarogyaButtonVariant.ghost,
                    icon: Icons.share_rounded,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report sharing link generated.')),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AarogyaButton(
                    label: 'Download PDF',
                    icon: Icons.file_download_outlined,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading ${report.testName} report PDF...'),
                          backgroundColor: AarogyaColors.primaryCyan,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
