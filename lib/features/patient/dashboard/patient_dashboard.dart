import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/adaptive_shell.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/metric_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/appointment.dart';
import '../../../shared/domain/models/doctor.dart';
import '../../../shared/domain/models/queue_entry.dart';
import '../../../shared/state/aarogya_providers.dart';
import '../abha/abha_card_sheet.dart';

class PatientDashboard extends ConsumerWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(currentPatientProfileProvider);
    final appointments = ref.watch(appointmentsProvider);
    final prescriptions = ref.watch(prescriptionsProvider);
    final liveQueue = ref.watch(liveQueueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    final upcomingAppointment = appointments.cast<Appointment?>().firstWhere(
      (a) =>
          a?.status == AppointmentStatus.confirmed ||
          a?.status == AppointmentStatus.upcoming,
      orElse: () => null,
    );

    final activeQueueEntry = liveQueue.cast<QueueEntry?>().firstWhere(
      (entry) =>
          entry?.patientId == patient.id &&
          entry?.status != QueueStatus.completed &&
          entry?.status != QueueStatus.skipped,
      orElse: () => null,
    );

    final isMobile = Responsive.isMobile(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 1320,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Status Banner
              _buildGreetingSection(
                context,
                patient,
                isDark,
                primaryText,
                secondaryText,
              ),
              SizedBox(height: isMobile ? 8 : 12),

              // Day-of-Visit Live OPD Queue Tracker (shows if patient checked in)
              if (activeQueueEntry != null) ...[
                _buildLiveQueueTracker(
                  context,
                  ref,
                  activeQueueEntry,
                  liveQueue,
                  isDark,
                  primaryText,
                  secondaryText,
                ),
                SizedBox(height: isMobile ? 10 : 14),
              ],

              // Vitals Glance Row
              _buildVitalsGlance(patient, isDark),
              SizedBox(height: isMobile ? 10 : 14),

              // Next Upcoming Appointment Card
              if (upcomingAppointment != null) ...[
                Text(
                  'Upcoming Consultation',
                  style: AarogyaTypography.headingMedium(primaryText),
                ),
                const SizedBox(height: 6),
                _buildUpcomingAppointmentCard(
                  context,
                  ref,
                  upcomingAppointment,
                  isDark,
                  primaryText,
                  secondaryText,
                ),
                SizedBox(height: isMobile ? 10 : 14),
              ],

              // Quick Actions
              Text(
                'Quick Actions',
                style: AarogyaTypography.headingMedium(primaryText),
              ),
              const SizedBox(height: 6),
              _buildQuickActions(context, ref, patient, isDark, primaryText),
              SizedBox(height: isMobile ? 10 : 14),

              // Active Prescriptions Summary
              Text(
                'Medications',
                style: AarogyaTypography.headingMedium(primaryText),
              ),
              const SizedBox(height: 6),
              _buildActiveMedications(
                context,
                ref,
                prescriptions,
                isDark,
                primaryText,
                secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection(
    BuildContext context,
    dynamic patient,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AarogyaAvatar(
            name: patient.name,
            imageUrl: patient.avatarUrl,
            size: 50,
            isOnline: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      patient.name,
                      style: AarogyaTypography.title(primaryText)
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${patient.age} Yrs • ${patient.gender} • ${patient.bloodGroup}',
                  style: AarogyaTypography.caption(secondaryText),
                ),
                const SizedBox(height: 6),
                const SizedBox(height: 6),
                // Single scannable row for allergies and clinical conditions
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: AarogyaRadius.radius8,
            onTap: () => AbhaCardSheet.show(context, patient),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    (isDark
                            ? AarogyaColors.primaryCyan
                            : AarogyaColors.primaryBlue)
                        .withValues(alpha: 0.12),
                borderRadius: AarogyaRadius.radius8,
                border: Border.all(
                  color:
                      (isDark
                              ? AarogyaColors.primaryCyan
                              : AarogyaColors.primaryBlue)
                          .withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.badge_rounded,
                    size: 14,
                    color: isDark
                        ? AarogyaColors.primaryCyan
                        : AarogyaColors.primaryBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ABHA ID',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AarogyaColors.primaryCyan
                          : AarogyaColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGlance(dynamic patient, bool isDark) {
    final vitals = patient.vitals;
    return Builder(
      builder: (context) {
        final isMobile = Responsive.isMobile(context);
        final primaryText = isDark
            ? AarogyaColors.textDarkPrimary
            : AarogyaColors.textLightPrimary;
        final secondaryText = isDark
            ? AarogyaColors.textDarkSecondary
            : AarogyaColors.textLightSecondary;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vitals & Biometrics',
                  style: AarogyaTypography.headingMedium(primaryText),
                ),
                Text(
                  vitals.provenanceLabel,
                  style: AarogyaTypography.caption(secondaryText).copyWith(
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Primary Tier Hero Vitals: Blood Pressure + Heart Rate
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Blood Pressure',
                    value: vitals.bloodPressure,
                    unit: 'mmHg',
                    delta: vitals.isStale()
                        ? 'Last updated ${AarogyaFormatters.timeAgo(vitals.recordedAt)}'
                        : 'Optimal',
                    status: MetricClinicalStatus.stable,
                    tier: MetricCardTier.primary,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: MetricCard(
                    label: 'Heart Rate',
                    value: '${vitals.heartRate}',
                    unit: 'bpm',
                    delta: 'Normal Sinus',
                    status: MetricClinicalStatus.stable,
                    tier: MetricCardTier.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 10),
            // Secondary Tier Compact Vitals: SpO2 + Body Temperature
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: 'Blood Oxygen',
                    value: '${vitals.spo2.toInt()}',
                    unit: '%',
                    status: MetricClinicalStatus.stable,
                    tier: MetricCardTier.secondary,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: MetricCard(
                    label: 'Temperature',
                    value: '${vitals.temperature}',
                    unit: '°F',
                    status: MetricClinicalStatus.stable,
                    tier: MetricCardTier.secondary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingAppointmentCard(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final isMobile = Responsive.isMobile(context);

    if (!isMobile) {
      // Sleek single-row layout for web desktop
      return GlassCard(
        glowColor: AarogyaColors.primaryCyan,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            AarogyaAvatar(
              name: appointment.doctorName,
              imageUrl: appointment.doctorAvatar,
              size: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          appointment.doctorName,
                          style: AarogyaTypography.headingMedium(primaryText)
                              .copyWith(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AarogyaColors.primaryCyan.withValues(
                            alpha: 0.14,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AarogyaColors.primaryCyan.withValues(
                              alpha: 0.35,
                            ),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '#${appointment.tokenNumber}',
                          style:
                              AarogyaTypography.code(AarogyaColors.primaryCyan)
                                  .copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        appointment.specialty,
                        style: AarogyaTypography.bodyMedium(
                          AarogyaColors.primaryCyan,
                        ).copyWith(fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '• ${AarogyaFormatters.date(appointment.dateTime)} • ${appointment.timeSlot} • ${appointment.type.displayName}',
                          style: AarogyaTypography.caption(secondaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (appointment.symptoms != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      appointment.symptoms!,
                      style: AarogyaTypography.caption(secondaryText)
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                AarogyaButton(
                  label: 'Schedule',
                  variant: AarogyaButtonVariant.secondary,
                  size: AarogyaButtonSize.sm,
                  onPressed: () {
                    ref.read(selectedTabIndexProvider.notifier).state = 2;
                  },
                ),
                AarogyaButton(
                  label: appointment.type == ConsultationType.inPerson
                      ? 'Directions'
                      : 'Join Call',
                  icon: appointment.type == ConsultationType.inPerson
                      ? Icons.near_me_rounded
                      : Icons.video_call_rounded,
                  size: AarogyaButtonSize.sm,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Opening consultation for Token #${appointment.tokenNumber}',
                        ),
                        backgroundColor: AarogyaColors.primaryCyan,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Original Mobile Layout - Completely untouched!
    return GlassCard(
      glowColor: AarogyaColors.primaryCyan,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AarogyaAvatar(
                name: appointment.doctorName,
                imageUrl: appointment.doctorAvatar,
                size: 48,
              ),
              const SizedBox(width: AarogyaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            appointment.doctorName,
                            style: AarogyaTypography.headingMedium(primaryText),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AarogyaColors.primaryCyan.withValues(
                              alpha: 0.14,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AarogyaColors.primaryCyan.withValues(
                                alpha: 0.35,
                              ),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            '#${appointment.tokenNumber}',
                            style:
                                AarogyaTypography.code(
                                  AarogyaColors.primaryCyan,
                                ).copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      appointment.specialty,
                      style: AarogyaTypography.bodyMedium(
                        AarogyaColors.primaryCyan,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AarogyaFormatters.date(appointment.dateTime)} • ${appointment.timeSlot} • ${appointment.type.displayName}',
                      style: AarogyaTypography.caption(secondaryText),
                    ),
                    if (appointment.symptoms != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        appointment.symptoms!,
                        style: AarogyaTypography.caption(secondaryText)
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              AarogyaButton(
                label: 'Schedule',
                variant: AarogyaButtonVariant.secondary,
                size: AarogyaButtonSize.sm,
                onPressed: () {
                  ref.read(selectedTabIndexProvider.notifier).state = 2;
                },
              ),
              AarogyaButton(
                label: appointment.type == ConsultationType.inPerson
                    ? 'Directions'
                    : 'Join Call',
                icon: appointment.type == ConsultationType.inPerson
                    ? Icons.near_me_rounded
                    : Icons.video_call_rounded,
                size: AarogyaButtonSize.sm,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Opening consultation for Token #${appointment.tokenNumber}',
                      ),
                      backgroundColor: AarogyaColors.primaryCyan,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    dynamic patient,
    bool isDark,
    Color primaryText,
  ) {
    final actions = [
      (
        'Find Doctor',
        Icons.person_search_rounded,
        AarogyaColors.primaryCyan,
        () => ref.read(selectedTabIndexProvider.notifier).state = 1,
      ),
      (
        'Consults',
        Icons.calendar_month_rounded,
        AarogyaColors.accentIndigo,
        () => ref.read(selectedTabIndexProvider.notifier).state = 2,
      ),
      (
        'Prescriptions',
        Icons.medication_rounded,
        AarogyaColors.accentPurple,
        () => ref.read(selectedTabIndexProvider.notifier).state = 3,
      ),
      (
        'Lab Reports',
        Icons.biotech_rounded,
        const Color(0xFF00BFA5),
        () => ref.read(selectedTabIndexProvider.notifier).state = 4,
      ),
      (
        'EHR Records',
        Icons.history_edu_rounded,
        AarogyaColors.success,
        () => ref.read(selectedTabIndexProvider.notifier).state = 5,
      ),
      (
        'ABHA Card',
        Icons.badge_rounded,
        AarogyaColors.warning,
        () => AbhaCardSheet.show(context, patient),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isTablet = constraints.maxWidth > 600;
        final crossCount = isWide ? 6 : (isTablet ? 3 : 3);
        final aspect = isWide
            ? 2.6
            : (isTablet ? 2.2 : (constraints.maxWidth < 360 ? 1.05 : 1.18));

        return GridView.count(
          padding: EdgeInsets.zero,
          crossAxisCount: crossCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: aspect,
          children: actions.map((a) {
            return GlassCard(
              onTap: a.$4,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: constraints.maxWidth <= 600
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: a.$3.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: a.$3.withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                          ),
                          child: Icon(a.$2, size: 18, color: a.$3),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          a.$1,
                          style: AarogyaTypography.caption(
                            primaryText,
                          ).copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: a.$3.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: a.$3.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                          ),
                          child: Icon(a.$2, size: 16, color: a.$3),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            a.$1,
                            style: AarogyaTypography.label(primaryText)
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActiveMedications(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> prescriptions,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    if (prescriptions.isEmpty) {
      return Text(
        'No active prescriptions found.',
        style: AarogyaTypography.bodyMedium(secondaryText),
      );
    }

    final latestRx = prescriptions.first;
    final meds = latestRx.medications;

    return Column(
      children: meds.map<Widget>((med) {
        final cleanFrequency = med.frequency.contains('(')
            ? med.frequency.split('(')[1].replaceAll(')', '')
            : med.frequency;

        final startDate = med.startDate ?? latestRx.date;
        final durationMatch = RegExp(r'\d+').firstMatch(med.duration);
        final durationDays = durationMatch != null
            ? int.tryParse(durationMatch.group(0)!) ?? 30
            : 30;
        final endDate =
            med.endDate ?? startDate.add(Duration(days: durationDays));
        final now = DateTime.now();
        final daysRemaining = endDate.difference(now).inDays;
        final isCompleted = daysRemaining < 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: AarogyaSpacing.sm),
          child: GlassCard(
            glowColor: AarogyaColors.accentPurple,
            padding: AarogyaSpacing.paddingMd,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AarogyaColors.accentPurple.withValues(alpha: 0.12),
                    borderRadius: AarogyaRadius.radiusMd,
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: AarogyaColors.accentPurple,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AarogyaSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              med.name,
                              style: AarogyaTypography.title(primaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AarogyaColors.accentPurple.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AarogyaColors.accentPurple.withValues(
                                  alpha: 0.28,
                                ),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              med.dosage,
                              style:
                                  AarogyaTypography.code(
                                    isDark
                                        ? AarogyaColors.primaryCyan
                                        : AarogyaColors.accentPurple,
                                  ).copyWith(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$cleanFrequency • ${med.instructions}',
                        style: AarogyaTypography.caption(secondaryText),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 3,
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: secondaryText.withValues(alpha: 0.7),
                          ),
                          Text(
                            '${AarogyaFormatters.date(startDate)} – ${AarogyaFormatters.date(endDate)}',
                            style: AarogyaTypography.caption(secondaryText).copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: (isCompleted
                                      ? AarogyaColors.textDarkMuted
                                      : (isDark
                                          ? AarogyaColors.primaryCyan
                                          : AarogyaColors.primaryBlue))
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isCompleted
                                  ? 'Course Completed'
                                  : (daysRemaining == 0
                                      ? 'Ends Today'
                                      : '$daysRemaining days left'),
                              style: AarogyaTypography.caption(
                                isCompleted
                                    ? secondaryText
                                    : (isDark
                                        ? AarogyaColors.primaryCyan
                                        : AarogyaColors.primaryBlue),
                              ).copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLiveQueueTracker(
    BuildContext context,
    WidgetRef ref,
    QueueEntry entry,
    List<QueueEntry> liveQueue,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final isConsulting = entry.status == QueueStatus.consulting;
    final currentDoctorServing = liveQueue.cast<QueueEntry?>().firstWhere(
      (e) =>
          e?.doctorId == entry.doctorId &&
          e?.status == QueueStatus.consulting,
      orElse: () => null,
    );
    final peopleAhead = liveQueue
        .where((e) =>
            e.doctorId == entry.doctorId &&
            e.status == QueueStatus.waiting &&
            e.tokenNumber < entry.tokenNumber)
        .length;

    final doctors = ref.watch(doctorsListProvider);
    final doctor = doctors.cast<Doctor?>().firstWhere(
      (d) => d?.id == entry.doctorId,
      orElse: () => null,
    );

    final trackerColor = isConsulting
        ? const Color(0xFF10B981)
        : const Color(0xFF0284C7);

    return GlassCard(
      padding: const EdgeInsets.all(14),
      glowColor: isConsulting ? const Color(0xFF10B981) : null,
      customBorder: isConsulting
          ? Border.all(color: const Color(0xFF10B981), width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: trackerColor,
                  boxShadow: [
                    BoxShadow(
                      color: trackerColor.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConsulting ? 'NOW CONSULTING' : 'DAY-OF-VISIT LIVE OPD QUEUE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: trackerColor,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trackerColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: trackerColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  entry.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: trackerColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isConsulting
                        ? [const Color(0xFF059669), const Color(0xFF10B981)]
                        : [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: trackerColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOKEN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white70,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '#${entry.tokenNumber}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor != null
                          ? '${doctor.name} • ${doctor.specialty}'
                          : 'Assigned Physician Chamber',
                      style: AarogyaTypography.title(primaryText).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isConsulting
                          ? '👉 You are currently inside the consultation chamber with the doctor.'
                          : peopleAhead == 0
                              ? '🔔 You are NEXT in line! Please wait near chamber door.'
                              : '$peopleAhead patient${peopleAhead > 1 ? "s" : ""} ahead of you • Est. wait ~${entry.estimatedWaitMinutes} mins',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: peopleAhead == 0 || isConsulting
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isConsulting
                            ? const Color(0xFF10B981)
                            : (peopleAhead == 0
                                ? const Color(0xFFF59E0B)
                                : secondaryText),
                      ),
                    ),
                    if (currentDoctorServing != null && !isConsulting) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Currently inside chamber: Token #${currentDoctorServing.tokenNumber}',
                        style: AarogyaTypography.caption(secondaryText).copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (entry.vitals != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark
                        ? AarogyaColors.darkSurface
                        : AarogyaColors.lightBg)
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? AarogyaColors.darkGlassBorderSubtle
                      : AarogyaColors.lightGlassBorderSubtle,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monitor_heart_rounded,
                    size: 14,
                    color: AarogyaColors.accentPurple,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Triage Counter Vitals: BP ${entry.vitals!.bloodPressure} • HR ${entry.vitals!.heartRate} bpm • SpO2 ${entry.vitals!.spo2.toInt()}%',
                      style: AarogyaTypography.caption(secondaryText).copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (entry.ewsScore != null)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AarogyaColors.accentPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'NEWS2: ${entry.ewsScore}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AarogyaColors.accentPurple,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
