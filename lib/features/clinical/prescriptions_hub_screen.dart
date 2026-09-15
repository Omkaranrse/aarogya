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
import '../../shared/domain/models/prescription.dart';
import '../../shared/state/aarogya_providers.dart';

class PrescriptionsHubScreen extends ConsumerWidget {
  const PrescriptionsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptions = ref.watch(prescriptionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : AarogyaSpacing.xxl),
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
                      Text('Digital Prescriptions', style: AarogyaTypography.headingLarge(primaryText)),
                      Text(
                        'Cryptographically signed e-prescriptions with dosage schedules',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AarogyaBadge(
                  label: '${prescriptions.length} Active Prescriptions',
                  variant: AarogyaBadgeVariant.cyan,
                ),
              ],
            ),
            const SizedBox(height: 8),

            Expanded(
              child: prescriptions.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.medication_outlined,
                      title: 'No Prescriptions Yet',
                      description: 'Your signed prescriptions will appear here immediately after consultations.',
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: prescriptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final rx = prescriptions[index];
                        return _buildPrescriptionSlip(context, rx, isDark, primaryText, secondaryText);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionSlip(
    BuildContext context,
    Prescription rx,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return GlassCard(
      glowColor: AarogyaColors.accentPurple,
      padding: Responsive.isMobile(context)
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : AarogyaSpacing.paddingXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rx icon, ID, and Date
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AarogyaColors.accentPurple.withValues(alpha: 0.15),
                      borderRadius: AarogyaRadius.radiusSm,
                      border: Border.all(color: AarogyaColors.accentPurple.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '℞ PRESCRIPTION',
                      style: AarogyaTypography.label(AarogyaColors.accentPurple).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('#${rx.id.toUpperCase()}', style: AarogyaTypography.caption(secondaryText)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_rounded, size: 16, color: AarogyaColors.success),
                  const SizedBox(width: 4),
                  Text('Signed Digitally', style: AarogyaTypography.caption(AarogyaColors.success)),
                  const SizedBox(width: 8),
                  Text(AarogyaFormatters.date(rx.date), style: AarogyaTypography.caption(secondaryText)),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Doctor & Patient Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRESCRIBED BY', style: AarogyaTypography.caption(secondaryText)),
                    const SizedBox(height: 2),
                    Text(rx.doctorName, style: AarogyaTypography.title(primaryText)),
                    Text(rx.doctorSpecialty, style: AarogyaTypography.caption(AarogyaColors.primaryCyan)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PATIENT', style: AarogyaTypography.caption(secondaryText)),
                    const SizedBox(height: 2),
                    Text(rx.patientName, style: AarogyaTypography.title(primaryText)),
                    Text('ID: #${rx.patientId}', style: AarogyaTypography.caption(secondaryText)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Medications Table
          Text('Prescribed Medications', style: AarogyaTypography.label(primaryText)),
          const SizedBox(height: AarogyaSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: (isDark ? AarogyaColors.darkSurface : AarogyaColors.lightBg).withValues(alpha: 0.5),
              borderRadius: AarogyaRadius.radiusMd,
              border: Border.all(
                color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
              ),
            ),
            child: Column(
              children: rx.medications.asMap().entries.map((entry) {
                final idx = entry.key;
                final med = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: idx < rx.medications.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AarogyaColors.darkGlassBorderSubtle
                                  : AarogyaColors.lightGlassBorderSubtle,
                            ),
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 7, color: AarogyaColors.accentPurple),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    med.name,
                                    style: AarogyaTypography.label(primaryText).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AarogyaBadge(
                            label: med.dosage,
                            variant: AarogyaBadgeVariant.purple,
                            showDot: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${med.frequency} • ${med.duration} • ${med.instructions}',
                        style: AarogyaTypography.caption(secondaryText),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          if (rx.generalAdvice != null) ...[
            const SizedBox(height: AarogyaSpacing.md),
            Text('Clinical Advice / Instructions', style: AarogyaTypography.caption(secondaryText)),
            const SizedBox(height: 2),
            Text(rx.generalAdvice!, style: AarogyaTypography.bodyMedium(primaryText)),
          ],

          const Divider(height: 24),

          // Doctor Signature & Export
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHYSICIAN SIGNATURE', style: AarogyaTypography.caption(secondaryText)),
                  Text(
                    rx.doctorSignature ?? rx.doctorName,
                    style: AarogyaTypography.caption(primaryText).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AarogyaButton(
                    label: 'Share',
                    icon: Icons.share_rounded,
                    variant: AarogyaButtonVariant.ghost,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prescription link copied to clipboard.')),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AarogyaButton(
                    label: 'Download PDF',
                    icon: Icons.download_rounded,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Downloading official signed prescription PDF...'),
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
