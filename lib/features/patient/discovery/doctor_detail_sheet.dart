import 'package:flutter/material.dart';
import '../../../core/design_system/glass/glass_container.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/spacing.dart';
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
    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: AarogyaSpacing.paddingXl,
          backgroundColor: isDark ? AarogyaColors.darkSurface : AarogyaColors.lightSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AarogyaSpacing.lg),

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
                          size: 72,
                          isOnline: doctor.isAvailableToday,
                        ),
                        const SizedBox(width: AarogyaSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(doctor.name, style: AarogyaTypography.headingLarge(primaryText)),
                                  const SizedBox(width: 6),
                                  if (doctor.isVerified)
                                    const Icon(Icons.verified_rounded, size: 18, color: AarogyaColors.primaryCyan),
                                ],
                              ),
                              Text(doctor.specialty, style: AarogyaTypography.title(AarogyaColors.primaryCyan)),
                              const SizedBox(height: 4),
                              Text(doctor.qualifications, style: AarogyaTypography.caption(secondaryText)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doctor.rating} (${doctor.reviewsCount} reviews)',
                                    style: AarogyaTypography.label(primaryText),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.workspace_premium_rounded, size: 16, color: secondaryText),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${doctor.experienceYears} Years Exp.',
                                    style: AarogyaTypography.label(secondaryText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AarogyaSpacing.xl),

                    // Hospital affiliation
                    Container(
                      padding: AarogyaSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: (isDark ? AarogyaColors.darkGlassCard : AarogyaColors.lightBg).withOpacity(0.6),
                        borderRadius: AarogyaRadius.radiusMd,
                        border: Border.all(
                          color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.domain_rounded, size: 20, color: AarogyaColors.primaryCyan),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Clinical Affiliation', style: AarogyaTypography.caption(secondaryText)),
                                Text(doctor.hospital, style: AarogyaTypography.label(primaryText)),
                              ],
                            ),
                          ),
                          Text(
                            AarogyaFormatters.currency(doctor.consultationFee),
                            style: AarogyaTypography.title(AarogyaColors.success).copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AarogyaSpacing.xl),

                    // About Doctor
                    Text('About Doctor', style: AarogyaTypography.headingMedium(primaryText)),
                    const SizedBox(height: AarogyaSpacing.sm),
                    Text(doctor.bio, style: AarogyaTypography.bodyMedium(secondaryText)),
                    const SizedBox(height: AarogyaSpacing.xl),

                    // Available Days & Schedule
                    Text('OPD Clinical Schedule', style: AarogyaTypography.headingMedium(primaryText)),
                    const SizedBox(height: AarogyaSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.availableDays.map((day) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AarogyaColors.primaryCyan.withOpacity(0.1),
                            borderRadius: AarogyaRadius.radiusPill,
                            border: Border.all(color: AarogyaColors.primaryCyan.withOpacity(0.3)),
                          ),
                          child: Text(day, style: AarogyaTypography.caption(AarogyaColors.primaryCyan)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AarogyaSpacing.md),
                    Text('Available Time Slots Today', style: AarogyaTypography.label(secondaryText)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.timeSlots.map((slot) {
                        return AarogyaBadge(label: slot, variant: AarogyaBadgeVariant.info, showDot: false);
                      }).toList(),
                    ),
                    const SizedBox(height: AarogyaSpacing.xxl),
                  ],
                ),
              ),

              // Booking Bottom CTA
              SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Consultation Fee', style: AarogyaTypography.caption(secondaryText)),
                        Text(
                          AarogyaFormatters.currency(doctor.consultationFee),
                          style: AarogyaTypography.headingLarge(AarogyaColors.success),
                        ),
                      ],
                    ),
                    const Spacer(),
                    AarogyaButton(
                      label: 'Book Appointment',
                      icon: Icons.calendar_today_rounded,
                      size: AarogyaButtonSize.lg,
                      onPressed: () {
                        Navigator.pop(context);
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
              ),
            ],
          ),
        );
      },
    );
  }
}
