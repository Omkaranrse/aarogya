import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/utils/responsive.dart';

class DepartmentData {
  final String id;
  final String name;
  final String headOfDept;
  final int activeDoctors;
  final int opdRooms;
  final String feeRange;
  final IconData icon;

  const DepartmentData({
    required this.id,
    required this.name,
    required this.headOfDept,
    required this.activeDoctors,
    required this.opdRooms,
    required this.feeRange,
    required this.icon,
  });
}

class DepartmentManagementScreen extends ConsumerWidget {
  const DepartmentManagementScreen({super.key});

  static const List<DepartmentData> departments = [
    DepartmentData(
      id: 'dept-cardio',
      name: 'Cardiology & Vascular Sciences',
      headOfDept: 'Dr. Ananya Sharma, DM (Cardio)',
      activeDoctors: 4,
      opdRooms: 6,
      feeRange: '₹1,000 - ₹1,800',
      icon: Icons.favorite_rounded,
    ),
    DepartmentData(
      id: 'dept-neuro',
      name: 'Neurology & Neurosurgery',
      headOfDept: 'Dr. Rahul Mehta, DM (Neuro)',
      activeDoctors: 3,
      opdRooms: 4,
      feeRange: '₹1,200 - ₹2,000',
      icon: Icons.psychology_rounded,
    ),
    DepartmentData(
      id: 'dept-pedia',
      name: 'Pediatrics & Neonatology',
      headOfDept: 'Dr. Priya Nambiar, DNB (Pedia)',
      activeDoctors: 5,
      opdRooms: 8,
      feeRange: '₹800 - ₹1,200',
      icon: Icons.child_care_rounded,
    ),
    DepartmentData(
      id: 'dept-ortho',
      name: 'Orthopedics & Joint Replacement',
      headOfDept: 'Dr. Siddharth Sen, M.Ch',
      activeDoctors: 4,
      opdRooms: 5,
      feeRange: '₹1,200 - ₹1,800',
      icon: Icons.accessibility_new_rounded,
    ),
    DepartmentData(
      id: 'dept-derma',
      name: 'Dermatology & Cosmetology',
      headOfDept: 'Dr. Sneha Kulkarni, MD',
      activeDoctors: 2,
      opdRooms: 3,
      feeRange: '₹900 - ₹1,500',
      icon: Icons.spa_rounded,
    ),
    DepartmentData(
      id: 'dept-lab',
      name: 'Central Diagnostic & Pathology Labs',
      headOfDept: 'Dr. Arvind Joshi, MD (Path)',
      activeDoctors: 3,
      opdRooms: 4,
      feeRange: '₹250 - ₹5,000',
      icon: Icons.biotech_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? AarogyaSpacing.md : AarogyaSpacing.xxl),
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
                      Text('Clinical Departments & Specialties', style: AarogyaTypography.headingLarge(primaryText)),
                      Text(
                        'Configure OPD clinic suites, faculty allocations, and tariff ceilings',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AarogyaBadge(label: '${departments.length} Operational Units', variant: AarogyaBadgeVariant.cyan),
              ],
            ),
            const SizedBox(height: AarogyaSpacing.xl),

            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 850 ? 2 : 1;
                return GridView.builder(
                  itemCount: departments.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: AarogyaSpacing.md,
                    mainAxisSpacing: AarogyaSpacing.md,
                    mainAxisExtent: 180,
                  ),
                  itemBuilder: (context, index) {
                    final dept = departments[index];
                    return GlassCard(
                      glowColor: AarogyaColors.primaryCyan,
                      padding: AarogyaSpacing.paddingLg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AarogyaColors.primaryCyan.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(dept.icon, color: AarogyaColors.primaryCyan, size: 20),
                              ),
                              const SizedBox(width: AarogyaSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(dept.name, style: AarogyaTypography.title(primaryText)),
                                    Text('Chair: ${dept.headOfDept}', style: AarogyaTypography.caption(secondaryText)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Active Faculty', style: AarogyaTypography.caption(secondaryText)),
                                  Text('${dept.activeDoctors} Specialists', style: AarogyaTypography.label(primaryText)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('OPD Suites', style: AarogyaTypography.caption(secondaryText)),
                                  Text('${dept.opdRooms} Rooms', style: AarogyaTypography.label(primaryText)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Fee Tariff', style: AarogyaTypography.caption(secondaryText)),
                                  Text(dept.feeRange, style: AarogyaTypography.label(AarogyaColors.success)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
