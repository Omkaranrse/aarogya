import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/appointment.dart';
import '../../../shared/state/aarogya_providers.dart';

class PatientAppointmentsScreen extends ConsumerStatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  ConsumerState<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends ConsumerState<PatientAppointmentsScreen> {
  int _selectedTabIndex = 0; // 0: All, 1: Upcoming, 2: Completed, 3: Cancelled

  @override
  Widget build(BuildContext context) {
    final appointments = ref.watch(appointmentsProvider);
    final repo = ref.read(repositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    List<Appointment> filtered;
    switch (_selectedTabIndex) {
      case 1:
        filtered = appointments
            .where((a) => a.status == AppointmentStatus.upcoming || a.status == AppointmentStatus.confirmed)
            .toList();
        break;
      case 2:
        filtered = appointments.where((a) => a.status == AppointmentStatus.completed).toList();
        break;
      case 3:
        filtered = appointments.where((a) => a.status == AppointmentStatus.cancelled).toList();
        break;
      default:
        filtered = appointments;
    }

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
                      Text('My Consultations', style: AarogyaTypography.headingLarge(primaryText)),
                      Text(
                        'Manage scheduled appointments and view clinical history',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AarogyaBadge(
                  label: '${appointments.length} Total',
                  variant: AarogyaBadgeVariant.cyan,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tab bar filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab('All (${appointments.length})', 0, isDark),
                  const SizedBox(width: 8),
                  _buildTab(
                    'Upcoming (${appointments.where((a) => a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.upcoming).length})',
                    1,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    'Completed (${appointments.where((a) => a.status == AppointmentStatus.completed).length})',
                    2,
                    isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    'Cancelled (${appointments.where((a) => a.status == AppointmentStatus.cancelled).length})',
                    3,
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Appointments List
            Expanded(
              child: filtered.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'No Appointments in this Category',
                      description: 'You do not have any appointments matching the selected filter status.',
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final apt = filtered[index];
                        return _buildAppointmentCard(context, apt, repo, isDark, primaryText, secondaryText);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index, bool isDark) {
    final isSelected = _selectedTabIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedTabIndex = index),
      selectedColor: isDark ? AarogyaColors.primaryCyan.withOpacity(0.25) : AarogyaColors.primaryBlue.withOpacity(0.15),
      labelStyle: AarogyaTypography.caption(
        isSelected
            ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
            : (isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary),
      ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
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

    return GlassCard(
      glowColor: AarogyaColors.primaryCyan,
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
                size: 52,
              ),
              const SizedBox(width: AarogyaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(apt.doctorName, style: AarogyaTypography.title(primaryText)),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            AarogyaBadge(label: 'Token #${apt.tokenNumber}', variant: AarogyaBadgeVariant.cyan),
                            AarogyaBadge(label: apt.status.displayName, variant: badgeVariant),
                          ],
                        ),
                      ],
                    ),
                    Text(apt.specialty, style: AarogyaTypography.bodyMedium(AarogyaColors.primaryCyan)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 14, color: secondaryText),
                            const SizedBox(width: 4),
                            Text(
                              '${AarogyaFormatters.dateWithDay(apt.dateTime)} at ${apt.timeSlot}',
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
                              size: 14,
                              color: secondaryText,
                            ),
                            const SizedBox(width: 4),
                            Text(apt.type.displayName, style: AarogyaTypography.caption(secondaryText)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (apt.symptoms != null) ...[
            const SizedBox(height: AarogyaSpacing.md),
            Text(
              'Symptoms: ${apt.symptoms}',
              style: AarogyaTypography.bodyMedium(secondaryText),
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fee: ${AarogyaFormatters.currency(apt.fee)}',
                style: AarogyaTypography.label(primaryText),
              ),
              Row(
                children: [
                  if (apt.status == AppointmentStatus.confirmed || apt.status == AppointmentStatus.upcoming) ...[
                    AarogyaButton(
                      label: 'Cancel',
                      variant: AarogyaButtonVariant.destructive,
                      size: AarogyaButtonSize.sm,
                      onPressed: () {
                        repo.cancelAppointment(apt.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appointment cancelled successfully.')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  AarogyaButton(
                    label: apt.status == AppointmentStatus.completed ? 'View Prescription' : 'Consultation Info',
                    variant: AarogyaButtonVariant.secondary,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Viewing consultation details for ${apt.id}')),
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
