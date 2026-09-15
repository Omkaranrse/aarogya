import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_empty_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/queue_entry.dart';
import '../../../shared/state/aarogya_providers.dart';

class PatientQueueScreen extends ConsumerWidget {
  const PatientQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(liveQueueProvider);
    final repo = ref.read(repositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final waiting = queue.where((q) => q.status == QueueStatus.waiting).toList();
    final consulting = queue.where((q) => q.status == QueueStatus.consulting).toList();
    final completed = queue.where((q) => q.status == QueueStatus.completed).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? AarogyaSpacing.md : AarogyaSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Live OPD Queue Manager', style: AarogyaTypography.headingLarge(primaryText)),
                    Text(
                      'Real-time token sequence and patient triage status',
                      style: AarogyaTypography.bodyMedium(secondaryText),
                    ),
                  ],
                ),
                AarogyaButton(
                  label: 'Call Next in Queue',
                  icon: Icons.record_voice_over_rounded,
                  onPressed: () {
                    repo.callNextInQueue();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Next patient called into consultation room.'),
                        backgroundColor: AarogyaColors.primaryCyan,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AarogyaSpacing.lg),

            // Queue stats HUD strip
            GlassCard(
              glowColor: AarogyaColors.primaryCyan,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQueueMetricItem('Consulting', consulting.length, AarogyaColors.primaryCyan, isDark),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
                  ),
                  Expanded(
                    child: _buildQueueMetricItem('In Lobby', waiting.length, AarogyaColors.warning, isDark),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
                  ),
                  Expanded(
                    child: _buildQueueMetricItem('Completed', completed.length, AarogyaColors.success, isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AarogyaSpacing.lg),

            // Queue List
            Expanded(
              child: queue.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.groups_outlined,
                      title: 'Queue is Empty',
                      description: 'No patients checked into today’s OPD schedule.',
                    )
                  : ListView.separated(
                      itemCount: queue.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AarogyaSpacing.md),
                      itemBuilder: (context, index) {
                        final entry = queue[index];
                        return _buildQueueCard(context, entry, repo, isDark, primaryText, secondaryText);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueMetricItem(String label, int count, Color color, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: AarogyaTypography.headingMedium(color).copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AarogyaTypography.caption(isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary),
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
    Color glowColor;
    AarogyaBadgeVariant statusBadgeVariant;

    switch (entry.status) {
      case QueueStatus.consulting:
        glowColor = AarogyaColors.primaryCyan;
        statusBadgeVariant = AarogyaBadgeVariant.cyan;
        break;
      case QueueStatus.completed:
        glowColor = AarogyaColors.success;
        statusBadgeVariant = AarogyaBadgeVariant.success;
        break;
      case QueueStatus.skipped:
        glowColor = AarogyaColors.critical;
        statusBadgeVariant = AarogyaBadgeVariant.critical;
        break;
      case QueueStatus.waiting:
        glowColor = AarogyaColors.warning;
        statusBadgeVariant = AarogyaBadgeVariant.warning;
    }

    final isMobile = Responsive.isMobile(context);

    return GlassCard(
      glowColor: glowColor,
      padding: AarogyaSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier 1: Token, Name, and Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: glowColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: glowColor.withValues(alpha: 0.35)),
                ),
                child: Center(
                  child: Text(
                    '#${entry.tokenNumber}',
                    style: AarogyaTypography.title(glowColor).copyWith(fontWeight: FontWeight.w800),
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
                      '${entry.age} Yrs • ${entry.gender} • In queue ${AarogyaFormatters.timeAgo(entry.checkInTime)}',
                      style: AarogyaTypography.caption(secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  AarogyaBadge(
                    label: entry.priority.displayName,
                    variant: entry.priority == PatientPriority.emergency
                        ? AarogyaBadgeVariant.critical
                        : (entry.priority == PatientPriority.urgent ? AarogyaBadgeVariant.warning : AarogyaBadgeVariant.info),
                    showDot: false,
                  ),
                  AarogyaBadge(
                    label: entry.status.displayName,
                    variant: statusBadgeVariant,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tier 2: Chief Complaint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Complaint: ${entry.chiefComplaint}',
              style: AarogyaTypography.caption(secondaryText).copyWith(
                color: isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Tier 3: Action Buttons
          if (entry.status == QueueStatus.waiting || entry.status == QueueStatus.consulting) ...[
            const SizedBox(height: 10),
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
                    label: 'Call Patient',
                    icon: Icons.phone_in_talk_rounded,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      repo.updateQueueStatus(entry.id, QueueStatus.consulting);
                    },
                  ),
                ] else if (entry.status == QueueStatus.consulting) ...[
                  AarogyaButton(
                    label: 'Mark Done',
                    icon: Icons.check_circle_outline_rounded,
                    variant: AarogyaButtonVariant.primary,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      repo.updateQueueStatus(entry.id, QueueStatus.completed);
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
}
