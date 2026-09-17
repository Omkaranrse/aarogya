import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/glass/glass_container.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_text_field.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/domain/models/appointment.dart';
import '../../../shared/domain/models/doctor.dart';
import '../../../shared/state/aarogya_providers.dart';

class AppointmentBookingSheet extends ConsumerStatefulWidget {
  final Doctor doctor;

  const AppointmentBookingSheet({super.key, required this.doctor});

  @override
  ConsumerState<AppointmentBookingSheet> createState() =>
      _AppointmentBookingSheetState();
}

class _AppointmentBookingSheetState
    extends ConsumerState<AppointmentBookingSheet> {
  int _currentStep = 0;
  ConsultationType _selectedType = ConsultationType.inPerson;
  late DateTime _selectedDate;
  late String _selectedSlot;
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _symptomsError;
  bool _isBooking = false;
  Appointment? _confirmedAppointment;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _selectedSlot = widget.doctor.timeSlots.first;
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _proceedToNext() {
    if (_currentStep == 1) {
      if (_selectedSlot.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an appointment time slot.'),
            backgroundColor: AarogyaColors.critical,
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      final symp = _symptomsController.text.trim();
      if (symp.isEmpty) {
        setState(() => _symptomsError = 'Please describe your symptoms or reason for visit.');
        return;
      } else if (symp.length < 5) {
        setState(() => _symptomsError = 'Symptoms description must be at least 5 characters.');
        return;
      } else {
        setState(() => _symptomsError = null);
      }
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _confirmBooking();
    }
  }

  void _confirmBooking() async {
    setState(() => _isBooking = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final repo = ref.read(repositoryProvider);
    final apt = repo.bookAppointment(
      doctor: widget.doctor,
      date: _selectedDate,
      timeSlot: _selectedSlot,
      type: _selectedType,
      symptoms: _symptomsController.text.trim().isNotEmpty
          ? _symptomsController.text.trim()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    if (mounted) {
      setState(() {
        _isBooking = false;
        _confirmedAppointment = apt;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          backgroundColor: isDark
              ? AarogyaColors.darkSurface
              : AarogyaColors.lightSurface,
          child: _confirmedAppointment != null
              ? _buildSuccessView(
                  context,
                  _confirmedAppointment!,
                  isDark,
                  primaryText,
                  secondaryText,
                  accentColor,
                )
              : Column(
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

                    // Header with Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book Appointment',
                              style: AarogyaTypography.headingLarge(
                                primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Step ${_currentStep + 1} of 4: ${_getStepTitle(_currentStep)}',
                              style: AarogyaTypography.caption(accentColor)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Row(
                          children: List.generate(4, (index) {
                            final isActive = index <= _currentStep;
                            return Container(
                              margin: const EdgeInsets.only(left: 4),
                              width: 18,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? accentColor
                                    : (isDark
                                          ? Colors.white12
                                          : Colors.black12),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Step Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          if (_currentStep == 0)
                            _buildStep1(
                              isDark,
                              primaryText,
                              secondaryText,
                              accentColor,
                            ),
                          if (_currentStep == 1)
                            _buildStep2(
                              isDark,
                              primaryText,
                              secondaryText,
                              accentColor,
                            ),
                          if (_currentStep == 2)
                            _buildStep3(isDark, primaryText, secondaryText),
                          if (_currentStep == 3)
                            _buildStep4(isDark, primaryText, secondaryText),
                        ],
                      ),
                    ),

                    // Bottom Navigation Buttons
                    SafeArea(
                      child: Row(
                        children: [
                          if (_currentStep > 0) ...[
                            AarogyaButton(
                              label: 'Back',
                              variant: AarogyaButtonVariant.secondary,
                              onPressed: () => setState(() => _currentStep--),
                            ),
                            const SizedBox(width: AarogyaSpacing.md),
                          ],
                          Expanded(
                            child: AarogyaButton(
                              label: _currentStep == 3
                                  ? 'Confirm & Book (Pay ₹${widget.doctor.consultationFee.toInt() + 50})'
                                  : 'Continue',
                              isLoading: _isBooking,
                              onPressed: _proceedToNext,
                            ),
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

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Format';
      case 1:
        return 'Date & Slot';
      case 2:
        return 'Symptoms';
      case 3:
      default:
        return 'Confirm';
    }
  }

  Widget _buildStep1(
    bool isDark,
    Color primaryText,
    Color secondaryText,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consultation Format',
          style: AarogyaTypography.title(primaryText),
        ),
        const SizedBox(height: AarogyaSpacing.md),
        _buildModeCard(
          type: ConsultationType.inPerson,
          title: 'In-Person Consultation',
          subtitle: 'Visit clinic at ${widget.doctor.hospital}.',
          icon: Icons.local_hospital_rounded,
          isDark: isDark,
          primaryText: primaryText,
          secondaryText: secondaryText,
          accentColor: accentColor,
        ),
        const SizedBox(height: AarogyaSpacing.md),
        _buildModeCard(
          type: ConsultationType.videoCall,
          title: 'Video Consultation',
          subtitle: 'Live encrypted video call with digital prescription.',
          icon: Icons.video_camera_front_rounded,
          isDark: isDark,
          primaryText: primaryText,
          secondaryText: secondaryText,
          accentColor: accentColor,
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required ConsultationType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    required Color accentColor,
  }) {
    final isSelected = _selectedType == type;

    return GlassCard(
      onTap: () => setState(() => _selectedType = type),
      customBorder: Border.all(
        color: isSelected
            ? accentColor
            : (isDark
                  ? AarogyaColors.darkGlassBorderSubtle
                  : AarogyaColors.lightGlassBorderSubtle),
        width: isSelected ? 1.5 : 1.0,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isSelected ? accentColor : secondaryText).withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? accentColor : secondaryText,
              size: 22,
            ),
          ),
          const SizedBox(width: AarogyaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AarogyaTypography.title(primaryText)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AarogyaTypography.bodyMedium(secondaryText),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle_rounded, color: accentColor, size: 22),
        ],
      ),
    );
  }

  Widget _buildStep2(
    bool isDark,
    Color primaryText,
    Color secondaryText,
    Color accentColor,
  ) {
    final dates = List.generate(
      7,
      (i) => DateTime.now().add(Duration(days: i + 1)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appointment Date', style: AarogyaTypography.title(primaryText)),
        const SizedBox(height: AarogyaSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.map((d) {
              final isSelected =
                  d.day == _selectedDate.day && d.month == _selectedDate.month;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GlassCard(
                  onTap: () => setState(() => _selectedDate = d),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  customBorder: Border.all(
                    color: isSelected
                        ? accentColor
                        : (isDark
                              ? AarogyaColors.darkGlassBorderSubtle
                              : AarogyaColors.lightGlassBorderSubtle),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ][d.weekday - 1],
                        style: AarogyaTypography.caption(secondaryText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: AarogyaTypography.title(primaryText).copyWith(
                          color: isSelected ? accentColor : primaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AarogyaSpacing.xl),
        Text('Time Slot', style: AarogyaTypography.title(primaryText)),
        const SizedBox(height: AarogyaSpacing.md),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.doctor.timeSlots.map((slot) {
            final isSelected = _selectedSlot == slot;
            return ChoiceChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedSlot = slot),
              selectedColor: accentColor.withValues(alpha: 0.15),
              backgroundColor: Colors.transparent,
              labelStyle:
                  AarogyaTypography.caption(
                    isSelected ? accentColor : secondaryText,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: AarogyaRadius.radiusPill,
                side: BorderSide(
                  color: isSelected
                      ? accentColor
                      : (isDark
                            ? AarogyaColors.darkGlassBorderSubtle
                            : AarogyaColors.lightGlassBorderSubtle),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep3(bool isDark, Color primaryText, Color secondaryText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reason for Visit', style: AarogyaTypography.title(primaryText)),
        const SizedBox(height: AarogyaSpacing.xs),
        Text(
          'Helps Dr. ${widget.doctor.name} understand your symptoms beforehand.',
          style: AarogyaTypography.bodyMedium(secondaryText),
        ),
        const SizedBox(height: AarogyaSpacing.md),
        AarogyaTextField(
          label: 'Primary Symptoms *',
          hintText: 'e.g. Mild chest tightness, fatigue...',
          controller: _symptomsController,
          maxLines: 3,
          errorText: _symptomsError,
          onChanged: (_) {
            if (_symptomsError != null) {
              setState(() => _symptomsError = null);
            }
          },
        ),
        const SizedBox(height: AarogyaSpacing.md),
        AarogyaTextField(
          label: 'Notes / Relevant Past Tests',
          hintText: 'e.g. Bringing latest ECG reports.',
          controller: _notesController,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildStep4(bool isDark, Color primaryText, Color secondaryText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Summary',
          style: AarogyaTypography.title(primaryText),
        ),
        const SizedBox(height: AarogyaSpacing.md),
        GlassCard(
          padding: AarogyaSpacing.paddingLg,
          child: Column(
            children: [
              _buildReviewRow(
                'Doctor',
                widget.doctor.name,
                primaryText,
                secondaryText,
              ),
              _buildReviewRow(
                'Specialty',
                widget.doctor.specialty,
                primaryText,
                secondaryText,
              ),
              _buildReviewRow(
                'Format',
                _selectedType.displayName,
                primaryText,
                secondaryText,
              ),
              _buildReviewRow(
                'Date',
                AarogyaFormatters.dateWithDay(_selectedDate),
                primaryText,
                secondaryText,
              ),
              _buildReviewRow(
                'Slot',
                _selectedSlot,
                primaryText,
                secondaryText,
              ),
              _buildReviewRow(
                'Hospital',
                widget.doctor.hospital,
                primaryText,
                secondaryText,
              ),
              const Divider(height: 20),
              _buildReviewRow(
                'Consultation Fee',
                AarogyaFormatters.currency(widget.doctor.consultationFee),
                primaryText,
                secondaryText,
              ),
              _buildReviewRow(
                'Platform Fee',
                '₹50',
                primaryText,
                secondaryText,
              ),
              const Divider(height: 20),
              _buildReviewRow(
                'Total Payable',
                AarogyaFormatters.currency(widget.doctor.consultationFee + 50),
                AarogyaColors.success,
                secondaryText,
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(
    String label,
    String value,
    Color valueColor,
    Color labelColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AarogyaTypography.bodyMedium(labelColor)),
          Text(
            value,
            style: AarogyaTypography.bodyMedium(
              valueColor,
            ).copyWith(fontWeight: isBold ? FontWeight.w800 : FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    Appointment apt,
    bool isDark,
    Color primaryText,
    Color secondaryText,
    Color accentColor,
  ) {
    return Center(
      child: Padding(
        padding: AarogyaSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AarogyaColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AarogyaColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AarogyaColors.success,
              ),
            ),
            const SizedBox(height: AarogyaSpacing.lg),
            Text(
              'Appointment Confirmed',
              style: AarogyaTypography.headingLarge(primaryText),
            ),
            const SizedBox(height: AarogyaSpacing.xs),
            Text(
              'Your consultation with ${apt.doctorName} is confirmed for ${AarogyaFormatters.dateWithDay(apt.dateTime)} at ${apt.timeSlot}.',
              style: AarogyaTypography.bodyMedium(secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AarogyaSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: AarogyaRadius.radiusPill,
                border: Border.all(color: accentColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                'OPD Token #${apt.tokenNumber}',
                style: AarogyaTypography.title(accentColor)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: AarogyaSpacing.xxl),
            AarogyaButton(
              label: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
