enum LabResultStatus {
  normal,
  low,
  high,
  critical;

  String get label {
    switch (this) {
      case LabResultStatus.normal:
        return 'Normal';
      case LabResultStatus.low:
        return 'Low';
      case LabResultStatus.high:
        return 'High';
      case LabResultStatus.critical:
        return 'Critical';
    }
  }
}

class LabTestItem {
  final String testName;
  final double value;
  final String unit;
  final double minRange;
  final double maxRange;
  final LabResultStatus status;

  const LabTestItem({
    required this.testName,
    required this.value,
    required this.unit,
    required this.minRange,
    required this.maxRange,
    required this.status,
  });
}

enum ReportStatus {
  pending,
  sampleCollected,
  inAnalysis,
  completed;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Order Placed';
      case ReportStatus.sampleCollected:
        return 'Sample Collected';
      case ReportStatus.inAnalysis:
        return 'In Analysis';
      case ReportStatus.completed:
        return 'Report Ready';
    }
  }
}

class LabReport {
  final String id;
  final String patientId;
  final String patientName;
  final String testName;
  final String category; // Biochemistry, Hematology, Pathology
  final String orderedByDoctor;
  final DateTime orderDate;
  final DateTime? completedDate;
  final ReportStatus status;
  final List<LabTestItem> items;
  final String? labTechnicianNotes;

  const LabReport({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.testName,
    required this.category,
    required this.orderedByDoctor,
    required this.orderDate,
    this.completedDate,
    required this.status,
    required this.items,
    this.labTechnicianNotes,
  });

  bool get hasAbnormalResults =>
      items.any((item) => item.status != LabResultStatus.normal);

  LabReport copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? testName,
    String? category,
    String? orderedByDoctor,
    DateTime? orderDate,
    DateTime? completedDate,
    ReportStatus? status,
    List<LabTestItem>? items,
    String? labTechnicianNotes,
  }) {
    return LabReport(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      testName: testName ?? this.testName,
      category: category ?? this.category,
      orderedByDoctor: orderedByDoctor ?? this.orderedByDoctor,
      orderDate: orderDate ?? this.orderDate,
      completedDate: completedDate ?? this.completedDate,
      status: status ?? this.status,
      items: items ?? this.items,
      labTechnicianNotes: labTechnicianNotes ?? this.labTechnicianNotes,
    );
  }
}
