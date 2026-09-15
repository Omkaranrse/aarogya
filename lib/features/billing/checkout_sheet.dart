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

class CheckoutSheet extends ConsumerStatefulWidget {
  final Invoice invoice;

  const CheckoutSheet({super.key, required this.invoice});

  @override
  ConsumerState<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<CheckoutSheet> {
  int _selectedMethod = 0; // 0: UPI, 1: Card, 2: Insurance
  final TextEditingController _upiController = TextEditingController(text: 'omkar@okaxis');
  final TextEditingController _cardNumberController = TextEditingController(text: '4532 •••• •••• 8921');
  bool _isProcessing = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 900));

    final methodName = _selectedMethod == 0
        ? 'UPI (${_upiController.text})'
        : (_selectedMethod == 1 ? 'Visa Card ending 8921' : 'Star Health Insurance TPA');

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
    final primaryText = isDark ? AarogyaColors.textDarkPrimary : AarogyaColors.textLightPrimary;
    final secondaryText = isDark ? AarogyaColors.textDarkSecondary : AarogyaColors.textLightSecondary;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          padding: AarogyaSpacing.paddingXl,
          backgroundColor: isDark ? AarogyaColors.darkSurface : AarogyaColors.lightSurface,
          child: _isSuccess
              ? _buildSuccess(context, isDark, primaryText, secondaryText)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: AarogyaSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Secure Clinical Checkout', style: AarogyaTypography.headingLarge(primaryText)),
                            Text('Invoice #${widget.invoice.invoiceNumber}', style: AarogyaTypography.caption(AarogyaColors.primaryCyan)),
                          ],
                        ),
                        const Icon(Icons.lock_outline_rounded, color: AarogyaColors.success, size: 22),
                      ],
                    ),
                    const SizedBox(height: AarogyaSpacing.lg),

                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          // Total Amount Hero
                          GlassCard(
                            glowColor: AarogyaColors.primaryCyan,
                            padding: AarogyaSpacing.paddingLg,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Amount Payable', style: AarogyaTypography.caption(secondaryText)),
                                    Text(
                                      AarogyaFormatters.currency(widget.invoice.totalAmount),
                                      style: AarogyaTypography.displayLarge(AarogyaColors.primaryCyan),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AarogyaColors.success.withOpacity(0.12),
                                    borderRadius: AarogyaRadius.radiusPill,
                                    border: Border.all(color: AarogyaColors.success.withOpacity(0.3)),
                                  ),
                                  child: Text('256-bit Encrypted', style: AarogyaTypography.caption(AarogyaColors.success)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AarogyaSpacing.xl),

                          // Payment Method Selector
                          Text('Select Payment Method', style: AarogyaTypography.title(primaryText)),
                          const SizedBox(height: AarogyaSpacing.md),
                          _buildPaymentOption(0, 'Instant UPI (GPay, PhonePe, Paytm)', Icons.qr_code_2_rounded, isDark, primaryText),
                          const SizedBox(height: 8),
                          _buildPaymentOption(1, 'Credit / Debit Card (Visa, Mastercard, RuPay)', Icons.credit_card_rounded, isDark, primaryText),
                          const SizedBox(height: 8),
                          _buildPaymentOption(2, 'Health Insurance Cashless Claim', Icons.health_and_safety_rounded, isDark, primaryText),
                          const SizedBox(height: AarogyaSpacing.lg),

                          // Method Details
                          if (_selectedMethod == 0) ...[
                            AarogyaTextField(
                              label: 'Virtual Payment Address (VPA / UPI ID)',
                              controller: _upiController,
                              prefixIcon: Icons.alternate_email_rounded,
                            ),
                          ] else if (_selectedMethod == 1) ...[
                            AarogyaTextField(
                              label: 'Card Number',
                              controller: _cardNumberController,
                              prefixIcon: Icons.credit_card_rounded,
                            ),
                          ] else ...[
                            Text(
                              'Direct hospital cashless desk will verify policy #STAR-48291 automatically.',
                              style: AarogyaTypography.bodyMedium(AarogyaColors.info),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Pay Button
                    SafeArea(
                      child: AarogyaButton(
                        label: 'Pay ${AarogyaFormatters.currency(widget.invoice.totalAmount)}',
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

  Widget _buildPaymentOption(int index, String title, IconData icon, bool isDark, Color primaryText) {
    final isSelected = _selectedMethod == index;
    return GlassCard(
      onTap: () => setState(() => _selectedMethod = index),
      glowColor: isSelected ? AarogyaColors.primaryCyan : null,
      padding: AarogyaSpacing.paddingMd,
      customBorder: Border.all(
        color: isSelected
            ? AarogyaColors.primaryCyan
            : (isDark ? AarogyaColors.darkGlassBorderSubtle : AarogyaColors.lightGlassBorderSubtle),
        width: isSelected ? 1.5 : 1.0,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isSelected ? AarogyaColors.primaryCyan : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AarogyaTypography.bodyMedium(primaryText))),
          if (isSelected) const Icon(Icons.check_circle_rounded, color: AarogyaColors.primaryCyan, size: 20),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, bool isDark, Color primaryText, Color secondaryText) {
    return Center(
      child: Padding(
        padding: AarogyaSpacing.paddingXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AarogyaColors.success.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AarogyaColors.success.withOpacity(0.4)),
              ),
              child: const Icon(Icons.check_circle_rounded, size: 54, color: AarogyaColors.success),
            ),
            const SizedBox(height: AarogyaSpacing.lg),
            Text('Payment Successful!', style: AarogyaTypography.headingLarge(primaryText)),
            const SizedBox(height: AarogyaSpacing.xs),
            Text(
              'Invoice #${widget.invoice.invoiceNumber} of ${AarogyaFormatters.currency(widget.invoice.totalAmount)} has been cleared.',
              style: AarogyaTypography.bodyMedium(secondaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AarogyaSpacing.xxl),
            AarogyaButton(
              label: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
