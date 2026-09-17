import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clinical/ews_triage_calculator.dart';
import '../../core/design_system/components/aarogya_avatar.dart';
import '../../core/design_system/components/aarogya_badge.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/design_system/components/aarogya_text_field.dart';
import '../../core/design_system/components/stat_card.dart';
import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/motion/aarogya_motion.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/spacing.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/appointment.dart';
import '../../shared/domain/models/doctor.dart';
import '../../shared/domain/models/patient.dart';
import '../../shared/domain/models/queue_entry.dart';
import '../../shared/state/aarogya_providers.dart';

enum BedStatus {
  available,
  occupied,
  sanitizing,
  reserved;

  String get label {
    switch (this) {
      case BedStatus.available:
        return 'Available';
      case BedStatus.occupied:
        return 'Occupied';
      case BedStatus.sanitizing:
        return 'Sanitizing';
      case BedStatus.reserved:
        return 'Reserved';
    }
  }

  Color get color {
    switch (this) {
      case BedStatus.available:
        return AarogyaColors.success;
      case BedStatus.occupied:
        return AarogyaColors.primaryCyan;
      case BedStatus.sanitizing:
        return AarogyaColors.warning;
      case BedStatus.reserved:
        return AarogyaColors.accentPurple;
    }
  }
}

class HospitalBed {
  final String id;
  final String ward;
  final String bedNumber;
  final BedStatus status;
  final String? patientName;
  final String? admissionDate;
  final String? attendingDoctor;

  const HospitalBed({
    required this.id,
    required this.ward,
    required this.bedNumber,
    required this.status,
    this.patientName,
    this.admissionDate,
    this.attendingDoctor,
  });

