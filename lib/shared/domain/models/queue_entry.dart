import 'patient.dart';

enum QueueStatus {
  waiting,
  consulting,
  completed,
  skipped;

  String get displayName {
    switch (this) {
      case QueueStatus.waiting:
        return 'Waiting';
      case QueueStatus.consulting:
        return 'Consulting Now';
      case QueueStatus.completed:
        return 'Completed';
      case QueueStatus.skipped:
        return 'Skipped';
    }
  }
}

enum PatientPriority {
  normal,
  urgent,
  emergency;

  String get displayName {
    switch (this) {
      case PatientPriority.normal:
        return 'Regular';
      case PatientPriority.urgent:
        return 'Urgent';
      case PatientPriority.emergency:
        return 'Emergency';
    }
  }
}

class QueueEntry {
  final String id;
  final int tokenNumber;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final int age;
  final String gender;
  final String doctorId;
  final DateTime checkInTime;
  final int estimatedWaitMinutes;
  final QueueStatus status;
  final PatientPriority priority;
  final String chiefComplaint;
  final int? ewsScore;
  final String? ewsCategory;
  final PatientVitals? vitals;

  const QueueEntry({
    required this.id,
    required this.tokenNumber,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.doctorId,
    required this.checkInTime,
    required this.estimatedWaitMinutes,
    required this.status,
    required this.priority,
    required this.chiefComplaint,
    this.ewsScore,
    this.ewsCategory,
    this.vitals,
  });

  QueueEntry copyWith({
    String? id,
    int? tokenNumber,
    String? appointmentId,
    String? patientId,
    String? patientName,
    int? age,
    String? gender,
    String? doctorId,
    DateTime? checkInTime,
    int? estimatedWaitMinutes,
    QueueStatus? status,
    PatientPriority? priority,
    String? chiefComplaint,
    int? ewsScore,
    String? ewsCategory,
    PatientVitals? vitals,
  }) {
    return QueueEntry(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      doctorId: doctorId ?? this.doctorId,
      checkInTime: checkInTime ?? this.checkInTime,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      ewsScore: ewsScore ?? this.ewsScore,
      ewsCategory: ewsCategory ?? this.ewsCategory,
      vitals: vitals ?? this.vitals,
    );
  }
}

