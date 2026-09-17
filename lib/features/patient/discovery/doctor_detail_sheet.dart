import 'package:flutter/material.dart';

import '../../../core/design_system/glass/glass_container.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/models/doctor.dart';
import '../booking/appointment_booking_sheet.dart';

class DoctorDetailSheet extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailSheet({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) {
        final accentColor = isDark
            ? AarogyaColors.primaryCyan
            : AarogyaColors.primaryBlue;

        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          backgroundColor: isDark
              ? AarogyaColors.darkSurface
              : AarogyaColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Doctor Profile Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AarogyaAvatar(
                          name: doctor.name,
                          imageUrl: doctor.avatarUrl,
                          size: 68,
                          isOnline: doctor.isAvailableToday,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      doctor.name,
                                      style: AarogyaTypography.headingLarge(
                                        primaryText,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (doctor.isVerified) ...[
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 18,
                                      color: accentColor,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doctor.specialty,
                                style: AarogyaTypography.title(accentColor),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doctor.qualifications,
                                style: AarogyaTypography.caption(secondaryText),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doctor.rating} (${doctor.reviewsCount})',
                                    style: AarogyaTypography.label(primaryText),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '•',
                                    style: AarogyaTypography.label(
                                      secondaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${doctor.experienceYears} yrs exp',
                                    style: AarogyaTypography.label(
                                      secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Hospital affiliation
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark
                                    ? AarogyaColors.darkGlassCard
                                    : AarogyaColors.lightBg)
                                .withValues(alpha: 0.6),
                        borderRadius: AarogyaRadius.radiusMd,
                        border: Border.all(
                          color: isDark
                              ? AarogyaColors.darkGlassBorderSubtle
                              : AarogyaColors.lightGlassBorderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.domain_rounded,
                            size: 20,
                            color: accentColor,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Clinical Affiliation',
                                  style: AarogyaTypography.caption(
                                    secondaryText,
                                  ),
                                ),
                                Text(
                                  doctor.hospital,
                                  style: AarogyaTypography.label(primaryText),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AarogyaFormatters.currency(doctor.consultationFee),
                            style: AarogyaTypography.title(
                              AarogyaColors.success,
                            ).copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // About Doctor
                    Text(
                      'About',
                      style: AarogyaTypography.headingMedium(primaryText),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      doctor.bio,
                      style: AarogyaTypography.bodyMedium(secondaryText),
                    ),
                    const SizedBox(height: 18),

                    // Available Days & Schedule
                    Text(
                      'OPD Schedule',
                      style: AarogyaTypography.headingMedium(primaryText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.availableDays.map((day) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: AarogyaRadius.radiusPill,
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            day,
                            style: AarogyaTypography.caption(accentColor),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Today\'s Available Slots',
                      style: AarogyaTypography.label(secondaryText),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.timeSlots.map((slot) {
                        return AarogyaBadge(
                          label: slot,
                          variant: AarogyaBadgeVariant.info,
                          showDot: false,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom CTA Bar
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AarogyaColors.darkGlassBorderSubtle
                          : AarogyaColors.lightGlassBorderSubtle,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fee',
                            style: AarogyaTypography.caption(secondaryText),
                          ),
                          Text(
                            AarogyaFormatters.currency(doctor.consultationFee),
                            style: AarogyaTypography.headingLarge(
                              AarogyaColors.success,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AarogyaButton(
                        label: 'Book Appointment',
                        icon: Icons.calendar_today_rounded,
                        size: AarogyaButtonSize.md,
                        onPressed: () {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                AppointmentBookingSheet(doctor: doctor),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
