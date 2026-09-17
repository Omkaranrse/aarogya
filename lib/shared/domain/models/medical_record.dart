import 'package:flutter/foundation.dart';

enum MedicalRecordType {
  consultation,
  prescription,
  labReport,
  radiology,
  dischargeSummary,
  advisedDiagnostic;

  String get displayName {
    switch (this) {
      case MedicalRecordType.consultation:
        return 'Consultation Note';
      case MedicalRecordType.prescription:
        return 'Digital Prescription';
      case MedicalRecordType.labReport:
        return 'Laboratory Report';
      case MedicalRecordType.radiology:
        return 'Imaging & Radiology';
      case MedicalRecordType.dischargeSummary:
        return 'Discharge Summary';
      case MedicalRecordType.advisedDiagnostic:
        return 'Advised Test — Pending';
    }
  }
}

@immutable
class MedicalRecord {
  final String id;
  final String patientId;
  final String? encounterId;
  final String title;
  final MedicalRecordType type;
  final DateTime occurredAt;
  final String doctorName;
  final String department;
  final String summary;
  final String? attachmentUrl;
  final List<String> tags;
  final bool isAdvisedPending;

  /// Canonical date getter
  DateTime get date => occurredAt;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    this.encounterId,
    required this.title,
    required this.type,
    required this.occurredAt,
    required this.doctorName,
    required this.department,
    required this.summary,
    this.attachmentUrl,
    this.tags = const [],
    this.isAdvisedPending = false,
  });

  /// Deterministic sort strictly by occurredAt descending with stable ID tiebreaker
  static int compareEvents(MedicalRecord a, MedicalRecord b, {bool descending = true}) {
    final comp = a.occurredAt.compareTo(b.occurredAt);
    if (comp != 0) {
      return descending ? -comp : comp;
    }
    // Stable tiebreaker on ID
    return descending ? -a.id.compareTo(b.id) : a.id.compareTo(b.id);
  }

  MedicalRecord copyWith({
    String? id,
    String? patientId,
    String? encounterId,
    String? title,
    MedicalRecordType? type,
    DateTime? occurredAt,
    String? doctorName,
    String? department,
    String? summary,
    String? attachmentUrl,
    List<String>? tags,
    bool? isAdvisedPending,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      encounterId: encounterId ?? this.encounterId,
      title: title ?? this.title,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      doctorName: doctorName ?? this.doctorName,
      department: department ?? this.department,
      summary: summary ?? this.summary,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      tags: tags ?? this.tags,
      isAdvisedPending: isAdvisedPending ?? this.isAdvisedPending,
    );
  }
}
