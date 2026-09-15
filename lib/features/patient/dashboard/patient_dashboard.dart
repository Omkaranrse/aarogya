import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/shell/adaptive_shell.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/stat_card.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/appointment.dart';
import '../../../shared/state/aarogya_providers.dart';

class PatientDashboard extends ConsumerWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(currentPatientProfileProvider);
    final appointments = ref.watch(appointmentsProvider);
    final prescriptions = ref.watch(prescriptionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final upcomingAppointment = appointments.cast<Appointment?>().firstWhere(
          (a) => a?.status == AppointmentStatus.confirmed || a?.status == AppointmentStatus.upcoming,
          orElse: () => null,
        );

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? AarogyaSpacing.md : AarogyaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Status Banner
          _buildGreetingSection(patient, isDark, primaryText, secondaryText),
          const SizedBox(height: 10),

          // Vitals Glance Row
          _buildVitalsGlance(patient, isDark),
          const SizedBox(height: 12),

          // Next Upcoming Appointment Card
          if (upcomingAppointment != null) ...[
            Text(
              'Upcoming Consultation',
              style: AarogyaTypography.headingMedium(primaryText),
            ),
            const SizedBox(height: 6),
            _buildUpcomingAppointmentCard(context, ref, upcomingAppointment, isDark, primaryText, secondaryText),
            const SizedBox(height: 12),
          ],

          // Quick Actions Grid
          Text(
            'Quick Clinical Actions',
            style: AarogyaTypography.headingMedium(primaryText),
          ),
          const SizedBox(height: 6),
          _buildQuickActions(context, ref, isDark, primaryText),
          const SizedBox(height: 12),

          // Active Prescriptions Summary
          Text(
            'Active Medications',
            style: AarogyaTypography.headingMedium(primaryText),
          ),
          const SizedBox(height: 6),
          _buildActiveMedications(context, ref, prescriptions, isDark, primaryText, secondaryText),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(
    dynamic patient,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return GlassCard(
      glowColor: AarogyaColors.primaryCyan,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AarogyaAvatar(
            name: patient.name,
            imageUrl: patient.avatarUrl,
            size: 54,
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
                      'Welcome back, ${patient.name}',
                      style: AarogyaTypography.title(primaryText).copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const AarogyaBadge(
                      label: 'Verified Patient',
                      variant: AarogyaBadgeVariant.success,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Patient ID: #${patient.id} • ${patient.age} Yrs • ${patient.gender} • Blood: ${patient.bloodGroup}',
                  style: AarogyaTypography.caption(secondaryText),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...patient.allergies.map<Widget>((allergy) => AarogyaBadge(
                          label: 'Allergy: $allergy',
                          variant: AarogyaBadgeVariant.critical,
                          showDot: false,
                        )),
                    ...patient.chronicConditions.map<Widget>((c) => AarogyaBadge(
                          label: c,
                          variant: AarogyaBadgeVariant.warning,
                          showDot: false,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGlance(dynamic patient, bool isDark) {
    final vitals = patient.vitals;
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 700;
      return GridView.count(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: isWide ? 1.6 : 1.45,
        children: [
          StatCard(
            title: 'Blood Pressure',
            value: vitals.bloodPressure,
            subtitle: 'Optimal: <120/80',
            icon: Icons.favorite_border_rounded,
            accentColor: AarogyaColors.primaryCyan,
          ),
          StatCard(
            title: 'Heart Rate',
            value: '${vitals.heartRate} bpm',
            subtitle: 'Resting Normal',
            icon: Icons.monitor_heart_rounded,
            accentColor: AarogyaColors.critical,
            trendPercent: -2.1,
          ),
          StatCard(
            title: 'Blood Oxygen',
            value: '${vitals.spo2.toInt()}%',
            subtitle: 'Room Air SpO2',
            icon: Icons.air_rounded,
            accentColor: AarogyaColors.success,
          ),
          StatCard(
            title: 'Body Temperature',
            value: '${vitals.temperature}°F',
            subtitle: 'Afebrile',
            icon: Icons.thermostat_rounded,
            accentColor: AarogyaColors.warning,
          ),
        ],
      );
    });
  }

  Widget _buildUpcomingAppointmentCard(
    BuildContext context,
    WidgetRef ref,
    Appointment appointment,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
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
                size: 54,
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
                        AarogyaBadge(
                          label: 'Token #${appointment.tokenNumber}',
                          variant: AarogyaBadgeVariant.cyan,
                        ),
                      ],
                    ),
                    Text(
                      appointment.specialty,
                      style: AarogyaTypography.bodyMedium(AarogyaColors.primaryCyan),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: secondaryText),
                            const SizedBox(width: 4),
                            Text(
                              '${AarogyaFormatters.dateWithDay(appointment.dateTime)} at ${appointment.timeSlot}',
                              style: AarogyaTypography.caption(secondaryText),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              appointment.type == ConsultationType.inPerson
                                  ? Icons.local_hospital_rounded
                                  : Icons.video_camera_front_rounded,
                              size: 14,
                              color: AarogyaColors.primaryCyan,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              appointment.type.displayName,
                              style: AarogyaTypography.caption(AarogyaColors.primaryCyan),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (appointment.symptoms != null) ...[
            const SizedBox(height: AarogyaSpacing.md),
            Container(
              padding: AarogyaSpacing.paddingMd,
              decoration: BoxDecoration(
                color: (isDark ? AarogyaColors.darkSurface : AarogyaColors.lightBg).withValues(alpha: 0.5),
                borderRadius: AarogyaRadius.radiusMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AarogyaColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reported Symptoms: ${appointment.symptoms}',
                      style: AarogyaTypography.caption(secondaryText),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AarogyaSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AarogyaButton(
                label: 'View Schedule',
                variant: AarogyaButtonVariant.secondary,
                size: AarogyaButtonSize.sm,
                onPressed: () {
                  ref.read(selectedTabIndexProvider.notifier).state = 2; // Appointments tab
                },
              ),
              const SizedBox(width: AarogyaSpacing.md),
              AarogyaButton(
                label: appointment.type == ConsultationType.inPerson ? 'Directions to OPD' : 'Join Call Room',
                icon: appointment.type == ConsultationType.inPerson ? Icons.near_me_rounded : Icons.video_call_rounded,
                size: AarogyaButtonSize.sm,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening consultation for Token #${appointment.tokenNumber}'),
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
    bool isDark,
    Color primaryText,
  ) {
    final actions = [
      (
        'Book Doctor',
        Icons.person_search_rounded,
        AarogyaColors.primaryCyan,
        () => ref.read(selectedTabIndexProvider.notifier).state = 1,
      ),
      (
        'My Prescriptions',
        Icons.medication_rounded,
        AarogyaColors.accentPurple,
        () => ref.read(selectedTabIndexProvider.notifier).state = 3,
      ),
      (
        'Lab Reports',
        Icons.biotech_rounded,
        AarogyaColors.primaryBlue,
        () => ref.read(selectedTabIndexProvider.notifier).state = 4,
      ),
      (
        'Health Timeline',
        Icons.history_edu_rounded,
        AarogyaColors.success,
        () => ref.read(selectedTabIndexProvider.notifier).state = 5,
      ),
      (
        'Billing & Invoices',
        Icons.receipt_long_rounded,
        AarogyaColors.warning,
        () => ref.read(selectedTabIndexProvider.notifier).state = 6,
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      return GridView.count(
        crossAxisCount: isWide ? 5 : (constraints.maxWidth > 500 ? 3 : 2),
        crossAxisSpacing: AarogyaSpacing.md,
        mainAxisSpacing: AarogyaSpacing.md,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.3,
        children: actions.map((a) {
          return GlassCard(
            onTap: a.$4,
            glowColor: a.$3,
            padding: AarogyaSpacing.paddingMd,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: a.$3.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: a.$3.withOpacity(0.3)),
                  ),
                  child: Icon(a.$2, size: 22, color: a.$3),
                ),
                const SizedBox(height: 8),
                Text(
                  a.$1,
                  style: AarogyaTypography.label(primaryText),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
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
      return Text('No active prescriptions found.', style: AarogyaTypography.bodyMedium(secondaryText));
    }

    final latestRx = prescriptions.first;
    final meds = latestRx.medications;

    return Column(
      children: meds.map<Widget>((med) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AarogyaSpacing.sm),
          child: GlassCard(
            glowColor: AarogyaColors.accentPurple,
            padding: AarogyaSpacing.paddingMd,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AarogyaColors.accentPurple.withOpacity(0.12),
                      borderRadius: AarogyaRadius.radiusMd,
                    ),
                    child: const Icon(Icons.medication_rounded, color: AarogyaColors.accentPurple, size: 20),
                  ),
                  const SizedBox(width: AarogyaSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(med.name, style: AarogyaTypography.title(primaryText)),
                            AarogyaBadge(label: med.dosage, variant: AarogyaBadgeVariant.info, showDot: false),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${med.frequency} • ${med.duration} • ${med.instructions}',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ],
                    ),
                  ),
                  if (!Responsive.isMobile(context)) ...[
                    const SizedBox(width: 8),
                    const AarogyaBadge(label: 'Active Course', variant: AarogyaBadgeVariant.success),
                  ],
                ],
              ),
          ),
        );
      }).toList(),
    );
  }
}
