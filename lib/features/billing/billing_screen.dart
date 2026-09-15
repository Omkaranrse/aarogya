import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/spacing.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_badge.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/design_system/components/stat_card.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/invoice.dart';
import '../../shared/state/aarogya_providers.dart';
import 'checkout_sheet.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  int _selectedFilter = 0; // 0: All, 1: Pending, 2: Paid

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoicesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    final pendingTotal = invoices
        .where((inv) => inv.status == InvoiceStatus.pending)
        .fold(0.0, (acc, inv) => acc + inv.totalAmount);

    final paidTotal = invoices
        .where((inv) => inv.status == InvoiceStatus.paid)
        .fold(0.0, (acc, inv) => acc + inv.totalAmount);

    final filtered = _selectedFilter == 1
        ? invoices.where((i) => i.status == InvoiceStatus.pending).toList()
        : (_selectedFilter == 2
            ? invoices.where((i) => i.status == InvoiceStatus.paid).toList()
            : invoices);

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
                      Text('Invoices & Medical Billing', style: AarogyaTypography.headingLarge(primaryText)),
                      Text(
                        'Track OPD consultation charges, laboratory bills, and payment receipts',
                        style: AarogyaTypography.bodyMedium(secondaryText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AarogyaBadge(
                  label: '${invoices.length} Total Invoices',
                  variant: AarogyaBadgeVariant.cyan,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Financial KPIs
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Pending Outstanding',
                    value: AarogyaFormatters.currency(pendingTotal),
                    subtitle: 'Due upon arrival at OPD',
                    icon: Icons.pending_actions_rounded,
                    accentColor: AarogyaColors.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    title: 'Total Settled',
                    value: AarogyaFormatters.currency(paidTotal),
                    subtitle: 'Receipts verified',
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: AarogyaColors.success,
                    isIncreasePositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Filter tabs
            Row(
              children: [
                _buildFilterChip('All Invoices (${invoices.length})', 0, isDark),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pending (${invoices.where((i) => i.status == InvoiceStatus.pending).length})',
                  1,
                  isDark,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Paid (${invoices.where((i) => i.status == InvoiceStatus.paid).length})',
                  2,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Invoices List
            Expanded(
              child: filtered.isEmpty
                  ? const AarogyaEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No Invoices Found',
                      description: 'No medical invoices currently match the selected payment status.',
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final invoice = filtered[index];
                        return _buildInvoiceCard(context, invoice, isDark, primaryText, secondaryText);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, bool isDark) {
    final isSelected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = index),
      selectedColor: isDark ? AarogyaColors.primaryCyan.withOpacity(0.25) : AarogyaColors.primaryBlue.withOpacity(0.15),
      labelStyle: AarogyaTypography.caption(
        isSelected
            ? (isDark ? AarogyaColors.primaryCyan : AarogyaColors.primaryBlue)
            : (isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary),
      ).copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    Invoice invoice,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final isPaid = invoice.status == InvoiceStatus.paid;

    return GlassCard(
      glowColor: isPaid ? AarogyaColors.success : AarogyaColors.warning,
      padding: AarogyaSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_rounded, color: AarogyaColors.primaryCyan, size: 20),
                  const SizedBox(width: 8),
                  Text('#${invoice.invoiceNumber}', style: AarogyaTypography.title(primaryText)),
                ],
              ),
              AarogyaBadge(
                label: invoice.status.displayName,
                variant: isPaid ? AarogyaBadgeVariant.success : AarogyaBadgeVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Billed to ${invoice.patientName} on ${AarogyaFormatters.date(invoice.date)}',
            style: AarogyaTypography.caption(secondaryText),
          ),
          const Divider(height: 20),

          // Line Items
          ...invoice.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(item.description, style: AarogyaTypography.bodyMedium(primaryText)),
                  ),
                  Text(
                    AarogyaFormatters.currency(item.total),
                    style: AarogyaTypography.bodyMedium(primaryText).copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }),

          const Divider(height: 20),

          // Total & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount', style: AarogyaTypography.caption(secondaryText)),
                  Text(
                    AarogyaFormatters.currency(invoice.totalAmount),
                    style: AarogyaTypography.headingMedium(isPaid ? AarogyaColors.success : AarogyaColors.warning),
                  ),
                ],
              ),
              Row(
                children: [
                  if (!isPaid) ...[
                    AarogyaButton(
                      label: 'Pay Now',
                      icon: Icons.credit_card_rounded,
                      size: AarogyaButtonSize.sm,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => CheckoutSheet(invoice: invoice),
                        );
                      },
                    ),
                  ] else ...[
                    AarogyaButton(
                      label: 'Download Receipt',
                      icon: Icons.download_rounded,
                      variant: AarogyaButtonVariant.secondary,
                      size: AarogyaButtonSize.sm,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading receipt for #${invoice.invoiceNumber}...'),
                            backgroundColor: AarogyaColors.success,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
