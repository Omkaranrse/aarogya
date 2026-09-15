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
  ConsumerState<AppointmentBookingSheet> createState() => _AppointmentBookingSheetState();
}

class _AppointmentBookingSheetState extends ConsumerState<AppointmentBookingSheet> {
  int _currentStep = 0;
  ConsultationType _selectedType = ConsultationType.inPerson;
  late DateTime _selectedDate;
  late String _selectedSlot;
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
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
      symptoms: _symptomsController.text.trim().isNotEmpty ? _symptomsController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
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
          child: _confirmedAppointment != null
              ? _buildSuccessView(context, _confirmedAppointment!, isDark, primaryText, secondaryText)
              : Column(
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

                    // Header with Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Book Appointment',
                              style: AarogyaTypography.headingLarge(primaryText),
                            ),
                            Text(
                              'Step ${_currentStep + 1} of 4: ${_getStepTitle(_currentStep)}',
                              style: AarogyaTypography.caption(AarogyaColors.primaryCyan),
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
                                    ? AarogyaColors.primaryCyan
                                    : (isDark ? Colors.white12 : Colors.black12),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: AarogyaSpacing.xl),

                    // Step Content
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          if (_currentStep == 0) _buildStep1(isDark, primaryText, secondaryText),
                          if (_currentStep == 1) _buildStep2(isDark, primaryText, secondaryText),
                          if (_currentStep == 2) _buildStep3(isDark, primaryText, secondaryText),
                          if (_currentStep == 3) _buildStep4(isDark, primaryText, secondaryText),
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
                              label: _currentStep == 3 ? 'Confirm & Book (Pay ₹${widget.doctor.consultationFee.toInt()})' : 'Continue',
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
        return 'Consultation Mode';
      case 1:
        return 'Date & Time Slot';
      case 2:
        return 'Symptoms & Clinical Reason';
      case 3:
      default:
        return 'Review & Confirm';
    }
  }

  Widget _buildStep1(bool isDark, Color primaryText, Color secondaryText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Consultation Format', style: AarogyaTypography.title(primaryText)),
        const SizedBox(height: AarogyaSpacing.md),
        _buildModeCard(
          type: ConsultationType.inPerson,
          title: 'In-Person Hospital OPD',
          subtitle: 'Visit ${widget.doctor.hospital} with an OPD appointment queue pass.',
          icon: Icons.local_hospital_rounded,
          isDark: isDark,
          primaryText: primaryText,
          secondaryText: secondaryText,
        ),
        const SizedBox(height: AarogyaSpacing.md),
        _buildModeCard(
          type: ConsultationType.videoCall,
          title: 'Futuristic Tele-Consultation',
          subtitle: 'Encrypted HD Video Room consultation with instant digital prescription.',
          icon: Icons.video_camera_front_rounded,
          isDark: isDark,
          primaryText: primaryText,
          secondaryText: secondaryText,
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
  }) {
    final isSelected = _selectedType == type;

    return GlassCard(
      onTap: () => setState(() => _selectedType = type),
      glowColor: isSelected ? AarogyaColors.primaryCyan : null,
      customBorder: Border.all(
        color: isSelected
            ? AarogyaColors.primaryCyan
            : (isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle),
        width: isSelected ? 2.0 : 1.0,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isSelected ? AarogyaColors.primaryCyan : secondaryText).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isSelected ? AarogyaColors.primaryCyan : secondaryText, size: 24),
          ),
          const SizedBox(width: AarogyaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AarogyaTypography.title(primaryText)),
                const SizedBox(height: 2),
                Text(subtitle, style: AarogyaTypography.bodyMedium(secondaryText)),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded, color: AarogyaColors.primaryCyan, size: 22),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark, Color primaryText, Color secondaryText) {
    final dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i + 1)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Appointment Date', style: AarogyaTypography.title(primaryText)),
        const SizedBox(height: AarogyaSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dates.map((d) {
              final isSelected = d.day == _selectedDate.day && d.month == _selectedDate.month;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GlassCard(
                  onTap: () => setState(() => _selectedDate = d),
                  glowColor: isSelected ? AarogyaColors.primaryCyan : null,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  customBorder: Border.all(
                    color: isSelected ? AarogyaColors.primaryCyan : Colors.transparent,
                    width: 1.5,
                  ),
                  child: Column(
                    children: [
                      Text(
                        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1],
                        style: AarogyaTypography.caption(secondaryText),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: AarogyaTypography.title(primaryText).copyWith(
                          color: isSelected ? AarogyaColors.primaryCyan : primaryText,
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
        Text('Select Time Slot', style: AarogyaTypography.title(primaryText)),
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
              selectedColor: AarogyaColors.primaryCyan.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: AarogyaRadius.radiusPill,
                side: BorderSide(
                  color: isSelected ? AarogyaColors.primaryCyan : Colors.transparent,
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
        Text('Reason for Consultation', style: AarogyaTypography.title(primaryText)),
        const SizedBox(height: AarogyaSpacing.xs),
        Text(
          'Brief description helps Dr. ${widget.doctor.name} prepare clinical context before you arrive.',
          style: AarogyaTypography.bodyMedium(secondaryText),
        ),
        const SizedBox(height: AarogyaSpacing.md),
        AarogyaTextField(
          label: 'Primary Symptoms / Complaints',
          hintText: 'e.g. Mild chest tightness while jogging, shortness of breath...',
          controller: _symptomsController,
          maxLines: 3,
        ),
        const SizedBox(height: AarogyaSpacing.md),
        AarogyaTextField(
          label: 'Special Notes or Past Relevant Tests',
          hintText: 'e.g. Bringing latest ECG & Fasting Lipid Panel reports from last week.',
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
        Text('Review Appointment Summary', style: AarogyaTypography.title(primaryText)),
        const SizedBox(height: AarogyaSpacing.md),
        GlassCard(
          padding: AarogyaSpacing.paddingLg,
          child: Column(
            children: [
              _buildReviewRow('Doctor', widget.doctor.name, primaryText, secondaryText),
              _buildReviewRow('Specialty', widget.doctor.specialty, primaryText, secondaryText),
              _buildReviewRow('Format', _selectedType.displayName, primaryText, secondaryText),
              _buildReviewRow('Date', AarogyaFormatters.dateWithDay(_selectedDate), primaryText, secondaryText),
              _buildReviewRow('Slot', _selectedSlot, primaryText, secondaryText),
              _buildReviewRow('Hospital', widget.doctor.hospital, primaryText, secondaryText),
              const Divider(height: 24),
              _buildReviewRow('Consultation Fee', AarogyaFormatters.currency(widget.doctor.consultationFee), primaryText, secondaryText),
              _buildReviewRow('Digital Record & Platform Fee', '₹50', primaryText, secondaryText),
              const Divider(height: 24),
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

  Widget _buildReviewRow(String label, String value, Color valueColor, Color labelColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AarogyaTypography.bodyMedium(labelColor)),
          Text(
            value,
            style: AarogyaTypography.bodyMedium(valueColor).copyWith(
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
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
  ) {
    return Center(
      child: Padding(
        padding: AarogyaSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AarogyaColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AarogyaColors.success.withOpacity(0.4)),
              ),
              child: const Icon(Icons.check_circle_rounded, size: 54, color: AarogyaColors.success),
            ),
            const SizedBox(height: AarogyaSpacing.lg),
            Text('Appointment Confirmed!', style: AarogyaTypography.headingLarge(primaryText)),
            const SizedBox(height: AarogyaSpacing.xs),
            Text(
              'Your consultation with ${apt.doctorName} is confirmed for ${AarogyaFormatters.dateWithDay(apt.dateTime)} at ${apt.timeSlot}.',
              style: AarogyaTypography.bodyMedium(secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AarogyaSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AarogyaColors.primaryCyan.withOpacity(0.12),
                borderRadius: AarogyaRadius.radiusPill,
                border: Border.all(color: AarogyaColors.primaryCyan.withOpacity(0.3)),
              ),
              child: Text(
                'OPD Token: #${apt.tokenNumber}',
                style: AarogyaTypography.headingMedium(AarogyaColors.primaryCyan),
              ),
            ),
            const SizedBox(height: AarogyaSpacing.xxl),
            AarogyaButton(
              label: 'Done & Return to Dashboard',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
