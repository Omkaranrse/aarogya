import 'package:flutter/foundation.dart';

/// Represents an active patient session in the clinical application.
/// Ensures all clinical records loaded in the UI match the session subject.
@immutable
class PatientSession {
  final String patientId;
  final String patientName;
  final DateTime sessionStartedAt;
  final String? nationalHealthId; // ABHA ID

  const PatientSession({
    required this.patientId,
    required this.patientName,
    required this.sessionStartedAt,
    this.nationalHealthId,
  });

  PatientSession copyWith({
    String? patientId,
    String? patientName,
    DateTime? sessionStartedAt,
    String? nationalHealthId,
  }) {
    return PatientSession(
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      nationalHealthId: nationalHealthId ?? this.nationalHealthId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientSession &&
          runtimeType == other.runtimeType &&
          patientId == other.patientId;

  @override
  int get hashCode => patientId.hashCode;
}

/// Security & Data Integrity Exception thrown when a clinical record's patientId
/// does not match the authenticated session patientId.
class PatientMismatchException implements Exception {
  final String expectedPatientId;
  final String actualPatientId;
  final String recordType;
  final String recordId;

  const PatientMismatchException({
    required this.expectedPatientId,
    required this.actualPatientId,
    required this.recordType,
    required this.recordId,
  });

  @override
  String toString() {
    return 'PatientMismatchException: Security Guard Violation. Record $recordType ($recordId) belongs to patient "$actualPatientId", but active session is for patient "$expectedPatientId".';
  }
}
