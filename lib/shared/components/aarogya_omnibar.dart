import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/shell/adaptive_shell.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/utils/formatters.dart';
import '../../features/billing/invoice_receipt_dialog.dart';
import '../../features/patient/discovery/doctor_detail_sheet.dart';
import '../../shared/domain/models/doctor.dart';
import '../../shared/domain/models/invoice.dart';
import '../../shared/domain/models/lab_report.dart';
import '../../shared/domain/models/patient.dart';
import '../../shared/domain/models/user.dart';
import '../../shared/state/aarogya_providers.dart';

enum OmnibarCategory {
  all,
  doctors,
  patients,
  tests,
  invoices,
  actions;

  String get label {
    switch (this) {
      case OmnibarCategory.all:
        return 'All';
      case OmnibarCategory.doctors:
        return 'Doctors';
      case OmnibarCategory.patients:
        return 'Patients';
      case OmnibarCategory.tests:
        return 'Lab Tests';
      case OmnibarCategory.invoices:
        return 'Invoices';
      case OmnibarCategory.actions:
        return 'Actions';
    }
  }
}

class OmnibarItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final OmnibarCategory category;
  final VoidCallback onSelect;

  const OmnibarItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.category,
    required this.onSelect,
  });
}

class AarogyaOmnibar extends ConsumerStatefulWidget {
  const AarogyaOmnibar({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const AarogyaOmnibar(),
    );
  }

  @override
  ConsumerState<AarogyaOmnibar> createState() => _AarogyaOmnibarState();
}

