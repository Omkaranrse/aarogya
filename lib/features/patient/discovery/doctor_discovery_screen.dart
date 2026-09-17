import 'dart:async';
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

enum ConsultationModeFilter { all, inPerson, video }
enum FeeRangeFilter { all, under600, midRange, premium }

class DoctorDiscoveryScreen extends ConsumerStatefulWidget {
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
  ConsumerState<DoctorDiscoveryScreen> createState() =>
      _DoctorDiscoveryScreenState();
}

class _DoctorDiscoveryScreenState extends ConsumerState<DoctorDiscoveryScreen> {
  Timer? _debounceTimer;
  ConsultationModeFilter _modeFilter = ConsultationModeFilter.all;
  FeeRangeFilter _feeFilter = FeeRangeFilter.all;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(doctorSearchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rawFilteredDoctors = ref.watch(filteredDoctorsProvider);
    final selectedSpecialty =
        ref.watch(selectedSpecialtyFilterProvider) ?? 'All';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;
    final accentColor = isDark
        ? AarogyaColors.primaryCyan
        : AarogyaColors.primaryBlue;

    // Multi-criteria filtering: fee & mode
    final filteredDoctors = rawFilteredDoctors.where((doc) {
      if (_feeFilter == FeeRangeFilter.under600 && doc.consultationFee >= 600) {
        return false;
      }
      if (_feeFilter == FeeRangeFilter.midRange &&
          (doc.consultationFee < 600 || doc.consultationFee > 1000)) {
        return false;
      }
      if (_feeFilter == FeeRangeFilter.premium && doc.consultationFee <= 1000) {
        return false;
      }
      if (_modeFilter == ConsultationModeFilter.video && !doc.isAvailableToday) {
        return false;
      }
      return true;
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
            // Screen Title & Search Header
            Text(
              'Find Specialists',
              style: AarogyaTypography.headingLarge(primaryText),
            ),
            const SizedBox(height: 8),

            // 300ms Debounced Search Bar
            AarogyaTextField(
              hintText: 'Search doctor, specialty, or hospital...',
              prefixIcon: Icons.search_rounded,
              showClearButton: true,
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 8),

            // Primary Specialty Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: DoctorDiscoveryScreen.specialties.map((spec) {
                  final isSelected = selectedSpecialty == spec;
                  final count = spec == 'All'
                      ? ref.watch(doctorsListProvider).length
                      : ref
                          .watch(doctorsListProvider)
                          .where((d) => d.specialty.toLowerCase().contains(spec.toLowerCase()))
                          .length;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$spec ($count)'),
                      selected: isSelected,
                      onSelected: count > 0 || spec == 'All'
                          ? (_) => ref
                              .read(selectedSpecialtyFilterProvider.notifier)
                              .state = spec
                          : null,
                      selectedColor: isDark
                          ? AarogyaColors.primaryCyan.withValues(alpha: 0.15)
                          : AarogyaColors.primaryBlue.withValues(alpha: 0.12),
                      backgroundColor: Colors.transparent,
                      disabledColor: Colors.transparent,
                      labelStyle: AarogyaTypography.caption(
                        count == 0 && spec != 'All'
                            ? (isDark
                                ? AarogyaColors.textDarkMuted
                                : AarogyaColors.textLightMuted)
                            : (isSelected
                                ? (isDark
                                    ? AarogyaColors.primaryCyan
                                    : AarogyaColors.primaryBlue)
                                : secondaryText),
                      ).copyWith(
                        fontWeight: isSelected && (count > 0 || spec == 'All')
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AarogyaRadius.radiusPill,
                        side: BorderSide(
                          color: isSelected && (count > 0 || spec == 'All')
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
            const SizedBox(height: 6),

            // Multi-criteria secondary filters: Fee Range & Mode
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSecondaryChip(
                    label: 'All Modes',
                    isSelected: _modeFilter == ConsultationModeFilter.all,
                    onTap: () => setState(() => _modeFilter = ConsultationModeFilter.all),
                    accentColor: accentColor,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                  _buildSecondaryChip(
                    label: 'Video Consult',
                    isSelected: _modeFilter == ConsultationModeFilter.video,
                    onTap: () => setState(() => _modeFilter = ConsultationModeFilter.video),
                    accentColor: accentColor,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                  _buildSecondaryChip(
                    label: 'In-Person',
                    isSelected: _modeFilter == ConsultationModeFilter.inPerson,
                    onTap: () => setState(() => _modeFilter = ConsultationModeFilter.inPerson),
                    accentColor: accentColor,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 16,
                    width: 1,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  const SizedBox(width: 12),
                  _buildSecondaryChip(
                    label: 'All Fees',
                    isSelected: _feeFilter == FeeRangeFilter.all,
                    onTap: () => setState(() => _feeFilter = FeeRangeFilter.all),
                    accentColor: accentColor,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                  _buildSecondaryChip(
                    label: '< ₹600',
                    isSelected: _feeFilter == FeeRangeFilter.under600,
                    onTap: () => setState(() => _feeFilter = FeeRangeFilter.under600),
                    accentColor: accentColor,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                  _buildSecondaryChip(
                    label: '₹600 - ₹1,000',
                    isSelected: _feeFilter == FeeRangeFilter.midRange,
                    onTap: () => setState(() => _feeFilter = FeeRangeFilter.midRange),
                    accentColor: accentColor,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 6),
                  _buildSecondaryChip(
                    label: '₹1,000+',
                    isSelected: _feeFilter == FeeRangeFilter.premium,
                    onTap: () => setState(() => _feeFilter = FeeRangeFilter.premium),
                    accentColor: accentColor,
                    secondaryText: secondaryText,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Doctors Grid / List
            Expanded(
              child: filteredDoctors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AarogyaEmptyState(
                            icon: Icons.person_search_rounded,
                            title: 'No Doctors Found',
                            description:
                                'Try adjusting your search keywords or clearing active filters.',
                          ),
                          const SizedBox(height: 12),
                          AarogyaButton(
                            label: 'Reset Filters',
                            variant: AarogyaButtonVariant.secondary,
                            icon: Icons.filter_alt_off_rounded,
                            size: AarogyaButtonSize.sm,
                            onPressed: () {
                              ref.read(doctorSearchQueryProvider.notifier).state = '';
                              ref
                                  .read(selectedSpecialtyFilterProvider.notifier)
                                  .state = 'All';
                              setState(() {
                                _feeFilter = FeeRangeFilter.all;
                                _modeFilter = ConsultationModeFilter.all;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossCount = constraints.maxWidth > 1150
                            ? 3
                            : (constraints.maxWidth > 750 ? 2 : 1);

                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: filteredDoctors.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 240,
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

  Widget _buildSecondaryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
    required Color secondaryText,
    required bool isDark,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark
                    ? AarogyaColors.darkGlassBorderSubtle
                    : AarogyaColors.lightGlassBorderSubtle),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: AarogyaTypography.caption(
            isSelected ? accentColor : secondaryText,
          ).copyWith(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
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

    final nextSlotText = doctor.isAvailableToday
        ? 'Next: Today ${doctor.timeSlots.isNotEmpty ? doctor.timeSlots.first : "4:30 PM"}'
        : 'Next: Tomorrow ${doctor.timeSlots.isNotEmpty ? doctor.timeSlots.first : "10:00 AM"}';

    final previewSlots = doctor.timeSlots.take(3).toList();

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

          // Standardized Availability Chip & Telemetry Row
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.surfaceActionable,
              borderRadius: AarogyaRadius.radius8,
              border: Border.all(color: colors.borderHairline, width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Slot 1: Rating
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

                // Slot 2: Experience
                Text(
                  '${doctor.experienceYears} yrs exp',
                  style: typography.caption.copyWith(
                    fontSize: 11,
                    color: colors.neutrals.gray600,
                  ),
                ),

                // Slot 3: Time-based availability chip
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
                  child: Text(
                    nextSlotText,
                    style: typography.caption.copyWith(
                      color: doctor.isAvailableToday
                          ? colors.clinicalStable
                          : colors.neutrals.gray600,
                      fontWeight: FontWeight.w700,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 1-Tap Quick Bookable Slots Row
          if (previewSlots.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Slots: ',
                  style: typography.caption.copyWith(
                    fontSize: 10,
                    color: colors.neutrals.gray500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: previewSlots.map((slot) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) =>
                                    AppointmentBookingSheet(doctor: doctor),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                slot,
                                style: typography.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colors.primary,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],

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
