class Medication {
  final String id;
  final String name;
  final String dosage; // e.g. 500mg
  final String frequency; // e.g. 1-0-1 (Morning & Night)
  final String duration; // e.g. 5 Days
  final String instructions; // e.g. After Food

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }
}

class Prescription {
  final String id;
  final String consultationId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime date;
  final List<Medication> medications;
  final String? generalAdvice;
  final String? doctorSignature;

  const Prescription({
    required this.id,
    required this.consultationId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    required this.medications,
    this.generalAdvice,
    this.doctorSignature,
  });

  Prescription copyWith({
    String? id,
    String? consultationId,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    DateTime? date,
    List<Medication>? medications,
    String? generalAdvice,
    String? doctorSignature,
  }) {
    return Prescription(
      id: id ?? this.id,
      consultationId: consultationId ?? this.consultationId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      date: date ?? this.date,
      medications: medications ?? this.medications,
      generalAdvice: generalAdvice ?? this.generalAdvice,
      doctorSignature: doctorSignature ?? this.doctorSignature,
    );
  }
}