  HospitalBed copyWith({
    BedStatus? status,
    String? patientName,
    String? admissionDate,
    String? attendingDoctor,
  }) {
    return HospitalBed(
      id: id,
      ward: ward,
      bedNumber: bedNumber,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      admissionDate: admissionDate ?? this.admissionDate,
      attendingDoctor: attendingDoctor ?? this.attendingDoctor,
    );
  }
}

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  String _selectedWard = 'All';
  int _triageTab = 0; // 0: Awaiting Counter Triage, 1: Live Checked-In Queue
  int _selectedAdminSection = 0; // 0: OPD & Triage Desk, 1: Bed & Ward Census, 2: Operations & Staff
  late List<HospitalBed> _beds;

  @override
  void initState() {
    super.initState();
    _beds = [
      const HospitalBed(
        id: 'b-1',
        ward: 'ICU',
        bedNumber: 'ICU-01',
        status: BedStatus.occupied,
        patientName: 'Rajesh Verma (62M)',
        admissionDate: '14 Sep',
        attendingDoctor: 'Dr. Ananya Sharma',
      ),
      const HospitalBed(
        id: 'b-2',
        ward: 'ICU',
        bedNumber: 'ICU-02',
        status: BedStatus.occupied,
        patientName: 'Meera Iyer (49F)',
        admissionDate: '15 Sep',
        attendingDoctor: 'Dr. Vikram Patel',
      ),
      const HospitalBed(
        id: 'b-3',
        ward: 'ICU',
        bedNumber: 'ICU-03',
        status: BedStatus.sanitizing,
      ),
      const HospitalBed(
        id: 'b-4',
        ward: 'ICU',
        bedNumber: 'ICU-04',
        status: BedStatus.available,
      ),
      const HospitalBed(
        id: 'b-5',
        ward: 'Emergency',
        bedNumber: 'EMG-01',
        status: BedStatus.occupied,
        patientName: 'Sanjay Deshmukh (35M)',
        admissionDate: 'Today',
        attendingDoctor: 'Dr. Neha Gupta',
      ),
      const HospitalBed(
        id: 'b-6',
        ward: 'Emergency',
        bedNumber: 'EMG-02',
        status: BedStatus.occupied,
        patientName: 'Pooja Kulkarni (28F)',
        admissionDate: 'Today',
        attendingDoctor: 'Dr. Neha Gupta',
      ),
      const HospitalBed(
        id: 'b-7',
        ward: 'Emergency',
        bedNumber: 'EMG-03',
        status: BedStatus.reserved,
        patientName: 'Incoming Ambulance Transfer',
        admissionDate: 'Pending',
        attendingDoctor: 'Triage Desk',
      ),
      const HospitalBed(
        id: 'b-8',
        ward: 'Emergency',
        bedNumber: 'EMG-04',
        status: BedStatus.available,
      ),
      const HospitalBed(
        id: 'b-9',
        ward: 'General',
        bedNumber: 'GW-101',
        status: BedStatus.occupied,
        patientName: 'Amit Shah (55M)',
        admissionDate: '12 Sep',
        attendingDoctor: 'Dr. Rajesh Nair',
      ),
      const HospitalBed(
        id: 'b-10',
        ward: 'General',
        bedNumber: 'GW-102',
        status: BedStatus.occupied,
        patientName: 'Kavita Joshi (41F)',
        admissionDate: '13 Sep',
        attendingDoctor: 'Dr. Ananya Sharma',
      ),
      const HospitalBed(
        id: 'b-11',
        ward: 'General',
        bedNumber: 'GW-103',
        status: BedStatus.available,
      ),
      const HospitalBed(
        id: 'b-12',
        ward: 'General',
        bedNumber: 'GW-104',
        status: BedStatus.sanitizing,
      ),
      const HospitalBed(
        id: 'b-13',
        ward: 'Pediatrics',
        bedNumber: 'PED-01',
        status: BedStatus.occupied,
        patientName: 'Aarav Mehta (7M)',
        admissionDate: '15 Sep',
        attendingDoctor: 'Dr. Sneha Reddy',
      ),
      const HospitalBed(
        id: 'b-14',
        ward: 'Pediatrics',
        bedNumber: 'PED-02',
        status: BedStatus.available,
      ),
      const HospitalBed(
        id: 'b-15',
        ward: 'Pediatrics',
        bedNumber: 'PED-03',
        status: BedStatus.available,
      ),
      const HospitalBed(
        id: 'b-16',
        ward: 'Pediatrics',
        bedNumber: 'PED-04',
        status: BedStatus.reserved,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final doctors = ref.watch(doctorsListProvider);
    final appointments = ref.watch(appointmentsProvider);
    final patients = ref.watch(allPatientsProvider);
    final queue = ref.watch(liveQueueProvider);
    final repo = ref.read(repositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

    final activeDoctors = doctors.where((d) => d.isAvailableToday).length;
    final pendingTriageCount = appointments
        .where(
          (a) =>
              a.status == AppointmentStatus.confirmed ||
              a.status == AppointmentStatus.upcoming,
        )
        .length;

    final filteredBeds = _selectedWard == 'All'
        ? _beds
        : _beds.where((b) => b.ward == _selectedWard).toList();

    final occupiedCount = _beds
        .where((b) => b.status == BedStatus.occupied)
        .length;
    final availableCount = _beds
        .where((b) => b.status == BedStatus.available)
        .length;
    final sanitizingCount = _beds
        .where((b) => b.status == BedStatus.sanitizing)
        .length;
    final reservedCount = _beds
        .where((b) => b.status == BedStatus.reserved)
        .length;

    final isMobile = Responsive.isMobile(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 1320,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: isMobile ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital Command Center Header
              if (isMobile) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Hospital Command Center',
                        style: AarogyaTypography.headingLarge(primaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AarogyaColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
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
                          const SizedBox(width: 4),
                          Text(
                            '99.98% Live',
                            style: AarogyaTypography.caption(
                              AarogyaColors.success,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Real-time institutional capacity, live bed management, and clinical throughput',
                  style: AarogyaTypography.bodyMedium(secondaryText),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hospital Command Center',
                            style: AarogyaTypography.headingLarge(primaryText),
                          ),
                          Text(
                            'Real-time institutional capacity, live bed management, and clinical throughput',
                            style: AarogyaTypography.bodyMedium(secondaryText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
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
                          const SizedBox(width: 6),
                          Text(
                            'Operational • 99.98% Live',
                            style: AarogyaTypography.caption(
                              AarogyaColors.success,
                            ).copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: isMobile ? 12 : 14),

              // Executive Metric Stats
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 750;
                  return GridView.count(
                    padding: EdgeInsets.zero,
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isMobile ? 1.35 : (isWide ? 2.1 : 1.7),
                    children: [
                      StatCard(
                        title: 'Total Patients',
                        value: '${patients.length * 280}',
                        subtitle: '+48 this week',
                        icon: Icons.people_alt_rounded,
                        accentColor: AarogyaColors.primaryCyan,
                        trendPercent: 14.2,
                      ),
                      StatCard(
                        title: 'Active Specialists',
                        value: '$activeDoctors / ${doctors.length}',
                        subtitle: '84% OPD coverage',
                        icon: Icons.medical_services_rounded,
                        accentColor: AarogyaColors.success,
                      ),
                      StatCard(
                        title: "Today's Consults",
                        value: '${appointments.length * 4}',
                        subtitle: isMobile ? '12m avg' : 'Avg 12m duration',
                        icon: Icons.calendar_today_rounded,
                        accentColor: AarogyaColors.accentPurple,
                        trendPercent: 6.8,
                      ),
                      StatCard(
                        title: 'Bed Occupancy',
                        value:
                            '${((occupiedCount / _beds.length) * 100).toStringAsFixed(1)}%',
                        subtitle: '$occupiedCount / ${_beds.length} Occupied',
                        icon: Icons.hotel_rounded,
                        accentColor: AarogyaColors.warning,
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: isMobile ? 16 : 14),

              // Executive Section Navigator Bar
              _buildExecutiveSectionBar(
                isDark: isDark,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isMobile: isMobile,
                pendingTriageCount: pendingTriageCount,
                occupiedBedCount: occupiedCount,
                totalBeds: _beds.length,
              ),
              SizedBox(height: isMobile ? 14 : 16),

              if (_selectedAdminSection == 0) ...[
                // OPD Arrival & Vitals Triage Desk
                _buildOpdTriageDesk(
                  context: context,
                  appointments: appointments,
                  patients: patients,
                  doctors: doctors,
                  queue: queue,
                  repo: repo,
                  isDark: isDark,
                  primaryText: primaryText,
                  secondaryText: secondaryText,
                  isMobile: isMobile,
                ),
              ] else if (_selectedAdminSection == 1) ...[
                // Bed Management Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inpatient Bed Occupancy Grid',
                            style: AarogyaTypography.headingMedium(primaryText),
                          ),
                          Text(
                            'Real-time bed tracking across ICU, Emergency, and Speciality Wards',
                            style: AarogyaTypography.caption(secondaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Status counts strip
                    if (!Responsive.isMobile(context))
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildLegendItem(
                            'Available ($availableCount)',
                            AarogyaColors.success,
                            secondaryText,
                          ),
                          _buildLegendItem(
                            'Occupied ($occupiedCount)',
                            AarogyaColors.primaryCyan,
                            secondaryText,
                          ),
                          _buildLegendItem(
                            'Sanitizing ($sanitizingCount)',
                            AarogyaColors.warning,
                            secondaryText,
                          ),
                          _buildLegendItem(
                            'Reserved ($reservedCount)',
                            AarogyaColors.accentPurple,
                            secondaryText,
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Ward Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'ICU', 'Emergency', 'General', 'Pediatrics']
                        .map((ward) {
                          final isSelected = _selectedWard == ward;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                ward == 'All'
                                    ? 'All Wards (${_beds.length})'
                                    : '$ward Ward',
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedWard = ward),
                              selectedColor:
                                  (isDark
                                          ? AarogyaColors.primaryCyan
                                          : AarogyaColors.primaryBlue)
                                      .withValues(alpha: 0.15),
                              backgroundColor: Colors.transparent,
                              side: BorderSide(
                                color: isSelected
                                    ? (isDark
                                          ? AarogyaColors.primaryCyan
                                          : AarogyaColors.primaryBlue)
                                    : (isDark
                                          ? AarogyaColors.darkGlassBorderSubtle
                                          : AarogyaColors.lightGlassBorderSubtle),
                              ),
                              labelStyle:
                                  AarogyaTypography.caption(
                                    isSelected
                                        ? (isDark
                                              ? AarogyaColors.primaryCyan
                                              : AarogyaColors.primaryBlue)
                                        : secondaryText,
                                  ).copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Interactive Bed Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxis = constraints.maxWidth > 900
                        ? 4
                        : (constraints.maxWidth > 550 ? 3 : 2);
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBeds.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxis,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: isMobile ? 1.75 : 2.9,
                      ),
                      itemBuilder: (context, index) {
                        final bed = filteredBeds[index];
                        return _buildBedTile(
                          context,
                          bed,
                          isDark,
                          primaryText,
                          secondaryText,
                          isMobile,
                        );
                      },
                    );
                  },
                ),
              ] else ...[
                // Department Clinical KPIs
                Text(
                  'Clinical Department Throughput',
                  style: AarogyaTypography.headingMedium(primaryText),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    return GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 4 : 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: isMobile ? 1.35 : (isWide ? 2.3 : 1.5),
                      children: [
                        _buildDepartmentCard(
                          'Cardiology',
                          '92% Bed Occupancy',
                          '11m Avg Wait',
                          48,
                          Icons.favorite_rounded,
                          AarogyaColors.critical,
                          isDark,
                          primaryText,
                          secondaryText,
                        ),
                        _buildDepartmentCard(
                          'Neurology',
                          '84% Bed Occupancy',
                          '14m Avg Wait',
                          32,
                          Icons.psychology_rounded,
                          AarogyaColors.accentPurple,
                          isDark,
                          primaryText,
                          secondaryText,
                        ),
                        _buildDepartmentCard(
                          'Orthopedics',
                          '76% Bed Occupancy',
                          '9m Avg Wait',
                          29,
                          Icons.accessibility_new_rounded,
                          AarogyaColors.primaryCyan,
                          isDark,
                          primaryText,
                          secondaryText,
                        ),
                        _buildDepartmentCard(
                          'Emergency',
                          '94% Triage Surge',
                          '2m Avg Response',
                          64,
                          Icons.emergency_rounded,
                          AarogyaColors.warning,
                          isDark,
                          primaryText,
                          secondaryText,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: isMobile ? 20 : 16),

                // Staff Shift Tracker
                Text(
                  'Staff Shift & Specialists On-Duty',
                  style: AarogyaTypography.headingMedium(primaryText),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: AarogyaSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              isMobile
                                  ? 'Morning Shift (07:00 – 15:00)'
                                  : 'Current Roster: Morning Shift (07:00 – 15:00)',
                              style: AarogyaTypography.title(primaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AarogyaColors.success.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AarogyaColors.success.withValues(
                                  alpha: 0.28,
                                ),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AarogyaPulseBeacon(
                                  color: AarogyaColors.success,
                                  size: 4.5,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Shift Active',
                                  style:
                                      AarogyaTypography.caption(
                                        AarogyaColors.success,
                                      ).copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildShiftStaffRow(
                        'Dr. Ananya Sharma',
                        'Senior Cardiologist • Ward ICU Lead',
                        'On Duty (In Consultation)',
                        AarogyaBadgeVariant.cyan,
                        isDark,
                        primaryText,
                        secondaryText,
                      ),
                      const Divider(height: 16),
                      _buildShiftStaffRow(
                        'Dr. Vikram Patel',
                        'Neurology Specialist • Neuro ICU',
                        'On Duty (Rounds)',
                        AarogyaBadgeVariant.success,
                        isDark,
                        primaryText,
                        secondaryText,
                      ),
                      const Divider(height: 16),
                      _buildShiftStaffRow(
                        'Sister Sunita Rao',
                        'Head Nurse • Emergency Trauma',
                        'Active on Shift',
                        AarogyaBadgeVariant.success,
                        isDark,
                        primaryText,
                        secondaryText,
                      ),
                      const Divider(height: 16),
                      _buildShiftStaffRow(
                        'Manoj Kumar',
                        'Senior Bio-Medical Lab Tech',
                        'On Call (Diagnostic Lab)',
                        AarogyaBadgeVariant.warning,
                        isDark,
                        primaryText,
                        secondaryText,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 16),

                // Live Hospital Activity Feed
                Text(
                  'Live Institutional Events',
                  style: AarogyaTypography.headingMedium(primaryText),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  padding: AarogyaSpacing.paddingLg,
                  child: Column(
                    children: [
                      _buildActivityRow(
                        'Dr. Ananya Sharma concluded OPD Consultation for Token #08',
                        '2 mins ago',
                        Icons.check_circle_rounded,
                        AarogyaColors.success,
                        primaryText,
                        secondaryText,
                      ),
                      const Divider(height: 14),
                      _buildActivityRow(
                        'Central Biochemistry Lab published verified Lipid Panel #LAB-301',
                        '14 mins ago',
                        Icons.biotech_rounded,
                        AarogyaColors.primaryCyan,
                        primaryText,
                        secondaryText,
                      ),
                      const Divider(height: 14),
                      _buildActivityRow(
                        'New patient admission registered in Cardiology ICU Bed #02',
                        '38 mins ago',
                        Icons.local_hospital_rounded,
                        AarogyaColors.warning,
                        primaryText,
                        secondaryText,
                      ),
                      const Divider(height: 14),
                      _buildActivityRow(
                        'Emergency triage queue escalated Token #09 priority to Urgent',
                        '1 hour ago',
                        Icons.warning_rounded,
                        AarogyaColors.critical,
                        primaryText,
                        secondaryText,
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: isMobile ? 88 : 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveSectionBar({
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    required bool isMobile,
    required int pendingTriageCount,
    required int occupiedBedCount,
    required int totalBeds,
  }) {
    final sections = [
      (
        title: 'OPD & Triage Desk',
        icon: Icons.speed_rounded,
        badge: '$pendingTriageCount Awaiting',
        badgeColor: pendingTriageCount > 0
            ? AarogyaColors.warning
            : AarogyaColors.success,
      ),
      (
        title: 'Bed & Ward Census',
        icon: Icons.hotel_rounded,
        badge: '$occupiedBedCount/$totalBeds Occupied',
        badgeColor: AarogyaColors.primaryCyan,
      ),
      (
        title: 'Operations & Staff',
        icon: Icons.hub_rounded,
        badge: '4 Wards Active',
        badgeColor: AarogyaColors.accentPurple,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AarogyaColors.darkGlassBorderSubtle
              : AarogyaColors.lightGlassBorderSubtle,
        ),
      ),
      child: Row(
        children: List.generate(sections.length, (index) {
          final sec = sections[index];
          final isSelected = _selectedAdminSection == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
              child: InkWell(
                onTap: () => setState(() => _selectedAdminSection = index),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 8 : 10,
                    horizontal: isMobile ? 4 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFF1E2633)
                            : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.3 : 0.06,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isMobile
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  sec.icon,
                                  size: 14,
                                  color: isSelected
                                      ? AarogyaColors.primaryCyan
                                      : secondaryText,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    sec.title,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? primaryText
                                          : secondaryText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: sec.badgeColor.withValues(
                                  alpha: isSelected ? 0.2 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                sec.badge,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: sec.badgeColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              sec.icon,
                              size: 18,
                              color: isSelected
                                  ? AarogyaColors.primaryCyan
                                  : secondaryText,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sec.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected ? primaryText : secondaryText,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: sec.badgeColor
                                    .withValues(alpha: isSelected ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                sec.badge,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: sec.badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBedTile(
    BuildContext context,
    HospitalBed bed,
    bool isDark,
    Color primaryText,
    Color secondaryText, [
    bool isMobile = false,
  ]) {
    return InkWell(
      borderRadius: AarogyaRadius.radiusMd,
      onTap: () => _showBedManagementDialog(context, bed, isDark),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: isMobile ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161A20) : const Color(0xFFF9FAFB),
          borderRadius: AarogyaRadius.radiusMd,
          border: Border.all(
            color: bed.status.color.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.hotel_rounded,
                        size: 14,
                        color: bed.status.color,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          bed.bedNumber,
                          style: AarogyaTypography.bodyMedium(primaryText)
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: bed.status.color.withValues(alpha: 0.15),
                    borderRadius: AarogyaRadius.radiusPill,
                  ),
                  child: Text(
                    bed.status.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: bed.status.color,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bed.patientName ??
                      (bed.status == BedStatus.available
                          ? 'Ready for Admission'
                          : 'Sanitization in progress'),
                  style: AarogyaTypography.caption(secondaryText).copyWith(
                    fontWeight: bed.patientName != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile && bed.attendingDoctor != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    'Attending: ${bed.attendingDoctor}',
                    style: AarogyaTypography.caption(secondaryText)
                        .copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBedManagementDialog(
    BuildContext context,
    HospitalBed bed,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AarogyaRadius.radiusXl),
        title: Row(
          children: [
            Icon(Icons.hotel_rounded, color: bed.status.color, size: 22),
            const SizedBox(width: 8),
            Text('Bed ${bed.bedNumber} (${bed.ward} Ward)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status: ${bed.status.label}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: bed.status.color,
              ),
            ),
            const SizedBox(height: 8),
            if (bed.patientName != null) ...[
              Text(
                'Admitted Patient: ${bed.patientName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('Admission Date: ${bed.admissionDate ?? 'N/A'}'),
              Text('Attending Physician: ${bed.attendingDoctor ?? 'N/A'}'),
            ] else ...[
              const Text('This bed is currently unassigned.'),
            ],
            const SizedBox(height: 16),
            const Text(
              'Select Action:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          if (bed.status == BedStatus.occupied)
            TextButton(
              onPressed: () {
                _updateBedStatus(bed.id, BedStatus.sanitizing, null);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Discharged patient from ${bed.bedNumber}. Marked for sanitization.',
                    ),
                  ),
                );
              },
              child: const Text('Discharge & Sanitize'),
            ),
          if (bed.status == BedStatus.sanitizing)
            TextButton(
              onPressed: () {
                _updateBedStatus(bed.id, BedStatus.available, null);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${bed.bedNumber} sanitized and marked available.',
                    ),
                  ),
                );
              },
              child: const Text('Mark Ready'),
            ),
          if (bed.status == BedStatus.available)
            ElevatedButton(
              onPressed: () {
                _updateBedStatus(
                  bed.id,
                  BedStatus.occupied,
                  'Emergency Admission (Pending Reg)',
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Assigned patient to ${bed.bedNumber}.'),
                  ),
                );
              },
              child: const Text('Admit Patient'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _updateBedStatus(String id, BedStatus newStatus, String? patient) {
    setState(() {
      final index = _beds.indexWhere((b) => b.id == id);
      if (index != -1) {
        _beds[index] = _beds[index].copyWith(
          status: newStatus,
          patientName: patient,
        );
      }
    });
  }

  Widget _buildLegendItem(String label, Color color, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AarogyaTypography.caption(textColor)),
      ],
    );
  }

  Widget _buildDepartmentCard(
    String dept,
    String occupancy,
    String waitTime,
    int consultations,
    IconData icon,
    Color accent,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  dept,
                  style: AarogyaTypography.title(primaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 18, color: accent),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                occupancy,
                style: AarogyaTypography.caption(accent)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '$waitTime • $consultations Consults',
                style: AarogyaTypography.caption(secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftStaffRow(
    String name,
    String role,
    String status,
    AarogyaBadgeVariant badgeVariant,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E232B) : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_rounded, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AarogyaTypography.bodyMedium(primaryText)
                    .copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                role,
                style: AarogyaTypography.caption(secondaryText),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color:
                (badgeVariant == AarogyaBadgeVariant.success
                        ? AarogyaColors.success
                        : (badgeVariant == AarogyaBadgeVariant.warning
                              ? AarogyaColors.warning
                              : AarogyaColors.primaryCyan))
                    .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color:
                  (badgeVariant == AarogyaBadgeVariant.success
                          ? AarogyaColors.success
                          : (badgeVariant == AarogyaBadgeVariant.warning
                                ? AarogyaColors.warning
                                : AarogyaColors.primaryCyan))
                      .withValues(alpha: 0.28),
              width: 0.8,
            ),
          ),
          child: Text(
            status,
            style: AarogyaTypography.caption(
              badgeVariant == AarogyaBadgeVariant.success
                  ? AarogyaColors.success
                  : (badgeVariant == AarogyaBadgeVariant.warning
                        ? AarogyaColors.warning
                        : AarogyaColors.primaryCyan),
            ).copyWith(fontWeight: FontWeight.w700, fontSize: 9.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRow(
    String title,
    String time,
    IconData icon,
    Color iconColor,
    Color primaryText,
    Color secondaryText,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AarogyaTypography.bodyMedium(primaryText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(time, style: AarogyaTypography.caption(secondaryText)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // OPD Arrival & Vitals Triage Desk
  // ---------------------------------------------------------------------------

  Widget _buildOpdTriageDesk({
    required BuildContext context,
    required List<Appointment> appointments,
    required List<Patient> patients,
    required List<Doctor> doctors,
    required List<QueueEntry> queue,
    required dynamic repo,
    required bool isDark,
    required Color primaryText,
    required Color secondaryText,
    required bool isMobile,
  }) {
    final scheduledForTriage = appointments
        .where(
          (a) =>
              a.status == AppointmentStatus.confirmed ||
              a.status == AppointmentStatus.upcoming,
        )
        .toList();

    final checkedInQueue = queue
        .where(
          (q) =>
              q.status == QueueStatus.waiting ||
              q.status == QueueStatus.consulting,
        )
        .toList();

    return GlassCard(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AarogyaColors.primaryCyan.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: AarogyaColors.primaryCyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPD Arrival & Vitals Triage Desk',
                            style: AarogyaTypography.headingMedium(primaryText),
                          ),
                          Text(
                            'Counter intake • Vitals & NEWS2 triage',
                            style: AarogyaTypography.caption(secondaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: AarogyaButton(
                    label: 'Register Walk-In',
                    icon: Icons.person_add_alt_1_rounded,
                    size: AarogyaButtonSize.sm,
                    variant: AarogyaButtonVariant.secondary,
                    onPressed: () => _showWalkInRegistrationModal(
                      context,
                      doctors,
                      repo,
                      isDark,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AarogyaColors.primaryCyan.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.speed_rounded,
                        color: AarogyaColors.primaryCyan,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OPD Arrival & Vitals Triage Desk',
                          style: AarogyaTypography.headingMedium(primaryText),
                        ),
                        Text(
                          'Counter intake • Physiological vitals recording • Automated NEWS2 triage',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ],
                    ),
                  ],
                ),
                AarogyaButton(
                  label: 'Register Walk-In',
                  icon: Icons.person_add_alt_1_rounded,
                  size: AarogyaButtonSize.sm,
                  variant: AarogyaButtonVariant.secondary,
                  onPressed: () => _showWalkInRegistrationModal(
                    context,
                    doctors,
                    repo,
                    isDark,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          // Triage Navigation Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('Awaiting Counter Triage (${scheduledForTriage.length})'),
                  selected: _triageTab == 0,
                  onSelected: (_) => setState(() => _triageTab = 0),
                  selectedColor: AarogyaColors.primaryCyan.withValues(alpha: 0.16),
                  backgroundColor: Colors.transparent,
                  labelStyle: AarogyaTypography.caption(
                    _triageTab == 0 ? AarogyaColors.primaryCyan : secondaryText,
                  ).copyWith(
                    fontWeight: _triageTab == 0 ? FontWeight.w700 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _triageTab == 0
                          ? AarogyaColors.primaryCyan
                          : (isDark
                              ? AarogyaColors.darkGlassBorderSubtle
                              : AarogyaColors.lightGlassBorderSubtle),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Checked-In Live Queue (${checkedInQueue.length})'),
                  selected: _triageTab == 1,
                  onSelected: (_) => setState(() => _triageTab = 1),
                  selectedColor: AarogyaColors.primaryCyan.withValues(alpha: 0.16),
                  backgroundColor: Colors.transparent,
                  labelStyle: AarogyaTypography.caption(
                    _triageTab == 1 ? AarogyaColors.primaryCyan : secondaryText,
                  ).copyWith(
                    fontWeight: _triageTab == 1 ? FontWeight.w700 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _triageTab == 1
                          ? AarogyaColors.primaryCyan
                          : (isDark
                              ? AarogyaColors.darkGlassBorderSubtle
                              : AarogyaColors.lightGlassBorderSubtle),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Content body
          if (_triageTab == 0) ...[
            if (scheduledForTriage.isEmpty)
              const AarogyaEmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'All Scheduled Patients Triaged',
                description:
                    'No arriving appointments awaiting check-in. New bookings or walk-ins can be triaged using "Register Walk-In".',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scheduledForTriage.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final apt = scheduledForTriage[index];
                  final matchingPatient = patients.cast<Patient?>().firstWhere(
                        (p) => p?.id == apt.patientId,
                        orElse: () => null,
                      );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.03),
                      borderRadius: AarogyaRadius.radiusMd,
                      border: Border.all(
                        color: isDark
                            ? AarogyaColors.darkGlassBorderSubtle
                            : AarogyaColors.lightGlassBorderSubtle,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AarogyaAvatar(
                          name: apt.patientName,
                          size: 40,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    apt.patientName,
                                    style: AarogyaTypography.title(primaryText)
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AarogyaColors.warning
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Awaiting Triage',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AarogyaColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Dr. ${apt.doctorName} (${apt.specialty}) • Slot: ${apt.timeSlot}',
                                style: AarogyaTypography.caption(secondaryText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (apt.symptoms != null && apt.symptoms!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Complaint: ${apt.symptoms}',
                                  style: AarogyaTypography.caption(secondaryText)
                                      .copyWith(fontStyle: FontStyle.italic),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AarogyaButton(
                          label: isMobile ? 'Triage' : 'Triage & Check-In',
                          icon: Icons.speed_rounded,
                          size: AarogyaButtonSize.sm,
                          onPressed: () => _showTriageCheckInModal(
                            context,
                            apt,
                            matchingPatient,
                            repo,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ] else ...[
            if (checkedInQueue.isEmpty)
              const AarogyaEmptyState(
                icon: Icons.hourglass_empty_rounded,
                title: 'No Patients in Queue',
                description:
                    'The live OPD queue is currently clear. Checked-in patients will appear here with measured vitals and NEWS2 acuity.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: checkedInQueue.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = checkedInQueue[index];
                  final isEmergency = entry.priority == PatientPriority.emergency;
                  final isUrgent = entry.priority == PatientPriority.urgent;
                  final isConsulting = entry.status == QueueStatus.consulting;

                  Color priorityColor = AarogyaColors.success;
                  if (isEmergency) {
                    priorityColor = AarogyaColors.critical;
                  } else if (isUrgent) {
                    priorityColor = AarogyaColors.warning;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.03),
                      borderRadius: AarogyaRadius.radiusMd,
                      border: Border.all(
                        color: (isEmergency || isUrgent)
                            ? priorityColor.withValues(alpha: 0.4)
                            : (isDark
                                ? AarogyaColors.darkGlassBorderSubtle
                                : AarogyaColors.lightGlassBorderSubtle),
                        width: (isEmergency || isUrgent) ? 1.2 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: (isConsulting
                                        ? AarogyaColors.primaryCyan
                                        : AarogyaColors.accentPurple)
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Token #${entry.tokenNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: isConsulting
                                      ? AarogyaColors.primaryCyan
                                      : AarogyaColors.accentPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${entry.patientName} (${entry.age}${entry.gender.isNotEmpty ? entry.gender[0] : ""})',
                                style: AarogyaTypography.title(primaryText)
                                    .copyWith(fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (entry.ewsScore != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: priorityColor.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: priorityColor.withValues(alpha: 0.35),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  'NEWS2: ${entry.ewsScore}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    color: priorityColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (isConsulting
                                        ? AarogyaColors.primaryCyan
                                        : AarogyaColors.success)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isConsulting ? 'In Chamber' : 'Waiting',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  color: isConsulting
                                      ? AarogyaColors.primaryCyan
                                      : AarogyaColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (entry.vitals != null) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                'BP: ${entry.vitals!.bloodPressure} mmHg',
                                style: AarogyaTypography.caption(secondaryText),
                              ),
                              Text('•', style: AarogyaTypography.caption(secondaryText)),
                              Text(
                                'HR: ${entry.vitals!.heartRate} bpm',
                                style: AarogyaTypography.caption(secondaryText),
                              ),
                              Text('•', style: AarogyaTypography.caption(secondaryText)),
                              Text(
                                'SpO2: ${entry.vitals!.spo2.toInt()}%',
                                style: AarogyaTypography.caption(secondaryText),
                              ),
                              Text('•', style: AarogyaTypography.caption(secondaryText)),
                              Text(
                                'Temp: ${entry.vitals!.temperature}°F',
                                style: AarogyaTypography.caption(secondaryText),
                              ),
                              if (entry.vitals!.respiratoryRate != null) ...[
                                Text('•', style: AarogyaTypography.caption(secondaryText)),
                                Text(
                                  'RR: ${entry.vitals!.respiratoryRate} bpm',
                                  style: AarogyaTypography.caption(secondaryText),
                                ),
                              ],
                            ],
                          ),
                        ],
                        if (entry.chiefComplaint.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Chief Complaint: ${entry.chiefComplaint}',
                            style: AarogyaTypography.caption(secondaryText)
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  void _showTriageCheckInModal(
    BuildContext context,
    Appointment apt,
    Patient? patient,
    dynamic repo,
    bool isDark,
  ) {
    final sysCtrl = TextEditingController(
      text: patient?.vitals.bloodPressure.split('/').first ?? '120',
    );
    final diaCtrl = TextEditingController(
      text: patient?.vitals.bloodPressure.split('/').last ?? '80',
    );
    final hrCtrl = TextEditingController(
      text: '${patient?.vitals.heartRate ?? 76}',
    );
    final spo2Ctrl = TextEditingController(
      text: '${patient?.vitals.spo2.toInt() ?? 98}',
    );
    final tempCtrl = TextEditingController(
      text: '${patient?.vitals.temperature ?? 98.6}',
    );
    final rrCtrl = TextEditingController(
      text: '${patient?.vitals.respiratoryRate ?? 16}',
    );
    final complaintCtrl = TextEditingController(
      text: apt.symptoms ?? 'Routine OPD consultation',
    );

    String? sysError;
    String? diaError;
    String? hrError;
    String? spo2Error;
    String? tempError;
    String? rrError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sysVal = int.tryParse(sysCtrl.text.trim()) ?? 120;
            final diaVal = int.tryParse(diaCtrl.text.trim()) ?? 80;
            final hrVal = int.tryParse(hrCtrl.text.trim()) ?? 76;
            final spo2Val = double.tryParse(spo2Ctrl.text.trim()) ?? 98.0;
            final tempVal = double.tryParse(tempCtrl.text.trim()) ?? 98.6;
            final rrVal = int.tryParse(rrCtrl.text.trim()) ?? 16;

            final currentVitals = PatientVitals(
              bloodPressure: '$sysVal/$diaVal',
              heartRate: hrVal,
              spo2: spo2Val,
              temperature: tempVal,
              respiratoryRate: rrVal,
              weight: patient?.vitals.weight ?? 68.0,
              recordedAt: DateTime.now(),
            );

            final ews = EwsTriageCalculator.calculate(currentVitals);

            Color acuityColor = AarogyaColors.success;
            if (ews.priority == PatientPriority.emergency) {
              acuityColor = AarogyaColors.critical;
            } else if (ews.priority == PatientPriority.urgent) {
              acuityColor = AarogyaColors.warning;
            }

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? AarogyaColors.darkSurface : AarogyaColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark ? AarogyaColors.darkGlassBorder : AarogyaColors.lightGlassBorder,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AarogyaColors.primaryCyan.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.speed_rounded,
                            color: AarogyaColors.primaryCyan,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OPD Triage Check-In',
                                style: AarogyaTypography.headingMedium(
                                  isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                '${apt.patientName} • Dr. ${apt.doctorName} (${apt.specialty})',
                                style: AarogyaTypography.caption(
                                  isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Live NEWS2 Acuity Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: acuityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: acuityColor.withValues(alpha: 0.35), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            ews.priority == PatientPriority.emergency
                                ? Icons.warning_amber_rounded
                                : (ews.priority == PatientPriority.urgent
                                    ? Icons.bolt_rounded
                                    : Icons.verified_user_rounded),
                            color: acuityColor,
                            size: 26,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'NEWS2 Score: ${ews.totalScore} / 20',
                                      style: AarogyaTypography.title(acuityColor).copyWith(fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: acuityColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ews.priority.displayName.toUpperCase(),
                                        style: TextStyle(
                                          color: acuityColor,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ews.priority == PatientPriority.emergency
                                      ? '🚨 Critical Acuity: High risk. Patient will automatically sort to the top of the doctor queue.'
                                      : (ews.priority == PatientPriority.urgent
                                          ? '⚡ Moderate Acuity: Urgent triage category. Prioritized ahead of routine waiting cases.'
                                          : '✅ Stable Baseline: Low clinical risk. Standard queue position.'),
                                  style: AarogyaTypography.caption(
                                    isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Vitals Inputs Grid
                    Text(
                      'Physiological Vital Signs (Counter Intake)',
                      style: AarogyaTypography.label(
                        isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Systolic BP (mmHg)',
                            controller: sysCtrl,
                            keyboardType: TextInputType.number,
                            errorText: sysError,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Diastolic BP (mmHg)',
                            controller: diaCtrl,
                            keyboardType: TextInputType.number,
                            errorText: diaError,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Heart Rate (bpm)',
                            controller: hrCtrl,
                            keyboardType: TextInputType.number,
                            errorText: hrError,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Oxygen SpO2 (%)',
                            controller: spo2Ctrl,
                            keyboardType: TextInputType.number,
                            errorText: spo2Error,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Body Temp (°F)',
                            controller: tempCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            errorText: tempError,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Respiratory Rate (bpm)',
                            controller: rrCtrl,
                            keyboardType: TextInputType.number,
                            errorText: rrError,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AarogyaTextField(
                      label: 'Presenting Complaint / Triage Observations',
                      controller: complaintCtrl,
                      hintText: 'e.g. Mild chest discomfort, high fever, severe headache...',
                    ),
                    const SizedBox(height: 18),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: AarogyaButton(
                            label: 'Cancel',
                            variant: AarogyaButtonVariant.secondary,
                            onPressed: () => Navigator.pop(sheetCtx),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: AarogyaButton(
                            label: 'Confirm & Issue Token',
                            icon: Icons.check_circle_rounded,
                            onPressed: () {
                              bool valid = true;
                              final sVal = int.tryParse(sysCtrl.text.trim());
                              final dVal = int.tryParse(diaCtrl.text.trim());
                              final hVal = int.tryParse(hrCtrl.text.trim());
                              final spVal = double.tryParse(spo2Ctrl.text.trim());
                              final tVal = double.tryParse(tempCtrl.text.trim());
                              final rVal = int.tryParse(rrCtrl.text.trim());

                              if (sVal == null || sVal < 50 || sVal > 260) {
                                sysError = '50 - 260';
                                valid = false;
                              } else {
                                sysError = null;
                              }

                              if (dVal == null || dVal < 30 || dVal > 160) {
                                diaError = '30 - 160';
                                valid = false;
                              } else {
                                diaError = null;
                              }

                              if (hVal == null || hVal < 30 || hVal > 240) {
                                hrError = '30 - 240';
                                valid = false;
                              } else {
                                hrError = null;
                              }

                              if (spVal == null || spVal < 50 || spVal > 100) {
                                spo2Error = '50 - 100%';
                                valid = false;
                              } else {
                                spo2Error = null;
                              }

                              if (tVal == null || tVal < 92.0 || tVal > 108.0) {
                                tempError = '92 - 108°F';
                                valid = false;
                              } else {
                                tempError = null;
                              }

                              if (rVal == null || rVal < 4 || rVal > 60) {
                                rrError = '4 - 60';
                                valid = false;
                              } else {
                                rrError = null;
                              }

                              setModalState(() {});

                              if (!valid) return;

                              final validatedVitals = PatientVitals(
                                bloodPressure: '$sVal/$dVal',
                                heartRate: hVal!,
                                spo2: spVal!,
                                temperature: tVal!,
                                respiratoryRate: rVal!,
                                weight: patient?.vitals.weight ?? 68.0,
                                recordedAt: DateTime.now(),
                              );

                              final entry = repo.checkInAppointment(
                                appointmentId: apt.id,
                                vitals: validatedVitals,
                                patientName: apt.patientName,
                                age: patient?.age ?? 35,
                                gender: patient?.gender ?? 'Male',
                                chiefComplaint: complaintCtrl.text.trim().isNotEmpty
                                    ? complaintCtrl.text.trim()
                                    : (apt.symptoms ?? 'OPD Consultation'),
                              );

                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Token #${entry.tokenNumber} issued for ${entry.patientName} (${entry.priority.displayName} Priority • NEWS2: ${entry.ewsScore ?? 0})',
                                  ),
                                  backgroundColor: acuityColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWalkInRegistrationModal(
    BuildContext context,
    List<Doctor> doctors,
    dynamic repo,
    bool isDark,
  ) {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController(text: '32');
    String selectedGender = 'Male';
    Doctor? selectedDoctor = doctors.isNotEmpty ? doctors.first : null;
    final sysCtrl = TextEditingController(text: '120');
    final diaCtrl = TextEditingController(text: '80');
    final hrCtrl = TextEditingController(text: '74');
    final spo2Ctrl = TextEditingController(text: '98');
    final tempCtrl = TextEditingController(text: '98.6');
    final rrCtrl = TextEditingController(text: '16');
    final complaintCtrl = TextEditingController();

    String? nameError;
    String? ageError;
    String? complaintError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sysVal = int.tryParse(sysCtrl.text.trim()) ?? 120;
            final diaVal = int.tryParse(diaCtrl.text.trim()) ?? 80;
            final hrVal = int.tryParse(hrCtrl.text.trim()) ?? 74;
            final spo2Val = double.tryParse(spo2Ctrl.text.trim()) ?? 98.0;
            final tempVal = double.tryParse(tempCtrl.text.trim()) ?? 98.6;
            final rrVal = int.tryParse(rrCtrl.text.trim()) ?? 16;

            final currentVitals = PatientVitals(
              bloodPressure: '$sysVal/$diaVal',
              heartRate: hrVal,
              spo2: spo2Val,
              temperature: tempVal,
              respiratoryRate: rrVal,
              weight: 65.0,
              recordedAt: DateTime.now(),
            );

            final ews = EwsTriageCalculator.calculate(currentVitals);
            Color acuityColor = AarogyaColors.success;
            if (ews.priority == PatientPriority.emergency) {
              acuityColor = AarogyaColors.critical;
            } else if (ews.priority == PatientPriority.urgent) {
              acuityColor = AarogyaColors.warning;
            }

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? AarogyaColors.darkSurface : AarogyaColors.lightSurface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark ? AarogyaColors.darkGlassBorder : AarogyaColors.lightGlassBorder,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AarogyaColors.accentPurple.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: AarogyaColors.accentPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Register Walk-In Patient',
                                style: AarogyaTypography.headingMedium(
                                  isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                'Ad-hoc OPD registration, vitals triage & instant token assignment',
                                style: AarogyaTypography.caption(
                                  isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // NEWS2 preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: acuityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: acuityColor.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            ews.priority == PatientPriority.emergency
                                ? Icons.warning_amber_rounded
                                : (ews.priority == PatientPriority.urgent
                                    ? Icons.bolt_rounded
                                    : Icons.verified_user_rounded),
                            color: acuityColor,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Calculated NEWS2: ${ews.totalScore} • Priority: ${ews.priority.displayName}',
                              style: AarogyaTypography.title(acuityColor).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Patient Details
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AarogyaTextField(
                            label: 'Patient Full Name',
                            controller: nameCtrl,
                            hintText: 'e.g. Amit Verma',
                            errorText: nameError,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Age',
                            controller: ageCtrl,
                            keyboardType: TextInputType.number,
                            errorText: ageError,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gender', style: AarogyaTypography.caption(isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedGender,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setModalState(() => selectedGender = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Attending Doctor', style: AarogyaTypography.caption(isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<Doctor>(
                                initialValue: selectedDoctor,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                isExpanded: true,
                                items: doctors
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(
                                          '${d.name} (${d.specialty})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (doc) {
                                  if (doc != null) setModalState(() => selectedDoctor = doc);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AarogyaTextField(
                      label: 'Chief Complaint',
                      controller: complaintCtrl,
                      hintText: 'e.g. Acute abdominal pain, fever for 3 days...',
                      errorText: complaintError,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Triage Vitals',
                      style: AarogyaTypography.label(
                        isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: AarogyaTextField(
                            label: 'BP (Sys/Dia)',
                            controller: sysCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Heart Rate',
                            controller: hrCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AarogyaTextField(
                            label: 'SpO2 (%)',
                            controller: spo2Ctrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Body Temp (°F)',
                            controller: tempCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AarogyaTextField(
                            label: 'Respiration Rate',
                            controller: rrCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AarogyaButton(
                            label: 'Cancel',
                            variant: AarogyaButtonVariant.secondary,
                            onPressed: () => Navigator.pop(sheetCtx),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: AarogyaButton(
                            label: 'Issue Walk-In Token',
                            icon: Icons.check_circle_rounded,
                            onPressed: () {
                              final name = nameCtrl.text.trim();
                              final age = int.tryParse(ageCtrl.text.trim());
                              final comp = complaintCtrl.text.trim();

                              bool valid = true;
                              if (name.isEmpty) {
                                nameError = 'Enter patient name';
                                valid = false;
                              } else {
                                nameError = null;
                              }
                              if (age == null || age < 1 || age > 130) {
                                ageError = 'Valid age';
                                valid = false;
                              } else {
                                ageError = null;
                              }
                              if (comp.isEmpty) {
                                complaintError = 'Enter chief complaint';
                                valid = false;
                              } else {
                                complaintError = null;
                              }

                              setModalState(() {});
                              if (!valid) return;

                              final entry = repo.addPatientToQueue(
                                patientName: name,
                                age: age!,
                                gender: selectedGender,
                                chiefComplaint: comp,
                                vitals: currentVitals,
                                doctorId: selectedDoctor?.id,
                              );

                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Walk-In Token #${entry.tokenNumber} issued for $name (${entry.priority.displayName} Priority • NEWS2: ${entry.ewsScore ?? 0})',
                                  ),
                                  backgroundColor: acuityColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
