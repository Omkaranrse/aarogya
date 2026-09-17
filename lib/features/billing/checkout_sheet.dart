import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/glass/glass_container.dart';
import '../../core/design_system/glass/glass_card.dart';
import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/radius.dart';
import '../../core/design_system/tokens/spacing.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/design_system/components/aarogya_text_field.dart';
import '../../core/utils/formatters.dart';
import '../../shared/domain/models/invoice.dart';
import '../../shared/state/aarogya_providers.dart';
import 'invoice_receipt_dialog.dart';

class CheckoutSheet extends ConsumerStatefulWidget {
  final Invoice invoice;

  const CheckoutSheet({super.key, required this.invoice});

  @override
  ConsumerState<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<CheckoutSheet> {
  int _selectedMethod = 0; // 0: UPI, 1: Card, 2: Insurance
  final TextEditingController _upiController = TextEditingController(
    text: 'omkar@okaxis',
  );
  final TextEditingController _cardNumberController = TextEditingController(
    text: '4532 •••• •••• 8921',
  );
  final TextEditingController _cardExpiryController = TextEditingController(
    text: '08/29',
  );
  final TextEditingController _cardCvvController = TextEditingController(
    text: '•••',
  );
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 700));

    final methodName = _selectedMethod == 0
        ? 'UPI (${_upiController.text})'
        : (_selectedMethod == 1
              ? 'Visa Card ending 8921'
              : 'Star Health Insurance TPA');

    ref.read(repositoryProvider).payInvoice(widget.invoice.id, methodName);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
    }
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
    final accentColor = isDark
        ? AarogyaColors.primaryCyan
        : AarogyaColors.primaryBlue;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      snap: true,
      builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          backgroundColor: isDark
              ? AarogyaColors.darkSurface
              : AarogyaColors.lightSurface,
          child: _isSuccess
              ? _buildSuccess(
                  context,
                  isDark,
                  primaryText,
                  secondaryText,
                  accentColor,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure OPD Checkout',
                              style: AarogyaTypography.headingLarge(
                                primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Invoice #${widget.invoice.invoiceNumber}',
                              style: AarogyaTypography.caption(accentColor)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: AarogyaColors.success,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Total Amount Hero
                          GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Payable',
                                      style: AarogyaTypography.caption(
                                        secondaryText,
                                      ),
                                    ),
                                    Text(
                                      AarogyaFormatters.currency(
                                        widget.invoice.totalAmount,
                                      ),
                                      style: AarogyaTypography.displayLarge(
                                        accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AarogyaColors.success.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: AarogyaRadius.radiusPill,
                                    border: Border.all(
                                      color: AarogyaColors.success.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.shield_rounded,
                                        size: 14,
                                        color: AarogyaColors.success,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '256-bit Encrypted',
                                        style: TextStyle(
                                          color: AarogyaColors.success,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Payment Method Selector
                          Text(
                            'Select Payment Method',
                            style: AarogyaTypography.title(primaryText),
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentOption(
                            0,
                            'Instant UPI (GPay, PhonePe, Paytm)',
                            Icons.qr_code_2_rounded,
                            isDark,
                            primaryText,
                            accentColor,
                          ),
                          const SizedBox(height: 8),
                          _buildPaymentOption(
                            1,
                            'Card (Visa, Mastercard, RuPay)',
                            Icons.credit_card_rounded,
                            isDark,
                            primaryText,
                            accentColor,
                          ),
                          const SizedBox(height: 8),
                          _buildPaymentOption(
                            2,
                            'Health Insurance Cashless Pre-Auth',
                            Icons.health_and_safety_rounded,
                            isDark,
                            primaryText,
                            accentColor,
                          ),
                          const SizedBox(height: 16),

                          // Method Details
                          if (_selectedMethod == 0) ...[
                            AarogyaTextField(
                              label: 'Virtual Payment Address (UPI ID)',
                              controller: _upiController,
                              prefixIcon: Icons.alternate_email_rounded,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children:
                                  [
                                    '@okaxis',
                                    '@okhdfcbank',
                                    '@paytm',
                                    '@ybl',
                                  ].map((handle) {
                                    return ActionChip(
                                      label: Text(
                                        handle,
                                        style: AarogyaTypography.caption(
                                          primaryText,
                                        ),
                                      ),
                                      backgroundColor:
                                          (isDark ? Colors.white : Colors.black)
                                              .withValues(alpha: 0.05),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: isDark
                                              ? AarogyaColors
                                                    .darkGlassBorderSubtle
                                              : AarogyaColors
                                                    .lightGlassBorderSubtle,
                                        ),
                                      ),
                                      onPressed: () {
                                        final current = _upiController.text
                                            .split('@')
                                            .first;
                                        _upiController.text = '$current$handle';
                                      },
                                    );
                                  }).toList(),
                            ),
                          ] else if (_selectedMethod == 1) ...[
                            AarogyaTextField(
                              label: 'Card Number',
                              controller: _cardNumberController,
                              prefixIcon: Icons.credit_card_rounded,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: AarogyaTextField(
                                    label: 'Expiry',
                                    controller: _cardExpiryController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AarogyaTextField(
                                    label: 'CVV',
                                    controller: _cardCvvController,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    (isDark
                                            ? AarogyaColors.darkGlassCard
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
                                    Icons.verified_user_rounded,
                                    color: AarogyaColors.info,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Star Health Insurance TPA',
                                          style: AarogyaTypography.title(
                                            primaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Policy #STAR-48291 • Instant OPD Cashless eligible',
                                          style: AarogyaTypography.caption(
                                            secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Pay Button
                    SafeArea(
                      child: AarogyaButton(
                        label:
                            'Pay ${AarogyaFormatters.currency(widget.invoice.totalAmount)}',
                        icon: Icons.check_circle_outline_rounded,
                        fullWidth: true,
                        size: AarogyaButtonSize.lg,
                        isLoading: _isProcessing,
                        onPressed: _processPayment,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPaymentOption(
    int index,
    String title,
    IconData icon,
    bool isDark,
    Color primaryText,
    Color accentColor,
  ) {
    final isSelected = _selectedMethod == index;
    return GlassCard(
      onTap: () => setState(() => _selectedMethod = index),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      customBorder: Border.all(
        color: isSelected
            ? accentColor
            : (isDark
                  ? AarogyaColors.darkGlassBorderSubtle
                  : AarogyaColors.lightGlassBorderSubtle),
        width: isSelected ? 1.5 : 1.0,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isSelected ? accentColor : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AarogyaTypography.bodyMedium(primaryText),
            ),
          ),
          if (isSelected)
            Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildSuccess(
    BuildContext context,
    bool isDark,
    Color primaryText,
    Color secondaryText,
    Color accentColor,
  ) {
    final invoices = ref.watch(invoicesProvider);
    final updatedInvoice = invoices.firstWhere(
      (i) => i.id == widget.invoice.id,
      orElse: () => widget.invoice,
    );

    return Center(
      child: Padding(
        padding: AarogyaSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AarogyaColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AarogyaColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AarogyaColors.success,
              ),
            ),
            const SizedBox(height: AarogyaSpacing.lg),
            Text(
              'Payment Successful',
              style: AarogyaTypography.headingLarge(primaryText),
            ),
            const SizedBox(height: AarogyaSpacing.xs),
            Text(
              'Invoice #${widget.invoice.invoiceNumber} of ${AarogyaFormatters.currency(widget.invoice.totalAmount)} has been settled.',
              style: AarogyaTypography.bodyMedium(secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AarogyaSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: AarogyaButton(
                    label: 'View Receipt',
                    icon: Icons.receipt_long_rounded,
                    variant: AarogyaButtonVariant.secondary,
                    onPressed: () {
                      Navigator.pop(context);
                      InvoiceReceiptDialog.show(context, updatedInvoice);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AarogyaButton(
                    label: 'Done',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
