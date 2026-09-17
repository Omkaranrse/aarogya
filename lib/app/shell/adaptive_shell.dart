import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/glass/glass_container.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/spacing.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_avatar.dart';
import '../../core/design_system/components/aarogya_badge.dart';
import '../../core/design_system/components/offline_status_banner.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/user_role.dart';
import '../../shared/state/aarogya_providers.dart';
import '../../features/notifications/notifications_panel.dart';

// Screens
import '../../features/patient/dashboard/patient_dashboard.dart';
import '../../features/patient/discovery/doctor_discovery_screen.dart';
import '../../features/patient/appointments/patient_appointments_screen.dart';
import '../../features/clinical/prescriptions_hub_screen.dart';
import '../../features/clinical/laboratory_hub_screen.dart';
import '../../features/clinical/medical_records_screen.dart';
import '../../features/billing/billing_screen.dart';

import '../../features/doctor/dashboard/doctor_dashboard.dart';
import '../../features/doctor/queue/patient_queue_screen.dart';
import '../../features/doctor/consultation/clinical_workspace_screen.dart';

import '../../features/admin/admin_dashboard.dart';
import '../../features/admin/analytics/admin_analytics_screen.dart';
import '../../features/admin/management/doctor_management_screen.dart';
import '../../features/admin/management/patient_management_screen.dart';
import '../../features/admin/management/department_management_screen.dart';

final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

class NavItemData {
  final String label;
  final String? shortLabel;
  final IconData icon;
  final Widget screen;

  const NavItemData({
    required this.label,
    this.shortLabel,
    required this.icon,
    required this.screen,
  });
}

