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

class InvoiceLineItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  const InvoiceLineItem({
    required this.description,
    this.quantity = 1,
    required this.unitPrice,
    required this.total,
  });
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String patientId;
  final String patientName;
  final String? appointmentId;
  final DateTime date;
  final DateTime dueDate;
  final List<InvoiceLineItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double totalAmount;
  final InvoiceStatus status;
  final String? paymentMethod;
  final DateTime? paidAt;

  const Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.patientId,
    required this.patientName,
    this.appointmentId,
    required this.date,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.status,
    this.paymentMethod,
    this.paidAt,
  });

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? patientId,
    String? patientName,
    String? appointmentId,
    DateTime? date,
    DateTime? dueDate,
    List<InvoiceLineItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? totalAmount,
    InvoiceStatus? status,
    String? paymentMethod,
    DateTime? paidAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      appointmentId: appointmentId ?? this.appointmentId,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
