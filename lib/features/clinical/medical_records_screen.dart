import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/spacing.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_badge.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/medical_record.dart';
import '../../shared/state/aarogya_providers.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  ConsumerState<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  MedicalRecordType? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(medicalRecordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final filtered = _selectedFilter == null
        ? records
        : records.where((r) => r.type == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : AarogyaSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Health Timeline & EHR Records', style: AarogyaTypography.headingLarge(primaryText)),
                      Text(
                        'Unified chronological history of consultations, diagnostic panels, and prescriptions',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AarogyaBadge(
                  label: '${records.length} Total Records',
                  variant: AarogyaBadgeVariant.cyan,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Records', _selectedFilter == null, () {
                    setState(() => _selectedFilter = null);
                  }, isDark),
                  ...MedicalRecordType.values.map((type) {
                    final isSelected = _selectedFilter == type;
                    return _buildFilterChip(type.displayName, isSelected, () {
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
                        return _buildTimelineItem(context, record, isLast, isDark, primaryText, secondaryText);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: isDark ? AarogyaColors.primaryCyan.withOpacity(0.2) : AarogyaColors.primaryBlue.withOpacity(0.15),
        labelStyle: AarogyaTypography.caption(
          isSelected
              ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
              : (isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary),
        ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: AarogyaRadius.radiusPill,
          side: BorderSide(
            color: isSelected
                ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                : Colors.transparent,
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
    IconData icon;
    Color accentColor;

    switch (record.type) {
      case MedicalRecordType.consultation:
        icon = Icons.medical_services_rounded;
        accentColor = AarogyaColors.primaryCyan;
        break;
      case MedicalRecordType.labReport:
        icon = Icons.biotech_rounded;
        accentColor = AarogyaColors.primaryBlue;
        break;
      case MedicalRecordType.prescription:
        icon = Icons.medication_rounded;
        accentColor = AarogyaColors.accentPurple;
        break;
      case MedicalRecordType.radiology:
        icon = Icons.camera_enhance_rounded;
        accentColor = AarogyaColors.warning;
        break;
      case MedicalRecordType.dischargeSummary:
      default:
        icon = Icons.assignment_turned_in_rounded;
        accentColor = AarogyaColors.success;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor, width: 2),
                  ),
                  child: Icon(icon, size: 16, color: accentColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: (isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AarogyaSpacing.md),

          // Record Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AarogyaSpacing.lg),
              child: GlassCard(
                glowColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            record.title,
                            style: AarogyaTypography.title(primaryText).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AarogyaFormatters.date(record.date),
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        AarogyaBadge(label: record.type.displayName, variant: AarogyaBadgeVariant.info),
                        Text(
                          '${record.doctorName} • Department of ${record.department}',
                          style: AarogyaTypography.caption(AarogyaColors.primaryCyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(record.summary, style: AarogyaTypography.bodyMedium(secondaryText)),
                    if (record.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: record.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                              borderRadius: AarogyaRadius.radiusSm,
                            ),
                            child: Text('#$tag', style: AarogyaTypography.caption(secondaryText)),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
