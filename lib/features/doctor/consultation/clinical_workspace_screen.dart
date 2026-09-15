import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/glass/glass_container.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_badge.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_text_field.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/patient.dart';
import '../../../shared/domain/models/prescription.dart';
import '../../../shared/domain/models/queue_entry.dart';
import '../../../shared/state/aarogya_providers.dart';
import '../../../app/shell/adaptive_shell.dart';

class ClinicalWorkspaceScreen extends ConsumerStatefulWidget {
  const ClinicalWorkspaceScreen({super.key});

  @override
  ConsumerState<ClinicalWorkspaceScreen> createState() => _ClinicalWorkspaceScreenState();
}

class _ClinicalWorkspaceScreenState extends ConsumerState<ClinicalWorkspaceScreen> {
  final TextEditingController _complaintController = TextEditingController(
    text: 'Mild chest discomfort during morning exercise and fatigue.',
  );
  final TextEditingController _diagnosisController = TextEditingController(
    text: 'Atypical Angina Pectoris / Borderline Hyperlipidemia',
  );
  final TextEditingController _notesController = TextEditingController(
    text: 'Resting ECG shows normal sinus rhythm. Advised lifestyle modifications, lipid management, and strict low sodium diet.',
  );

  // Digital Prescription items
  final List<Medication> _medications = [
    const Medication(
      id: 'm-1',
      name: 'Atorvastatin',
      dosage: '10 mg',
      frequency: '0-0-1 (Night)',
      duration: '30 Days',
      instructions: 'After Dinner',
    ),
    const Medication(
      id: 'm-2',
      name: 'Metoprolol Succinate',
      dosage: '25 mg',
      frequency: '1-0-0 (Morning)',
      duration: '30 Days',
      instructions: 'After Breakfast',
    ),
  ];

  // Lab Orders
  final List<String> _selectedLabTests = [
    'Comprehensive Lipid Profile',
    'Resting 12-Lead ECG',
  ];

  final List<String> _availableLabTests = [
    'Complete Blood Count (CBC)',
    'Comprehensive Lipid Profile',
    'HbA1c (Glycated Hemoglobin)',
    'Thyroid Profile (TSH, T3, T4)',
    'Serum Creatinine & Electrolytes',
    'Resting 12-Lead ECG',
    'Echocardiogram (2D Echo)',
    'Chest X-Ray (PA View)',
  ];

