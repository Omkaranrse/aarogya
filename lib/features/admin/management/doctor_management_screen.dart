import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_empty_state.dart';
import '../../../core/design_system/components/aarogya_text_field.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/doctor.dart';
import '../../../shared/state/aarogya_providers.dart';

class DoctorManagementScreen extends ConsumerStatefulWidget {
  const DoctorManagementScreen({super.key});

  @override
  ConsumerState<DoctorManagementScreen> createState() =>
      _DoctorManagementScreenState();
}

class _DoctorManagementScreenState
    extends ConsumerState<DoctorManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDoctorDialog(BuildContext context, dynamic repo, bool isDark) {
    final nameCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController(text: 'Cardiologist');
    final qualCtrl = TextEditingController(text: 'MBBS, MD');
    final feeCtrl = TextEditingController(text: '1200');
    final hospitalCtrl = TextEditingController(text: 'Aarogya Super Specialty');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark
              ? AarogyaColors.darkSurface
              : AarogyaColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
          title: Text(
            'Register Medical Specialist',
            style: AarogyaTypography.headingMedium(
              isDark ? Colors.white : Colors.black,
            ),
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AarogyaTextField(
                    label: 'Full Name',
                    hintText: 'Dr. John Doe',
                    controller: nameCtrl,
                  ),
                  const SizedBox(height: AarogyaSpacing.md),
                  AarogyaTextField(
                    label: 'Specialty',
                    controller: specialtyCtrl,
                  ),
                  const SizedBox(height: AarogyaSpacing.md),
                  AarogyaTextField(
                    label: 'Qualifications',
                    controller: qualCtrl,
                  ),
                  const SizedBox(height: AarogyaSpacing.md),
                  AarogyaTextField(
                    label: 'Consultation Fee (₹)',
                    controller: feeCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AarogyaSpacing.md),
                  AarogyaTextField(
                    label: 'Hospital Affiliation',
                    controller: hospitalCtrl,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            AarogyaButton(
              label: 'Add Doctor',
              size: AarogyaButtonSize.sm,
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  repo.addDoctor(
                    Doctor(
                      id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      specialty: specialtyCtrl.text.trim(),
                      qualifications: qualCtrl.text.trim(),
                      experienceYears: 8,
                      rating: 5.0,
                      reviewsCount: 1,
                      consultationFee:
                          double.tryParse(feeCtrl.text.trim()) ?? 1000,
                      hospital: hospitalCtrl.text.trim(),
                      bio: 'Experienced clinical specialist dedicated to patient outcomes.',
                      avatarUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
                      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                      timeSlots: [
                        '09:00 AM',
                        '11:00 AM',
                        '02:00 PM',
                        '04:00 PM',
                      ],
                      isAvailableToday: true,
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctors = ref.watch(doctorsListProvider);
    final repo = ref.read(repositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    final filtered = doctors.where((d) {
      return d.name.toLowerCase().contains(_query.toLowerCase()) ||
          d.specialty.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? 12 : 24,
          vertical: Responsive.isMobile(context) ? 12 : 16,
        ),
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
                    Text(
                      'Specialist & Faculty Directory',
                      style: AarogyaTypography.headingLarge(primaryText),
                    ),
                    Text(
                      'Manage physician privileges, OPD availability toggles, and tariff ceilings',
                      style: AarogyaTypography.bodyMedium(secondaryText),
                    ),
                  ],
                ),
                AarogyaButton(
                  label: 'Register Doctor',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => _showAddDoctorDialog(context, repo, isDark),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Search Bar
            AarogyaTextField(
              hintText: 'Search doctors by name or medical specialty...',
              prefixIcon: Icons.search_rounded,
              controller: _searchController,
              showClearButton: true,
              onChanged: (val) => setState(() => _query = val),
            ),
            const SizedBox(height: 8),

            // Doctor List
            Expanded(
              child: filtered.isEmpty
                  ? AarogyaEmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'No Doctors Found',
                      description: _query.isNotEmpty
                          ? 'No specialists match "$_query". Check doctor name or specialty.'
                          : 'No doctors are currently registered.',
                      actionLabel: _query.isNotEmpty ? 'Clear Search' : null,
                      onAction: _query.isNotEmpty
                          ? () {
                              _searchController.clear();
                              setState(() => _query = '');
                            }
                          : null,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final doc = filtered[index];
                        return GlassCard(
                          glowColor: doc.isAvailableToday
                              ? AarogyaColors.primaryCyan
                              : Colors.grey,
                          padding: AarogyaSpacing.paddingMd,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AarogyaAvatar(
                                    name: doc.name,
                                    imageUrl: doc.avatarUrl,
                                    size: 48,
                                    isOnline: doc.isAvailableToday,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          alignment: WrapAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: [
                                            Text(
                                              doc.name,
                                              style: AarogyaTypography.title(
                                                primaryText,
                                              ),
                                            ),
                                            AarogyaBadge(
                                              label: doc.isAvailableToday
                                                  ? 'On OPD Duty'
                                                  : 'Off-Duty',
                                              variant: doc.isAvailableToday
                                                  ? AarogyaBadgeVariant.success
                                                  : AarogyaBadgeVariant.neutral,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          doc.specialty,
                                          style: AarogyaTypography.bodyMedium(
                                            AarogyaColors.primaryCyan,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${doc.qualifications} • ${doc.experienceYears} Yrs Exp • Fee: ${AarogyaFormatters.currency(doc.consultationFee)}',
                                          style: AarogyaTypography.caption(
                                            secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (isDark ? Colors.white : Colors.black)
                                      .withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: doc.isAvailableToday
                                                  ? AarogyaColors.success
                                                  : AarogyaColors.critical,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              doc.isAvailableToday
                                                  ? 'Available for OPD Today'
                                                  : 'Off-Duty / Unavailable',
                                              style: AarogyaTypography.caption(
                                                doc.isAvailableToday
                                                    ? AarogyaColors.success
                                                    : secondaryText,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: doc.isAvailableToday,
                                        activeThumbColor:
                                            AarogyaColors.primaryCyan,
                                        onChanged: (_) {
                                          repo.toggleDoctorStatus(doc.id);
                                        },
                                      ),
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
