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

    final activeRxCount = prescriptions.where((p) => p.hasActiveMedications()).length;

    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 1320,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 24,
              vertical: isMobile ? 12 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContextualHeader(
                  title: 'Prescriptions',
                  subtitle: 'Digital medical slips & authorized pharmacy directives',
                  statusLabel: '$activeRxCount Active Rx',
                  statusColor: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 8),

            Expanded(
              child: prescriptions.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.medication_outlined,
                      title: 'No Prescriptions Found',
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
    final isActiveRx = rx.hasActiveMedications();

    return TimelineEntryCard(
      icon: Icons.medication_rounded,
      iconColor: rxAccent,
      isLast: isLast,
      title: '℞ #${rx.id.toUpperCase()}',
      subtitle: '${rx.doctorName} • ${rx.department}',
      timestamp: AarogyaFormatters.date(rx.date),
      statusBadge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: (isActiveRx ? rxAccent : colors.neutrals.gray400)
              .withValues(alpha: 0.12),
          borderRadius: AarogyaRadius.radius4,
          border: Border.all(
            color: (isActiveRx ? rxAccent : colors.neutrals.gray400)
                .withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActiveRx ? Icons.check_circle_rounded : Icons.history_rounded,
              size: 10,
              color: isActiveRx ? rxAccent : colors.neutrals.gray500,
            ),
            const SizedBox(width: 3),
            Text(
              isActiveRx ? 'Active Course' : 'Completed Course',
              style: typography.caption.copyWith(
                color: isActiveRx ? rxAccent : colors.neutrals.gray600,
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
            final medStatus = med.getStatus();
            final isMedActive = medStatus == MedicationStatus.active;
            final isCompleted = medStatus == MedicationStatus.completed;

            return Opacity(
              opacity: isCompleted ? 0.65 : 1.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? colors.neutrals.gray50
                      : colors.surfaceActionable,
                  borderRadius: AarogyaRadius.radius12,
                  border: Border.all(
                    color: isCompleted
                        ? colors.borderHairline.withValues(alpha: 0.5)
                        : colors.borderHairline,
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
                            color: (isMedActive ? rxAccent : colors.neutrals.gray400)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (isMedActive ? rxAccent : colors.neutrals.gray400)
                                  .withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            Icons.medication_liquid_rounded,
                            size: 18,
                            color: isMedActive ? rxAccent : colors.neutrals.gray600,
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
                                  decoration: isCompleted
                                      ? TextDecoration.none
                                      : null,
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
                            color: isMedActive
                                ? rxAccent.withValues(alpha: 0.12)
                                : colors.neutrals.gray100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isMedActive
                                  ? rxAccent.withValues(alpha: 0.25)
                                  : colors.borderHairline,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            med.progressLabel(),
                            style: typography.caption.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isMedActive
                                  ? rxAccent
                                  : colors.neutrals.gray600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Indian 1-0-1 Triplet Dosage Chips
                    _buildIntakeChips(med.frequency, colors, typography),
                    const SizedBox(height: 8),

                    // Instruction & Date details
                    Row(
                      children: [
                        const Icon(
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
                        if (med.startDate != null && med.endDate != null) ...[
                          Icon(
                            Icons.event_available_rounded,
                            size: 11,
                            color: colors.neutrals.gray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${AarogyaFormatters.date(med.startDate!)} – ${AarogyaFormatters.date(med.endDate!)}',
                            style: typography.caption.copyWith(
                              fontSize: 10,
                              color: colors.neutrals.gray500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
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
          // Prescriber's Electronic Signature Seal
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
                    'Electronically Authorized: ${rx.doctorSignature ?? rx.doctorName} • Department of ${rx.department}',
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
          label: 'Print Rx Slip',
          icon: Icons.print_rounded,
          variant: AarogyaButtonVariant.secondary,
          size: AarogyaButtonSize.sm,
          onPressed: () {
            PrintableClinicalDocumentDialog.showPrescription(
              context,
              rx,
            );
          },
        ),
      ],
    );
  }

  Widget _buildIntakeChips(
    String frequency,
    AarogyaColorTokens colors,
    AarogyaTypographyTokens typography,
  ) {
    final parts = frequency.split(RegExp(r'[-\s]+'));
    final m = parts.isNotEmpty && parts[0] == '1';
    final a = parts.length > 1 && parts[1] == '1';
    final n = parts.length > 2 && parts[2] == '1';

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _buildSlotChip('Morning (1)', m, colors, typography),
        _buildSlotChip('Afternoon (0)', a, colors, typography),
        _buildSlotChip('Night (1)', n, colors, typography),
      ],
    );
  }

  Widget _buildSlotChip(
    String label,
    bool isActive,
    AarogyaColorTokens colors,
    AarogyaTypographyTokens typography,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
            : colors.neutrals.gray100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive
              ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
              : colors.borderHairline,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 11,
            color: isActive ? const Color(0xFF8B5CF6) : colors.neutrals.gray400,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: typography.caption.copyWith(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? const Color(0xFF8B5CF6) : colors.neutrals.gray600,
            ),
          ),
        ],
      ),
    );
  }
}
