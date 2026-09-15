import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/shell/adaptive_shell.dart';
import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/spacing.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_badge.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/stat_card.dart';
import '../../core/utils/responsive.dart';
import '../../shared/state/aarogya_providers.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsListProvider);
    final appointments = ref.watch(appointmentsProvider);
    final patients = ref.watch(allPatientsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final activeDoctors = doctors.where((d) => d.isAvailableToday).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : AarogyaSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital Command Center Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hospital Command Center', style: AarogyaTypography.headingLarge(primaryText)),
                    Text(
                      'Real-time operational intelligence, hospital capacity, and clinical throughput',
                      style: AarogyaTypography.bodyMedium(secondaryText),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const AarogyaBadge(
                label: 'System Normal • 99.98% Uptime',
                variant: AarogyaBadgeVariant.success,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Executive Metric Stats
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 750;
            return GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: isWide ? 1.6 : 1.45,
              children: [
                StatCard(
                  title: 'Total Active Patients',
                  value: '${patients.length * 280}',
                  subtitle: '+48 new this week',
                  icon: Icons.people_alt_rounded,
                  accentColor: AarogyaColors.primaryCyan,
                  trendPercent: 14.2,
                ),
                StatCard(
                  title: 'Specialists On Duty',
                  value: '$activeDoctors / ${doctors.length}',
                  subtitle: '84% OPD coverage',
                  icon: Icons.medical_services_rounded,
                  accentColor: AarogyaColors.success,
                ),
                StatCard(
                  title: "Today's Consultations",
                  value: '${appointments.length * 4}',
                  subtitle: 'Avg 12m consultation',
                  icon: Icons.calendar_today_rounded,
                  accentColor: AarogyaColors.accentPurple,
                  trendPercent: 6.8,
                ),
                const StatCard(
                  title: 'Hospital Bed Occupancy',
                  value: '78.5%',
                  subtitle: '157 / 200 Inpatient Beds',
                  icon: Icons.hotel_rounded,
                  accentColor: AarogyaColors.warning,
                ),
              ],
            );
          }),
          const SizedBox(height: 10),

          // Operational Quick Jump Cards
          Text('Operational Suites', style: AarogyaTypography.headingMedium(primaryText)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 1, // Analytics
                  glowColor: AarogyaColors.primaryCyan,
                  padding: AarogyaSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.insights_rounded, color: AarogyaColors.primaryCyan, size: 28),
                      const SizedBox(height: 12),
                      Text('Clinical & Financial Analytics', style: AarogyaTypography.title(primaryText)),
                      const SizedBox(height: 4),
                      Text('Interactive charts for OPD throughput, doctor utilization, and revenue trends.', style: AarogyaTypography.caption(secondaryText)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 2, // Doctors
                  glowColor: AarogyaColors.success,
                  padding: AarogyaSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.badge_rounded, color: AarogyaColors.success, size: 28),
                      const SizedBox(height: 12),
                      Text('Doctor & Staff Roster', style: AarogyaTypography.title(primaryText)),
                      const SizedBox(height: 4),
                      Text('Manage active medical specialists, adjust OPD schedules, and verify credentials.', style: AarogyaTypography.caption(secondaryText)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  onTap: () => ref.read(selectedTabIndexProvider.notifier).state = 4, // Departments
                  glowColor: AarogyaColors.warning,
                  padding: AarogyaSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.domain_rounded, color: AarogyaColors.warning, size: 28),
                      const SizedBox(height: 12),
                      Text('Department Management', style: AarogyaTypography.title(primaryText)),
                      const SizedBox(height: 4),
                      Text('Configure specialties, consultation tariff ceilings, and department chairs.', style: AarogyaTypography.caption(secondaryText)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AarogyaSpacing.xxl),

          // Live Hospital Activity Feed
          Text('Live Institutional Events', style: AarogyaTypography.headingMedium(primaryText)),
          const SizedBox(height: AarogyaSpacing.md),
          GlassCard(
            padding: AarogyaSpacing.paddingLg,
            child: Column(
              children: [
                _buildActivityRow('Dr. Ananya Sharma concluded OPD Consultation for Token #08', '2 mins ago', Icons.check_circle_rounded, AarogyaColors.success, primaryText, secondaryText),
                const Divider(height: 16),
                _buildActivityRow('Central Biochemistry Lab published verified Lipid Panel #LAB-301', '14 mins ago', Icons.biotech_rounded, AarogyaColors.primaryCyan, primaryText, secondaryText),
                const Divider(height: 16),
                _buildActivityRow('New patient admission registered in Cardiology ICU Bed #12', '38 mins ago', Icons.local_hospital_rounded, AarogyaColors.warning, primaryText, secondaryText),
                const Divider(height: 16),
                _buildActivityRow('Emergency triage queue escalated Token #09 priority to Urgent', '1 hour ago', Icons.warning_rounded, AarogyaColors.critical, primaryText, secondaryText),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    String title,
    String time,
    IconData icon,
    Color iconColor,
    Color primaryText,
    Color secondaryText,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: AarogyaTypography.bodyMedium(primaryText))),
        Text(time, style: AarogyaTypography.caption(secondaryText)),
      ],
    );
  }
}
