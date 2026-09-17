import 'package:flutter/foundation.dart';

enum MedicationStatus {
  scheduled,
  active,
  completed,
  stopped;

  String get displayName {
    switch (this) {
      case MedicationStatus.scheduled:
        return 'Scheduled';
      case MedicationStatus.active:
        return 'Active';
      case MedicationStatus.completed:
        return 'Completed';
      case MedicationStatus.stopped:
        return 'Discontinued';
    }
  }
}

@immutable
class Medication {
  final String id;
  final String name;
  final String dosage; // e.g. 10 mg
  final String frequency; // e.g. 1-0-1 (Morning & Night)
  final String duration; // e.g. 30 Days
  final String instructions; // e.g. After Food
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isStopped;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    this.startDate,
    this.endDate,
    this.isStopped = false,
  });

  /// Normalize DateTime to midnight (calendar day boundary in local time)
  static DateTime _dateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Derived medication status computed reactively at calendar day boundaries
  MedicationStatus getStatus([DateTime? referenceDate]) {
    if (isStopped) return MedicationStatus.stopped;
    if (startDate == null && endDate == null) return MedicationStatus.active;

    final today = _dateOnly(referenceDate ?? DateTime.now());
    final start = startDate != null ? _dateOnly(startDate!) : null;
    final end = endDate != null ? _dateOnly(endDate!) : null;

    if (start != null && today.isBefore(start)) {
      return MedicationStatus.scheduled;
    }
    if (end != null && today.isAfter(end)) {
      return MedicationStatus.completed;
    }
    return MedicationStatus.active;
  }

  /// Exact day difference based on calendar day boundaries
  int get totalDays {
    if (startDate == null || endDate == null) {
      // Fallback parse from duration string if explicit dates not set
      final match = RegExp(r'(\d+)').firstMatch(duration);
      if (match != null) return int.tryParse(match.group(1)!) ?? 1;
      return 1;
    }
    final start = _dateOnly(startDate!);
    final end = _dateOnly(endDate!);
    return end.difference(start).inDays + 1;
  }

  /// Returns current day in course (e.g. 14 for "Day 14 of 30")
  int currentDay([DateTime? referenceDate]) {
    if (startDate == null) return 1;
    final today = _dateOnly(referenceDate ?? DateTime.now());
    final start = _dateOnly(startDate!);
    if (today.isBefore(start)) return 0;
    final diff = today.difference(start).inDays + 1;
    final total = totalDays;
    return diff > total ? total : diff;
  }

  /// Days remaining in course
  int daysRemaining([DateTime? referenceDate]) {
    if (endDate == null) return 0;
    final today = _dateOnly(referenceDate ?? DateTime.now());
    final end = _dateOnly(endDate!);
    if (today.isAfter(end)) return 0;
    return end.difference(today).inDays;
  }

  String progressLabel([DateTime? referenceDate]) {
    final status = getStatus(referenceDate);
    if (status == MedicationStatus.completed) {
      return 'Completed ($totalDays-day course)';
    }
    if (status == MedicationStatus.scheduled) {
      return 'Starts in ${startDate != null ? _dateOnly(startDate!).difference(_dateOnly(referenceDate ?? DateTime.now())).inDays : 0} days';
    }
    if (status == MedicationStatus.stopped) {
      return 'Discontinued by physician';
    }
    return 'Day ${currentDay(referenceDate)} of $totalDays';
  }

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
    DateTime? startDate,
    DateTime? endDate,
    bool? isStopped,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isStopped: isStopped ?? this.isStopped,
    );
  }
}

@immutable
class Prescription {
  final String id;
  final String consultationId;
  final String? encounterId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String department;
  final DateTime date;
  final List<Medication> medications;
  final String? generalAdvice;
  final String? doctorSignature;

  const Prescription({
    required this.id,
    required this.consultationId,
    this.encounterId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    this.department = 'Cardiology',
    required this.date,
    required this.medications,
    this.generalAdvice,
    this.doctorSignature,
  });

  /// Computed: Has at least one active medication
  bool hasActiveMedications([DateTime? referenceDate]) {
    return medications.any(
      (m) => m.getStatus(referenceDate) == MedicationStatus.active,
    );
  }

  /// Count of currently active medications
  int activeMedicationsCount([DateTime? referenceDate]) {
    return medications
        .where((m) => m.getStatus(referenceDate) == MedicationStatus.active)
        .length;
  }

  String statusLabel([DateTime? referenceDate]) {
    return hasActiveMedications(referenceDate) ? 'Active' : 'Completed';
  }

  Prescription copyWith({
    String? id,
    String? consultationId,
    String? encounterId,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? department,
    DateTime? date,
    List<Medication>? medications,
    String? generalAdvice,
    String? doctorSignature,
  }) {
    return Prescription(
      id: id ?? this.id,
      consultationId: consultationId ?? this.consultationId,
      encounterId: encounterId ?? this.encounterId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      department: department ?? this.department,
      date: date ?? this.date,
      medications: medications ?? this.medications,
      generalAdvice: generalAdvice ?? this.generalAdvice,
      doctorSignature: doctorSignature ?? this.doctorSignature,
    );
  }
}
