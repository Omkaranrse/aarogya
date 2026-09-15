import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/design_system/components/aarogya_text_field.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/patient.dart';
import '../../../shared/state/aarogya_providers.dart';

class PatientManagementScreen extends ConsumerStatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  ConsumerState<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends ConsumerState<PatientManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(allPatientsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final filtered = patients.where((p) {
      return p.name.toLowerCase().contains(_query.toLowerCase()) ||
          p.phone.contains(_query) ||
          p.id.toLowerCase().contains(_query.toLowerCase());
    }).toList();

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
                      Text('Patient Master Registry', style: AarogyaTypography.headingLarge(primaryText)),
                      Text(
                        'Hospital census, emergency contacts, allergy profiles, and EHR identifiers',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AarogyaBadge(label: '${patients.length} Registered Patients', variant: AarogyaBadgeVariant.cyan),
              ],
            ),
            const SizedBox(height: AarogyaSpacing.lg),

            // Search
            AarogyaTextField(
              hintText: 'Search patients by name, MRN / ID, or contact number...',
              prefixIcon: Icons.search_rounded,
              controller: _searchCtrl,
              showClearButton: true,
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: AarogyaSpacing.lg),

            // Patient List
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: AarogyaSpacing.md),
                itemBuilder: (context, index) {
                  final pat = filtered[index];
                  return GlassCard(
                    glowColor: AarogyaColors.primaryCyan,
                    padding: AarogyaSpacing.paddingLg,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AarogyaAvatar(
                          name: pat.name,
                          imageUrl: pat.avatarUrl,
                          size: 52,
                        ),
                        const SizedBox(width: AarogyaSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Text(pat.name, style: AarogyaTypography.title(primaryText)),
                                  AarogyaBadge(label: 'MRN #${pat.id}', variant: AarogyaBadgeVariant.info, showDot: false),
                                  AarogyaBadge(label: 'Blood: ${pat.bloodGroup}', variant: AarogyaBadgeVariant.cyan, showDot: false),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${pat.age} Years • ${pat.gender} • Phone: ${pat.phone} • Email: ${pat.email}',
                                style: AarogyaTypography.caption(secondaryText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Emergency Contact: ${pat.emergencyContact}',
                                style: AarogyaTypography.caption(AarogyaColors.warning),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: pat.allergies
                                    .map((a) => AarogyaBadge(label: 'Allergy: $a', variant: AarogyaBadgeVariant.critical, showDot: false))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