class _AarogyaOmnibarState extends ConsumerState<AarogyaOmnibar> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OmnibarCategory _selectedCategory = OmnibarCategory.all;
  int _highlightedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
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

    final doctors = ref.watch(doctorsListProvider);
    final patients = ref.watch(allPatientsProvider);
    final labReports = ref.watch(labReportsProvider);
    final invoices = ref.watch(invoicesProvider);
    final repo = ref.read(repositoryProvider);

    final query = _queryController.text.trim().toLowerCase();
    final items = _buildSearchItems(
      context: context,
      query: query,
      doctors: doctors,
      patients: patients,
      labReports: labReports,
      invoices: invoices,
      repo: repo,
    );

    final filteredItems = _selectedCategory == OmnibarCategory.all
        ? items
        : items.where((i) => i.category == _selectedCategory).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 580),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14171D) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3540) : const Color(0xFFE5E7EB),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Input Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: AarogyaColors.primaryCyan,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        focusNode: _focusNode,
                        style: AarogyaTypography.title(primaryText),
                        decoration: InputDecoration(
                          hintText: 'Search patients, doctors, lab tests, bills, or actions...',
                          hintStyle: AarogyaTypography.bodyMedium(
                            secondaryText,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (_) {
                          setState(() {
                            _highlightedIndex = 0;
                          });
                        },
                      ),
                    ),
                    if (_queryController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        onPressed: () {
                          _queryController.clear();
                          setState(() {});
                        },
                      ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF222831)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ESC',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF252B33)
                    : const Color(0xFFE5E7EB),
              ),

              // Category Pills Strip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: OmnibarCategory.values.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                            ? AarogyaColors.primaryCyan
                                            : AarogyaColors.primaryBlue)
                                        .withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                          ? AarogyaColors.primaryCyan
                                          : AarogyaColors.primaryBlue)
                                    : (isDark
                                          ? const Color(0xFF252B33)
                                          : const Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? (isDark
                                          ? AarogyaColors.primaryCyan
                                          : AarogyaColors.primaryBlue)
                                    : secondaryText,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF252B33)
                    : const Color(0xFFE5E7EB),
              ),

              // Results List
              Flexible(
                child: filteredItems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 36,
                              color: secondaryText,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No matching records found',
                              style: AarogyaTypography.title(primaryText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching for doctor name, condition, or test name',
                              style: AarogyaTypography.caption(secondaryText),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        itemCount: filteredItems.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF1E232B)
                              : const Color(0xFFF3F4F6),
                        ),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isHighlighted = index == _highlightedIndex;
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              item.onSelect();
                            },
                            child: Container(
                              color: isHighlighted
                                  ? (isDark
                                        ? const Color(0xFF1E232C)
                                        : const Color(0xFFF3F4F6))
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: item.iconColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: AarogyaRadius.radiusMd,
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 16,
                                      color: item.iconColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style:
                                              AarogyaTypography.bodyMedium(
                                                primaryText,
                                              ).copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          item.subtitle,
                                          style: AarogyaTypography.caption(
                                            secondaryText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF222831)
                                          : const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.category.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Footer Shortcuts Hint
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF111418)
                      : const Color(0xFFF9FAFB),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFF222831)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildKeyHint('↑↓', 'Navigate', secondaryText, isDark),
                        const SizedBox(width: 12),
                        _buildKeyHint('↵', 'Select', secondaryText, isDark),
                        const SizedBox(width: 12),
                        _buildKeyHint('ESC', 'Dismiss', secondaryText, isDark),
                      ],
                    ),
                    Text(
                      '${filteredItems.length} results',
                      style: AarogyaTypography.caption(secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyHint(String key, String label, Color textColor, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF222831) : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: textColor)),
      ],
    );
  }

  List<OmnibarItem> _buildSearchItems({
    required BuildContext context,
    required String query,
    required List<Doctor> doctors,
    required List<Patient> patients,
    required List<LabReport> labReports,
    required List<Invoice> invoices,
    required dynamic repo,
  }) {
    final List<OmnibarItem> results = [];

    // 1. Actions & Navigation Commands
    final actions = [
      OmnibarItem(
        id: 'act-switch-doctor',
        title: 'Switch to Doctor Workspace',
        subtitle:
            'View live OPD patient queue and clinical consultation builder',
        icon: Icons.medical_services_rounded,
        iconColor: AarogyaColors.primaryCyan,
        category: OmnibarCategory.actions,
        onSelect: () {
          repo.switchRole(UserRole.doctor);
          ref.read(selectedTabIndexProvider.notifier).state = 0;
        },
      ),
      OmnibarItem(
        id: 'act-switch-admin',
        title: 'Switch to Admin Command Center',
        subtitle: 'Monitor inpatient bed occupancy, department throughput, and shifts',
        icon: Icons.admin_panel_settings_rounded,
        iconColor: AarogyaColors.warning,
        category: OmnibarCategory.actions,
        onSelect: () {
          repo.switchRole(UserRole.admin);
          ref.read(selectedTabIndexProvider.notifier).state = 0;
        },
      ),
      OmnibarItem(
        id: 'act-switch-patient',
        title: 'Switch to Patient Portal',
        subtitle:
            'Access health summary, appointments, prescriptions, and lab tests',
        icon: Icons.person_rounded,
        iconColor: AarogyaColors.success,
        category: OmnibarCategory.actions,
        onSelect: () {
          repo.switchRole(UserRole.patient);
          ref.read(selectedTabIndexProvider.notifier).state = 0;
        },
      ),
      OmnibarItem(
        id: 'act-nav-labs',
        title: 'Open Laboratory Hub',
        subtitle: 'Review diagnostic test panels, reference ranges, and abnormal flags',
        icon: Icons.biotech_rounded,
        iconColor: AarogyaColors.primaryCyan,
        category: OmnibarCategory.actions,
        onSelect: () {
          repo.switchRole(UserRole.patient);
          ref.read(selectedTabIndexProvider.notifier).state = 4; // Labs
        },
      ),
      OmnibarItem(
        id: 'act-nav-billing',
        title: 'Open Billing & Invoices',
        subtitle: 'Review hospital invoices, pay via UPI, and download digital receipts',
        icon: Icons.receipt_long_rounded,
        iconColor: AarogyaColors.success,
        category: OmnibarCategory.actions,
        onSelect: () {
          repo.switchRole(UserRole.patient);
          ref.read(selectedTabIndexProvider.notifier).state = 6; // Billing
        },
      ),
    ];

    for (final act in actions) {
      if (query.isEmpty ||
          act.title.toLowerCase().contains(query) ||
          act.subtitle.toLowerCase().contains(query)) {
        results.add(act);
      }
    }

    // 2. Doctors
    for (final doc in doctors) {
      if (query.isEmpty ||
          doc.name.toLowerCase().contains(query) ||
          doc.specialty.toLowerCase().contains(query) ||
          doc.bio.toLowerCase().contains(query)) {
        results.add(
          OmnibarItem(
            id: 'doc-${doc.id}',
            title: doc.name,
            subtitle:
                '${doc.specialty} • ${doc.experienceYears} Yrs Exp • ${AarogyaFormatters.currency(doc.consultationFee)}',
            icon: Icons.person_search_rounded,
            iconColor: AarogyaColors.primaryCyan,
            category: OmnibarCategory.doctors,
            onSelect: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => DoctorDetailSheet(doctor: doc),
              );
            },
          ),
        );
      }
    }

    // 3. Patients
    for (final pat in patients) {
      if (query.isEmpty ||
          pat.name.toLowerCase().contains(query) ||
          pat.allergies.any((a) => a.toLowerCase().contains(query)) ||
          pat.chronicConditions.any((c) => c.toLowerCase().contains(query))) {
        results.add(
          OmnibarItem(
            id: 'pat-${pat.id}',
            title: pat.name,
            subtitle:
                '${pat.age} Yrs • ${pat.gender} • Blood ${pat.bloodGroup} • ${pat.allergies.isNotEmpty ? 'Allergies: ${pat.allergies.join(", ")}' : 'No Allergies'}',
            icon: Icons.personal_injury_rounded,
            iconColor: AarogyaColors.accentPurple,
            category: OmnibarCategory.patients,
            onSelect: () {
              repo.switchRole(UserRole.doctor);
              ref.read(selectedTabIndexProvider.notifier).state =
                  2; // Clinical Workspace
            },
          ),
        );
      }
    }

    // 4. Lab Reports
    for (final lab in labReports) {
      if (query.isEmpty ||
          lab.testName.toLowerCase().contains(query) ||
          lab.category.toLowerCase().contains(query) ||
          (lab.labTechnicianNotes != null &&
              lab.labTechnicianNotes!.toLowerCase().contains(query))) {
        results.add(
          OmnibarItem(
            id: 'lab-${lab.id}',
            title: lab.testName,
            subtitle:
                '${lab.category} • ${lab.status.displayName} • ${lab.hasAbnormalResults ? "Abnormal Flags" : "Normal Values"}',
            icon: Icons.science_rounded,
            iconColor: lab.hasAbnormalResults
                ? AarogyaColors.critical
                : AarogyaColors.primaryCyan,
            category: OmnibarCategory.tests,
            onSelect: () {
              repo.switchRole(UserRole.patient);
              ref.read(selectedTabIndexProvider.notifier).state = 4; // Labs
            },
          ),
        );
      }
    }

    // 5. Invoices
    for (final inv in invoices) {
      if (query.isEmpty ||
          inv.id.toLowerCase().contains(query) ||
          inv.patientName.toLowerCase().contains(query)) {
        results.add(
          OmnibarItem(
            id: 'inv-${inv.id}',
            title:
                'Invoice #${inv.id.toUpperCase()} — ${AarogyaFormatters.currency(inv.totalAmount)}',
            subtitle:
                '${inv.patientName} • ${inv.status.displayName} • ${AarogyaFormatters.date(inv.date)}',
            icon: Icons.receipt_rounded,
            iconColor: inv.status == InvoiceStatus.paid
                ? AarogyaColors.success
                : AarogyaColors.warning,
            category: OmnibarCategory.invoices,
            onSelect: () {
              InvoiceReceiptDialog.show(context, inv);
            },
          ),
        );
      }
    }

    return results;
  }
}
