import 'package:flutter/material.dart';

import '../../core/design_system/tokens/colors.dart';
import '../../core/design_system/tokens/typography.dart';
import '../../core/design_system/components/aarogya_button.dart';
import '../../core/utils/formatters.dart';
import '../../shared/domain/models/prescription.dart';
import '../../shared/domain/models/lab_report.dart';
import '../../shared/domain/models/invoice.dart';

enum ClinicalDocumentType {
  prescription,
  labReport,
  invoice;

  String get title {
    switch (this) {
      case ClinicalDocumentType.prescription:
        return 'Official OPD Prescription Slip';
      case ClinicalDocumentType.labReport:
        return 'Diagnostic Pathology Report';
      case ClinicalDocumentType.invoice:
        return 'Hospital Tax Invoice & Bill';
    }
  }
}

class PrintableClinicalDocumentDialog extends StatelessWidget {
  final ClinicalDocumentType type;
  final Prescription? prescription;
  final LabReport? labReport;
  final Invoice? invoice;

  const PrintableClinicalDocumentDialog({
    super.key,
    required this.type,
    this.prescription,
    this.labReport,
    this.invoice,
  });

  static Future<void> showPrescription(BuildContext context, Prescription rx) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => PrintableClinicalDocumentDialog(
        type: ClinicalDocumentType.prescription,
        prescription: rx,
      ),
    );
  }

  static Future<void> showLabReport(BuildContext context, LabReport report) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => PrintableClinicalDocumentDialog(
        type: ClinicalDocumentType.labReport,
        labReport: report,
      ),
    );
  }

  static Future<void> showInvoice(BuildContext context, Invoice inv) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => PrintableClinicalDocumentDialog(
        type: ClinicalDocumentType.invoice,
        invoice: inv,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 500;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 16,
        vertical: isCompact ? 12 : 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14171E) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF2C3542) : const Color(0xFFD1D5DB),
            ),
          ),
          child: Column(
            children: [
              // Top Action Bar
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 12 : 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF191F28)
                      : const Color(0xFFFFFFFF),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF2B3441)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.print_rounded,
                      color: AarogyaColors.primaryCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        type.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AarogyaTypography.title(
                          isDark
                              ? AarogyaColors.textDarkPrimary
                              : AarogyaColors.textLightPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF222B36)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompact ? 'A4 • NABH' : 'A4 • Portrait (NABH)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Scrollable Printable A4 Sheet
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isCompact ? 8 : 16),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 580),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 14 : 28,
                        vertical: isCompact ? 18 : 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Official Hospital Letterhead
                          _buildHospitalHeader(),
                          const Divider(
                            height: 24,
                            thickness: 1.5,
                            color: Colors.black87,
                          ),

                          // Dynamic Content Based on Type
                          if (type == ClinicalDocumentType.prescription &&
                              prescription != null)
                            _buildPrescriptionContent(prescription!)
                          else if (type == ClinicalDocumentType.labReport &&
                              labReport != null)
                            _buildLabReportContent(labReport!)
                          else if (type == ClinicalDocumentType.invoice &&
                              invoice != null)
                            _buildInvoiceContent(invoice!),

                          const SizedBox(height: 32),
                          const Divider(
                            height: 16,
                            thickness: 1,
                            color: Colors.black26,
                          ),

                          // Document Footer with Barcode & Seal
                          _buildDocumentFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Print Actions
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 12 : 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF191F28)
                      : const Color(0xFFFFFFFF),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFF2B3441)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AarogyaButton(
                      label: 'Save PDF',
                      variant: AarogyaButtonVariant.secondary,
                      size: AarogyaButtonSize.sm,
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document downloaded as PDF.'),
                            backgroundColor: AarogyaColors.success,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    AarogyaButton(
                      label: 'Print Document',
                      icon: Icons.print_rounded,
                      size: AarogyaButtonSize.sm,
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sent to hospital default printer.'),
                            backgroundColor: AarogyaColors.primaryCyan,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/Aarogya.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF006699),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AAROGYA INSTITUTE OF MEDICAL SCIENCES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF003366),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Super-Speciality Hospital & Research Center • NABH & NABL Accredited',
                style: TextStyle(
                  fontSize: 9.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Sector 12, Institutional Area, Mumbai 400076 • Emergency: +91 22 2450 0000',
                style: TextStyle(fontSize: 8.5, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green.shade800),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'NABH CERTIFIED',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: Colors.green.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionContent(Prescription rx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meta row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rx.doctorName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${rx.doctorSpecialty} • Reg. No: MMC-2015-84920',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Date: ${AarogyaFormatters.date(rx.date)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Rx ID: ${rx.id.toUpperCase()}',
                  style: const TextStyle(fontSize: 9, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Patient Strip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          color: const Color(0xFFF3F4F6),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Patient: ${rx.patientName}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Text(
                'Age: 62 Yrs • Gender: Male • Blood: O+',
                style: TextStyle(fontSize: 10, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Rx Symbol
        const Text(
          '℞',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Color(0xFF003366),
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 8),

        // Table with horizontal scroll container to guarantee no overflow on narrow devices
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 460),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(4.5),
                2: FlexColumnWidth(2.5),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(3.5),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
                  children:
                      [
                            '#',
                            'Medicine & Strength',
                            'Dose',
                            'Duration',
                            'Instructions',
                          ]
                          .map(
                            (h) => Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                h,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                ...rx.medications.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final m = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text('$idx', style: const TextStyle(fontSize: 10)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          '${m.name} (${m.dosage})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          m.frequency,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          m.duration,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          m.instructions,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        if (rx.generalAdvice != null) ...[
          const Text(
            'Clinical Advice & Precautions:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            rx.generalAdvice!,
            style: const TextStyle(fontSize: 10, color: Colors.black87),
          ),
        ],
      ],
    );
  }

  Widget _buildLabReportContent(LabReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.testName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Department: ${report.category} • Ordered by: ${report.orderedByDoctor}',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Sample Date: ${AarogyaFormatters.date(report.orderDate)}',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 480),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
              columnWidths: const {
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(3),
                4: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
                  children:
                      [
                            'Investigation Parameter',
                            'Result',
                            'Unit',
                            'Reference Range',
                            'Status',
                          ]
                          .map(
                            (h) => Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                h,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                ...report.items.map((item) {
                  final isAbnormal = item.status != LabResultStatus.normal;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          item.testName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          '${item.value}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isAbnormal
                                ? Colors.red.shade800
                                : Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          item.unit,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          '${item.minRange} - ${item.maxRange}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          item.status.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isAbnormal
                                ? Colors.red.shade800
                                : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceContent(Invoice inv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TAX INVOICE #${inv.invoiceNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'Hospital GSTIN: 27AABCA1234F1Z5',
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Billing Date: ${AarogyaFormatters.date(inv.date)}',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 440),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
                  children: ['Service / Description', 'Qty', 'Unit Price', 'Amount']
                      .map(
                        (h) => Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            h,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ...inv.items.map(
                  (item) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          item.description,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          AarogyaFormatters.currency(item.unitPrice),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          AarogyaFormatters.currency(item.total),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Subtotal: ${AarogyaFormatters.currency(inv.subtotal)}',
                  style: const TextStyle(fontSize: 10),
                ),
                const Text(
                  'Tax (Healthcare Exempt): ₹0.00',
                  style: TextStyle(fontSize: 10),
                ),
                Text(
                  'Grand Total: ${AarogyaFormatters.currency(inv.totalAmount)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF003366),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentFooter() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      runSpacing: 10,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fake Barcode Lines
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                26,
                (i) => Container(
                  margin: const EdgeInsets.only(right: 2),
                  width: (i % 3 == 0) ? 2.5 : 1.2,
                  height: 22,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'AAROGYA-DIGI-DOC-982103810',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 0.8,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF0D47A1), width: 1.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Column(
                children: [
                  Text(
                    'DIGITALLY SIGNED',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                  Text(
                    'Medical Superintendent',
                    style: TextStyle(fontSize: 7, color: Color(0xFF0D47A1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Valid without physical seal',
              style: TextStyle(fontSize: 7, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }
}
