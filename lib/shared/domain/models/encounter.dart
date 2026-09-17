import 'package:flutter/foundation.dart';

enum EncounterType {
  opdConsultation,
  teleConsultation,
  emergency,
  inpatientWard,
  diagnosticVisit;

  String get displayName {
    switch (this) {
      case EncounterType.opdConsultation:
        return 'OPD Consultation';
      case EncounterType.teleConsultation:
        return 'Tele-Consultation';
      case EncounterType.emergency:
        return 'Emergency Triage';
      case EncounterType.inpatientWard:
        return 'Inpatient Ward';
      case EncounterType.diagnosticVisit:
        return 'Diagnostic Visit';
    }
  }
}

@immutable
class Encounter {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String department;
  final DateTime occurredAt;
  final EncounterType type;
  final String? summary;

  const Encounter({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.department,
    required this.occurredAt,
    required this.type,
    this.summary,
  });

  Encounter copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? department,
    DateTime? occurredAt,
    EncounterType? type,
    String? summary,
  }) {
    return Encounter(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      department: department ?? this.department,
      occurredAt: occurredAt ?? this.occurredAt,
      type: type ?? this.type,
      summary: summary ?? this.summary,
    );
  }
}
