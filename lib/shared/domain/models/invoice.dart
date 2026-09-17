import 'package:flutter/foundation.dart';

enum InvoiceStatus {
  paid,
  pending,
  refunded;

  String get displayName {
    switch (this) {
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.refunded:
        return 'Refunded';
    }
  }
}

@immutable
class InvoiceTaxItem {
  final String label;
  final double ratePercent;
  final int amountPaise;

  const InvoiceTaxItem({
    required this.label,
    required this.ratePercent,
    required this.amountPaise,
  });

  double get amountRupees => amountPaise / 100.0;
}

@immutable
class InvoiceLineItem {
  final String description;
  final int quantity;
  final int unitPricePaise;
  final int totalPaise;

  const InvoiceLineItem({
    required this.description,
    this.quantity = 1,
    required this.unitPricePaise,
    required this.totalPaise,
  });

  /// Legacy double accessor for UI migration convenience
  double get unitPrice => unitPricePaise / 100.0;
  double get total => totalPaise / 100.0;
}

@immutable
class Invoice {
  final String id;
  final String invoiceNumber;
  final String patientId;
  final String patientName;
  final String? encounterId;
  final String? appointmentId;
  final DateTime date;
  final DateTime dueDate;
  final List<InvoiceLineItem> items;
  final int subtotalPaise;
  final int discountPaise;
  final List<InvoiceTaxItem> taxes;
  final int roundingPaise;
  final int totalPaise;
  final int amountPaidPaise;
  final int balanceDuePaise;
  final String? gstin;
  final InvoiceStatus status;
  final String? paymentMethod;
  final DateTime? paidAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.patientId,
    required this.patientName,
    this.encounterId,
    this.appointmentId,
    required this.date,
    required this.dueDate,
    required this.items,
    required this.subtotalPaise,
    required this.discountPaise,
    this.taxes = const [],
    this.roundingPaise = 0,
    required this.totalPaise,
    this.amountPaidPaise = 0,
    int? balanceDuePaise,
    this.gstin,
    required this.status,
    this.paymentMethod,
    this.paidAt,
  }) : balanceDuePaise = balanceDuePaise ?? (totalPaise - amountPaidPaise) {
    // Assert computed arithmetic matches stored total
    assert(
      computedTotalPaise == totalPaise,
      'Invoice arithmetic mismatch for $invoiceNumber: computed $computedTotalPaise paise != stored $totalPaise paise',
    );
  }

  /// Computed total from components: Subtotal - Discount + Taxes + Rounding
  int get computedTotalPaise {
    final taxesTotal = taxes.fold<int>(0, (sum, tax) => sum + tax.amountPaise);
    return subtotalPaise - discountPaise + taxesTotal + roundingPaise;
  }

  /// Helper rupee conversions for UI presentation
  double get subtotal => subtotalPaise / 100.0;
  double get discount => discountPaise / 100.0;
  double get totalAmount => totalPaise / 100.0;
  double get amountPaid => amountPaidPaise / 100.0;
  double get balanceDue => balanceDuePaise / 100.0;
  double get tax => taxes.fold<double>(0.0, (sum, t) => sum + t.amountRupees);

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? patientId,
    String? patientName,
    String? encounterId,
    String? appointmentId,
    DateTime? date,
    DateTime? dueDate,
    List<InvoiceLineItem>? items,
    int? subtotalPaise,
    int? discountPaise,
    List<InvoiceTaxItem>? taxes,
    int? roundingPaise,
    int? totalPaise,
    int? amountPaidPaise,
    int? balanceDuePaise,
    String? gstin,
    InvoiceStatus? status,
    String? paymentMethod,
    DateTime? paidAt,
  }) {
    final newTotal = totalPaise ?? this.totalPaise;
    final newPaid = amountPaidPaise ?? this.amountPaidPaise;
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      encounterId: encounterId ?? this.encounterId,
      appointmentId: appointmentId ?? this.appointmentId,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotalPaise: subtotalPaise ?? this.subtotalPaise,
      discountPaise: discountPaise ?? this.discountPaise,
      taxes: taxes ?? this.taxes,
      roundingPaise: roundingPaise ?? this.roundingPaise,
      totalPaise: newTotal,
      amountPaidPaise: newPaid,
      balanceDuePaise: balanceDuePaise ?? (newTotal - newPaid),
      gstin: gstin ?? this.gstin,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
