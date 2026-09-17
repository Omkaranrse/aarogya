import 'package:flutter/foundation.dart';

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

  String get glyph {
    switch (this) {
      case LabResultStatus.normal:
        return '●';
      case LabResultStatus.low:
        return '↓';
      case LabResultStatus.high:
      case LabResultStatus.critical:
        return '↑';
    }
  }
}

@immutable
class LabTestItem {
  final String testName;
  final double value;
  final String unit;
  final double minRange;
  final double maxRange;
  final LabResultStatus status;
  final String? customSeverityLabel;

  const LabTestItem({
    required this.testName,
    required this.value,
    required this.unit,
    required this.minRange,
    required this.maxRange,
    required this.status,
    this.customSeverityLabel,
  });

  String get displaySeverity => customSeverityLabel ?? status.label;

  LabTestItem copyWith({
    String? testName,
    double? value,
    String? unit,
    double? minRange,
    double? maxRange,
    LabResultStatus? status,
    String? customSeverityLabel,
  }) {
    return LabTestItem(
      testName: testName ?? this.testName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      minRange: minRange ?? this.minRange,
      maxRange: maxRange ?? this.maxRange,
      status: status ?? this.status,
      customSeverityLabel: customSeverityLabel ?? this.customSeverityLabel,
    );
  }
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

@immutable
class LabReport {
  final String id;
  final String patientId;
  final String patientName;
  final String? encounterId;
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
    this.encounterId,
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
    String? encounterId,
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
      encounterId: encounterId ?? this.encounterId,
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
