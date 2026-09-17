import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/aarogya_empty_state.dart';
import '../../core/design_system/components/contextual_header.dart';
import '../../core/design_system/components/stat_card.dart';
import '../../core/design_system/components/timeline_entry_card.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/theme/aarogya_theme_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../shared/domain/models/invoice.dart';
import '../../shared/state/aarogya_providers.dart';
import 'checkout_sheet.dart';
import 'invoice_receipt_dialog.dart';

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

    final primaryText = isDark
        ? AarogyaColors.textDarkPrimary
        : AarogyaColors.textLightPrimary;
    final secondaryText = isDark
        ? AarogyaColors.textDarkSecondary
        : AarogyaColors.textLightSecondary;

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
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? 12 : 24,
          vertical: Responsive.isMobile(context) ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContextualHeader(
              title: 'Invoices & Billing',
              subtitle: 'Clinical charges, diagnostic fees & payment receipts',
              statusLabel:
                  '${invoices.where((i) => i.status == InvoiceStatus.pending).length} Pending • ${invoices.where((i) => i.status == InvoiceStatus.paid).length} Settled',
              statusColor:
                  invoices.any((i) => i.status == InvoiceStatus.pending)
                      ? context.aarogyaColors.clinicalWarning
                      : context.aarogyaColors.clinicalStable,
            ),
            const SizedBox(height: 8),

            // Financial KPIs
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Pending Dues',
                    value: AarogyaFormatters.currency(pendingTotal),
                    subtitle: 'Due at clinic',
                    icon: Icons.pending_actions_rounded,
                    accentColor: AarogyaColors.warning,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    title: 'Total Settled',
                    value: AarogyaFormatters.currency(paidTotal),
                    subtitle: 'Settled',
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: AarogyaColors.success,
                    isIncreasePositive: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Filter tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'All (${invoices.length})',
                    0,
                    isDark,
                    primaryText,
                    secondaryText,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending (${invoices.where((i) => i.status == InvoiceStatus.pending).length})',
                    1,
                    isDark,
                    primaryText,
                    secondaryText,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Paid (${invoices.where((i) => i.status == InvoiceStatus.paid).length})',
                    2,
                    isDark,
                    primaryText,
                    secondaryText,
                  ),
                ],
              ),
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
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final invoice = filtered[index];
                        final isLast = index == filtered.length - 1;
                        return _buildInvoiceCard(
                          context,
                          invoice,
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
    int index,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final isSelected = _selectedFilter == index;
    final accentColor = isDark
        ? AarogyaColors.primaryCyan
        : AarogyaColors.primaryBlue;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = index),
      selectedColor: accentColor.withValues(alpha: 0.15),
      backgroundColor: Colors.transparent,
      labelStyle: AarogyaTypography.caption(
        isSelected ? accentColor : secondaryText,
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
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    Invoice invoice,
    bool isLast,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final colors = context.aarogyaColors;
    final typography = context.aarogyaTypography;
    final isPaid = invoice.status == InvoiceStatus.paid;

    return TimelineEntryCard(
      icon: isPaid ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
      iconColor: isPaid ? colors.clinicalStable : colors.clinicalWarning,
      isLast: isLast,
      title: '#${invoice.invoiceNumber}',
      subtitle: AarogyaFormatters.date(invoice.date),
      statusBadge: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: (isPaid ? colors.clinicalStable : colors.clinicalWarning)
              .withValues(alpha: 0.12),
          borderRadius: AarogyaRadius.radius4,
          border: Border.all(
            color: (isPaid ? colors.clinicalStable : colors.clinicalWarning)
                .withValues(alpha: 0.28),
            width: 0.8,
          ),
        ),
        child: Text(
          invoice.status.displayName,
          style: typography.caption.copyWith(
            color: isPaid ? colors.clinicalStable : colors.clinicalWarning,
            fontWeight: FontWeight.w700,
            fontSize: 9.5,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...invoice.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.description,
                      style: typography.body.copyWith(
                        color: colors.neutrals.gray800,
                      ),
                    ),
                  ),
                  Text(
                    AarogyaFormatters.currency(item.total),
                    style: typography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: colors.neutrals.gray900,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Divider(
            color: colors.borderHairline,
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BILLED',
                style: typography.caption.copyWith(
                  fontSize: 10,
                  letterSpacing: 0.6,
                  color: colors.neutrals.gray500,
                ),
              ),
              Text(
                AarogyaFormatters.currency(invoice.totalAmount),
                style: typography.subtitle.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontWeight: FontWeight.w800,
                  color: isPaid ? colors.clinicalStable : colors.clinicalWarning,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (!isPaid)
          AarogyaButton(
            label: 'Pay Now',
            icon: Icons.credit_card_rounded,
            variant: AarogyaButtonVariant.primary,
            size: AarogyaButtonSize.sm,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CheckoutSheet(invoice: invoice),
              );
            },
          )
        else
          AarogyaButton(
            label: 'View Receipt',
            icon: Icons.receipt_long_rounded,
            variant: AarogyaButtonVariant.secondary,
            size: AarogyaButtonSize.sm,
            onPressed: () {
              InvoiceReceiptDialog.show(context, invoice);
            },
          ),
      ],
    );
  }
}