class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({super.key});

  List<NavItemData> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return const [
          NavItemData(
            label: 'Overview',
            shortLabel: 'Overview',
            icon: Icons.dashboard_rounded,
            screen: PatientDashboard(),
          ),
          NavItemData(
            label: 'Find Doctors',
            shortLabel: 'Doctors',
            icon: Icons.person_search_rounded,
            screen: DoctorDiscoveryScreen(),
          ),
          NavItemData(
            label: 'Appointments',
            shortLabel: 'Consults',
            icon: Icons.calendar_month_rounded,
            screen: PatientAppointmentsScreen(),
          ),
          NavItemData(
            label: 'Prescriptions',
            shortLabel: 'Rx Hub',
            icon: Icons.medication_rounded,
            screen: PrescriptionsHubScreen(),
          ),
          NavItemData(
            label: 'Lab Reports',
            shortLabel: 'Labs',
            icon: Icons.biotech_rounded,
            screen: LaboratoryHubScreen(),
          ),
          NavItemData(
            label: 'Timeline',
            shortLabel: 'EHR',
            icon: Icons.history_edu_rounded,
            screen: MedicalRecordsScreen(),
          ),
          NavItemData(
            label: 'Billing',
            shortLabel: 'Billing',
            icon: Icons.receipt_long_rounded,
            screen: BillingScreen(),
          ),
        ];

      case UserRole.doctor:
        return const [
          NavItemData(
            label: 'Doctor Dashboard',
            shortLabel: 'Overview',
            icon: Icons.dashboard_customize_rounded,
            screen: DoctorDashboard(),
          ),
          NavItemData(
            label: 'Live Queue',
            shortLabel: 'OPD Queue',
            icon: Icons.groups_rounded,
            screen: PatientQueueScreen(),
          ),
          NavItemData(
            label: 'Consultation',
            shortLabel: 'Consult',
            icon: Icons.medical_services_rounded,
            screen: ClinicalWorkspaceScreen(),
          ),
          NavItemData(
            label: 'Prescriptions',
            shortLabel: 'Rx Hub',
            icon: Icons.medication_rounded,
            screen: PrescriptionsHubScreen(),
          ),
          NavItemData(
            label: 'Lab Tests',
            shortLabel: 'Labs',
            icon: Icons.biotech_rounded,
            screen: LaboratoryHubScreen(),
          ),
        ];

      case UserRole.admin:
        return const [
          NavItemData(
            label: 'Command Center',
            shortLabel: 'Command',
            icon: Icons.space_dashboard_rounded,
            screen: AdminDashboard(),
          ),
          NavItemData(
            label: 'Analytics',
            shortLabel: 'Analytics',
            icon: Icons.insights_rounded,
            screen: AdminAnalyticsScreen(),
          ),
          NavItemData(
            label: 'Doctors & Staff',
            shortLabel: 'Staff',
            icon: Icons.badge_rounded,
            screen: DoctorManagementScreen(),
          ),
          NavItemData(
            label: 'Patients Master',
            shortLabel: 'Patients',
            icon: Icons.people_alt_rounded,
            screen: PatientManagementScreen(),
          ),
          NavItemData(
            label: 'Departments',
            shortLabel: 'Units',
            icon: Icons.domain_rounded,
            screen: DepartmentManagementScreen(),
          ),
          NavItemData(
            label: 'Invoices & Billing',
            shortLabel: 'Billing',
            icon: Icons.account_balance_wallet_rounded,
            screen: BillingScreen(),
          ),
        ];

      default:
        return const [
          NavItemData(
            label: 'Overview',
            icon: Icons.dashboard_rounded,
            screen: PatientDashboard(),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(activeRoleProvider);
    final user = ref.watch(currentUserProvider);
    final navItems = _getNavItems(role);
    final currentIndex = ref.watch(selectedTabIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final safeIndex = currentIndex < navItems.length ? currentIndex : 0;
    final currentScreen = navItems[safeIndex].screen;
    final isLocked = ref.watch(isStationLockedProvider);

    return Scaffold(
      backgroundColor: isDark ? AarogyaColors.darkBg : AarogyaColors.lightBg,
      body: Stack(
        children: [
          // Futuristic Background Glow Orbs
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                    .withValues(alpha: isDark ? 0.09 : 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              width: 440,
              height: 440,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AarogyaColors.accentPurple : AarogyaColors.primaryTeal)
                    .withValues(alpha: isDark ? 0.07 : 0.04),
              ),
            ),
          ),

          // Main Layout
          Column(
            children: [
              // Top Header
              _buildTopHeader(context, ref, user, role, isDark),

              // Non-blocking Connectivity / Cache Banner
              const OfflineStatusBanner(),

              // Body Content + Sidebar or BottomNav
              Expanded(
                child: Responsive(
                  mobile: Column(
                    children: [
                      Expanded(child: currentScreen),
                      _buildMobileBottomNav(context, ref, navItems, safeIndex, isDark),
                    ],
                  ),
                  tablet: Row(
                    children: [
                      _buildSidebar(context, ref, navItems, safeIndex, isDark, isCollapsed: true),
                      Expanded(child: currentScreen),
                    ],
                  ),
                  desktop: Row(
                    children: [
                      _buildSidebar(context, ref, navItems, safeIndex, isDark, isCollapsed: false),
                      Expanded(child: currentScreen),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Clinical Duty Rounds Biometric Lock Screen Overlay
          if (isLocked)
            Positioned.fill(
              child: _buildStationLockOverlay(context, ref, user, role, isDark),
            ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    UserRole role,
    bool isDark,
  ) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isMobile = Responsive.isMobile(context);

    return Container(
      color: isDark
          ? AarogyaColors.darkGlassBg.withValues(alpha: 0.88)
          : AarogyaColors.lightGlassBg.withValues(alpha: 0.92),
      child: SafeArea(
        bottom: false,
        child: GlassContainer(
          height: isMobile ? 58 : 70,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? AarogyaSpacing.sm : AarogyaSpacing.lg),
          borderRadius: BorderRadius.zero,
          blur: 20,
          backgroundColor: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
            ),
          ),
          child: Row(
            children: [
              // Logo & Branding
              Container(
                width: isMobile ? 32 : 38,
                height: isMobile ? 32 : 38,
                decoration: BoxDecoration(
                  gradient: AarogyaColors.primaryGradient,
                  borderRadius: AarogyaRadius.radiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: AarogyaColors.primaryCyan.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: isMobile ? 18 : 22,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AAROGYA',
                        style: (isMobile
                                ? AarogyaTypography.title(
                                    isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary,
                                  )
                                : AarogyaTypography.headingMedium(
                                    isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary,
                                  ))
                            .copyWith(
                          letterSpacing: isMobile ? 1.0 : 2.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AarogyaColors.primaryCyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile)
                    Text(
                      'CLINICAL INTELLIGENCE OS',
                      style: AarogyaTypography.caption(
                        isDark ? AarogyaColors.textDarkMuted : AarogyaColors.textLightMuted,
                      ).copyWith(
                        fontSize: 9.5,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              const Spacer(),

              // Role Switcher Dropdown — DEV ONLY (hidden in release builds)
              if (kDebugMode) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0x331E293B) : const Color(0x1F0284C7),
                    borderRadius: AarogyaRadius.radiusPill,
                    border: Border.all(
                      color: AarogyaColors.primaryCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole>(
                      value: role,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AarogyaColors.primaryCyan),
                      dropdownColor: isDark ? AarogyaColors.darkSurface : AarogyaColors.lightSurface,
                      borderRadius: AarogyaRadius.radiusMd,
                      items: UserRole.values.take(3).map((r) {
                        return DropdownMenuItem<UserRole>(
                          value: r,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                r == UserRole.patient
                                    ? Icons.person_rounded
                                    : r == UserRole.doctor
                                        ? Icons.medical_services_rounded
                                        : Icons.admin_panel_settings_rounded,
                                size: 14,
                                color: AarogyaColors.primaryCyan,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isMobile
                                    ? (r == UserRole.patient ? 'Patient' : (r == UserRole.doctor ? 'Doctor' : 'Admin'))
                                    : r.displayName,
                                style: AarogyaTypography.caption(
                                  isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newRole) {
                        if (newRole != null) {
                          ref.read(repositoryProvider).switchRole(newRole);
                          ref.read(selectedTabIndexProvider.notifier).state = 0;
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 4 : AarogyaSpacing.md),
              ],

              // Theme Toggle Button
              IconButton(
                visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                padding: EdgeInsets.zero,
                constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                tooltip: 'Toggle Theme',
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: isMobile ? 18 : 20,
                  color: isDark ? Colors.amber : AarogyaColors.accentIndigo,
                ),
                onPressed: () {
                  ref.read(themeModeProvider.notifier).state =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),

              // Notifications Drawer Trigger
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                    padding: EdgeInsets.zero,
                    constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                    tooltip: 'Notifications',
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      size: isMobile ? 20 : 22,
                      color: isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const NotificationsPanel(),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: isMobile ? 2 : 8,
                      top: isMobile ? 2 : 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AarogyaColors.critical,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              // Clinical Duty Rounds Station Lock (Doctors & Admins)
              if (role == UserRole.doctor || role == UserRole.admin) ...[
                IconButton(
                  visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                  padding: EdgeInsets.zero,
                  constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                  tooltip: 'Lock Station for Clinical Rounds',
                  icon: Icon(
                    Icons.lock_outline_rounded,
                    size: isMobile ? 18 : 20,
                    color: isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary,
                  ),
                  onPressed: () {
                    ref.read(biometricAuthServiceProvider).lockStation();
                  },
                ),
              ],

              // Sign Out / Switch Account Action
              IconButton(
                visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                padding: EdgeInsets.zero,
                constraints: isMobile ? const BoxConstraints(minWidth: 32, minHeight: 32) : null,
                tooltip: 'Sign Out',
                icon: Icon(
                  Icons.logout_rounded,
                  size: isMobile ? 18 : 20,
                  color: isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary,
                ),
                onPressed: () async {
                  await ref.read(authServiceProvider).signOut();
                },
              ),

              // User Profile Pill (Desktop only)
              if (Responsive.isDesktop(context)) ...[
                const SizedBox(width: AarogyaSpacing.sm),
                AarogyaAvatar(
                  name: user.name,
                  imageUrl: user.avatarUrl,
                  size: 38,
                  isOnline: true,
                ),
                const SizedBox(width: AarogyaSpacing.sm),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AarogyaTypography.label(
                        isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary,
                      ),
                    ),
                    Text(
                      role.displayName,
                      style: AarogyaTypography.caption(AarogyaColors.primaryCyan),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    List<NavItemData> items,
    int activeIndex,
    bool isDark, {
    required bool isCollapsed,
  }) {
    final width = isCollapsed ? 76.0 : 240.0;

    return GlassContainer(
      width: width,
      borderRadius: BorderRadius.zero,
      padding: const EdgeInsets.symmetric(vertical: AarogyaSpacing.lg, horizontal: AarogyaSpacing.sm),
      backgroundColor: isDark
          ? AarogyaColors.darkGlassBg.withValues(alpha: 0.6)
          : AarogyaColors.lightGlassBg.withValues(alpha: 0.7),
      border: Border(
        right: BorderSide(
          color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = activeIndex == index;

                return InkWell(
                  onTap: () {
                    ref.read(selectedTabIndexProvider.notifier).state = index;
                  },
                  borderRadius: AarogyaRadius.radiusMd,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.symmetric(
                      horizontal: isCollapsed ? 0 : AarogyaSpacing.md,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? AarogyaColors.primaryCyan.withValues(alpha: 0.15)
                              : AarogyaColors.primaryBlue.withValues(alpha: 0.12))
                          : Colors.transparent,
                      borderRadius: AarogyaRadius.radiusMd,
                      border: isSelected
                          ? Border.all(
                              color: isDark
                                  ? AarogyaColors.primaryCyan.withValues(alpha: 0.4)
                                  : AarogyaColors.primaryBlue.withValues(alpha: 0.3),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: isSelected
                              ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                              : (isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary),
                        ),
                        if (!isCollapsed) ...[
                          const SizedBox(width: AarogyaSpacing.md),
                          Expanded(
                            child: Text(
                              item.label,
                              style: AarogyaTypography.bodyMedium(
                                isSelected
                                    ? (isDark ? Colors.white : AarogyaColors.textLightPrimary)
                                    : (isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary),
                              ).copyWith(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AarogyaColors.primaryCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Clinical System Status Indicator
          if (!isCollapsed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0x331E293B) : const Color(0x1F0284C7),
                borderRadius: AarogyaRadius.radiusMd,
                border: Border.all(
                  color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AarogyaBadge(
                    label: 'Sync Live',
                    variant: AarogyaBadgeVariant.success,
                    showDot: true,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'v2.6 Cloud',
                      style: AarogyaTypography.caption(
                        isDark ? AarogyaColors.textDarkMuted : AarogyaColors.textLightMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav(
    BuildContext context,
    WidgetRef ref,
    List<NavItemData> items,
    int activeIndex,
    bool isDark,
  ) {
    final displayItems = items.take(4).toList();

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: GlassContainer(
            height: 64,
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            backgroundColor: isDark
                ? AarogyaColors.darkGlassBg.withValues(alpha: 0.92)
                : AarogyaColors.lightGlassBg.withValues(alpha: 0.96),
            border: Border.all(
              color: isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle,
              width: 1.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...displayItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  final isSelected = activeIndex == idx;
                  final activeColor = isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue;
                  final inactiveColor = isDark ? AarogyaColors.textDarkMuted : AarogyaColors.textLightMuted;

                  return Expanded(
                    child: InkWell(
                      onTap: () => ref.read(selectedTabIndexProvider.notifier).state = idx,
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? activeColor.withValues(alpha: 0.14) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(color: activeColor.withValues(alpha: 0.35), width: 0.8)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: isSelected ? 20 : 18,
                              color: isSelected ? activeColor : inactiveColor,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.shortLabel ?? item.label,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? activeColor : inactiveColor,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (items.length > 4) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showMoreSheet(context, ref, items, activeIndex, isDark),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: activeIndex >= 4
                              ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue).withValues(alpha: 0.14)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: activeIndex >= 4
                              ? Border.all(
                                  color: (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue).withValues(alpha: 0.35),
                                  width: 0.8,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.grid_view_rounded,
                              size: activeIndex >= 4 ? 20 : 18,
                              color: activeIndex >= 4
                                  ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                                  : (isDark ? AarogyaColors.textDarkMuted : AarogyaColors.textLightMuted),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'More',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 10.5,
                                fontWeight: activeIndex >= 4 ? FontWeight.w700 : FontWeight.w500,
                                color: activeIndex >= 4
                                    ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
                                    : (isDark ? AarogyaColors.textDarkMuted : AarogyaColors.textLightMuted),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreSheet(
    BuildContext context,
    WidgetRef ref,
    List<NavItemData> items,
    int activeIndex,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final moreItems = items.skip(4).toList();
        final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
        final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          backgroundColor: isDark ? AarogyaColors.darkSurface : AarogyaColors.lightSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AarogyaSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Extended Modules', style: AarogyaTypography.headingMedium(primaryText)),
                      Text('Quick access to additional hospital workflows', style: AarogyaTypography.caption(secondaryText)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: AarogyaSpacing.lg),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: moreItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 76,
                ),
                itemBuilder: (context, index) {
                  final realIndex = index + 4;
                  final item = moreItems[index];
                  final isSelected = activeIndex == realIndex;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      ref.read(selectedTabIndexProvider.notifier).state = realIndex;
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AarogyaColors.primaryCyan.withValues(alpha: 0.16)
                            : (isDark ? AarogyaColors.darkGlassCard : AarogyaColors.lightGlassCard),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AarogyaColors.primaryCyan
                              : (isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AarogyaColors.primaryCyan.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, size: 20, color: AarogyaColors.primaryCyan),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.label,
                              style: AarogyaTypography.caption(primaryText).copyWith(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStationLockOverlay(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    UserRole role,
    bool isDark,
  ) {
    return Container(
      color: isDark ? const Color(0xF2080B11) : const Color(0xF2F8FAFC),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0E1524) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0x29FFFFFF) : const Color(0x140F172A),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 32,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Clinical Station Locked',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${user.name} • ${role.displayName} Duty Session',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00BFA5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Clinical station secured during ward rounds in compliance with hospital confidentiality standards.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final bio = ref.read(biometricAuthServiceProvider);
                      await bio.authenticate(
                        reason: 'Scan Face ID / Touch ID to resume clinical rounds',
                      );
                    },
                    icon: const Icon(Icons.fingerprint_rounded, size: 20),
                    label: const Text(
                      'Verify Biometrics to Unlock',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BFA5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      ref.read(biometricAuthServiceProvider).unlockStation();
                      await ref.read(authServiceProvider).signOut();
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: AarogyaColors.critical),
                    label: const Text(
                      'Emergency Sign Out',
                      style: TextStyle(fontSize: 13, color: AarogyaColors.critical),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
