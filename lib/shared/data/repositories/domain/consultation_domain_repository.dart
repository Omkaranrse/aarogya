import '../../../domain/models/consultation.dart';
import '../../../domain/models/medical_record.dart';
import '../../../domain/models/patient.dart';
import '../../../domain/models/prescription.dart';
import '../mock_data.dart';

/// Domain Repository for managing clinical consultations, encounter signing,
/// prescriptions, and digital electronic health records (EHR).
class ConsultationDomainRepository {
  final List<Consultation> _consultations = [];
  List<Prescription> _prescriptions = [];
  List<MedicalRecord> _medicalRecords = [];

  ConsultationDomainRepository() {
    _prescriptions = List.from(AarogyaMockData.samplePrescriptions);
    _medicalRecords = List.from(AarogyaMockData.medicalRecords);
  }

  List<Consultation> get consultations => List.unmodifiable(_consultations);
  List<Prescription> get prescriptions => List.unmodifiable(_prescriptions);
  List<MedicalRecord> get medicalRecords => List.unmodifiable(_medicalRecords);

  Future<List<Prescription>> fetchPrescriptions() async => List.unmodifiable(_prescriptions);
  Future<List<MedicalRecord>> fetchMedicalRecords() async => List.unmodifiable(_medicalRecords);

  Consultation completeConsultation({
    required String appointmentId,
    required Patient patient,
    required String doctorId,
    required String doctorName,
    required String chiefComplaint,
    required List<String> symptoms,
    required PatientVitals vitals,
    required String diagnosis,
    required String clinicalNotes,
    required List<Medication> medications,
    required List<String> orderedLabTests,
    DateTime? followUpDate,
  }) {
    final consultationId = 'c-${DateTime.now().millisecondsSinceEpoch}';
    final consultation = Consultation(
      id: consultationId,
      appointmentId: appointmentId,
      patientId: patient.id,
      patientName: patient.name,
      doctorId: doctorId,
      doctorName: doctorName,
      date: DateTime.now(),
      chiefComplaint: chiefComplaint,
      symptoms: symptoms,
      vitals: vitals,
      diagnosis: diagnosis,
      clinicalNotes: clinicalNotes,
      prescribedMedications: medications,
      orderedLabTests: orderedLabTests,
      followUpDate: followUpDate,
    );

    _consultations.insert(0, consultation);

    if (medications.isNotEmpty) {
      final prescription = Prescription(
        id: 'rx-${DateTime.now().millisecondsSinceEpoch}',
        consultationId: consultationId,
        patientId: patient.id,
        patientName: patient.name,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: 'Cardiology',
        date: DateTime.now(),
        medications: medications,
        generalAdvice: clinicalNotes,
      );
      _prescriptions.insert(0, prescription);
    }

    _medicalRecords.insert(
      0,
      MedicalRecord(
        id: 'mr-${DateTime.now().millisecondsSinceEpoch}',
        patientId: patient.id,
        occurredAt: DateTime.now(),
        type: MedicalRecordType.consultation,
        title: 'Consultation - $diagnosis',
        doctorName: doctorName,
        department: 'Cardiology',
        summary: '$chiefComplaint. Diagnosis: $diagnosis.',
      ),
    );

    return consultation;
  }
}
