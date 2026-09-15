enum MedicalRecordType {
  consultation,
  prescription,
  labReport,
  radiology,
  dischargeSummary;

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
    }
  }
}

class MedicalRecord {
  final String id;
  final String patientId;
  final String title;
  final MedicalRecordType type;
  final DateTime date;
  final String doctorName;
  final String department;
  final String summary;
  final String? attachmentUrl;
  final List<String> tags;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    required this.title,
    required this.type,
    required this.date,
    required this.doctorName,
    required this.department,
    required this.summary,
    this.attachmentUrl,
    this.tags = const [],
  });
}
