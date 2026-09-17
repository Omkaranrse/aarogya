import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/glass/glass_card.dart';
import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/radius.dart';
import '../../../core/design_system/tokens/spacing.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/motion/aarogya_motion.dart';
import '../../../core/design_system/components/aarogya_avatar.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../core/design_system/components/aarogya_text_field.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/domain/models/patient.dart';
import '../../../shared/domain/models/prescription.dart';
import '../../../shared/domain/models/queue_entry.dart';
import '../../../shared/state/aarogya_providers.dart';
import '../../../app/shell/adaptive_shell.dart';

class _FormularyPreset {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  const _FormularyPreset(
    this.name,
    this.dosage,
    this.frequency,
    this.duration,
    this.instructions,
  );
}

class ClinicalWorkspaceScreen extends ConsumerStatefulWidget {
  const ClinicalWorkspaceScreen({super.key});

  @override
  ConsumerState<ClinicalWorkspaceScreen> createState() =>
      _ClinicalWorkspaceScreenState();
}

class _ClinicalWorkspaceScreenState
    extends ConsumerState<ClinicalWorkspaceScreen> {
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

  final DateTime _followUpDate = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  PatientVitals? _activeVitals;

  @override
  void dispose() {
    _complaintController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyOrderSet({
    required String complaint,
    required String diagnosis,
    required String notes,
    required List<Medication> meds,
    required List<String> labs,
    required Patient patient,
  }) {
    setState(() {
      _complaintController.text = complaint;
      _diagnosisController.text = diagnosis;
      _notesController.text = notes;

      for (final lab in labs) {
        if (!_selectedLabTests.contains(lab)) {
          _selectedLabTests.add(lab);
        }
      }

      int addedCount = 0;
      final blocked = <String>[];

      for (final m in meds) {
        final conflict = _detectAllergyConflict(m.name, patient.allergies);
        if (conflict != null) {
          blocked.add(m.name);
        } else {
          if (!_medications.any((existing) => existing.name == m.name)) {
            _medications.add(m);
            addedCount++;
          }
        }
      }

      if (blocked.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '⚠️ Order set applied, but ${blocked.join(", ")} was withheld due to detected allergy conflict!',
            ),
            backgroundColor: AarogyaColors.critical,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Order set applied: $diagnosis ($addedCount meds, ${labs.length} labs)',
            ),
            backgroundColor: AarogyaColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  Widget _buildOrderSetCard({
    required String title,
    required String desc,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.38 : 0.28),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AarogyaColors.textDarkSecondary
                    : AarogyaColors.textLightSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clinical Allergy Detection Engine: Cross-references prescribed medicine
  /// against documented patient drug allergies and pharmaceutical cross-reactivities.
  String? _detectAllergyConflict(String medicineName, List<String> patientAllergies) {
    if (medicineName.trim().isEmpty || patientAllergies.isEmpty) return null;
    final medLower = medicineName.toLowerCase().trim();

    for (final allergy in patientAllergies) {
      final aLower = allergy.toLowerCase().trim();
      if (aLower == 'none recorded' || aLower.isEmpty) continue;

      // Penicillin & Beta-Lactam class
      if (aLower.contains('penicillin')) {
        const penicillinFamily = [
          'penicillin',
          'amoxicillin',
          'amoxil',
          'augmentin',
          'ampicillin',
          'piperacillin',
          'cloxacillin',
          'clavulanate',
          'methicillin',
        ];
        for (final p in penicillinFamily) {
          if (medLower.contains(p)) {
            return 'Patient has documented "$allergy" allergy. $medicineName is a Penicillin-class drug and carries a high risk of anaphylaxis.';
          }
        }
      }

      // Sulfa / Sulfonamides
      if (aLower.contains('sulfa')) {
        const sulfaFamily = [
          'sulfa',
          'sulfamethoxazole',
          'bactrim',
          'septra',
          'sulfasalazine',
          'sulfadiazine',
        ];
        for (final s in sulfaFamily) {
          if (medLower.contains(s)) {
            return 'Patient has documented "$allergy" allergy. $medicineName contains sulfonamides and may cause severe hypersensitivity.';
          }
        }
      }

      // Aspirin / NSAIDs
      if (aLower.contains('aspirin') || aLower.contains('nsaid')) {
        const nsaidFamily = [
          'aspirin',
          'ibuprofen',
          'combiflam',
          'diclofenac',
          'naproxen',
          'ketorolac',
          'indomethacin',
          'piroxicam',
          'aceclofenac',
        ];
        for (final n in nsaidFamily) {
          if (medLower.contains(n)) {
            return 'Patient has documented "$allergy" allergy. $medicineName is an NSAID/salicylate and is contraindicated.';
          }
        }
      }

      // Cephalosporins
      if (aLower.contains('cephalosporin')) {
        const cephFamily = [
          'cef',
          'ceph',
          'cefixime',
          'ceftriaxone',
          'cefuroxime',
          'cephalexin',
        ];
        for (final c in cephFamily) {
          if (medLower.contains(c)) {
            return 'Patient has documented "$allergy" allergy. $medicineName is a Cephalosporin with cross-reactivity risk.';
          }
        }
      }

      // Direct name match
      final cleanAllergy = aLower.replaceAll(RegExp(r'\(.*?\)'), '').trim();
      if (cleanAllergy.length >= 3 && medLower.contains(cleanAllergy)) {
        return 'Patient has documented "$allergy" allergy. $medicineName directly matches this allergy profile.';
      }
    }

    return null;
  }

  void _showAddMedicationDialog(
    BuildContext context,
    bool isDark,
    Patient patient,
  ) {
    final nameCtrl = TextEditingController();
    final dosageCtrl = TextEditingController(text: '500 mg');
    String frequency = '1-0-1 (Morning & Night)';
    String duration = '5 Days';
    String instructions = 'After Food';

    String? nameError;
    String? dosageError;
    String? allergyConflict;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            void checkAllergy() {
              final conflict = _detectAllergyConflict(
                nameCtrl.text,
                patient.allergies,
              );
              if (conflict != allergyConflict) {
                setDlgState(() => allergyConflict = conflict);
              }
            }

            return AlertDialog(
              backgroundColor: isDark
                  ? AarogyaColors.darkSurface
                  : AarogyaColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: AarogyaRadius.radiusXl,
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.medication_rounded,
                    color: AarogyaColors.accentPurple,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Prescription Medicine',
                    style: AarogyaTypography.title(
                      isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active patient allergy banner inside dialog
                      if (patient.allergies.isNotEmpty &&
                          !patient.allergies.contains('None recorded')) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AarogyaColors.critical.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AarogyaColors.critical.withValues(alpha: 0.35),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AarogyaColors.critical,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Known Patient Allergies: ${patient.allergies.join(", ")}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AarogyaColors.critical,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      Text(
                        'Formulary Quick Select',
                        style: AarogyaTypography.label(Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            _FormularyPreset(
                              'Paracetamol',
                              '650 mg',
                              '1-0-1 (Morning & Night)',
                              '5 Days',
                              'After Food',
                            ),
                            _FormularyPreset(
                              'Telmisartan',
                              '40 mg',
                              '1-0-0 (Morning)',
                              '30 Days',
                              'Before Food',
                            ),
                            _FormularyPreset(
                              'Amlodipine',
                              '5 mg',
                              '0-0-1 (Night)',
                              '30 Days',
                              'After Food',
                            ),
                            _FormularyPreset(
                              'Metformin',
                              '500 mg',
                              '1-0-1 (Morning & Night)',
                              '30 Days',
                              'After Food',
                            ),
                            _FormularyPreset(
                              'Atorvastatin',
                              '20 mg',
                              '0-0-1 (Night)',
                              '30 Days',
                              'At Bedtime',
                            ),
                            _FormularyPreset(
                              'Amoxicillin',
                              '500 mg',
                              '1-1-1 (Thrice Daily)',
                              '7 Days',
                              'After Food',
                            ),
                            _FormularyPreset(
                              'Pantoprazole',
                              '40 mg',
                              '1-0-0 (Morning)',
                              '14 Days',
                              'Empty Stomach',
                            ),
                            _FormularyPreset(
                              'Cetirizine',
                              '10 mg',
                              '0-0-1 (Night)',
                              '5 Days',
                              'At Bedtime',
                            ),
                          ].map((f) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                avatar: const Icon(
                                  Icons.bolt_rounded,
                                  size: 14,
                                  color: AarogyaColors.accentPurple,
                                ),
                                label: Text(
                                  '${f.name} ${f.dosage}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  setDlgState(() {
                                    nameCtrl.text = f.name;
                                    dosageCtrl.text = f.dosage;
                                    frequency = f.frequency;
                                    duration = f.duration;
                                    instructions = f.instructions;
                                    nameError = null;
                                    dosageError = null;
                                    checkAllergy();
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AarogyaSpacing.md),

                      AarogyaTextField(
                        label: 'Medicine Name *',
                        hintText: 'e.g. Paracetamol, Amoxicillin, Atorvastatin...',
                        controller: nameCtrl,
                        autofocus: true,
                        errorText: nameError,
                        onChanged: (_) {
                          setDlgState(() {
                            nameError = null;
                            checkAllergy();
                          });
                        },
                      ),

                      // Real-time Allergy Conflict Warning Box
                      if (allergyConflict != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AarogyaColors.critical.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AarogyaColors.critical,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.dangerous_rounded,
                                color: AarogyaColors.critical,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CONTRAINDICATION WARNING',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AarogyaColors.critical,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      allergyConflict!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AarogyaColors.critical,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AarogyaSpacing.md),
                      AarogyaTextField(
                        label: 'Dosage & Strength *',
                        hintText: 'e.g. 500 mg, 10 mg, 1 puff',
                        controller: dosageCtrl,
                        errorText: dosageError,
                        onChanged: (_) {
                          if (dosageError != null) {
                            setDlgState(() => dosageError = null);
                          }
                        },
                      ),
                      const SizedBox(height: AarogyaSpacing.md),
                      Text(
                        'Frequency',
                        style: AarogyaTypography.label(Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: [
                          '1-0-0 (Morning)',
                          '0-0-1 (Night)',
                          '1-0-1 (Morning & Night)',
                          '1-1-1 (Thrice Daily)',
                          'PRN (As Needed)',
                        ]
                            .map(
                              (f) => ChoiceChip(
                                label: Text(f),
                                selected: frequency == f,
                                onSelected: (_) =>
                                    setDlgState(() => frequency = f),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AarogyaSpacing.md),
                      Text(
                        'Duration',
                        style: AarogyaTypography.label(Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: [
                          '3 Days',
                          '5 Days',
                          '7 Days',
                          '14 Days',
                          '30 Days',
                          '60 Days',
                        ]
                            .map(
                              (d) => ChoiceChip(
                                label: Text(d),
                                selected: duration == d,
                                onSelected: (_) =>
                                    setDlgState(() => duration = d),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AarogyaSpacing.md),
                      Text(
                        'Instructions',
                        style: AarogyaTypography.label(Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: [
                          'After Food',
                          'Before Food',
                          'With Water',
                          'At Bedtime',
                          'Empty Stomach',
                        ]
                            .map(
                              (i) => ChoiceChip(
                                label: Text(i),
                                selected: instructions == i,
                                onSelected: (_) =>
                                    setDlgState(() => instructions = i),
                              ),
                            )
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
                  label: allergyConflict != null ? 'Override & Add' : 'Add to Rx',
                  variant: allergyConflict != null
                      ? AarogyaButtonVariant.destructive
                      : AarogyaButtonVariant.primary,
                  size: AarogyaButtonSize.sm,
                  onPressed: () {
                    final medName = nameCtrl.text.trim();
                    final dosage = dosageCtrl.text.trim();

                    bool valid = true;
                    if (medName.isEmpty) {
                      setDlgState(() => nameError = 'Medicine name is required.');
                      valid = false;
                    } else if (medName.length < 2) {
                      setDlgState(() => nameError = 'Please enter a valid medicine name (min 2 characters).');
                      valid = false;
                    }

                    if (dosage.isEmpty) {
                      setDlgState(() => dosageError = 'Dosage is required (e.g. 500 mg, 10 ml).');
                      valid = false;
                    }

                    if (!valid) return;

                    // Safety Barrier Confirmation Modal for Allergy Conflicts
                    if (allergyConflict != null) {
                      showDialog(
                        context: context,
                        builder: (confirmCtx) {
                          return AlertDialog(
                            backgroundColor: isDark
                                ? AarogyaColors.darkSurface
                                : AarogyaColors.lightSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: AarogyaRadius.radiusLg,
                            ),
                            title: const Row(
                              children: [
                                Icon(
                                  Icons.dangerous_rounded,
                                  color: AarogyaColors.critical,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text('Clinical Allergy Override'),
                              ],
                            ),
                            content: Text(
                              'Patient has documented allergy: $allergyConflict\n\nAre you clinically certain you want to prescribe $medName?',
                              style: AarogyaTypography.bodyMedium(
                                isDark
                                    ? AarogyaColors.textDarkPrimary
                                    : AarogyaColors.textLightPrimary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(confirmCtx),
                                child: const Text('Cancel & Choose Safe Drug'),
                              ),
                              AarogyaButton(
                                label: 'Confirm Override',
                                variant: AarogyaButtonVariant.destructive,
                                size: AarogyaButtonSize.sm,
                                onPressed: () {
                                  Navigator.pop(confirmCtx);
                                  Navigator.pop(ctx);
                                  setState(() {
                                    _medications.add(
                                      Medication(
                                        id: 'm-${DateTime.now().millisecondsSinceEpoch}',
                                        name: '$medName [⚠️ Allergy Overridden]',
                                        dosage: dosage,
                                        frequency: frequency,
                                        duration: duration,
                                        instructions: instructions,
                                      ),
                                    );
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Prescription added with documented clinical allergy override for $medName.',
                                      ),
                                      backgroundColor: AarogyaColors.warning,
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    setState(() {
                      _medications.add(
                        Medication(
                          id: 'm-${DateTime.now().millisecondsSinceEpoch}',
                          name: medName,
                          dosage: dosage,
                          frequency: frequency,
                          duration: duration,
                          instructions: instructions,
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditVitalsDialog(
    BuildContext context,
    Patient patient,
    bool isDark, {
    QueueEntry? currentQueue,
  }) {
    final current = _activeVitals ?? currentQueue?.vitals ?? patient.vitals;
    final bpCtrl = TextEditingController(text: current.bloodPressure);
    final hrCtrl = TextEditingController(text: '${current.heartRate}');
    final spo2Ctrl = TextEditingController(text: '${current.spo2.toInt()}');
    final tempCtrl = TextEditingController(text: '${current.temperature}');
    final rrCtrl = TextEditingController(text: '${current.respiratoryRate ?? 16}');
    final weightCtrl = TextEditingController(text: '${current.weight}');

    String? bpError;
    String? hrError;
    String? spo2Error;
    String? tempError;
    String? rrError;
    String? weightError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              backgroundColor: isDark
                  ? AarogyaColors.darkSurface
                  : AarogyaColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: AarogyaRadius.radiusXl,
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AarogyaColors.critical,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Record Patient Vitals',
                    style: AarogyaTypography.title(
                      isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AarogyaTextField(
                        label: 'Blood Pressure (Systolic/Diastolic mmHg) *',
                        hintText: 'e.g. 120/80',
                        controller: bpCtrl,
                        errorText: bpError,
                      ),
                      const SizedBox(height: 10),
                      AarogyaTextField(
                        label: 'Heart Rate (bpm) *',
                        hintText: 'e.g. 72',
                        controller: hrCtrl,
                        keyboardType: TextInputType.number,
                        errorText: hrError,
                      ),
                      const SizedBox(height: 10),
                      AarogyaTextField(
                        label: 'Oxygen Saturation SpO2 (%) *',
                        hintText: 'e.g. 98',
                        controller: spo2Ctrl,
                        keyboardType: TextInputType.number,
                        errorText: spo2Error,
                      ),
                      const SizedBox(height: 10),
                      AarogyaTextField(
                        label: 'Body Temperature (°F) *',
                        hintText: 'e.g. 98.6',
                        controller: tempCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        errorText: tempError,
                      ),
                      const SizedBox(height: 10),
                      AarogyaTextField(
                        label: 'Body Weight (kg) *',
                        hintText: 'e.g. 68.5',
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        errorText: weightError,
                      ),
                      const SizedBox(height: 12),
                      AarogyaTextField(
                        label: 'Respiratory Rate (breaths/min)',
                        controller: rrCtrl,
                        keyboardType: TextInputType.number,
                        errorText: rrError,
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
                  label: 'Save Vitals',
                  size: AarogyaButtonSize.sm,
                  onPressed: () {
                    // Perform clinical range validation
                    bool isValid = true;
                    final bpText = bpCtrl.text.trim();
                    final bpRegex = RegExp(r'^(\d{2,3})\/(\d{2,3})$');
                    final match = bpRegex.firstMatch(bpText);
                    if (match == null) {
                      bpError = 'Format must be Systolic/Diastolic (e.g. 120/80)';
                      isValid = false;
                    } else {
                      final sys = int.tryParse(match.group(1)!) ?? 0;
                      final dia = int.tryParse(match.group(2)!) ?? 0;
                      if (sys < 60 || sys > 260 || dia < 35 || dia > 160) {
                        bpError = 'Physiological range: Sys 60-260, Dia 35-160';
                        isValid = false;
                      } else {
                        bpError = null;
                      }
                    }

                    final hr = int.tryParse(hrCtrl.text.trim());
                    if (hr == null || hr < 30 || hr > 240) {
                      hrError = 'Enter valid heart rate (30 - 240 bpm)';
                      isValid = false;
                    } else {
                      hrError = null;
                    }

                    final spo2 = double.tryParse(spo2Ctrl.text.trim());
                    if (spo2 == null || spo2 < 50 || spo2 > 100) {
                      spo2Error = 'Enter valid SpO2 (50% - 100%)';
                      isValid = false;
                    } else {
                      spo2Error = null;
                    }

                    final temp = double.tryParse(tempCtrl.text.trim());
                    if (temp == null || temp < 92.0 || temp > 108.0) {
                      tempError = 'Enter valid body temp (92.0°F - 108.0°F)';
                      isValid = false;
                    } else {
                      tempError = null;
                    }

                    final weight = double.tryParse(weightCtrl.text.trim());
                    if (weight == null || weight < 1.0 || weight > 350.0) {
                      weightError = 'Enter valid weight (1 - 350 kg)';
                      isValid = false;
                    } else {
                      weightError = null;
                    }

                    final rr = int.tryParse(rrCtrl.text.trim());
                    if (rr == null || rr < 4 || rr > 60) {
                      rrError = 'Enter valid respiration rate (4 - 60 bpm)';
                      isValid = false;
                    } else {
                      rrError = null;
                    }

                    setDlgState(() {});

                    if (isValid) {
                      setState(() {
                        _activeVitals = PatientVitals(
                          bloodPressure: bpText,
                          heartRate: hr!,
                          spo2: spo2!,
                          temperature: temp!,
                          respiratoryRate: rr!,
                          weight: weight!,
                          recordedAt: DateTime.now(),
                        );
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Patient vitals updated and validated successfully.',
                          ),
                          backgroundColor: AarogyaColors.success,
                        ),
                      );
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

  void _finalizeEncounter(
    dynamic repo,
    Patient patient,
    QueueEntry? currentQueue,
  ) async {
    final complaint = _complaintController.text.trim();
    final diagnosis = _diagnosisController.text.trim();

    // Clinical Encounter Form Validation
    if (complaint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the chief clinical complaint before finalizing encounter.'),
          backgroundColor: AarogyaColors.critical,
        ),
      );
      return;
    }

    if (diagnosis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a clinical diagnosis before finalizing encounter.'),
          backgroundColor: AarogyaColors.critical,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));

    repo.completeConsultation(
      appointmentId: currentQueue?.appointmentId ?? 'apt-101',
      patient: patient,
      chiefComplaint: complaint,
      symptoms: ['Chest Discomfort', 'Exertional Shortness of Breath'],
      vitals: _activeVitals ?? currentQueue?.vitals ?? patient.vitals,
      diagnosis: diagnosis,
      clinicalNotes: _notesController.text.trim(),
      medications: _medications,
      orderedLabTests: _selectedLabTests,
      followUpDate: _followUpDate,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
        title: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AarogyaColors.success,
              size: 28,
            ),
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
              ref.read(selectedTabIndexProvider.notifier).state =
                  1; // back to queue
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(repositoryProvider);
    final queue = ref.watch(liveQueueProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    final currentQueue = queue.cast<QueueEntry?>().firstWhere(
      (q) => q?.status == QueueStatus.consulting,
      orElse: () => queue.isNotEmpty ? queue.first : null,
    );

    // Resolve the actual patient being consulted in this chamber encounter
    final fallbackPatient = ref.watch(currentPatientProfileProvider);
    final Patient patient = currentQueue != null
        ? repo.patients.firstWhere(
            (p) => p.id == currentQueue.patientId,
            orElse: () {
              final byName = repo.patients.where(
                (p) =>
                    p.name.toLowerCase() ==
                    currentQueue.patientName.toLowerCase(),
              );
              if (byName.isNotEmpty) return byName.first;
              return fallbackPatient.copyWith(
                id: currentQueue.patientId,
                name: currentQueue.patientName,
                age: currentQueue.age,
                gender: currentQueue.gender,
              );
            },
          )
        : fallbackPatient;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? 12 : 24,
          vertical: Responsive.isMobile(context) ? 12 : 16,
        ),
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
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AarogyaColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AarogyaColors.success.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AarogyaPulseBeacon(
                            color: AarogyaColors.success,
                            size: 5,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Token #${currentQueue.tokenNumber} • In Clinic',
                              style:
                                  AarogyaTypography.caption(AarogyaColors.success)
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10.5,
                                      ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Responsive Layout: Desktop 2-Column or Mobile Column
            Responsive(
              mobile: Column(
                children: [
                  _buildPatientClinicalSummary(
                    patient,
                    isDark,
                    primaryText,
                    secondaryText,
                    currentQueue: currentQueue,
                  ),
                  const SizedBox(height: 8),
                  _buildConsultationForm(
                    context,
                    isDark,
                    primaryText,
                    secondaryText,
                    patient,
                  ),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane: Clinical History & Vitals
                  SizedBox(
                    width: 380,
                    child: _buildPatientClinicalSummary(
                      patient,
                      isDark,
                      primaryText,
                      secondaryText,
                      currentQueue: currentQueue,
                    ),
                  ),
                  const SizedBox(width: AarogyaSpacing.lg),

                  // Right Pane: Active Consultation Form & Prescription Builder
                  Expanded(
                    child: _buildConsultationForm(
                      context,
                      isDark,
                      primaryText,
                      secondaryText,
                      patient,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Finalize CTA
            GlassCard(
              padding: AarogyaSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AarogyaColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ready to Finalize Encounter?',
                          style: AarogyaTypography.title(primaryText)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Will generate signed prescription, place lab orders, and discharge patient from OPD queue.',
                    style: AarogyaTypography.caption(secondaryText),
                  ),
                  const SizedBox(height: 12),
                  AarogyaButton(
                    label: 'Finalize & Sign Clinical Encounter',
                    icon: Icons.draw_rounded,
                    size: AarogyaButtonSize.md,
                    fullWidth: true,
                    isLoading: _isSaving,
                    onPressed: () =>
                        _finalizeEncounter(repo, patient, currentQueue),
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
    Color secondaryText, {
    QueueEntry? currentQueue,
  }) {
    return Column(
      children: [
        // Patient Vitals Card
        GlassCard(
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
                        Text(
                          patient.name,
                          style: AarogyaTypography.title(primaryText),
                        ),
                        Text(
                          '#${patient.id} • ${patient.age} Yrs • ${patient.gender}',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                        Text(
                          'Blood Group: ${patient.bloodGroup}',
                          style: AarogyaTypography.caption(
                            isDark
                                ? AarogyaColors.primaryCyan
                                : AarogyaColors.primaryBlue,
                          ),
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
                  border: Border.all(
                    color: AarogyaColors.critical.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AarogyaColors.critical,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KNOWN ALLERGIES',
                            style: AarogyaTypography.caption(
                              AarogyaColors.critical,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            patient.allergies.join(', '),
                            style: AarogyaTypography.bodyMedium(primaryText)
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AarogyaSpacing.md),

              // Chronic conditions
              Text(
                'Chronic Conditions',
                style: AarogyaTypography.label(secondaryText),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: patient.chronicConditions
                    .map(
                      (c) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: AarogyaColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AarogyaColors.warning.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          c,
                          style: AarogyaTypography.caption(
                            AarogyaColors.warning,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Divider(height: 20),

              // Objective Vitals Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Objective Vitals',
                    style: AarogyaTypography.label(primaryText),
                  ),
                  InkWell(
                    onTap: () => _showEditVitalsDialog(context, patient, isDark),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                              .withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 13,
                            color: isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Record / Edit',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (currentQueue?.ewsScore != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: (currentQueue!.priority == PatientPriority.emergency || currentQueue.priority == PatientPriority.urgent)
                        ? AarogyaColors.critical.withValues(alpha: 0.12)
                        : AarogyaColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (currentQueue.priority == PatientPriority.emergency || currentQueue.priority == PatientPriority.urgent)
                          ? AarogyaColors.critical.withValues(alpha: 0.3)
                          : AarogyaColors.success.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        currentQueue.priority == PatientPriority.emergency || currentQueue.priority == PatientPriority.urgent
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 14,
                        color: (currentQueue.priority == PatientPriority.emergency || currentQueue.priority == PatientPriority.urgent)
                            ? AarogyaColors.critical
                            : AarogyaColors.success,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Triage Counter: NEWS2 Acuity ${currentQueue.ewsScore} (${currentQueue.priority.displayName})',
                          style: AarogyaTypography.caption(
                            (currentQueue.priority == PatientPriority.emergency || currentQueue.priority == PatientPriority.urgent)
                                ? AarogyaColors.critical
                                : AarogyaColors.success,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              _buildVitalRow(
                'Blood Pressure',
                (_activeVitals ?? currentQueue?.vitals ?? patient.vitals).bloodPressure,
                'mmHg',
                secondaryText,
                primaryText,
              ),
              _buildVitalRow(
                'Heart Rate',
                '${(_activeVitals ?? currentQueue?.vitals ?? patient.vitals).heartRate}',
                'bpm',
                secondaryText,
                primaryText,
              ),
              _buildVitalRow(
                'Oxygen SpO2',
                '${(_activeVitals ?? currentQueue?.vitals ?? patient.vitals).spo2.toInt()}',
                '%',
                secondaryText,
                primaryText,
              ),
              _buildVitalRow(
                'Body Temp',
                '${(_activeVitals ?? currentQueue?.vitals ?? patient.vitals).temperature}',
                '°F',
                secondaryText,
                primaryText,
              ),
              if ((_activeVitals ?? currentQueue?.vitals ?? patient.vitals).respiratoryRate != null)
                _buildVitalRow(
                  'Respiration Rate',
                  '${(_activeVitals ?? currentQueue?.vitals ?? patient.vitals).respiratoryRate}',
                  'bpm',
                  secondaryText,
                  primaryText,
                ),
              _buildVitalRow(
                'Body Weight',
                '${(_activeVitals ?? currentQueue?.vitals ?? patient.vitals).weight}',
                'kg',
                secondaryText,
                primaryText,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVitalRow(
    String label,
    String value,
    String unit,
    Color labelColor,
    Color valColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AarogyaTypography.caption(labelColor)),
          Text(
            '$value $unit',
            style: AarogyaTypography.caption(valColor)
                .copyWith(fontWeight: FontWeight.w700),
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
    Patient patient,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⚡ 1-Click Clinical Order Sets (Protocols)
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AarogyaColors.accentPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.electric_bolt_rounded,
                      color: AarogyaColors.accentPurple,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '1-Click Clinical Protocols & Order Sets',
                      style: AarogyaTypography.headingMedium(primaryText).copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AarogyaColors.accentPurple.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AarogyaColors.accentPurple.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      'Auto-fill',
                      style: AarogyaTypography.caption(AarogyaColors.accentPurple).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildOrderSetCard(
                      title: '🫀 Hypertension Refill',
                      desc: 'Telmisartan 40mg + Amlodipine 5mg • Lipids, Creatinine',
                      color: AarogyaColors.primaryBlue,
                      isDark: isDark,
                      onTap: () => _applyOrderSet(
                        complaint: 'Routine hypertension follow-up, asymptomatic',
                        diagnosis: 'Essential Hypertension (ICD-10 I10)',
                        notes: 'Blood pressure controlled on dual therapy. Advised low-sodium diet, 30 min daily walking. Review in 3 months.',
                        meds: const [
                          Medication(
                            id: 'ord-htn-1',
                            name: 'Telmisartan',
                            dosage: '40 mg',
                            frequency: '1-0-0 (Morning)',
                            duration: '30 Days',
                            instructions: 'Before Food',
                          ),
                          Medication(
                            id: 'ord-htn-2',
                            name: 'Amlodipine',
                            dosage: '5 mg',
                            frequency: '0-0-1 (Night)',
                            duration: '30 Days',
                            instructions: 'After Food',
                          ),
                        ],
                        labs: const [
                          'Comprehensive Lipid Profile',
                          'Serum Creatinine & Electrolytes',
                        ],
                        patient: patient,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildOrderSetCard(
                      title: '🩸 T2DM Glycemic Control',
                      desc: 'Metformin 500mg • HbA1c, Fasting Blood Sugar',
                      color: AarogyaColors.success,
                      isDark: isDark,
                      onTap: () => _applyOrderSet(
                        complaint: 'Routine diabetic evaluation, no hypoglycemia or polyuria',
                        diagnosis: 'Type 2 Diabetes Mellitus (ICD-10 E11.9)',
                        notes: 'Glycemic monitoring discussed. Balanced diabetic diet and foot care precautions advised. Repeat HbA1c before next visit.',
                        meds: const [
                          Medication(
                            id: 'ord-dm-1',
                            name: 'Metformin',
                            dosage: '500 mg',
                            frequency: '1-0-1 (Morning & Night)',
                            duration: '30 Days',
                            instructions: 'After Food',
                          ),
                        ],
                        labs: const [
                          'HbA1c (Glycated Hemoglobin)',
                        ],
                        patient: patient,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildOrderSetCard(
                      title: '🤧 Acute URTI / Flu',
                      desc: 'Paracetamol 650mg + Cetirizine 10mg • CBC',
                      color: const Color(0xFFF59E0B),
                      isDark: isDark,
                      onTap: () => _applyOrderSet(
                        complaint: 'Sore throat, rhinorrhea, low-grade fever x 3 days',
                        diagnosis: 'Acute Upper Respiratory Tract Infection (ICD-10 J06.9)',
                        notes: 'Symptomatic viral URTI. Warm saline gargles, steam inhalation, and oral hydration. Return if dyspnea or high persistent fever.',
                        meds: const [
                          Medication(
                            id: 'ord-urti-1',
                            name: 'Paracetamol',
                            dosage: '650 mg',
                            frequency: '1-0-1 (Morning & Night)',
                            duration: '5 Days',
                            instructions: 'After Food',
                          ),
                          Medication(
                            id: 'ord-urti-2',
                            name: 'Cetirizine',
                            dosage: '10 mg',
                            frequency: '0-0-1 (Night)',
                            duration: '5 Days',
                            instructions: 'At Bedtime',
                          ),
                        ],
                        labs: const [
                          'Complete Blood Count (CBC)',
                        ],
                        patient: patient,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildOrderSetCard(
                      title: '💊 Dyslipidemia / Statin',
                      desc: 'Atorvastatin 20mg • Lipid & Liver Profile',
                      color: AarogyaColors.accentPurple,
                      isDark: isDark,
                      onTap: () => _applyOrderSet(
                        complaint: 'Cardiovascular risk evaluation and lipid management',
                        diagnosis: 'Hyperlipidemia (ICD-10 E78.5)',
                        notes: 'Lipid-lowering therapy initiated. Low saturated fat diet advised. Repeat fasting lipid panel in 12 weeks.',
                        meds: const [
                          Medication(
                            id: 'ord-statin-1',
                            name: 'Atorvastatin',
                            dosage: '20 mg',
                            frequency: '0-0-1 (Night)',
                            duration: '30 Days',
                            instructions: 'At Bedtime',
                          ),
                        ],
                        labs: const [
                          'Comprehensive Lipid Profile',
                        ],
                        patient: patient,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AarogyaSpacing.md),

        // Chief complaint & Diagnosis
        GlassCard(
          padding: AarogyaSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Assessment & Diagnosis',
                style: AarogyaTypography.headingMedium(primaryText),
              ),
              const SizedBox(height: AarogyaSpacing.md),
              AarogyaTextField(
                label: 'Chief Complaint *',
                controller: _complaintController,
                hintText: 'Primary symptoms reported by patient...',
              ),
              const SizedBox(height: AarogyaSpacing.md),
              AarogyaTextField(
                label: 'Clinical Diagnosis *',
                controller: _diagnosisController,
                hintText: 'Formal medical diagnosis...',
              ),
              const SizedBox(height: AarogyaSpacing.md),
              AarogyaTextField(
                label: 'Clinical Progress Notes',
                controller: _notesController,
                maxLines: 3,
                hintText: 'Detailed clinical assessment, examination findings...',
              ),
            ],
          ),
        ),
        const SizedBox(height: AarogyaSpacing.lg),

        // Digital Prescription Card
        GlassCard(
          padding: AarogyaSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (patient.allergies.isNotEmpty &&
                  !patient.allergies.contains('None recorded')) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AarogyaColors.critical.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AarogyaColors.critical.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AarogyaColors.critical,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Known Patient Allergies: ${patient.allergies.join(", ")} — Auto-checked on prescribing',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AarogyaColors.critical,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medication_rounded,
                          color: AarogyaColors.accentPurple,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Digital Prescription (Rx)',
                            style: AarogyaTypography.headingMedium(primaryText),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AarogyaButton(
                    label: 'Add Medicine',
                    icon: Icons.add_rounded,
                    size: AarogyaButtonSize.sm,
                    onPressed: () => _showAddMedicationDialog(context, isDark, patient),
                  ),
                ],
              ),
              const SizedBox(height: AarogyaSpacing.md),
              if (_medications.isEmpty)
                Text(
                  'No medications added yet.',
                  style: AarogyaTypography.bodyMedium(secondaryText),
                )
              else
                ..._medications.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final med = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isDark
                                  ? AarogyaColors.darkSurface
                                  : AarogyaColors.lightBg)
                              .withValues(alpha: 0.5),
                      borderRadius: AarogyaRadius.radiusMd,
                      border: Border.all(
                        color: isDark
                            ? AarogyaColors.darkGlassBorderSubtle
                            : AarogyaColors.lightGlassBorderSubtle,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.medication_rounded,
                          size: 18,
                          color: AarogyaColors.accentPurple,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${med.name} (${med.dosage})',
                                style: AarogyaTypography.label(primaryText),
                              ),
                              Text(
                                '${med.frequency} • ${med.duration} • ${med.instructions}',
                                style: AarogyaTypography.caption(secondaryText),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AarogyaColors.critical,
                          ),
                          onPressed: () =>
                              setState(() => _medications.removeAt(idx)),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.biotech_rounded,
                    color: isDark
                        ? AarogyaColors.primaryCyan
                        : AarogyaColors.primaryBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Diagnostic Lab Orders',
                    style: AarogyaTypography.headingMedium(primaryText),
                  ),
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
                    selectedColor:
                        (isDark
                                ? AarogyaColors.primaryCyan
                                : AarogyaColors.primaryBlue)
                            .withValues(alpha: 0.15),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
