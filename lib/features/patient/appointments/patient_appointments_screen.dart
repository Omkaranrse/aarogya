import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/adaptive_shell.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/motion/aarogya_motion.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_empty_state.dart';
import '../../../core/design_system/components/contextual_header.dart';
import '../../../core/theme/aarogya_theme_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/appointment.dart';
import '../../../shared/domain/models/prescription.dart';
import '../../../shared/state/aarogya_providers.dart';

class PatientAppointmentsScreen extends ConsumerStatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  ConsumerState<PatientAppointmentsScreen> createState() =>
      _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState
    extends ConsumerState<PatientAppointmentsScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Upcoming, 2: Completed, 3: Cancelled

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentsProvider);
    final repo = ref.read(repositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    List<Appointment> filtered;
    switch (_selectedTabIndex) {
      case 1:
        filtered = appointments
            .where(
              (a) =>
                  a.status == AppointmentStatus.upcoming ||
                  a.status == AppointmentStatus.confirmed,
            )
            .toList();
        break;
      case 2:
        filtered = appointments
            .where((a) => a.status == AppointmentStatus.completed)
            .toList();
        break;
      case 3:
        filtered = appointments
            .where((a) => a.status == AppointmentStatus.cancelled)
            .toList();
        break;
      default:
        filtered = appointments;
    }

    final allCount = appointments.length;
    final upcomingCount = appointments.where((a) => a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.upcoming).length;
    final completedCount = appointments.where((a) => a.status == AppointmentStatus.completed).length;
    final cancelledCount = appointments.where((a) => a.status == AppointmentStatus.cancelled).length;

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
              title: 'My Consultations',
              subtitle: 'Track upcoming appointments and clinical schedules',
              statusLabel: '$allCount Total',
              statusColor: context.aarogyaColors.primary,
            ),
            const SizedBox(height: 10),

            // Tab bar filter with counts and disabling 0-count tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('All ($allCount)', 0, allCount, isDark),
                  const SizedBox(width: 8),
                  _buildTab('Upcoming ($upcomingCount)', 1, upcomingCount, isDark),
                  const SizedBox(width: 8),
                  _buildTab('Completed ($completedCount)', 2, completedCount, isDark),
                  const SizedBox(width: 8),
                  _buildTab('Cancelled ($cancelledCount)', 3, cancelledCount, isDark),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Appointments List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AarogyaEmptyState(
                            icon: Icons.event_busy_rounded,
                            title: 'No Appointments Found',
                            description:
                                'No consultations match the selected status filter.',
                          ),
                          if (_selectedTabIndex != 0) ...[
                            const SizedBox(height: 12),
                            AarogyaButton(
                              label: 'Clear filter',
                              variant: AarogyaButtonVariant.secondary,
                              icon: Icons.filter_alt_off_rounded,
                              size: AarogyaButtonSize.sm,
                              onPressed: () => setState(() => _selectedTabIndex = 0),
                            ),
                          ],
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 850;
                        if (!isWide) {
                          return ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final apt = filtered[index];
                              return _buildAppointmentCard(
                                context,
                                apt,
                                repo,
                                isDark,
                                primaryText,
                                secondaryText,
                              );
                            },
                          );
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: filtered.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 260,
                          ),
                          itemBuilder: (context, index) {
                            final apt = filtered[index];
                            return _buildAppointmentCard(
                              context,
                              apt,
                              repo,
                              isDark,
                              primaryText,
                              secondaryText,
                            );
                          },
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

  Widget _buildTab(String label, int index, int count, bool isDark) {
    final isSelected = _selectedTabIndex == index;
    final isEnabled = count > 0 || index == 0;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: isEnabled ? (_) => setState(() => _selectedTabIndex = index) : null,
      selectedColor:
          (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
              .withValues(alpha: 0.15),
      backgroundColor: Colors.transparent,
      disabledColor: Colors.transparent,
      side: BorderSide(
        color: isSelected
            ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
            : (isDark
                  ? AarogyaColors.darkGlassBorderSubtle
                  : AarogyaColors.lightGlassBorderSubtle),
      ),
      labelStyle: AarogyaTypography.caption(
        !isEnabled
            ? (isDark ? AarogyaColors.textDarkMuted : AarogyaColors.textLightMuted)
            : (isSelected
                ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                : (isDark
                      ? AarogyaColors.textDarkSecondary
                      : AarogyaColors.textLightSecondary)),
      ).copyWith(fontWeight: isSelected && isEnabled ? FontWeight.w700 : FontWeight.w500),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    Appointment apt,
    dynamic repo,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    AarogyaBadgeVariant badgeVariant;
    switch (apt.status) {
      case AppointmentStatus.confirmed:
      case AppointmentStatus.completed:
        badgeVariant = AarogyaBadgeVariant.success;
        break;
      case AppointmentStatus.waiting:
      case AppointmentStatus.inProgress:
        badgeVariant = AarogyaBadgeVariant.warning;
        break;
      case AppointmentStatus.cancelled:
        badgeVariant = AarogyaBadgeVariant.critical;
        break;
      default:
        badgeVariant = AarogyaBadgeVariant.info;
    }

    final isInQueue =
        apt.status == AppointmentStatus.waiting ||
        apt.status == AppointmentStatus.inProgress;
    final isUpcoming =
        (apt.status == AppointmentStatus.confirmed ||
            apt.status == AppointmentStatus.upcoming) &&
        !isInQueue;
    final isCompleted = apt.status == AppointmentStatus.completed;

    return GlassCard(
      padding: AarogyaSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AarogyaAvatar(
                name: apt.doctorName,
                imageUrl: apt.doctorAvatar,
                size: 48,
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
                            apt.doctorName,
                            style: AarogyaTypography.title(primaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
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
                                '#${apt.tokenNumber}',
                                style:
                                    AarogyaTypography.code(
                                      AarogyaColors.primaryCyan,
                                    ).copyWith(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (badgeVariant == AarogyaBadgeVariant.success
                                            ? AarogyaColors.success
                                            : badgeVariant ==
                                                  AarogyaBadgeVariant.critical
                                            ? AarogyaColors.critical
                                            : badgeVariant ==
                                                  AarogyaBadgeVariant.warning
                                            ? AarogyaColors.warning
                                            : AarogyaColors.info)
                                        .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      (badgeVariant ==
                                                  AarogyaBadgeVariant.success
                                              ? AarogyaColors.success
                                              : badgeVariant ==
                                                    AarogyaBadgeVariant.critical
                                              ? AarogyaColors.critical
                                              : badgeVariant ==
                                                    AarogyaBadgeVariant.warning
                                              ? AarogyaColors.warning
                                              : AarogyaColors.info)
                                          .withValues(alpha: 0.28),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AarogyaPulseBeacon(
                                    color:
                                        badgeVariant ==
                                            AarogyaBadgeVariant.success
                                        ? AarogyaColors.success
                                        : badgeVariant ==
                                              AarogyaBadgeVariant.critical
                                        ? AarogyaColors.critical
                                        : badgeVariant ==
                                              AarogyaBadgeVariant.warning
                                        ? AarogyaColors.warning
                                        : AarogyaColors.info,
                                    size: 4.5,
                                    animate: isInQueue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    apt.status.displayName,
                                    style:
                                        AarogyaTypography.caption(
                                          badgeVariant ==
                                                  AarogyaBadgeVariant.success
                                              ? AarogyaColors.success
                                              : badgeVariant ==
                                                    AarogyaBadgeVariant.critical
                                              ? AarogyaColors.critical
                                              : badgeVariant ==
                                                    AarogyaBadgeVariant.warning
                                              ? AarogyaColors.warning
                                              : AarogyaColors.info,
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
                    const SizedBox(height: 2),
                    Text(
                      apt.specialty,
                      style: AarogyaTypography.caption(
                        isDark
                            ? AarogyaColors.primaryCyan
                            : AarogyaColors.primaryBlue,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 13,
                              color: secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${AarogyaFormatters.date(apt.dateTime)} • ${apt.timeSlot}',
                              style: AarogyaTypography.caption(secondaryText),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              apt.type == ConsultationType.inPerson
                                  ? Icons.local_hospital_rounded
                                  : Icons.video_camera_front_rounded,
                              size: 13,
                              color: secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              apt.type.displayName,
                              style: AarogyaTypography.caption(secondaryText),
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
          if (apt.symptoms != null && apt.symptoms!.isNotEmpty) ...[
            const SizedBox(height: AarogyaSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.grey.withValues(alpha: 0.06),
                borderRadius: AarogyaRadius.radiusSm,
              ),
              child: Row(
                children: [
                  Icon(Icons.notes_rounded, size: 14, color: secondaryText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      apt.symptoms!,
                      style: AarogyaTypography.caption(secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isInQueue) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AarogyaColors.success.withValues(alpha: 0.10),
                borderRadius: AarogyaRadius.radiusSm,
                border: Border.all(
                  color: AarogyaColors.success.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: [
                  const AarogyaPulseBeacon(
                    color: AarogyaColors.success,
                    size: 5,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Checked In at Triage Desk • Token #${apt.tokenNumber} • Active in Live Queue',
                      style: AarogyaTypography.caption(AarogyaColors.success)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (apt.status == AppointmentStatus.confirmed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AarogyaColors.info.withValues(alpha: 0.08),
                borderRadius: AarogyaRadius.radiusSm,
                border: Border.all(
                  color: AarogyaColors.info.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sensor_occupied_rounded,
                    size: 15,
                    color: AarogyaColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please present at Hospital OPD Triage Counter on arrival for clinical vitals measurement.',
                      style: AarogyaTypography.caption(secondaryText)
                          .copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Divider(
            height: 1,
            color: isDark
                ? AarogyaColors.darkGlassBorderSubtle
                : AarogyaColors.lightGlassBorderSubtle,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AarogyaFormatters.currency(apt.fee),
                style: AarogyaTypography.title(primaryText)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isInQueue) ...[
                    AarogyaButton(
                      label: 'View live queue',
                      icon: Icons.access_time_filled_rounded,
                      size: AarogyaButtonSize.sm,
                      onPressed: () {
                        ref.read(selectedTabIndexProvider.notifier).state = 0; // Navigate to Overview / Live Queue tracker
                      },
                    ),
                  ] else if (isUpcoming) ...[
                    AarogyaButton(
                      label: 'Reschedule',
                      variant: AarogyaButtonVariant.primary,
                      size: AarogyaButtonSize.sm,
                      onPressed: () =>
                          _showRescheduleSheet(context, apt, repo, isDark),
                    ),
                    const SizedBox(width: 8),
                    AarogyaButton(
                      label: 'Cancel',
                      variant: AarogyaButtonVariant.destructive,
                      size: AarogyaButtonSize.sm,
                      onPressed: () => _confirmCancel(context, apt, repo),
                    ),
                  ] else if (isCompleted) ...[
                    AarogyaButton(
                      label: 'View Prescription',
                      variant: AarogyaButtonVariant.secondary,
                      size: AarogyaButtonSize.sm,
                      onPressed: () =>
                          _showPrescriptionDetails(context, apt, isDark),
                    ),
                  ] else ...[
                    AarogyaButton(
                      label: 'Book Again',
                      variant: AarogyaButtonVariant.secondary,
                      size: AarogyaButtonSize.sm,
                      onPressed: () {
                        ref.read(selectedTabIndexProvider.notifier).state =
                            1; // Doctor Discovery
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, Appointment apt, dynamic repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AarogyaColors.critical,
              size: 22,
            ),
            SizedBox(width: 8),
            Text('Cancel Consultation?'),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel your appointment with ${apt.doctorName} for ${apt.timeSlot}? Token #${apt.tokenNumber} will be released.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Appointment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AarogyaColors.critical,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              repo.cancelAppointment(apt.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled successfully.'),
                  backgroundColor: AarogyaColors.critical,
                ),
              );
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleSheet(
    BuildContext context,
    Appointment apt,
    dynamic repo,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RescheduleSheet(
        appointment: apt,
        onRescheduled: (newDate, newSlot) {
          repo.rescheduleAppointment(
            appointmentId: apt.id,
            newDate: newDate,
            newTimeSlot: newSlot,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Consultation rescheduled to ${newDate.day}/${newDate.month} at $newSlot.',
              ),
              backgroundColor: AarogyaColors.success,
            ),
          );
        },
      ),
    );
  }

  void _showPrescriptionDetails(
    BuildContext context,
    Appointment apt,
    bool isDark,
  ) {
    final prescriptions = ref.read(prescriptionsProvider);
    final rx = prescriptions.cast<Prescription?>().firstWhere(
      (p) => p?.doctorId == apt.doctorId,
      orElse: () => prescriptions.isNotEmpty ? prescriptions.first : null,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AarogyaColors.primaryCyan.withValues(alpha: 0.15),
                borderRadius: AarogyaRadius.radiusMd,
              ),
              child: const Icon(
                Icons.medication_rounded,
                color: AarogyaColors.primaryCyan,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Consultation Rx')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Doctor: ${apt.doctorName} (${apt.specialty})',
                style: AarogyaTypography.bodyMedium(
                  isDark
                      ? AarogyaColors.textDarkPrimary
                      : AarogyaColors.textLightPrimary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Date: ${AarogyaFormatters.date(apt.dateTime)} • Token #${apt.tokenNumber}',
                style: AarogyaTypography.caption(
                  isDark
                      ? AarogyaColors.textDarkMuted
                      : AarogyaColors.textLightMuted,
                ),
              ),
              const Divider(height: 20),
              Text(
                'Prescribed Medications',
                style: AarogyaTypography.caption(
                  isDark
                      ? AarogyaColors.textDarkMuted
                      : AarogyaColors.textLightMuted,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (rx != null && rx.medications.isNotEmpty)
                ...rx.medications.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: AarogyaColors.success,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${m.name} (${m.dosage})',
                                style: AarogyaTypography.bodyMedium(
                                  isDark
                                      ? AarogyaColors.textDarkPrimary
                                      : AarogyaColors.textLightPrimary,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${m.frequency} • ${m.duration} • ${m.instructions}',
                                style: AarogyaTypography.caption(
                                  isDark
                                      ? AarogyaColors.textDarkMuted
                                      : AarogyaColors.textLightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  '1. Telmisartan 40mg — 1-0-0 (Morning after breakfast) for 30 days\n2. Atorvastatin 10mg — 0-0-1 (Night before sleep) for 30 days',
                  style: AarogyaTypography.bodyMedium(
                    isDark
                        ? AarogyaColors.textDarkSecondary
                        : AarogyaColors.textLightSecondary,
                  ),
                ),
              const Divider(height: 20),
              Text(
                'General Advice',
                style: AarogyaTypography.caption(
                  isDark
                      ? AarogyaColors.textDarkMuted
                      : AarogyaColors.textLightMuted,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                rx?.generalAdvice ?? 'Maintain low sodium diet, 30 min daily brisk walking, follow up after 30 days with repeat lipid profile.',
                style: AarogyaTypography.bodyMedium(
                  isDark
                      ? AarogyaColors.textDarkSecondary
                      : AarogyaColors.textLightSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          AarogyaButton(
            label: 'Close',
            variant: AarogyaButtonVariant.secondary,
            size: AarogyaButtonSize.sm,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}

class _RescheduleSheet extends StatefulWidget {
  final Appointment appointment;
  final Function(DateTime newDate, String newSlot) onRescheduled;

  const _RescheduleSheet({
    required this.appointment,
    required this.onRescheduled,
  });

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  late DateTime _selectedDate;
  late String _selectedSlot;
  bool _isSaving = false;

  final List<String> _timeSlots = [
    '09:30 AM',
    '10:15 AM',
    '11:00 AM',
    '11:45 AM',
    '02:30 PM',
    '03:15 PM',
    '04:00 PM',
    '05:15 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedSlot = _timeSlots.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14171C) : const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark
              ? AarogyaColors.darkGlassBorder
              : AarogyaColors.lightGlassBorder,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reschedule Consultation',
                    style: AarogyaTypography.headingMedium(primaryText),
                  ),
                  Text(
                    'Select a new date and time slot for your appointment',
                    style: AarogyaTypography.caption(secondaryText),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current Appointment Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B1F26) : const Color(0xFFF3F4F6),
              borderRadius: AarogyaRadius.radiusMd,
              border: Border.all(
                color: isDark
                    ? AarogyaColors.darkGlassBorderSubtle
                    : AarogyaColors.lightGlassBorderSubtle,
              ),
            ),
            child: Row(
              children: [
                AarogyaAvatar(
                  name: widget.appointment.doctorName,
                  imageUrl: widget.appointment.doctorAvatar,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appointment.doctorName,
                        style: AarogyaTypography.title(primaryText),
                      ),
                      Text(
                        'Current: ${AarogyaFormatters.date(widget.appointment.dateTime)} • ${widget.appointment.timeSlot}',
                        style: AarogyaTypography.caption(
                          isDark
                              ? AarogyaColors.primaryCyan
                              : AarogyaColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Date Selection
          Text(
            'Select New Date',
            style: AarogyaTypography.caption(secondaryText)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (i) {
                final date = DateTime.now().add(Duration(days: i + 1));
                final isSelected =
                    date.day == _selectedDate.day &&
                    date.month == _selectedDate.month &&
                    date.year == _selectedDate.year;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    borderRadius: AarogyaRadius.radiusMd,
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                      ? AarogyaColors.primaryCyan
                                      : AarogyaColors.primaryBlue)
                                  .withValues(alpha: 0.15)
                            : (isDark
                                  ? const Color(0xFF1B1F26)
                                  : const Color(0xFFF9FAFB)),
                        borderRadius: AarogyaRadius.radiusMd,
                        border: Border.all(
                          color: isSelected
                              ? (isDark
                                    ? AarogyaColors.primaryCyan
                                    : AarogyaColors.primaryBlue)
                              : (isDark
                                    ? AarogyaColors.darkGlassBorderSubtle
                                    : AarogyaColors.lightGlassBorderSubtle),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getWeekdayShort(date.weekday),
                            style: AarogyaTypography.caption(secondaryText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: AarogyaTypography.title(primaryText)
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? (isDark
                                            ? AarogyaColors.primaryCyan
                                            : AarogyaColors.primaryBlue)
                                      : primaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Time Slot Selection
          Text(
            'Select Time Slot',
            style: AarogyaTypography.caption(secondaryText)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((slot) {
              final isSelected = slot == _selectedSlot;
              return ChoiceChip(
                label: Text(slot),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedSlot = slot),
                selectedColor:
                    (isDark
                            ? AarogyaColors.primaryCyan
                            : AarogyaColors.primaryBlue)
                        .withValues(alpha: 0.15),
                backgroundColor: isDark
                    ? const Color(0xFF1B1F26)
                    : const Color(0xFFF9FAFB),
                side: BorderSide(
                  color: isSelected
                      ? (isDark
                            ? AarogyaColors.primaryCyan
                            : AarogyaColors.primaryBlue)
                      : (isDark
                            ? AarogyaColors.darkGlassBorderSubtle
                            : AarogyaColors.lightGlassBorderSubtle),
                ),
                labelStyle:
                    AarogyaTypography.caption(
                      isSelected
                          ? (isDark
                                ? AarogyaColors.primaryCyan
                                : AarogyaColors.primaryBlue)
                          : secondaryText,
                    ).copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Confirm Action
          AarogyaButton(
            label: 'Confirm Reschedule',
            size: AarogyaButtonSize.md,
            fullWidth: true,
            isLoading: _isSaving,
            onPressed: () async {
              final nav = Navigator.of(context);
              setState(() => _isSaving = true);
              await Future.delayed(const Duration(milliseconds: 400));
              if (!mounted) return;
              nav.pop();
              widget.onRescheduled(_selectedDate, _selectedSlot);
            },
          ),
        ],
      ),
    );
  }

  String _getWeekdayShort(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      default:
        return 'Sun';
    }
  }
}
