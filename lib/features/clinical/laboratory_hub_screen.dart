import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/motion/aarogya_motion.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/design_system/components/contextual_header.dart';
import '../../core/design_system/components/range_gauge_indicator.dart';
import '../../core/theme/aarogya_theme_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/lab_report.dart';
import '../../shared/state/aarogya_providers.dart';
import '../../shared/components/printable_clinical_document_dialog.dart';

class LaboratoryHubScreen extends ConsumerStatefulWidget {
  const LaboratoryHubScreen({super.key});

  @override
  ConsumerState<LaboratoryHubScreen> createState() =>
      _LaboratoryHubScreenState();
}

class _LaboratoryHubScreenState extends ConsumerState<LaboratoryHubScreen> {
  bool _onlyAbnormal = false;

  @override
  Widget build(BuildContext context) {
    final labReports = ref.watch(labReportsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;
    final accentColor = isDark
        ? AarogyaColors.primaryCyan
        : AarogyaColors.primaryBlue;

    final filtered = _onlyAbnormal
        ? labReports.where((r) => r.hasAbnormalResults).toList()
        : labReports;

    final abnormalCount = labReports.where((r) => r.hasAbnormalResults).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? 12 : 24,
          vertical: Responsive.isMobile(context) ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContextualHeader(
              title: 'Laboratory Reports',
              subtitle: 'Verified diagnostic panels & pathological findings',
              statusLabel: '${labReports.length} Panels',
              statusColor: context.aarogyaColors.primary,
            ),
            const SizedBox(height: 8),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text('All (${labReports.length})'),
                    selected: !_onlyAbnormal,
                    onSelected: (_) => setState(() => _onlyAbnormal = false),
                    selectedColor: accentColor.withValues(alpha: 0.15),
                    backgroundColor: Colors.transparent,
                    labelStyle:
                        AarogyaTypography.caption(
                          !_onlyAbnormal ? accentColor : secondaryText,
                        ).copyWith(
                          fontWeight: !_onlyAbnormal
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: !_onlyAbnormal
                            ? accentColor
                            : (isDark
                                  ? AarogyaColors.darkGlassBorderSubtle
                                  : AarogyaColors.lightGlassBorderSubtle),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('Abnormal Flagged ($abnormalCount)'),
                    selected: _onlyAbnormal,
                    onSelected: (_) => setState(() => _onlyAbnormal = true),
                    selectedColor: AarogyaColors.critical.withValues(alpha: 0.15),
                    backgroundColor: Colors.transparent,
                    labelStyle:
                        AarogyaTypography.caption(
                          _onlyAbnormal ? AarogyaColors.critical : secondaryText,
                        ).copyWith(
                          fontWeight: _onlyAbnormal
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: _onlyAbnormal
                            ? AarogyaColors.critical
                            : (isDark
                                  ? AarogyaColors.darkGlassBorderSubtle
                                  : AarogyaColors.lightGlassBorderSubtle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: filtered.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.biotech_outlined,
                      title: 'No Reports Found',
                      description:
                          'No diagnostic panels match the selected filter.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 850;
                        if (!isWide || filtered.length <= 1) {
                          return ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final report = filtered[index];
                              final card = _buildReportCard(
                                context,
                                report,
                                isDark,
                                primaryText,
                                secondaryText,
                                accentColor,
                              );
                              if (isWide) {
                                return Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 850),
                                    child: card,
                                  ),
                                );
                              }
                              return card;
                            },
                          );
                        }
                        return SingleChildScrollView(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    for (int i = 0; i < filtered.length; i += 2)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildReportCard(
                                          context,
                                          filtered[i],
                                          isDark,
                                          primaryText,
                                          secondaryText,
                                          accentColor,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  children: [
                                    for (int i = 1; i < filtered.length; i += 2)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildReportCard(
                                          context,
                                          filtered[i],
                                          isDark,
                                          primaryText,
                                          secondaryText,
                                          accentColor,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
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
    Color accentColor,
  ) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Title + Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (report.hasAbnormalResults
                              ? AarogyaColors.critical
                              : accentColor)
                          .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.science_rounded,
                  color: report.hasAbnormalResults
                      ? AarogyaColors.critical
                      : accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.testName,
                      style: AarogyaTypography.headingMedium(primaryText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${report.category} • ${report.orderedByDoctor}',
                      style: AarogyaTypography.caption(secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (report.status == ReportStatus.completed
                                  ? AarogyaColors.success
                                  : AarogyaColors.warning)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            (report.status == ReportStatus.completed
                                    ? AarogyaColors.success
                                    : AarogyaColors.warning)
                                .withValues(alpha: 0.28),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      report.status.displayName,
                      style: AarogyaTypography.caption(
                        report.status == ReportStatus.completed
                            ? AarogyaColors.success
                            : AarogyaColors.warning,
                      ).copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                    ),
                  ),
                  if (report.hasAbnormalResults)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AarogyaColors.critical.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AarogyaColors.critical.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AarogyaPulseBeacon(
                            color: AarogyaColors.critical,
                            size: 4.5,
                          ),
                          const SizedBox(width: 3.5),
                          Text(
                            'Flagged',
                            style:
                                AarogyaTypography.caption(
                                  AarogyaColors.critical,
                                ).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const Divider(height: 18),

          // Numeric Test Items with Visual Reference Ranges
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'Diagnostic Parameters & Reference Gauges',
                style: AarogyaTypography.label(primaryText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AarogyaColors.darkGlassBorderSubtle
                        : AarogyaColors.lightGlassBorderSubtle,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AarogyaColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Low',
                      style: AarogyaTypography.caption(secondaryText).copyWith(fontSize: 10),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AarogyaColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Normal',
                      style: AarogyaTypography.caption(secondaryText).copyWith(fontSize: 10),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AarogyaColors.critical,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'High',
                      style: AarogyaTypography.caption(secondaryText).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color:
                  (isDark ? AarogyaColors.darkSurface : AarogyaColors.lightBg)
                      .withValues(alpha: 0.5),
              borderRadius: AarogyaRadius.radiusMd,
              border: Border.all(
                color: isDark
                    ? AarogyaColors.darkGlassBorderSubtle
                    : AarogyaColors.lightGlassBorderSubtle,
              ),
            ),
            child: Column(
              children: report.items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: idx < report.items.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AarogyaColors.darkGlassBorderSubtle
                                  : AarogyaColors.lightGlassBorderSubtle,
                            ),
                          )
                        : null,
                  ),
                  child: RangeGaugeIndicator(
                    label: item.testName,
                    value: item.value,
                    minRange: item.minRange,
                    maxRange: item.maxRange,
                    unit: item.unit,
                    statusLabel: item.status.label,
                    showHeader: true,
                    showBandLabels: true,
                  ),
                );
              }).toList(),
            ),
          ),

          if (report.labTechnicianNotes != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AarogyaColors.info,
                ),
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

          const Divider(height: 18),

          // Footer with dates and actions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                'Sample: ${AarogyaFormatters.dateTime(report.orderDate)}',
                style: AarogyaTypography.caption(secondaryText),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AarogyaButton(
                    label: 'Share',
                    variant: AarogyaButtonVariant.ghost,
                    icon: Icons.share_rounded,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Secure medical sharing link copied.'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AarogyaButton(
                    label: 'Print / PDF',
                    icon: Icons.print_rounded,
                    size: AarogyaButtonSize.sm,
                    onPressed: () =>
                        PrintableClinicalDocumentDialog.showLabReport(
                          context,
                          report,
                        ),
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
