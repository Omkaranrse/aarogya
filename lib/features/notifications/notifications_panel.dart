import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/glass/glass_container.dart';
import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/spacing.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_badge.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/utils/formatters.dart';
import '../../shared/domain/models/notification_item.dart';
import '../../shared/state/aarogya_providers.dart';

class NotificationsPanel extends ConsumerStatefulWidget {
  const NotificationsPanel({super.key});

  @override
  ConsumerState<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends ConsumerState<NotificationsPanel> {
  NotificationCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsProvider);
    final repo = ref.read(repositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final filtered = _selectedCategory == null
        ? notifications
        : notifications.where((n) => n.category == _selectedCategory).toList();

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
              // Drag handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AarogyaSpacing.lg),

              // Title & Mark all read
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Notifications',
                        style: AarogyaTypography.headingLarge(primaryText),
                      ),
                      const SizedBox(width: 8),
                      AarogyaBadge(
                        label: '${notifications.length}',
                        variant: AarogyaBadgeVariant.cyan,
                        showDot: false,
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => repo.markAllNotificationsAsRead(),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Mark all as read'),
                  ),
                ],
              ),
              const SizedBox(height: AarogyaSpacing.md),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', _selectedCategory == null, () {
                      setState(() => _selectedCategory = null);
                    }, isDark),
                    ...NotificationCategory.values.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return _buildFilterChip(cat.displayName, isSelected, () {
                        setState(() => _selectedCategory = cat);
                      }, isDark);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AarogyaSpacing.lg),

              // Notification List
              Expanded(
                child: filtered.isEmpty
                    ? const AarogyaEmptyState(
                        icon: Icons.notifications_off_outlined,
                        title: 'No Notifications',
                        description: 'You are all caught up with your clinical updates and alerts.',
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: AarogyaSpacing.md),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return _buildNotificationCard(item, repo, isDark, primaryText, secondaryText);
                        },
                      ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildNotificationCard(
    NotificationItem item,
    dynamic repo,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    IconData icon;
    Color iconColor;

    switch (item.category) {
      case NotificationCategory.appointment:
        icon = Icons.calendar_today_rounded;
        iconColor = AarogyaColors.primaryCyan;
        break;
      case NotificationCategory.clinical:
        icon = Icons.health_and_safety_rounded;
        iconColor = AarogyaColors.accentPurple;
        break;
      case NotificationCategory.laboratory:
        icon = Icons.biotech_rounded;
        iconColor = AarogyaColors.primaryBlue;
        break;
      case NotificationCategory.billing:
        icon = Icons.payment_rounded;
        iconColor = AarogyaColors.success;
        break;
      case NotificationCategory.system:
        icon = Icons.info_outline_rounded;
        iconColor = AarogyaColors.warning;
    }

    return GlassCard(
      onTap: () => repo.markNotificationAsRead(item.id),
      padding: AarogyaSpacing.paddingMd,
      glowColor: iconColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withOpacity(0.3)),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: AarogyaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: AarogyaTypography.title(primaryText).copyWith(
                        fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AarogyaColors.primaryCyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: AarogyaTypography.bodyMedium(secondaryText),
                ),
                const SizedBox(height: 6),
                Text(
                  AarogyaFormatters.timeAgo(item.timestamp),
                  style: AarogyaTypography.caption(
                    isDark ? AarogyaColors.textDarkMuted : AarogyaColors.textLightMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
