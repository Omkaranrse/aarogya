import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/design_system/components/contextual_header.dart';
import '../../core/design_system/components/timeline_entry_card.dart';
import '../../core/theme/aarogya_theme_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/prescription.dart';
import '../../shared/state/aarogya_providers.dart';
import '../../shared/components/printable_clinical_document_dialog.dart';

class PrescriptionsHubScreen extends ConsumerWidget {
  const PrescriptionsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptions = ref.watch(prescriptionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

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
              title: 'Prescriptions',
              subtitle: 'Digital medical slips & authorized pharmacy directives',
              statusLabel: '${prescriptions.length} Active Rx',
              statusColor: const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: prescriptions.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.medication_outlined,
                      title: 'No Prescriptions Yet',
                      description:
                          'Your signed prescriptions will appear here immediately after consultations.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 850;
                        if (!isWide || prescriptions.length <= 1) {
                          return ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: prescriptions.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final rx = prescriptions[index];
                              final isLast = index == prescriptions.length - 1;
                              final slip = _buildPrescriptionSlip(
                                context,
                                rx,
                                isLast,
                                isDark,
                                primaryText,
                                secondaryText,
                              );
                              if (isWide) {
                                return Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 800),
                                    child: slip,
                                  ),
                                );
                              }
                              return slip;
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
                                    for (int i = 0;
                                        i < prescriptions.length;
                                        i += 2)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildPrescriptionSlip(
                                          context,
                                          prescriptions[i],
                                          i == prescriptions.length - 1,
                                          isDark,
                                          primaryText,
                                          secondaryText,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  children: [
                                    for (int i = 1;
                                        i < prescriptions.length;
                                        i += 2)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildPrescriptionSlip(
                                          context,
                                          prescriptions[i],
                                          i == prescriptions.length - 1,
                                          isDark,
                                          primaryText,
                                          secondaryText,
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

  Widget _buildPrescriptionSlip(
    BuildContext context,
    Prescription rx,
    bool isLast,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;
    const rxAccent = Color(0xFF8B5CF6);

    return TimelineEntryCard(
      icon: Icons.medication_rounded,
      iconColor: rxAccent,
      isLast: isLast,
      title: '℞ #${rx.id.toUpperCase()}',
      subtitle: '${rx.doctorName} • ${rx.doctorSpecialty}',
      timestamp: AarogyaFormatters.date(rx.date),
      statusBadge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: rxAccent.withValues(alpha: 0.12),
          borderRadius: AarogyaRadius.radius4,
          border: Border.all(
            color: rxAccent.withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_rounded, size: 10, color: rxAccent),
            const SizedBox(width: 3),
            Text(
              'Patient: ${rx.patientName}',
              style: typography.caption.copyWith(
                color: rxAccent,
                fontWeight: FontWeight.w700,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...rx.medications.map((med) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceActionable,
                borderRadius: AarogyaRadius.radius12,
                border: Border.all(
                  color: colors.borderHairline,
                  width: 0.9,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: rxAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: rxAccent.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.medication_liquid_rounded,
                          size: 18,
                          color: rxAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med.name,
                              style: typography.subtitle.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.neutrals.gray900,
                              ),
                            ),
                            Text(
                              'Strength: ${med.dosage}',
                              style: typography.caption.copyWith(
                                color: colors.neutrals.gray500,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.neutrals.gray100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: colors.borderHairline,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          med.duration,
                          style: typography.caption.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: colors.neutrals.gray700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Patient-Friendly Visual Intake Timing Chips
                  _buildIntakeChips(med.frequency, colors, typography),
                  const SizedBox(height: 8),
                  // Instruction & Date details
                  Builder(
                    builder: (context) {
                      final startDate = med.startDate ?? rx.date;
                      final durationMatch =
                          RegExp(r'\d+').firstMatch(med.duration);
                      final durationDays = durationMatch != null
                          ? int.tryParse(durationMatch.group(0)!) ?? 30
                          : 30;
                      final endDate = med.endDate ??
                          startDate.add(Duration(days: durationDays));

                      return Row(
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 12,
                            color: rxAccent,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              med.instructions,
                              style: typography.caption.copyWith(
                                color: colors.neutrals.gray700,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.event_available_rounded,
                            size: 11,
                            color: colors.neutrals.gray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${AarogyaFormatters.date(startDate)} – ${AarogyaFormatters.date(endDate)}',
                            style: typography.caption.copyWith(
                              fontSize: 10,
                              color: colors.neutrals.gray500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          }),
          if (rx.generalAdvice != null && rx.generalAdvice!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.neutrals.gray100.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.borderHairline,
                  width: 0.8,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Doctor\'s Advice: ${rx.generalAdvice}',
                      style: typography.caption.copyWith(
                        color: colors.neutrals.gray700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Doctor's Electronic Signature Seal
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  size: 14,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Electronically Authorized: ${rx.doctorName} • Reg #${rx.doctorId.replaceAll(RegExp(r'[^0-9]'), '').padLeft(5, '8')}',
                    style: typography.caption.copyWith(
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        AarogyaButton(
          label: 'Share',
          icon: Icons.share_rounded,
          variant: AarogyaButtonVariant.ghost,
          size: AarogyaButtonSize.sm,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prescription link copied to clipboard.'),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        AarogyaButton(
          label: 'Print / PDF',
          icon: Icons.print_rounded,
          variant: AarogyaButtonVariant.secondary,
          size: AarogyaButtonSize.sm,
          onPressed: () => PrintableClinicalDocumentDialog.showPrescription(
            context,
            rx,
          ),
        ),
      ],
    );
  }

  static Widget _buildIntakeChips(
    String frequency,
    AarogyaColorTokens colors,
    AarogyaTypographyTokens typography,
  ) {
    final match =
        RegExp(r'(\d+)\s*-\s*(\d+)\s*-\s*(\d+)').firstMatch(frequency);
    if (match != null) {
      final m = int.tryParse(match.group(1)!) ?? 0;
      final a = int.tryParse(match.group(2)!) ?? 0;
      final n = int.tryParse(match.group(3)!) ?? 0;

      return Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          _pillTimingChip(
            icon: Icons.wb_sunny_rounded,
            timeOfDay: 'Morning',
            count: m,
            activeColor: const Color(0xFFF59E0B),
            colors: colors,
          ),
          _pillTimingChip(
            icon: Icons.wb_cloudy_rounded,
            timeOfDay: 'Afternoon',
            count: a,
            activeColor: const Color(0xFF06B6D4),
            colors: colors,
          ),
          _pillTimingChip(
            icon: Icons.nightlight_round,
            timeOfDay: 'Night',
            count: n,
            activeColor: const Color(0xFF6366F1),
            colors: colors,
          ),
        ],
      );
    }

    final isSOS = frequency.toLowerCase().contains('prn') ||
        frequency.toLowerCase().contains('needed') ||
        frequency.toLowerCase().contains('sos');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: (isSOS ? AarogyaColors.warning : const Color(0xFF8B5CF6))
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isSOS ? AarogyaColors.warning : const Color(0xFF8B5CF6))
              .withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        frequency,
        style: typography.caption.copyWith(
          color: isSOS ? AarogyaColors.warning : const Color(0xFF8B5CF6),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  static Widget _pillTimingChip({
    required IconData icon,
    required String timeOfDay,
    required int count,
    required Color activeColor,
    required AarogyaColorTokens colors,
  }) {
    final isActive = count > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isActive
            ? activeColor.withValues(alpha: 0.12)
            : colors.surfaceActionable,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive
              ? activeColor.withValues(alpha: 0.35)
              : colors.borderHairline,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isActive ? activeColor : colors.neutrals.gray400,
          ),
          const SizedBox(width: 4),
          Text(
            '$timeOfDay: ${isActive ? "$count tab" : "—"}',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? activeColor : colors.neutrals.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

