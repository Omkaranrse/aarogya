import 'package:flutter/foundation.dart';

enum AppointmentStatus {
  upcoming,
  confirmed,
  checkedIn,
  inQueue,
  waiting,
  inProgress,
  completed,
  cancelled,
  noShow;

  String get displayName {
    switch (this) {
      case AppointmentStatus.upcoming:
        return 'Upcoming';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.checkedIn:
        return 'Checked In';
      case AppointmentStatus.inQueue:
        return 'In Queue';
      case AppointmentStatus.waiting:
        return 'Waiting';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.noShow:
        return 'No Show';
    }
  }

  bool get isLiveInQueue =>
      this == AppointmentStatus.checkedIn ||
      this == AppointmentStatus.inQueue ||
      this == AppointmentStatus.waiting;
}

enum ConsultationType {
  inPerson,
  videoCall;

  String get displayName =>
      this == ConsultationType.inPerson ? 'In-Person OPD' : 'Tele-Consultation';
}

@immutable
class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String? encounterId;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String doctorAvatar;
  final DateTime dateTime;
  final String timeSlot;
  final ConsultationType type;
  final AppointmentStatus status;
  final int tokenNumber;
  final int feePaise;
  final String? symptoms;
  final String? notes;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.encounterId,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.doctorAvatar,
    required this.dateTime,
    required this.timeSlot,
    required this.type,
    required this.status,
    required this.tokenNumber,
    required this.feePaise,
    this.symptoms,
    this.notes,
  });

  /// Rupee conversion helper
  double get fee => feePaise / 100.0;

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? encounterId,
    String? doctorId,
    String? doctorName,
    String? specialty,
    String? doctorAvatar,
    DateTime? dateTime,
    String? timeSlot,
    ConsultationType? type,
    AppointmentStatus? status,
    int? tokenNumber,
    int? feePaise,
    String? symptoms,
    String? notes,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      encounterId: encounterId ?? this.encounterId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      doctorAvatar: doctorAvatar ?? this.doctorAvatar,
      dateTime: dateTime ?? this.dateTime,
      timeSlot: timeSlot ?? this.timeSlot,
      type: type ?? this.type,
      status: status ?? this.status,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      feePaise: feePaise ?? this.feePaise,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
    );
  }
}
