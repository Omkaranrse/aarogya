import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/design_system/components/contextual_header.dart';
import '../../core/design_system/components/timeline_entry_card.dart';
import '../../core/theme/aarogya_theme_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/medical_record.dart';
import '../../shared/state/aarogya_providers.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  ConsumerState<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  MedicalRecordType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(medicalRecordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    final filtered = _selectedFilter == null
        ? records
        : records.where((r) => r.type == _selectedFilter).toList();

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
            ContextualHeader(
              title: 'Timeline & Health Records',
              subtitle: 'Unified chronological history of consultations & findings',
              statusLabel: '${records.length} Records',
              statusColor: context.aarogyaColors.primary,
            ),
            const SizedBox(height: 8),

            // Filter Chips with item count
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All (${records.length})', _selectedFilter == null, () {
                    setState(() => _selectedFilter = null);
                  }, isDark),
                  ...MedicalRecordType.values.map((type) {
                    final isSelected = _selectedFilter == type;
                    final count = records.where((r) => r.type == type).length;
                    return _buildFilterChip('${type.displayName} ($count)', isSelected, () {
                      setState(() => _selectedFilter = type);
                    }, isDark);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Timeline Feed
            Expanded(
              child: filtered.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.history_edu_outlined,
                      title: 'No Medical Records Found',
                      description: 'Records matching the selected filter will appear here in chronological order.',
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final record = filtered[index];
                        final isLast = index == filtered.length - 1;
                        return _buildTimelineItem(
                          context,
                          record,
                          isLast,
                          isDark,
                          primaryText,
                          secondaryText,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    final accentColor = isDark
        ? AarogyaColors.primaryCyan
        : AarogyaColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: accentColor.withValues(alpha: 0.15),
        backgroundColor: Colors.transparent,
        labelStyle: AarogyaTypography.caption(
          isSelected
              ? accentColor
              : (isDark
                    ? AarogyaColors.textDarkSecondary
                    : AarogyaColors.textLightSecondary),
        ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? accentColor
                : (isDark
                      ? AarogyaColors.darkGlassBorderSubtle
                      : AarogyaColors.lightGlassBorderSubtle),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    MedicalRecord record,
    bool isLast,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;

    IconData icon;
    Color accentColor;

    switch (record.type) {
      case MedicalRecordType.consultation:
        icon = Icons.medical_services_rounded;
        accentColor = colors.primary;
        break;
      case MedicalRecordType.labReport:
        icon = Icons.biotech_rounded;
        accentColor = colors.accentAction;
        break;
      case MedicalRecordType.prescription:
        icon = Icons.medication_rounded;
        accentColor = const Color(0xFF8B5CF6);
        break;
      case MedicalRecordType.radiology:
        icon = Icons.camera_enhance_rounded;
        accentColor = colors.clinicalWarning;
        break;
      case MedicalRecordType.dischargeSummary:
        icon = Icons.assignment_turned_in_rounded;
        accentColor = colors.clinicalStable;
        break;
      case MedicalRecordType.advisedDiagnostic:
        icon = Icons.pending_actions_rounded;
        accentColor = colors.clinicalWarning;
        break;
    }

    return TimelineEntryCard(
      icon: icon,
      iconColor: accentColor,
      isLast: isLast,
      title: record.title,
      subtitle: '${record.doctorName} • ${record.department}',
      timestamp: AarogyaFormatters.date(record.occurredAt),
      statusBadge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.12),
          borderRadius: AarogyaRadius.radius4,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: Text(
          record.type.displayName,
          style: typography.caption.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 9.5,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.summary,
            style: typography.body.copyWith(
              color: colors.neutrals.gray700,
            ),
          ),
          if (record.tags.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: record.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceActionable,
                    borderRadius: AarogyaRadius.radius4,
                    border: Border.all(
                      color: colors.borderHairline,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: typography.caption.copyWith(
                      color: colors.neutrals.gray500,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
