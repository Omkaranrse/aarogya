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
import '../booking/appointment_booking_sheet.dart';
import 'doctor_detail_sheet.dart';

class DoctorDiscoveryScreen extends ConsumerWidget {
  const DoctorDiscoveryScreen({super.key});

  static const List<String> specialties = [
    'All',
    'Cardiologist',
    'Neurologist',
    'Pediatrician',
    'Orthopedic Surgeon',
    'Dermatologist',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredDoctors = ref.watch(filteredDoctorsProvider);
    final selectedSpecialty = ref.watch(selectedSpecialtyFilterProvider) ?? 'All';
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
            // Screen Title & Search Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Find Specialists', style: AarogyaTypography.headingLarge(primaryText)),
                      Text(
                        'Browse verified clinical consultants & book instant OPD passes',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AarogyaBadge(
                  label: '${filteredDoctors.length} Active',
                  variant: AarogyaBadgeVariant.cyan,
                ),
              ],
            ),
            const SizedBox(height: AarogyaSpacing.lg),

            // Search Bar
            AarogyaTextField(
              hintText: 'Search by doctor name, specialty, hospital or condition...',
              prefixIcon: Icons.search_rounded,
              showClearButton: true,
              onChanged: (val) => ref.read(doctorSearchQueryProvider.notifier).state = val,
            ),
            const SizedBox(height: AarogyaSpacing.md),

            // Specialty Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: specialties.map((spec) {
                  final isSelected = selectedSpecialty == spec;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(spec),
                      selected: isSelected,
                      onSelected: (_) => ref.read(selectedSpecialtyFilterProvider.notifier).state = spec,
                      selectedColor: isDark
                          ? AarogyaColors.primaryCyan.withOpacity(0.2)
                          : AarogyaColors.primaryBlue.withOpacity(0.15),
                      labelStyle: AarogyaTypography.caption(
                        isSelected
                            ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                            : (isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary),
                      ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: AarogyaRadius.radiusPill,
                        side: BorderSide(
                          color: isSelected
                              ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AarogyaSpacing.lg),

            // Doctors Grid / List
            Expanded(
              child: filteredDoctors.isEmpty
                  ? AarogyaEmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'No Doctors Found',
                      description: 'Try adjusting your search keywords or clearing specialty filters.',
                      actionLabel: 'Reset Filters',
                      onAction: () {
                        ref.read(doctorSearchQueryProvider.notifier).state = '';
                        ref.read(selectedSpecialtyFilterProvider.notifier).state = 'All';
                      },
                    )
                  : LayoutBuilder(builder: (context, constraints) {
                      final crossCount = constraints.maxWidth > 950
                          ? 2
                          : 1;

                      return GridView.builder(
                        itemCount: filteredDoctors.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossCount,
                          crossAxisSpacing: AarogyaSpacing.md,
                          mainAxisSpacing: AarogyaSpacing.md,
                          mainAxisExtent: 220,
                        ),
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          return _buildDoctorCard(context, doctor, isDark, primaryText, secondaryText);
                        },
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(
    BuildContext context,
    Doctor doctor,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return GlassCard(
      glowColor: AarogyaColors.primaryCyan,
      padding: AarogyaSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AarogyaAvatar(
                name: doctor.name,
                imageUrl: doctor.avatarUrl,
                size: 56,
                isOnline: doctor.isAvailableToday,
              ),
              const SizedBox(width: AarogyaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            doctor.name,
                            style: AarogyaTypography.title(primaryText),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (doctor.isAvailableToday)
                          const AarogyaBadge(
                            label: 'Available Today',
                            variant: AarogyaBadgeVariant.success,
                          )
                        else
                          const AarogyaBadge(
                            label: 'Next: Tomorrow',
                            variant: AarogyaBadgeVariant.neutral,
                            showDot: false,
                          ),
                      ],
                    ),
                    Text(
                      doctor.specialty,
                      style: AarogyaTypography.bodyMedium(AarogyaColors.primaryCyan),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.qualifications,
                      style: AarogyaTypography.caption(secondaryText),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.rating}',
                          style: AarogyaTypography.caption(primaryText).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' (${doctor.reviewsCount}) • ${doctor.experienceYears} yrs exp',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ],
                    ),
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
                  Text('Consultation', style: AarogyaTypography.caption(secondaryText)),
                  Text(
                    AarogyaFormatters.currency(doctor.consultationFee),
                    style: AarogyaTypography.title(AarogyaColors.success).copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Row(
                children: [
                  AarogyaButton(
                    label: 'Profile',
                    variant: AarogyaButtonVariant.ghost,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => DoctorDetailSheet(doctor: doctor),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AarogyaButton(
                    label: 'Book Slot',
                    icon: Icons.calendar_month_rounded,
                    size: AarogyaButtonSize.sm,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AppointmentBookingSheet(doctor: doctor),
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
