import 'package:flutter/material.dart';

import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_badge.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/utils/formatters.dart';
import '../../shared/domain/models/invoice.dart';

class InvoiceReceiptDialog extends StatelessWidget {
  final Invoice invoice;

  const InvoiceReceiptDialog({super.key, required this.invoice});

  static void show(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (_) => InvoiceReceiptDialog(invoice: invoice),
    );
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
    final isPaid = invoice.status == InvoiceStatus.paid;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hospital Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/Aarogya.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: AarogyaColors.primaryBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: AarogyaColors.primaryBlue,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AAROGYA CLINICAL OS',
                            style: AarogyaTypography.title(primaryText)
                                .copyWith(
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            'Super-Speciality Hospital & Research Center',
                            style: AarogyaTypography.caption(secondaryText),
                          ),
                          Text(
                            'GSTIN: ${invoice.gstin ?? "27AARCG0001Z5Z1"} • OPD Billing Desk',
                            style: AarogyaTypography.caption(secondaryText),
                          ),
                        ],
                      ),
                    ),
                    AarogyaBadge(
                      label: isPaid ? 'SETTLED' : 'PENDING',
                      variant: isPaid
                          ? AarogyaBadgeVariant.success
                          : AarogyaBadgeVariant.warning,
                    ),
                  ],
                ),

                const Divider(height: 28),

                // Invoice & Patient Metadata
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INVOICE TO',
                          style: AarogyaTypography.caption(secondaryText)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          invoice.patientName,
                          style: AarogyaTypography.title(primaryText),
                        ),
                        Text(
                          'Patient ID: #${invoice.patientId}',
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TAX INVOICE',
                          style: AarogyaTypography.caption(secondaryText)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${invoice.invoiceNumber}',
                          style: AarogyaTypography.title(
                            isDark
                                ? AarogyaColors.primaryCyan
                                : AarogyaColors.primaryBlue,
                          ),
                        ),
                        Text(
                          AarogyaFormatters.date(invoice.date),
                          style: AarogyaTypography.caption(secondaryText),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.05,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Service / Item',
                          style: AarogyaTypography.caption(primaryText)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Qty',
                          textAlign: TextAlign.center,
                          style: AarogyaTypography.caption(primaryText)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Amount',
                          textAlign: TextAlign.right,
                          style: AarogyaTypography.caption(primaryText)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),

                // Line Items
                const SizedBox(height: 6),
                ...invoice.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.description,
                            style: AarogyaTypography.bodyMedium(primaryText),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${item.quantity}',
                            textAlign: TextAlign.center,
                            style: AarogyaTypography.caption(secondaryText),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AarogyaFormatters.currencyPaise(item.totalPaise),
                            textAlign: TextAlign.right,
                            style: AarogyaTypography.bodyMedium(primaryText)
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(height: 24),

                // Calculation Summary
                _buildSummaryRow(
                  'Subtotal',
                  AarogyaFormatters.currencyPaise(invoice.subtotalPaise),
                  primaryText,
                  secondaryText,
                ),
                if (invoice.discountPaise > 0)
                  _buildSummaryRow(
                    'Discount Applied',
                    '- ${AarogyaFormatters.currencyPaise(invoice.discountPaise)}',
                    AarogyaColors.success,
                    secondaryText,
                  ),
                ...invoice.taxes.map(
                  (tax) => _buildSummaryRow(
                    tax.label,
                    AarogyaFormatters.currencyPaise(tax.amountPaise),
                    primaryText,
                    secondaryText,
                  ),
                ),
                if (invoice.roundingPaise != 0)
                  _buildSummaryRow(
                    'Rounding',
                    AarogyaFormatters.currencyPaise(invoice.roundingPaise),
                    primaryText,
                    secondaryText,
                  ),

                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL BILLED',
                      style: AarogyaTypography.title(primaryText)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      AarogyaFormatters.currencyPaise(invoice.totalPaise),
                      style: AarogyaTypography.headingLarge(
                        isPaid ? AarogyaColors.success : AarogyaColors.warning,
                      ).copyWith(
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildSummaryRow(
                  'Amount Paid',
                  AarogyaFormatters.currencyPaise(invoice.amountPaidPaise),
                  AarogyaColors.success,
                  secondaryText,
                ),
                _buildSummaryRow(
                  'Balance Due',
                  AarogyaFormatters.currencyPaise(invoice.balanceDuePaise),
                  invoice.balanceDuePaise > 0
                      ? AarogyaColors.warning
                      : secondaryText,
                  secondaryText,
                ),

                const SizedBox(height: 18),

                // Payment Method & Digital Seal
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        (isDark
                                ? AarogyaColors.darkSurface
                                : AarogyaColors.lightBg)
                            .withValues(alpha: 0.6),
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
                        Icons.verified_rounded,
                        size: 22,
                        color: AarogyaColors.success,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPaid ? 'Payment Cleared' : 'Pending Payment',
                              style: AarogyaTypography.label(primaryText)
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              isPaid
                                  ? 'Method: ${invoice.paymentMethod ?? "Digital Payment"}'
                                  : 'Due at hospital cashier / UPI',
                              style: AarogyaTypography.caption(secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: AarogyaButton(
                        label: 'Save PDF',
                        icon: Icons.download_rounded,
                        variant: AarogyaButtonVariant.secondary,
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tax Invoice #${invoice.invoiceNumber} receipt downloaded.',
                              ),
                              backgroundColor: AarogyaColors.success,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AarogyaButton(
                        label: 'Close',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color valueColor,
    Color labelColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AarogyaTypography.bodyMedium(labelColor)),
          Text(
            value,
            style: AarogyaTypography.bodyMedium(valueColor).copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
