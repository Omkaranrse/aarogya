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
import '../../../core/design_system/components/stat_card.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/queue_entry.dart';
import '../../../shared/state/aarogya_providers.dart';

class DoctorDashboard extends ConsumerWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final queue = ref.watch(liveQueueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    final consultingPatient = queue.cast<QueueEntry?>().firstWhere(
      (q) => q?.status == QueueStatus.consulting,
      orElse: () => null,
    );

    final waitingCount = queue
        .where((q) => q.status == QueueStatus.waiting)
        .length;
    final urgentCount = queue
        .where(
          (q) =>
              q.status == QueueStatus.waiting &&
              (q.priority == PatientPriority.emergency ||
                  q.priority == PatientPriority.urgent),
        )
        .length;
    final completedCount = queue
        .where((q) => q.status == QueueStatus.completed)
        .length;

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
              // Doctor Header & Clinical Duty Card
              GlassCard(
                padding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
                    : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    AarogyaAvatar(
                      name: user.name,
                      imageUrl: user.avatarUrl,
                      size: isMobile ? 52 : 48,
                      isOnline: true,
                    ),
                    const SizedBox(width: 12),
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
                                user.name,
                                style: AarogyaTypography.title(primaryText)
                                    .copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.department ?? "Cardiology",
                            style: AarogyaTypography.caption(secondaryText),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile)
                      AarogyaButton(
                        label: 'Manage Live Queue',
                        icon: Icons.groups_rounded,
                        onPressed: () {
                          ref.read(selectedTabIndexProvider.notifier).state =
                              1; // Queue tab
                        },
                      )
                    else
                      IconButton(
                        tooltip: 'Manage Live Queue',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              (isDark
                                      ? AarogyaColors.primaryCyan
                                      : AarogyaColors.primaryBlue)
                                  .withValues(alpha: 0.15),
                        ),
                        icon: Icon(
                          Icons.groups_rounded,
                          color: isDark
                              ? AarogyaColors.primaryCyan
                              : AarogyaColors.primaryBlue,
                          size: 20,
                        ),
                        onPressed: () {
                          ref.read(selectedTabIndexProvider.notifier).state =
                              1; // Queue tab
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),

              // Clinical KPIs
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 750;
                  return GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isMobile ? 1.45 : (isWide ? 2.1 : 1.7),
                    children: [
                      StatCard(
                        title: 'Patients in Queue',
                        value: '$waitingCount Waiting',
                        subtitle: 'Avg wait: 14 mins',
                        icon: Icons.hourglass_top_rounded,
                        accentColor: AarogyaColors.warning,
                      ),
                      StatCard(
                        title: 'Completed Visits',
                        value: '$completedCount Consults',
                        subtitle: 'Target: 15 / day',
                        icon: Icons.check_circle_outline_rounded,
                        accentColor: AarogyaColors.success,
                        trendPercent: 12.5,
                      ),
                      const StatCard(
                        title: 'Pending Lab Reviews',
                        value: '3 Reports',
                        subtitle: '1 Abnormal flagged',
                        icon: Icons.biotech_rounded,
                        accentColor: AarogyaColors.critical,
                      ),
                      StatCard(
                        title: 'Urgent Triage',
                        value: '$urgentCount Flagged',
                        subtitle: urgentCount > 0
                            ? 'Requires immediate attention'
                            : 'All patients routine',
                        icon: Icons.emergency_rounded,
                        accentColor: urgentCount > 0
                            ? AarogyaColors.critical
                            : AarogyaColors.primaryCyan,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: isMobile ? 8 : 14),

              // Now Consulting Hero Banner
              Text(
                'Active Clinical Session',
                style: AarogyaTypography.headingMedium(primaryText),
              ),
              const SizedBox(height: 6),
              if (consultingPatient != null)
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  (isDark
                                          ? AarogyaColors.primaryCyan
                                          : AarogyaColors.primaryBlue)
                                      .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.medical_services_rounded,
                              color: isDark
                                  ? AarogyaColors.primaryCyan
                                  : AarogyaColors.primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                    Text(
                                      'Token #${consultingPatient.tokenNumber} • ${consultingPatient.patientName}',
                                      style: AarogyaTypography.title(
                                        primaryText,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AarogyaColors.primaryCyan
                                            .withValues(alpha: 0.14),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AarogyaColors.primaryCyan
                                              .withValues(alpha: 0.35),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const AarogyaPulseBeacon(
                                            color: AarogyaColors.primaryCyan,
                                            size: 5,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'IN CLINIC',
                                            style:
                                                AarogyaTypography.caption(
                                                  AarogyaColors.primaryCyan,
                                                ).copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 9.5,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${consultingPatient.age} Yrs • ${consultingPatient.gender} • ${consultingPatient.priority.displayName}',
                                  style: AarogyaTypography.caption(
                                    secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AarogyaSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (isDark
                                      ? AarogyaColors.darkSurface
                                      : AarogyaColors.lightBg)
                                  .withValues(alpha: 0.5),
                          borderRadius: AarogyaRadius.radiusMd,
                          border: Border.all(
                            color: isDark
                                ? AarogyaColors.darkGlassBorderSubtle
                                : AarogyaColors.lightGlassBorderSubtle,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notes_rounded,
                              size: 16,
                              color: AarogyaColors.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                consultingPatient.chiefComplaint,
                                style: AarogyaTypography.bodyMedium(
                                  primaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AarogyaSpacing.md),
                      AarogyaButton(
                        label: 'Open Clinical Workspace',
                        icon: Icons.edit_note_rounded,
                        size: AarogyaButtonSize.md,
                        fullWidth: true,
                        onPressed: () {
                          ref.read(selectedTabIndexProvider.notifier).state =
                              2; // Consultation tab
                        },
                      ),
                    ],
                  ),
                )
              else
                GlassCard(
                  padding: AarogyaSpacing.paddingLg,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      Text(
                        'No active patient in consultation room.',
                        style: AarogyaTypography.bodyLarge(secondaryText),
                      ),
                      AarogyaButton(
                        label: 'Call Next Patient',
                        icon: Icons.notifications_active_rounded,
                        onPressed: () {
                          ref.read(repositoryProvider).callNextInQueue();
                        },
                      ),
                    ],
                  ),
                ),

              // Web-Only: Live OPD Queue Stream & Fast Clinical Hub
              if (!isMobile) ...[
                const SizedBox(height: 16),
                _buildWebQueueAndScheduleSection(
                  context,
                  ref,
                  queue,
                  isDark,
                  primaryText,
                  secondaryText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebQueueAndScheduleSection(
    BuildContext context,
    WidgetRef ref,
    List<QueueEntry> queue,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final waiting = queue
        .where((q) => q.status == QueueStatus.waiting)
        .toList();
    final completed = queue
        .where((q) => q.status == QueueStatus.completed)
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Upcoming OPD Queue Stream
        Expanded(
          flex: 3,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            size: 20,
                            color: isDark
                                ? AarogyaColors.primaryCyan
                                : AarogyaColors.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Next in Queue (Waiting Patients)',
                              style: AarogyaTypography.title(primaryText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (waiting.isNotEmpty
                                    ? AarogyaColors.warning
                                    : AarogyaColors.success)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              (waiting.isNotEmpty
                                      ? AarogyaColors.warning
                                      : AarogyaColors.success)
                                  .withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${waiting.length} Waiting',
                        style: AarogyaTypography.caption(
                          waiting.isNotEmpty
                              ? AarogyaColors.warning
                              : AarogyaColors.success,
                        ).copyWith(fontWeight: FontWeight.w700, fontSize: 10.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (waiting.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'All OPD queue patients have been consulted.',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ),
                  )
                else
                  ...waiting.take(4).map((patient) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AarogyaColors.darkSurface
                                    : AarogyaColors.lightBg)
                                .withValues(alpha: 0.5),
                        borderRadius: AarogyaRadius.radiusMd,
                        border: Border.all(
                          color: isDark
                              ? AarogyaColors.darkGlassBorderSubtle
                              : AarogyaColors.lightGlassBorderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isDark
                                          ? AarogyaColors.primaryCyan
                                          : AarogyaColors.primaryBlue)
                                      .withValues(alpha: 0.15),
                              borderRadius: AarogyaRadius.radiusSm,
                            ),
                            child: Text(
                              '#${patient.tokenNumber}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isDark
                                    ? AarogyaColors.primaryCyan
                                    : AarogyaColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  patient.patientName,
                                  style: AarogyaTypography.bodyMedium(
                                    primaryText,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${patient.age}Y • ${patient.gender} • ${patient.chiefComplaint}',
                                  style: AarogyaTypography.caption(
                                    secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (patient.priority == PatientPriority.emergency
                                          ? AarogyaColors.critical
                                          : (patient.priority ==
                                                    PatientPriority.urgent
                                                ? AarogyaColors.warning
                                                : AarogyaColors.primaryCyan))
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    (patient.priority ==
                                                PatientPriority.emergency
                                            ? AarogyaColors.critical
                                            : (patient.priority ==
                                                      PatientPriority.urgent
                                                  ? AarogyaColors.warning
                                                  : AarogyaColors.primaryCyan))
                                        .withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              patient.priority.displayName.toUpperCase(),
                              style:
                                  AarogyaTypography.caption(
                                    patient.priority ==
                                            PatientPriority.emergency
                                        ? AarogyaColors.critical
                                        : (patient.priority ==
                                                  PatientPriority.urgent
                                              ? AarogyaColors.warning
                                              : AarogyaColors.primaryCyan),
                                  ).copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 9,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                            ),
                            tooltip: 'View in Queue',
                            onPressed: () {
                              ref
                                      .read(selectedTabIndexProvider.notifier)
                                      .state =
                                  1;
                            },
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Right Column: Fast Clinical Hub & Completed Visits
        Expanded(
          flex: 2,
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Clinical Shortcuts',
                          style: AarogyaTypography.title(primaryText),
                        ),
                        Icon(
                          Icons.bolt_rounded,
                          size: 18,
                          color: isDark
                              ? AarogyaColors.primaryCyan
                              : AarogyaColors.primaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: AarogyaRadius.radiusMd,
                            onTap: () =>
                                ref
                                        .read(selectedTabIndexProvider.notifier)
                                        .state =
                                    3, // Prescriptions
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (isDark
                                            ? AarogyaColors.darkSurface
                                            : AarogyaColors.lightBg)
                                        .withValues(alpha: 0.5),
                                borderRadius: AarogyaRadius.radiusMd,
                                border: Border.all(
                                  color: isDark
                                      ? AarogyaColors.darkGlassBorderSubtle
                                      : AarogyaColors.lightGlassBorderSubtle,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.medication_rounded,
                                    size: 20,
                                    color: AarogyaColors.success,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Prescriptions',
                                    style: AarogyaTypography.bodySmall(
                                      primaryText,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Active Rx drafts',
                                    style: AarogyaTypography.caption(
                                      secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            borderRadius: AarogyaRadius.radiusMd,
                            onTap: () =>
                                ref
                                        .read(selectedTabIndexProvider.notifier)
                                        .state =
                                    4, // Labs
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (isDark
                                            ? AarogyaColors.darkSurface
                                            : AarogyaColors.lightBg)
                                        .withValues(alpha: 0.5),
                                borderRadius: AarogyaRadius.radiusMd,
                                border: Border.all(
                                  color: isDark
                                      ? AarogyaColors.darkGlassBorderSubtle
                                      : AarogyaColors.lightGlassBorderSubtle,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.biotech_rounded,
                                    size: 20,
                                    color: AarogyaColors.accentPurple,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Lab Results',
                                    style: AarogyaTypography.bodySmall(
                                      primaryText,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '3 pending review',
                                    style: AarogyaTypography.caption(
                                      secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Consultations',
                          style: AarogyaTypography.title(primaryText),
                        ),
                        Text(
                          '${completed.length} Today',
                          style: AarogyaTypography.caption(
                            AarogyaColors.success,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (completed.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'No completed consultations yet today.',
                            style: AarogyaTypography.caption(secondaryText),
                          ),
                        ),
                      )
                    else
                      ...completed.take(3).map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AarogyaColors.success,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Token #${p.tokenNumber} • ${p.patientName}',
                                  style: AarogyaTypography.bodySmall(
                                    primaryText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const AarogyaBadge(
                                label: 'Done',
                                variant: AarogyaBadgeVariant.success,
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
