import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell/adaptive_shell.dart';
import '../../../core/clinical/ews_triage_calculator.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/motion/aarogya_motion.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/queue_entry.dart';
import '../../../shared/state/aarogya_providers.dart';

class PatientQueueScreen extends ConsumerStatefulWidget {
  const PatientQueueScreen({super.key});

  @override
  ConsumerState<PatientQueueScreen> createState() => _PatientQueueScreenState();
}

class _PatientQueueScreenState extends ConsumerState<PatientQueueScreen> {
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(liveQueueProvider);
    final repo = ref.read(repositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    final consulting = queue
        .where((q) => q.status == QueueStatus.consulting)
        .toList();
    final waiting = queue
        .where((q) => q.status == QueueStatus.waiting)
        .toList();
    final urgentWaiting = waiting
        .where(
          (q) =>
              q.priority == PatientPriority.emergency ||
              q.priority == PatientPriority.urgent,
        )
        .toList();
    final completed = queue
        .where((q) => q.status == QueueStatus.completed)
        .toList();

    // Clinically sorted queue:
    // 1. Consulting in chamber
    // 2. Urgent / Emergency waiting patients (pop-up at first in waiting list)
    // 3. Regular waiting patients
    // 4. Completed / Skipped
    final sortedQueue = List<QueueEntry>.from(queue)..sort(_compareEntries);

    // Apply triage filter
    final filteredQueue = sortedQueue.where((entry) {
      switch (_activeFilter) {
        case 'Urgent':
          return entry.priority == PatientPriority.emergency ||
              entry.priority == PatientPriority.urgent;
        case 'Waiting':
          return entry.status == QueueStatus.waiting;
        case 'Consulting':
          return entry.status == QueueStatus.consulting;
        case 'Completed':
          return entry.status == QueueStatus.completed;
        case 'All':
        default:
          return true;
      }
    }).toList();

    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 24,
          vertical: isMobile ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Header & Primary Clinical Actions
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'OPD Patient Queue',
                          style: AarogyaTypography.headingLarge(primaryText),
                        ),
                        if (urgentWaiting.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AarogyaColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AarogyaColors.warning.withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AarogyaPulseBeacon(
                                  color: AarogyaColors.warning,
                                  size: 4,
                                  animate: true,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${urgentWaiting.length} Urgent',
                                  style: AarogyaTypography.caption(
                                    AarogyaColors.warning,
                                  ).copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Live triage queue • Urgent cases prioritized automatically',
                      style: AarogyaTypography.bodyMedium(secondaryText),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (consulting.isNotEmpty)
                      AarogyaButton(
                        label: 'Open Workspace',
                        icon: Icons.medical_services_rounded,
                        variant: AarogyaButtonVariant.secondary,
                        onPressed: () {
                          // Switch to Clinical Workspace Tab (Tab index 2)
                          ref.read(selectedTabIndexProvider.notifier).state = 2;
                        },
                      ),
                    AarogyaButton(
                      label: urgentWaiting.isNotEmpty
                          ? 'Call Urgent Next'
                          : 'Call Next Patient',
                      icon: urgentWaiting.isNotEmpty
                          ? Icons.notification_important_rounded
                          : Icons.record_voice_over_rounded,
                      onPressed: () {
                        final called = repo.callNextInQueue();
                        if (called != null) {
                          final isUrgent =
                              called.priority == PatientPriority.emergency ||
                              called.priority == PatientPriority.urgent;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    isUrgent
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isUrgent
                                          ? 'Urgent Patient #${called.tokenNumber} ${called.patientName} called to chamber.'
                                          : 'Patient #${called.tokenNumber} ${called.patientName} called into chamber.',
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: isUrgent
                                  ? AarogyaColors.warning
                                  : AarogyaColors.primaryCyan,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No waiting patients in queue.'),
                              backgroundColor: AarogyaColors.textDarkSecondary,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Queue stats HUD strip (Triage-focused)
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQueueMetricItem(
                      'Consulting',
                      consulting.length,
                      AarogyaColors.primaryCyan,
                      isDark,
                    ),
                  ),
                  _buildMetricDivider(isDark),
                  Expanded(
                    child: _buildQueueMetricItem(
                      'Urgent Triage',
                      urgentWaiting.length,
                      urgentWaiting.isNotEmpty
                          ? AarogyaColors.warning
                          : AarogyaColors.textDarkSecondary,
                      isDark,
                      hasPulse: urgentWaiting.isNotEmpty,
                    ),
                  ),
                  _buildMetricDivider(isDark),
                  Expanded(
                    child: _buildQueueMetricItem(
                      'In Lobby',
                      waiting.length,
                      AarogyaColors.warning,
                      isDark,
                    ),
                  ),
                  _buildMetricDivider(isDark),
                  Expanded(
                    child: _buildQueueMetricItem(
                      'Completed',
                      completed.length,
                      AarogyaColors.success,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Urgent Priority Notice Banner (Pops up whenever urgent patients are waiting)
            if (urgentWaiting.isNotEmpty && _activeFilter != 'Completed') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AarogyaColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AarogyaColors.warning.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AarogyaColors.warning.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.priority_high_rounded,
                        color: AarogyaColors.warning,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'URGENT TRIAGE PRIORITY: #${urgentWaiting.first.tokenNumber} ${urgentWaiting.first.patientName}',
                            style: AarogyaTypography.caption(AarogyaColors.warning)
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            urgentWaiting.first.chiefComplaint,
                            style: AarogyaTypography.caption(primaryText)
                                .copyWith(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AarogyaButton(
                      label: 'Call Urgently',
                      icon: Icons.phone_in_talk_rounded,
                      size: AarogyaButtonSize.sm,
                      variant: AarogyaButtonVariant.primary,
                      onPressed: () {
                        repo.updateQueueStatus(
                          urgentWaiting.first.id,
                          QueueStatus.consulting,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Urgent Patient #${urgentWaiting.first.tokenNumber} ${urgentWaiting.first.patientName} called to chamber.',
                            ),
                            backgroundColor: AarogyaColors.warning,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Clinical Triage Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'All',
                    'All (${queue.length})',
                    isDark,
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    'Urgent',
                    'Urgent Triage (${urgentWaiting.length})',
                    isDark,
                    color: AarogyaColors.warning,
                    highlight: urgentWaiting.isNotEmpty,
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    'Waiting',
                    'In Lobby (${waiting.length})',
                    isDark,
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    'Consulting',
                    'In Chamber (${consulting.length})',
                    isDark,
                    color: AarogyaColors.primaryCyan,
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    'Completed',
                    'Completed (${completed.length})',
                    isDark,
                    color: AarogyaColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Queue List (Urgent patients pop-up first by default)
            Expanded(
              child: filteredQueue.isEmpty
                  ? AarogyaEmptyState(
                      icon: Icons.groups_outlined,
                      title: _activeFilter == 'Urgent'
                          ? 'No Urgent Triage Patients'
                          : 'Queue is Empty',
                      description: _activeFilter == 'Urgent'
                          ? 'All patients in the lobby are routine OPD consultations.'
                          : 'No patients found matching the selected filter.',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 850;
                        if (!isWide) {
                          return ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: filteredQueue.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final entry = filteredQueue[index];
                              return _buildQueueCard(
                                context,
                                entry,
                                repo,
                                isDark,
                                primaryText,
                                secondaryText,
                              );
                            },
                          );
                        }
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: filteredQueue.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 195,
                          ),
                          itemBuilder: (context, index) {
                            final entry = filteredQueue[index];
                            return _buildQueueCard(
                              context,
                              entry,
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
    );
  }

  Widget _buildMetricDivider(bool isDark) {
    return Container(
      width: 1,
      height: 28,
      color: isDark
          ? AarogyaColors.darkGlassBorderSubtle
          : AarogyaColors.lightGlassBorderSubtle,
    );
  }

  Widget _buildFilterChip(
    String key,
    String label,
    bool isDark, {
    Color? color,
    bool highlight = false,
  }) {
    final isSelected = _activeFilter == key;
    final activeColor = color ??
        (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue);

    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.16)
              : (highlight
                  ? AarogyaColors.warning.withValues(alpha: 0.08)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (highlight
                    ? AarogyaColors.warning.withValues(alpha: 0.35)
                    : (isDark
                        ? AarogyaColors.darkGlassBorderSubtle
                        : AarogyaColors.lightGlassBorderSubtle)),
            width: isSelected || highlight ? 1.2 : 0.9,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (highlight) ...[
              const AarogyaPulseBeacon(
                color: AarogyaColors.warning,
                size: 3.5,
                animate: true,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? activeColor
                    : (highlight
                        ? AarogyaColors.warning
                        : (isDark
                            ? AarogyaColors.textDarkSecondary
                            : AarogyaColors.textLightSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueMetricItem(
    String label,
    int count,
    Color color,
    bool isDark, {
    bool hasPulse = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasPulse)
              AarogyaPulseBeacon(color: color, size: 4.5, animate: true)
            else
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: AarogyaTypography.headingMedium(color)
                  .copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AarogyaTypography.caption(
            isDark
                ? AarogyaColors.textDarkSecondary
                : AarogyaColors.textLightSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQueueCard(
    BuildContext context,
    QueueEntry entry,
    dynamic repo,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    Color statusColor;
    switch (entry.status) {
      case QueueStatus.consulting:
        statusColor = AarogyaColors.primaryCyan;
        break;
      case QueueStatus.completed:
        statusColor = AarogyaColors.success;
        break;
      case QueueStatus.skipped:
        statusColor = AarogyaColors.critical;
        break;
      case QueueStatus.waiting:
        statusColor = entry.priority == PatientPriority.emergency
            ? AarogyaColors.critical
            : (entry.priority == PatientPriority.urgent
                ? AarogyaColors.warning
                : AarogyaColors.primaryCyan);
    }

    final isUrgent = entry.priority == PatientPriority.emergency ||
        entry.priority == PatientPriority.urgent;
    final isConsulting = entry.status == QueueStatus.consulting;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      glowColor: isUrgent && entry.status == QueueStatus.waiting
          ? AarogyaColors.warning
          : null,
      customBorder: isUrgent && entry.status == QueueStatus.waiting
          ? Border.all(
              color: AarogyaColors.warning.withValues(alpha: 0.5),
              width: 1.2,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier 1: Token, Name, Triage Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isUrgent && entry.status == QueueStatus.waiting
                          ? AarogyaColors.warning
                          : statusColor)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (isUrgent && entry.status == QueueStatus.waiting
                            ? AarogyaColors.warning
                            : statusColor)
                        .withValues(alpha: 0.35),
                    width: isUrgent ? 1.5 : 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    '#${entry.tokenNumber}',
                    style: AarogyaTypography.title(
                      isUrgent && entry.status == QueueStatus.waiting
                          ? AarogyaColors.warning
                          : statusColor,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.patientName,
                      style: AarogyaTypography.title(primaryText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.age} Yrs • ${entry.gender} • ${AarogyaFormatters.timeAgo(entry.checkInTime)}',
                      style: AarogyaTypography.caption(secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (entry.priority == PatientPriority.emergency
                                  ? AarogyaColors.critical
                                  : (entry.priority == PatientPriority.urgent
                                        ? AarogyaColors.warning
                                        : AarogyaColors.primaryCyan))
                              .withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            (entry.priority == PatientPriority.emergency
                                    ? AarogyaColors.critical
                                    : (entry.priority == PatientPriority.urgent
                                          ? AarogyaColors.warning
                                          : AarogyaColors.primaryCyan))
                                .withValues(alpha: 0.35),
                        width: 0.9,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isUrgent) ...[
                          AarogyaPulseBeacon(
                            color: entry.priority == PatientPriority.emergency
                                ? AarogyaColors.critical
                                : AarogyaColors.warning,
                            size: 4,
                            animate: true,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          entry.priority.displayName,
                          style: AarogyaTypography.caption(
                            entry.priority == PatientPriority.emergency
                                ? AarogyaColors.critical
                                : (entry.priority == PatientPriority.urgent
                                      ? AarogyaColors.warning
                                      : AarogyaColors.primaryCyan),
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 9.5),
                        ),
                      ],
                    ),
                  ),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.28),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AarogyaPulseBeacon(
                          color: statusColor,
                          size: 4.5,
                          animate: entry.status == QueueStatus.consulting,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.status.displayName,
                          style: AarogyaTypography.caption(statusColor)
                              .copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 9.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // EWS (NEWS2) Acuity Score Badge
                  if (entry.ewsScore != null || entry.vitals != null) ...[
                    Builder(
                      builder: (context) {
                        final ewsResult = entry.vitals != null
                            ? EwsTriageCalculator.calculate(entry.vitals!)
                            : null;
                        final score = entry.ewsScore ?? ewsResult?.totalScore ?? 0;
                        final Color ewsColor = score >= 5
                            ? AarogyaColors.critical
                            : (score >= 3
                                ? AarogyaColors.warning
                                : AarogyaColors.success);

                        return Tooltip(
                          message: 'National Early Warning Score (NEWS2): $score. Click for clinical breakdown.',
                          child: InkWell(
                            onTap: () => _showEwsBreakdownSheet(context, entry, ewsResult),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: ewsColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: ewsColor.withValues(alpha: 0.35),
                                  width: 0.9,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.speed_rounded,
                                    size: 11,
                                    color: ewsColor,
                                  ),
                                  const SizedBox(width: 3.5),
                                  Text(
                                    'NEWS2: $score',
                                    style: AarogyaTypography.caption(ewsColor)
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 9.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tier 2: Chief Complaint & Triage Notes
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isUrgent && entry.status == QueueStatus.waiting
                  ? AarogyaColors.warning.withValues(alpha: 0.08)
                  : (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.04,
                    ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isUrgent && entry.status == QueueStatus.waiting
                    ? AarogyaColors.warning.withValues(alpha: 0.25)
                    : (isDark
                        ? AarogyaColors.darkGlassBorderSubtle
                        : AarogyaColors.lightGlassBorderSubtle),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUrgent) ...[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AarogyaColors.warning,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    entry.chiefComplaint,
                    style: AarogyaTypography.caption(primaryText).copyWith(
                      fontWeight: isUrgent ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Tier 3: Doctor Action Buttons
          if (entry.status == QueueStatus.waiting ||
              entry.status == QueueStatus.consulting) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (entry.status == QueueStatus.waiting) ...[
                  AarogyaButton(
                    label: 'Skip',
                    variant: AarogyaButtonVariant.ghost,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      repo.updateQueueStatus(entry.id, QueueStatus.skipped);
                    },
                  ),
                  const SizedBox(width: 8),
                  AarogyaButton(
                    label: isUrgent ? 'Call Urgently' : 'Call Patient',
                    icon: isUrgent
                        ? Icons.notification_important_rounded
                        : Icons.phone_in_talk_rounded,
                    size: AarogyaButtonSize.sm,
                    variant: isUrgent
                        ? AarogyaButtonVariant.primary
                        : AarogyaButtonVariant.secondary,
                    onPressed: () {
                      repo.updateQueueStatus(entry.id, QueueStatus.consulting);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Patient #${entry.tokenNumber} ${entry.patientName} called into chamber.',
                          ),
                          backgroundColor: isUrgent
                              ? AarogyaColors.warning
                              : AarogyaColors.primaryCyan,
                        ),
                      );
                    },
                  ),
                ] else if (isConsulting) ...[
                  AarogyaButton(
                    label: 'Consultation Workspace',
                    icon: Icons.edit_note_rounded,
                    variant: AarogyaButtonVariant.secondary,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      ref.read(selectedTabIndexProvider.notifier).state = 2;
                    },
                  ),
                  const SizedBox(width: 8),
                  AarogyaButton(
                    label: 'Mark Done',
                    icon: Icons.check_circle_outline_rounded,
                    variant: AarogyaButtonVariant.primary,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      repo.updateQueueStatus(entry.id, QueueStatus.completed);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Consultation for #${entry.tokenNumber} ${entry.patientName} completed.',
                          ),
                          backgroundColor: AarogyaColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showEwsBreakdownSheet(
    BuildContext context,
    QueueEntry entry,
    EwsTriageResult? precalculated,
  ) {
    final result = precalculated ??
        (entry.vitals != null
            ? EwsTriageCalculator.calculate(entry.vitals!)
            : null);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    final score = entry.ewsScore ?? result?.totalScore ?? 0;
    final Color scoreColor = score >= 5
        ? AarogyaColors.critical
        : (score >= 3 ? AarogyaColors.warning : AarogyaColors.success);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141824) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark
                  ? AarogyaColors.darkGlassBorderSubtle
                  : AarogyaColors.lightGlassBorderSubtle,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: secondaryText.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEWS2 Clinical Triage Assessment',
                          style: AarogyaTypography.headingMedium(primaryText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Patient: ${entry.patientName} (${entry.age} Yrs • ${entry.gender})',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Acuity Score Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scoreColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$score',
                        style: AarogyaTypography.headingLarge(scoreColor)
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result?.riskCategory ??
                                (score >= 5
                                    ? 'High Clinical Risk (Emergency)'
                                    : (score >= 3
                                        ? 'Medium Clinical Risk (Urgent)'
                                        : 'Low Clinical Risk (Routine)')),
                            style: AarogyaTypography.title(scoreColor)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            result?.clinicalSummary ??
                                'Automated early warning score calculated on clinical presentation.',
                            style: AarogyaTypography.caption(secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (result != null && result.criticalAlerts.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...result.criticalAlerts.map(
                  (alert) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AarogyaColors.critical.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AarogyaColors.critical.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AarogyaColors.critical,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert,
                            style: AarogyaTypography.caption(
                              AarogyaColors.critical,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),
              Text(
                'Physiological Parameters Breakdown',
                style: AarogyaTypography.label(primaryText),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: result != null && result.parameters.isNotEmpty
                    ? ListView.separated(
                        shrinkWrap: true,
                        itemCount: result.parameters.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final p = result.parameters[idx];
                          final pColor = p.points == 3
                              ? AarogyaColors.critical
                              : (p.points > 0
                                  ? AarogyaColors.warning
                                  : AarogyaColors.success);

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark ? Colors.white : Colors.black)
                                  .withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? AarogyaColors.darkGlassBorderSubtle
                                    : AarogyaColors.lightGlassBorderSubtle,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.parameterName,
                                        style: AarogyaTypography.bodyMedium(primaryText)
                                            .copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        p.clinicalInterpretation,
                                        style: AarogyaTypography.caption(
                                          secondaryText,
                                        ).copyWith(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      p.observedValue,
                                      style: AarogyaTypography.label(primaryText)
                                          .copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '+${p.points} pts',
                                        style: AarogyaTypography.caption(pColor)
                                            .copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'No individual parameter details available for this record.',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AarogyaButton(
                  label: 'Close Triage Review',
                  variant: AarogyaButtonVariant.primary,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Clinical prioritization comparison:
  // 1. Patient currently consulting in chamber
  // 2. Waiting patients (Emergency > Urgent > Normal)
  // 3. Token number
  // 4. Completed / Skipped
  static int _compareEntries(QueueEntry a, QueueEntry b) {
    // 1. Active consultation first
    if (a.status == QueueStatus.consulting &&
        b.status != QueueStatus.consulting) {
      return -1;
    }
    if (b.status == QueueStatus.consulting &&
        a.status != QueueStatus.consulting) {
      return 1;
    }

    // 2. Waiting patients before others
    if (a.status == QueueStatus.waiting && b.status != QueueStatus.waiting) {
      return -1;
    }
    if (b.status == QueueStatus.waiting && a.status != QueueStatus.waiting) {
      return 1;
    }

    // 3. Among waiting patients, Urgent & Emergency pop up at first
    if (a.status == QueueStatus.waiting && b.status == QueueStatus.waiting) {
      const priorityWeights = {
        PatientPriority.emergency: 0,
        PatientPriority.urgent: 1,
        PatientPriority.normal: 2,
      };
      final weightA = priorityWeights[a.priority] ?? 2;
      final weightB = priorityWeights[b.priority] ?? 2;
      if (weightA != weightB) {
        return weightA.compareTo(weightB);
      }
    }

    // 4. Token number
    return a.tokenNumber.compareTo(b.tokenNumber);
  }
}
