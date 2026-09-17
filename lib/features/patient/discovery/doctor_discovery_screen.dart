import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_empty_state.dart';
import '../../../core/design_system/components/aarogya_text_field.dart';
import '../../../core/theme/aarogya_theme_tokens.dart';
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
    final selectedSpecialty =
        ref.watch(selectedSpecialtyFilterProvider) ?? 'All';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

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
            // Screen Title & Search Header
            Text(
              'Find Specialists',
              style: AarogyaTypography.headingLarge(primaryText),
            ),
            const SizedBox(height: 8),

            // Search Bar
            AarogyaTextField(
              hintText: 'Search doctor, specialty, or hospital...',
              prefixIcon: Icons.search_rounded,
              showClearButton: true,
              onChanged: (val) =>
                  ref.read(doctorSearchQueryProvider.notifier).state = val,
            ),
            const SizedBox(height: 8),

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
                      onSelected: (_) =>
                          ref
                                  .read(
                                    selectedSpecialtyFilterProvider.notifier,
                                  )
                                  .state =
                              spec,
                      selectedColor: isDark
                          ? AarogyaColors.primaryCyan.withValues(alpha: 0.15)
                          : AarogyaColors.primaryBlue.withValues(alpha: 0.12),
                      backgroundColor: Colors.transparent,
                      labelStyle:
                          AarogyaTypography.caption(
                            isSelected
                                ? (isDark
                                      ? AarogyaColors.primaryCyan
                                      : AarogyaColors.primaryBlue)
                                : secondaryText,
                          ).copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AarogyaRadius.radiusPill,
                        side: BorderSide(
                          color: isSelected
                              ? (isDark
                                    ? AarogyaColors.primaryCyan
                                    : AarogyaColors.primaryBlue)
                              : (isDark
                                    ? AarogyaColors.darkGlassBorderSubtle
                                    : AarogyaColors.lightGlassBorderSubtle),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

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
                        ref
                                .read(selectedSpecialtyFilterProvider.notifier)
                                .state =
                            'All';
                      },
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossCount = constraints.maxWidth > 1150
                            ? 3
                            : (constraints.maxWidth > 750 ? 2 : 1);

                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: filteredDoctors.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 190,
                              ),
                          itemBuilder: (context, index) {
                            final doctor = filteredDoctors[index];
                            return _buildDoctorCard(
                              context,
                              doctor,
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

  Widget _buildDoctorCard(
    BuildContext context,
    Doctor doctor,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceInformational,
        borderRadius: AarogyaRadius.radius12,
        border: Border.all(color: colors.borderHairline, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Identity: Avatar + Name + Specialty
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AarogyaAvatar(
                name: doctor.name,
                imageUrl: doctor.avatarUrl,
                size: 46,
                isOnline: doctor.isAvailableToday,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: typography.title.copyWith(
                        color: colors.neutrals.gray900,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${doctor.specialty} • ${doctor.qualifications}',
                      style: typography.caption.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Fixed Visual Telemetry Row: Rating | Experience | Availability
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceActionable,
              borderRadius: AarogyaRadius.radius8,
              border: Border.all(color: colors.borderHairline, width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Fixed Slot 1: Rating
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${doctor.rating}',
                      style: typography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.neutrals.gray900,
                      ),
                    ),
                    Text(
                      ' (${doctor.reviewsCount})',
                      style: typography.caption.copyWith(
                        fontSize: 10,
                        color: colors.neutrals.gray500,
                      ),
                    ),
                  ],
                ),

                // Fixed Slot 2: Experience
                Text(
                  '${doctor.experienceYears} yrs exp',
                  style: typography.caption.copyWith(
                    fontSize: 11,
                    color: colors.neutrals.gray600,
                  ),
                ),

                // Fixed Slot 3: Availability Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: doctor.isAvailableToday
                        ? colors.clinicalStableSubtle
                        : colors.neutrals.gray100,
                    borderRadius: AarogyaRadius.radius4,
                    border: Border.all(
                      color: doctor.isAvailableToday
                          ? colors.clinicalStable.withValues(alpha: 0.3)
                          : colors.borderHairline,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: doctor.isAvailableToday
                              ? colors.clinicalStable
                              : colors.neutrals.gray500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.isAvailableToday ? 'Available' : 'Tomorrow',
                        style: typography.caption.copyWith(
                          color: doctor.isAvailableToday
                              ? colors.clinicalStable
                              : colors.neutrals.gray600,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Compressed Price & Unified CTA Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'FEE',
                    style: typography.caption.copyWith(
                      fontSize: 9.5,
                      letterSpacing: 0.5,
                      color: colors.neutrals.gray500,
                    ),
                  ),
                  Text(
                    AarogyaFormatters.currency(doctor.consultationFee),
                    style: typography.subtitle.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w800,
                      color: colors.clinicalStable,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AarogyaButton(
                    label: 'Profile',
                    variant: AarogyaButtonVariant.secondary,
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
                    variant: AarogyaButtonVariant.primary,
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