  DateTime _followUpDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  @override
  void dispose() {
    _complaintController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddMedicationDialog(BuildContext context, bool isDark) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController(text: '500 mg');
    String frequency = '1-0-1 (Morning & Night)';
    String duration = '5 Days';
    String instructions = 'After Food';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: isDark ? AarogyaColors.darkSurface : AarogyaColors.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
              title: Text('Add Prescription Medicine', style: AarogyaTypography.title(isDark ? Colors.white : Colors.black)),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AarogyaTextField(
                        label: 'Medicine Name',
                        hintText: 'e.g. Paracetamol, Amoxicillin...',
                        controller: nameCtrl,
                        autofocus: true,
                      ),
                      const SizedBox(height: AarogyaSpacing.md),
                      AarogyaTextField(
                        label: 'Dosage',
                        hintText: 'e.g. 500 mg, 10 mg',
                        controller: dosageCtrl,
                      ),
                      const SizedBox(height: AarogyaSpacing.md),
                      Text('Frequency', style: AarogyaTypography.label(Colors.grey)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: ['1-0-0 (Morning)', '0-0-1 (Night)', '1-0-1 (Morning & Night)', '1-1-1 (Thrice Daily)']
                            .map((f) => ChoiceChip(
                                  label: Text(f),
                                  selected: frequency == f,
                                  onSelected: (_) => setDlgState(() => frequency = f),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: AarogyaSpacing.md),
                      Text('Duration', style: AarogyaTypography.label(Colors.grey)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: ['3 Days', '5 Days', '7 Days', '14 Days', '30 Days']
                            .map((d) => ChoiceChip(
                                  label: Text(d),
                                  selected: duration == d,
                                  onSelected: (_) => setDlgState(() => duration = d),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: AarogyaSpacing.md),
                      Text('Instructions', style: AarogyaTypography.label(Colors.grey)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: ['After Food', 'Before Food', 'With Water', 'At Bedtime']
                            .map((i) => ChoiceChip(
                                  label: Text(i),
                                  selected: instructions == i,
                                  onSelected: (_) => setDlgState(() => instructions = i),
                                ))
                            .toList(),
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
                  label: 'Add to Rx',
                  size: AarogyaButtonSize.sm,
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _medications.add(
                          Medication(
                            id: 'm-${DateTime.now().millisecondsSinceEpoch}',
                            name: nameCtrl.text.trim(),
                            dosage: dosageCtrl.text.trim(),
                            frequency: frequency,
                            duration: duration,
                            instructions: instructions,
                          ),
                        );
                      });
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _finalizeEncounter(BuildContext context, dynamic repo, Patient patient, QueueEntry? currentQueue) async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));

    repo.completeConsultation(
      appointmentId: currentQueue?.appointmentId ?? 'apt-101',
      patient: patient,
      chiefComplaint: _complaintController.text.trim(),
      symptoms: ['Chest Discomfort', 'Exertional Shortness of Breath'],
      vitals: patient.vitals,
      diagnosis: _diagnosisController.text.trim(),
      clinicalNotes: _notesController.text.trim(),
      medications: _medications,
      orderedLabTests: _selectedLabTests,
      followUpDate: _followUpDate,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AarogyaColors.success, size: 28),
              SizedBox(width: 8),
              Text('Encounter Finalized'),
            ],
          ),
          content: Text(
            'Clinical consultation record saved, digital prescription generated with cryptographic signature, and lab requisitions placed.\n\nNext patient has been notified.',
            style: AarogyaTypography.bodyMedium(Colors.grey.shade400),
          ),
          actions: [
            AarogyaButton(
              label: 'Return to Live Queue',
              onPressed: () {
                Navigator.pop(context);
                ref.read(selectedTabIndexProvider.notifier).state = 1; // back to queue
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(repositoryProvider);
    final patient = ref.watch(currentPatientProfileProvider);
    final queue = ref.watch(liveQueueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final currentQueue = queue.cast<QueueEntry?>().firstWhere(
          (q) => q?.status == QueueStatus.consulting,
          orElse: () => queue.isNotEmpty ? queue.first : null,
        );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : AarogyaSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Clinical Workspace',
                        style: AarogyaTypography.headingLarge(primaryText),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'EHR & Clinical Consultation Suite',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (currentQueue != null) ...[
                  const SizedBox(width: 8),
                  AarogyaBadge(
                    label: 'Token #${currentQueue.tokenNumber} • In Clinic',
                    variant: AarogyaBadgeVariant.success,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Responsive Layout: Desktop 2-Column or Mobile Column
            Responsive(
              mobile: Column(
                children: [
                  _buildPatientClinicalSummary(patient, isDark, primaryText, secondaryText),
                  const SizedBox(height: 8),
                  _buildConsultationForm(context, isDark, primaryText, secondaryText),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane: Clinical History & Vitals
                  SizedBox(
                    width: 380,
                    child: _buildPatientClinicalSummary(patient, isDark, primaryText, secondaryText),
                  ),
                  const SizedBox(width: AarogyaSpacing.lg),

                  // Right Pane: Active Consultation Form & Prescription Builder
                  Expanded(
                    child: _buildConsultationForm(context, isDark, primaryText, secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Finalize CTA
            GlassCard(
              glowColor: AarogyaColors.success,
              padding: AarogyaSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AarogyaColors.success, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ready to Finalize Encounter?',
                          style: AarogyaTypography.title(primaryText).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Will generate signed prescription, send lab orders, and discharge patient from OPD queue.',
                    style: AarogyaTypography.caption(secondaryText),
                  ),
                  const SizedBox(height: 12),
                  AarogyaButton(
                    label: 'Finalize & Sign Clinical Encounter',
                    icon: Icons.draw_rounded,
                    size: AarogyaButtonSize.md,
                    fullWidth: true,
                    isLoading: _isSaving,
                    onPressed: () => _finalizeEncounter(context, repo, patient, currentQueue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientClinicalSummary(
    Patient patient,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return Column(
      children: [
        // Patient Vitals Card
        GlassCard(
          glowColor: AarogyaColors.primaryCyan,
          padding: AarogyaSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AarogyaAvatar(
                    name: patient.name,
                    imageUrl: patient.avatarUrl,
                    size: 52,
                  ),
                  const SizedBox(width: AarogyaSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patient.name, style: AarogyaTypography.title(primaryText)),
                        Text(
                          '#${patient.id} • ${patient.age} Yrs • ${patient.gender}',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                        Text(
                          'Blood Group: ${patient.bloodGroup}',
                          style: AarogyaTypography.caption(AarogyaColors.primaryCyan),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Severe Allergies Banner
              Container(
                padding: AarogyaSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AarogyaColors.critical.withValues(alpha: 0.12),
                  borderRadius: AarogyaRadius.radiusMd,
                  border: Border.all(color: AarogyaColors.critical.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AarogyaColors.critical, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KNOWN ALLERGIES',
                            style: AarogyaTypography.caption(AarogyaColors.critical).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            patient.allergies.join(', '),
                            style: AarogyaTypography.bodyMedium(primaryText).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AarogyaSpacing.md),

              // Chronic conditions
              Text('Chronic Conditions', style: AarogyaTypography.label(secondaryText)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: patient.chronicConditions
                    .map((c) => AarogyaBadge(label: c, variant: AarogyaBadgeVariant.warning, showDot: false))
                    .toList(),
              ),
              const Divider(height: 20),

              // Objective Vitals Grid
              Text('Objective Vitals', style: AarogyaTypography.label(primaryText)),
              const SizedBox(height: 8),
              _buildVitalRow('Blood Pressure', patient.vitals.bloodPressure, 'mmHg', secondaryText, primaryText),
              _buildVitalRow('Heart Rate', '${patient.vitals.heartRate}', 'bpm', secondaryText, primaryText),
              _buildVitalRow('Oxygen SpO2', '${patient.vitals.spo2.toInt()}', '%', secondaryText, primaryText),
              _buildVitalRow('Body Temp', '${patient.vitals.temperature}', '°F', secondaryText, primaryText),
              _buildVitalRow('Body Weight', '${patient.vitals.weight}', 'kg', secondaryText, primaryText),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalRow(String label, String value, String unit, Color labelColor, Color valColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AarogyaTypography.caption(labelColor)),
          Text(
            '$value $unit',
            style: AarogyaTypography.caption(valColor).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationForm(
    BuildContext context,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chief complaint & Diagnosis
        GlassCard(
          padding: AarogyaSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clinical Assessment & Diagnosis', style: AarogyaTypography.headingMedium(primaryText)),
              const SizedBox(height: AarogyaSpacing.md),
              AarogyaTextField(
                label: 'Chief Complaint',
                controller: _complaintController,
                hintText: 'Primary symptoms reported by patient...',
              ),
              const SizedBox(height: AarogyaSpacing.md),
              AarogyaTextField(
                label: 'Clinical Diagnosis',
                controller: _diagnosisController,
                hintText: 'Formal medical diagnosis...',
              ),
              const SizedBox(height: AarogyaSpacing.md),
              AarogyaTextField(
                label: 'Examination Findings & Advice',
                controller: _notesController,
                maxLines: 3,
                hintText: 'Clinical notes, diet advice, precautions...',
              ),
            ],
          ),
        ),
        const SizedBox(height: AarogyaSpacing.lg),

        // Digital Prescription Builder
        GlassCard(
          padding: AarogyaSpacing.paddingLg,
          glowColor: AarogyaColors.accentPurple,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.medication_rounded, color: AarogyaColors.accentPurple, size: 22),
                      const SizedBox(width: 8),
                      Text('Digital Prescription (Rx)', style: AarogyaTypography.headingMedium(primaryText)),
                    ],
                  ),
                  AarogyaButton(
                    label: 'Add Medicine',
                    icon: Icons.add_rounded,
                    size: AarogyaButtonSize.sm,
                    onPressed: () => _showAddMedicationDialog(context, isDark),
                  ),
                ],
              ),
              const SizedBox(height: AarogyaSpacing.md),
              if (_medications.isEmpty)
                Text('No medications added yet.', style: AarogyaTypography.bodyMedium(secondaryText))
              else
                ..._medications.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final med = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: (isDark ? AarogyaColors.darkSurface : AarogyaColors.lightBg).withValues(alpha: 0.5),
                      borderRadius: AarogyaRadius.radiusMd,
                      border: Border.all(
                        color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medication_rounded, size: 18, color: AarogyaColors.accentPurple),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${med.name} (${med.dosage})', style: AarogyaTypography.label(primaryText)),
                              Text(
                                '${med.frequency} • ${med.duration} • ${med.instructions}',
                                style: AarogyaTypography.caption(secondaryText),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AarogyaColors.critical),
                          onPressed: () => setState(() => _medications.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: AarogyaSpacing.lg),

        // Lab Test Requisitions
        GlassCard(
          padding: AarogyaSpacing.paddingLg,
          glowColor: AarogyaColors.primaryBlue,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.biotech_rounded, color: AarogyaColors.primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  Text('Diagnostic Lab Orders', style: AarogyaTypography.headingMedium(primaryText)),
                ],
              ),
              const SizedBox(height: AarogyaSpacing.sm),
              Text(
                'Select laboratory investigations to order for this patient encounter:',
                style: AarogyaTypography.caption(secondaryText),
              ),
              const SizedBox(height: AarogyaSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableLabTests.map((test) {
                  final isSelected = _selectedLabTests.contains(test);
                  return FilterChip(
                    label: Text(test),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedLabTests.add(test);
                        } else {
                          _selectedLabTests.remove(test);
                        }
                      });
                    },
                    selectedColor: AarogyaColors.primaryBlue.withValues(alpha: 0.25),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
