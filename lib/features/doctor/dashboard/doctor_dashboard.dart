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

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final consultingPatient = queue.cast<QueueEntry?>().firstWhere(
          (q) => q?.status == QueueStatus.consulting,
          orElse: () => null,
        );

    final waitingCount = queue.where((q) => q.status == QueueStatus.waiting).length;
    final completedCount = queue.where((q) => q.status == QueueStatus.completed).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? AarogyaSpacing.md : AarogyaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Header & Clinical Duty Card
          GlassCard(
            glowColor: AarogyaColors.primaryCyan,
            padding: Responsive.isMobile(context)
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
                : AarogyaSpacing.paddingXl,
            child: Row(
              children: [
                AarogyaAvatar(
                  name: user.name,
                  imageUrl: user.avatarUrl,
                  size: 54,
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
                          Text(user.name, style: AarogyaTypography.headingLarge(primaryText)),
                          const AarogyaBadge(label: 'On OPD Duty', variant: AarogyaBadgeVariant.success),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${user.specialty ?? "Senior Consultant"} • ${user.department ?? "Cardiology"} • Room 204',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  AarogyaButton(
                    label: 'Manage Live Queue',
                    icon: Icons.groups_rounded,
                    onPressed: () {
                      ref.read(selectedTabIndexProvider.notifier).state = 1; // Queue tab
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Clinical KPIs
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 750;
            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isWide ? 1.6 : 1.45,
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
                const StatCard(
                  title: "Today's OPD Revenue",
                  value: '₹14,400',
                  subtitle: '12 invoices settled',
                  icon: Icons.account_balance_wallet_rounded,
                  accentColor: AarogyaColors.primaryCyan,
                  trendPercent: 8.2,
                ),
              ],
            );
          }),
          const SizedBox(height: 10),

          // Now Consulting Hero Banner
          Text('Active Clinical Session', style: AarogyaTypography.headingMedium(primaryText)),
          const SizedBox(height: 6),
          if (consultingPatient != null)
            GlassCard(
              glowColor: AarogyaColors.primaryCyan,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AarogyaColors.primaryCyan.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.medical_services_rounded, color: AarogyaColors.primaryCyan, size: 22),
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
                                  style: AarogyaTypography.title(primaryText).copyWith(fontWeight: FontWeight.w800),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                AarogyaBadge(
                                  label: 'NOW IN CLINIC',
                                  variant: consultingPatient.priority == PatientPriority.emergency
                                      ? AarogyaBadgeVariant.critical
                                      : AarogyaBadgeVariant.success,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${consultingPatient.age} Yrs • ${consultingPatient.gender} • Priority: ${consultingPatient.priority.displayName}',
                              style: AarogyaTypography.caption(secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AarogyaSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? AarogyaColors.darkSurface : AarogyaColors.lightBg).withValues(alpha: 0.5),
                      borderRadius: AarogyaRadius.radiusMd,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.comment_bank_outlined, size: 16, color: AarogyaColors.info),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Chief Complaint: ${consultingPatient.chiefComplaint}',
                            style: AarogyaTypography.bodyMedium(primaryText),
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
                      ref.read(selectedTabIndexProvider.notifier).state = 2; // Consultation tab
                    },
                  ),
                ],
              ),
            )
          else
            GlassCard(
              padding: AarogyaSpacing.paddingXl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('No active patient in consultation room.', style: AarogyaTypography.bodyLarge(secondaryText)),
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
        ],
      ),
    );
  }
}
