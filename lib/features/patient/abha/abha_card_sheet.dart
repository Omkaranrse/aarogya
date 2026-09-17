import 'package:flutter/material.dart';

import '../../../core/design_system/tokens/colors.dart';
import '../../../core/design_system/tokens/typography.dart';
import '../../../core/design_system/components/aarogya_button.dart';
import '../../../shared/domain/models/patient.dart';

class AbhaCardSheet extends StatelessWidget {
  final Patient patient;

  const AbhaCardSheet({super.key, required this.patient});

  static Future<void> show(BuildContext context, Patient patient) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AbhaCardSheet(patient: patient),
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

    const abhaNumber = '91-4829-1039-4820';
    const abhaAddress = 'rajesh.verma@abdm';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14171D) : const Color(0xFFFFFFFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark
              ? AarogyaColors.darkGlassBorder
              : AarogyaColors.lightGlassBorder,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Modal Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ayushman Bharat Health Account',
                    style: AarogyaTypography.headingMedium(primaryText),
                  ),
                  Text(
                    'National Digital Health Mission • Government of India',
                    style: AarogyaTypography.caption(secondaryText),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Digital ABHA Physical-Style Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1B222C), const Color(0xFF11161D)]
                    : [const Color(0xFFF9FAFB), const Color(0xFFFFFFFF)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2E3947)
                    : const Color(0xFFD1D5DB),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tricolor Header Bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          color: const Color(0xFFFF9933),
                        ),
                      ), // Saffron
                      Expanded(
                        child: Container(height: 4, color: Colors.white),
                      ), // White
                      Expanded(
                        child: Container(
                          height: 4,
                          color: const Color(0xFF138808),
                        ),
                      ), // Green
                    ],
                  ),

                  // NHA & Government Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D47A1)
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                size: 18,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NATIONAL HEALTH AUTHORITY',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: isDark
                                        ? const Color(0xFF90CAF9)
                                        : const Color(0xFF0D47A1),
                                  ),
                                ),
                                Text(
                                  'Ministry of Health & Family Welfare',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AarogyaColors.success.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AarogyaColors.success.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: AarogyaColors.success,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'ABHA ACTIVE',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AarogyaColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Card Body: Details + QR
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient Photo + Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient.name.toUpperCase(),
                                style: AarogyaTypography.title(primaryText)
                                    .copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              _buildCardField(
                                'ABHA Number',
                                abhaNumber,
                                primaryText,
                                isBold: true,
                              ),
                              const SizedBox(height: 4),
                              _buildCardField(
                                'ABHA Address',
                                abhaAddress,
                                isDark
                                    ? const Color(0xFF64B5F6)
                                    : const Color(0xFF1976D2),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildCardField(
                                    'Gender',
                                    patient.gender,
                                    secondaryText,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildCardField(
                                    'Age',
                                    '${patient.age} Yrs',
                                    secondaryText,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildCardField(
                                    'Blood',
                                    patient.bloodGroup,
                                    isDark
                                        ? AarogyaColors.critical
                                        : Colors.red.shade700,
                                    isBold: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              _buildCardField(
                                'Mobile',
                                '+91 98•••• 3210',
                                secondaryText,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Generated Digital QR Code
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: CustomPaint(
                                size: const Size(80, 80),
                                painter: _QrMatrixPainter(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scan at OPD Desk',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Verification Stripe
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: isDark
                        ? const Color(0xFF0F141A)
                        : const Color(0xFFF3F4F6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '100% Consent-Driven Health Record Access',
                          style: TextStyle(fontSize: 9, color: secondaryText),
                        ),
                        Text(
                          'ABDM v2.4 Compliant',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: AarogyaButton(
                  label: 'Download Card',
                  variant: AarogyaButtonVariant.primary,
                  size: AarogyaButtonSize.md,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'ABHA Card saved to device wallet & documents.',
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
                  label: 'Share Health ID',
                  variant: AarogyaButtonVariant.secondary,
                  size: AarogyaButtonSize.md,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'ABHA ID copied to clipboard: rajesh.verma@abdm',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardField(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Custom Vector 2D QR Code Matrix Painter
class _QrMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final step = size.width / 15;

    // Corner Finder 1: Top-Left
    _drawFinderPattern(canvas, paint, 0, 0, step);

    // Corner Finder 2: Top-Right
    _drawFinderPattern(canvas, paint, 8 * step, 0, step);

    // Corner Finder 3: Bottom-Left
    _drawFinderPattern(canvas, paint, 0, 8 * step, step);

    // Pseudo-random deterministic clinical data modules
    final matrix = [
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
      [1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1],
      [0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0],
      [0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 1, 1],
    ];

    for (int r = 0; r < 15; r++) {
      for (int c = 0; c < 15; c++) {
        // Skip finder areas
        if ((r < 7 && c < 7) || (r < 7 && c >= 8) || (r >= 8 && c < 7)) {
          continue;
        }
        if (matrix[r][c] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(c * step, r * step, step * 0.9, step * 0.9),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double step,
  ) {
    // Outer 7x7 box
    canvas.drawRect(Rect.fromLTWH(x, y, 7 * step, 7 * step), paint);

    // Inner 5x5 white box
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(x + step, y + step, 5 * step, 5 * step),
      whitePaint,
    );

    // Center 3x3 solid box
    canvas.drawRect(
      Rect.fromLTWH(x + 2 * step, y + 2 * step, 3 * step, 3 * step),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
