import 'patient.dart';
import 'prescription.dart';

class Consultation {
  final String id;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime date;
  final String chiefComplaint;
  final List<String> symptoms;
  final PatientVitals vitals;
  final String diagnosis;
  final String clinicalNotes;
  final List<Medication> prescribedMedications;
  final List<String> orderedLabTests;
  final DateTime? followUpDate;

  const Consultation({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.chiefComplaint,
    required this.symptoms,
    required this.vitals,
    required this.diagnosis,
    required this.clinicalNotes,
    required this.prescribedMedications,
    required this.orderedLabTests,
    this.followUpDate,
  });

  Consultation copyWith({
    String? id,
    String? appointmentId,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    DateTime? date,
    String? chiefComplaint,
    List<String>? symptoms,
    PatientVitals? vitals,
    String? diagnosis,
    String? clinicalNotes,
    List<Medication>? prescribedMedications,
    List<String>? orderedLabTests,
    DateTime? followUpDate,
  }) {
    return Consultation(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      date: date ?? this.date,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      symptoms: symptoms ?? this.symptoms,
      vitals: vitals ?? this.vitals,
      diagnosis: diagnosis ?? this.diagnosis,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      prescribedMedications:
          prescribedMedications ?? this.prescribedMedications,
      orderedLabTests: orderedLabTests ?? this.orderedLabTests,
      followUpDate: followUpDate ?? this.followUpDate,
    );
  }
}
