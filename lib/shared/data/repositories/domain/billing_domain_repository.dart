import '../../../domain/models/invoice.dart';
import '../mock_data.dart';

/// Domain Repository for managing medical invoices and patient billing records.
class BillingDomainRepository {
  List<Invoice> _invoices = [];

  BillingDomainRepository() {
    _invoices = List.from(AarogyaMockData.invoices);
  }

  List<Invoice> get invoices => List.unmodifiable(_invoices);

  Future<List<Invoice>> fetchInvoices() async => List.unmodifiable(_invoices);

  void payInvoice(String invoiceId) {
    final index = _invoices.indexWhere((i) => i.id == invoiceId);
    if (index != -1) {
      _invoices[index] = _invoices[index].copyWith(
        status: InvoiceStatus.paid,
        paidAt: DateTime.now(),
      );
    }
  }

  void addInvoice(Invoice invoice) {
    _invoices.insert(0, invoice);
  }
}
