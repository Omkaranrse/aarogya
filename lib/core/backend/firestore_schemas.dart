/// Standardized Firestore collection paths and data contracts for Aarogya Hospital Management System.
class FirestoreCollections {
  static const String users = 'users';
  static const String patients = 'patients';
  static const String doctors = 'doctors';
  static const String appointments = 'appointments';
  static const String liveQueue = 'live_queue';
  static const String prescriptions = 'prescriptions';
  static const String labReports = 'lab_reports';
  static const String medicalRecords = 'medical_records';
  static const String invoices = 'invoices';
  static const String hospitalBeds = 'hospital_beds';
  static const String notifications = 'notifications';
  static const String departments = 'departments';
}

/// Firebase Clinical Schema Field Keys
class FirestoreFields {
  // Common & User Profile
  static const String id = 'id';
  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String role = 'role';
  static const String avatarUrl = 'avatar_url';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String status = 'status';

  // Patient
  static const String patientName = 'patient_name';
  static const String abhaNumber = 'abha_number';
  static const String abhaAddress = 'abha_address';
  static const String age = 'age';
  static const String gender = 'gender';
  static const String bloodGroup = 'blood_group';
  static const String allergies = 'allergies';
  static const String chronicConditions = 'chronic_conditions';
  static const String emergencyContact = 'emergency_contact';
  static const String vitals = 'vitals';

  // Appointments & Queue
  static const String doctorId = 'doctor_id';
  static const String doctorName = 'doctor_name';
  static const String tokenNumber = 'token_number';
  static const String dateTime = 'date_time';
  static const String timeSlot = 'time_slot';
  static const String consultationType = 'consultation_type';
  static const String fee = 'fee';
  static const String queueStatus = 'queue_status';
  static const String estimatedWaitMins = 'estimated_wait_mins';

  // Prescriptions
  static const String medications = 'medications';
  static const String diagnosis = 'diagnosis';
  static const String generalAdvice = 'general_advice';
  static const String doctorSignature = 'doctor_signature';

  // Hospital Bed
  static const String bedNumber = 'bed_number';
  static const String ward = 'ward';
  static const String bedStatus = 'bed_status';
  static const String admittedPatientId = 'admitted_patient_id';
}

/// Generic mapper helper for Firestore document conversions
abstract class FirestoreSerializable<T> {
  Map<String, dynamic> toFirestore();
}
