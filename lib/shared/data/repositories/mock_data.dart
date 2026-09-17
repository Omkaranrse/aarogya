import '../../domain/models/appointment.dart';
import '../../domain/models/doctor.dart';
import '../../domain/models/encounter.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/lab_report.dart';
import '../../domain/models/medical_record.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/models/patient.dart';
import '../../domain/models/patient_session.dart';
import '../../domain/models/prescription.dart';
import '../../domain/models/queue_entry.dart';
import '../../domain/models/user.dart';

class AarogyaMockData {
  AarogyaMockData._();

  static final List<User> users = [
    const User(
      id: 'usr-patient-1',
      name: 'Omkar Anarse',
      email: 'omkar.anarse@aarogya.health',
      phone: '+91 98234 56789',
      role: UserRole.patient,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
    ),
    const User(
      id: 'usr-doc-1',
      name: 'Dr. Ananya Sharma',
      email: 'dr.ananya@aarogya.health',
      phone: '+91 98111 22334',
      role: UserRole.doctor,
      specialty: 'Cardiologist',
      department: 'Cardiology',
      avatarUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=200',
    ),
    const User(
      id: 'usr-admin-1',
      name: 'Vikram Malhotra',
      email: 'admin.malhotra@aarogya.health',
      phone: '+91 98450 11223',
      role: UserRole.admin,
      department: 'Hospital Administration',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200',
    ),
  ];

  static final PatientSession defaultSession = PatientSession(
    patientId: 'pat-1',
    patientName: 'Omkar Anarse',
    sessionStartedAt: DateTime(2026, 9, 1),
    nationalHealthId: 'ABHA-9482-1049-3829',
  );

  static final List<Doctor> doctors = [
    const Doctor(
      id: 'doc-1',
      name: 'Dr. Ananya Sharma',
      specialty: 'Cardiologist',
      qualifications: 'MBBS, MD, DM (Cardiology), FACC',
      experienceYears: 14,
      rating: 4.9,
      reviewsCount: 382,
      consultationFee: 1200,
      hospital: 'Aarogya Super Specialty Institute',
      bio:
          'Senior Consultant Interventional Cardiologist specializing in preventive cardiology, coronary angioplasty, and heart failure management with over 14 years of premier clinical excellence.',
      avatarUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      timeSlots: [
        '09:00 AM',
        '10:00 AM',
        '11:30 AM',
        '02:00 PM',
        '04:30 PM',
        '06:00 PM',
      ],
      isAvailableToday: true,
      departmentId: 'dept-cardio',
    ),
    const Doctor(
      id: 'doc-2',
      name: 'Dr. Rahul Mehta',
      specialty: 'Neurologist',
      qualifications: 'MBBS, MD, DM (Neurology)',
      experienceYears: 11,
      rating: 4.8,
      reviewsCount: 245,
      consultationFee: 1500,
      hospital: 'Aarogya Neurosciences Center',
      bio:
          'Renowned expert in epilepsy management, neuro-rehabilitation, migraine, and complex stroke interventions utilizing state-of-the-art diagnostic protocols.',
      avatarUrl:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
      availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
      timeSlots: ['10:00 AM', '11:00 AM', '03:00 PM', '05:00 PM'],
      isAvailableToday: true,
      departmentId: 'dept-neuro',
    ),
    const Doctor(
      id: 'doc-3',
      name: 'Dr. Priya Nambiar',
      specialty: 'Pediatrician',
      qualifications: 'MBBS, DCH, DNB (Pediatrics)',
      experienceYears: 9,
      rating: 4.95,
      reviewsCount: 420,
      consultationFee: 900,
      hospital: 'Aarogya Mother & Child Pavilion',
      bio:
          'Compassionate pediatric specialist focused on child growth tracking, neonatal care, pediatric asthma, and developmental milestones.',
      avatarUrl:
          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=300',
      availableDays: ['Mon', 'Tue', 'Thu', 'Fri', 'Sat'],
      timeSlots: ['09:30 AM', '11:00 AM', '01:30 PM', '04:00 PM'],
      isAvailableToday: true,
      departmentId: 'dept-pedia',
    ),
    const Doctor(
      id: 'doc-4',
      name: 'Dr. Siddharth Sen',
      specialty: 'Orthopedic Surgeon',
      qualifications: 'MBBS, MS (Ortho), M.Ch (Joint Replacement)',
      experienceYears: 16,
      rating: 4.75,
      reviewsCount: 310,
      consultationFee: 1400,
      hospital: 'Aarogya Orthopedics & Joint Clinic',
      bio:
          'Pioneer in minimally invasive arthroscopy, sports injuries, and robotic-assisted total knee and hip replacements.',
      avatarUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=300',
      availableDays: ['Tue', 'Thu', 'Sat'],
      timeSlots: ['08:30 AM', '10:30 AM', '02:30 PM', '05:30 PM'],
      isAvailableToday: false,
      departmentId: 'dept-ortho',
    ),
    const Doctor(
      id: 'doc-5',
      name: 'Dr. Sneha Kulkarni',
      specialty: 'Dermatologist',
      qualifications: 'MBBS, MD (Dermatology, Venereology & Leprosy)',
      experienceYears: 8,
      rating: 4.88,
      reviewsCount: 195,
      consultationFee: 1000,
      hospital: 'Aarogya Skin & Aesthetics Center',
      bio:
          'Specialist in clinical dermatology, autoimmune skin disorders, allergy patch testing, and advanced laser therapies.',
      avatarUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      timeSlots: ['11:00 AM', '12:30 PM', '03:30 PM', '06:00 PM'],
      isAvailableToday: true,
      departmentId: 'dept-derma',
    ),
  ];

  static final Patient defaultPatient = Patient(
    id: 'pat-1',
    name: 'Omkar Anarse',
    age: 26,
    gender: 'Male',
    bloodGroup: 'B+',
    phone: '+91 98234 56789',
    email: 'omkar.anarse@aarogya.health',
    allergies: ['Penicillin', 'Sulfa Drugs'],
    chronicConditions: ['Mild Asthma', 'Allergic Rhinitis'],
    vitals: PatientVitals(
      bloodPressure: '118/76',
      heartRate: 72,
      spo2: 99.0,
      temperature: 98.4,
      weight: 71.5,
      recordedAt: DateTime.now().subtract(const Duration(hours: 3)),
      source: VitalSource.triageCounter,
    ),
    emergencyContact: '+91 98234 11223 (Father)',
    avatarUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
    nationalHealthId: 'ABHA-9482-1049-3829',
  );

  static final List<Patient> samplePatients = [
    defaultPatient,
    Patient(
      id: 'pat-2',
      name: 'Meera Iyer',
      age: 42,
      gender: 'Female',
      bloodGroup: 'O+',
      phone: '+91 98123 45678',
      email: 'meera.iyer@example.com',
      allergies: ['Aspirin'],
      chronicConditions: ['Hypertension', 'Type 2 Diabetes'],
      vitals: PatientVitals(
        bloodPressure: '135/88',
        heartRate: 81,
        spo2: 98.0,
        temperature: 98.6,
        weight: 64.0,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        source: VitalSource.triageCounter,
      ),
      emergencyContact: '+91 98123 00001 (Spouse)',
      avatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200',
    ),
    Patient(
      id: 'pat-3',
      name: 'Rohan Deshmukh',
      age: 34,
      gender: 'Male',
      bloodGroup: 'A+',
      phone: '+91 98765 12345',
      email: 'rohan.d@example.com',
      allergies: ['None known'],
      chronicConditions: ['Migraine'],
      vitals: PatientVitals(
        bloodPressure: '122/80',
        heartRate: 74,
        spo2: 99.5,
        temperature: 98.2,
        weight: 78.0,
        recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
        source: VitalSource.homeDevice,
      ),
      emergencyContact: '+91 98765 00002 (Brother)',
      avatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200',
    ),
    Patient(
      id: 'pat-4',
      name: 'Sunita Nair',
      age: 58,
      gender: 'Female',
      bloodGroup: 'AB+',
      phone: '+91 98989 54321',
      email: 'sunita.nair@example.com',
      allergies: ['NSAIDs', 'Iodine Contrast'],
      chronicConditions: ['Osteoarthritis', 'Hyperlipidemia'],
      vitals: PatientVitals(
        bloodPressure: '142/90',
        heartRate: 86,
        spo2: 97.0,
        temperature: 99.1,
        weight: 68.2,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 20)),
        source: VitalSource.triageCounter,
      ),
      emergencyContact: '+91 98989 99999 (Daughter)',
      avatarUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200',
    ),
  ];

  static final List<Encounter> encounters = [
    Encounter(
      id: 'enc-1',
      patientId: 'pat-1',
      doctorId: 'doc-1',
      doctorName: 'Dr. Ananya Sharma',
      department: 'Cardiology',
      occurredAt: DateTime.now().subtract(const Duration(days: 14)),
      type: EncounterType.opdConsultation,
      summary: 'Initial Cardiology consultation for exertional chest tightness.',
    ),
    Encounter(
      id: 'enc-2',
      patientId: 'pat-1',
      doctorId: 'doc-1',
      doctorName: 'Dr. Ananya Sharma',
      department: 'Central Laboratory',
      occurredAt: DateTime.now().subtract(const Duration(days: 2)),
      type: EncounterType.diagnosticVisit,
      summary: '12-hour Fasting Comprehensive Lipid Profile sample collection.',
    ),
    Encounter(
      id: 'enc-3',
      patientId: 'pat-1',
      doctorId: 'doc-3',
      doctorName: 'Dr. Priya Nambiar',
      department: 'Pediatrics & Adolescent Medicine',
      occurredAt: DateTime.now().subtract(const Duration(days: 14)),
      type: EncounterType.opdConsultation,
      summary: 'Routine respiratory & allergy review with CBC diagnostic panel.',
    ),
    Encounter(
      id: 'enc-4',
      patientId: 'pat-1',
      doctorId: 'doc-1',
      doctorName: 'Dr. Ananya Sharma',
      department: 'Cardiology',
      occurredAt: DateTime.now().add(const Duration(hours: 2)),
      type: EncounterType.opdConsultation,
      summary: 'Cardiology follow-up & lipid panel review.',
    ),
  ];

  static final List<Appointment> appointments = [
    Appointment(
      id: 'apt-101',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      encounterId: 'enc-4',
      doctorId: 'doc-1',
      doctorName: 'Dr. Ananya Sharma',
      specialty: 'Cardiologist',
      doctorAvatar:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      timeSlot: '02:00 PM',
      type: ConsultationType.inPerson,
      status: AppointmentStatus.confirmed,
      tokenNumber: 8,
      feePaise: 120000,
      symptoms: 'Chest discomfort, morning fatigue',
      notes: 'Please bring latest ECG and lipid panel reports.',
    ),
    Appointment(
      id: 'apt-102',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      doctorId: 'doc-2',
      doctorName: 'Dr. Rahul Mehta',
      specialty: 'Neurologist',
      doctorAvatar:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 4)),
      timeSlot: '11:00 AM',
      type: ConsultationType.videoCall,
      status: AppointmentStatus.upcoming,
      tokenNumber: 14,
      feePaise: 150000,
      symptoms: 'Occasional throbbing headache on right temple.',
    ),
    Appointment(
      id: 'apt-103',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      encounterId: 'enc-3',
      doctorId: 'doc-3',
      doctorName: 'Dr. Priya Nambiar',
      specialty: 'Pediatrician',
      doctorAvatar:
          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=300',
      dateTime: DateTime.now().subtract(const Duration(days: 14)),
      timeSlot: '10:00 AM',
      type: ConsultationType.inPerson,
      status: AppointmentStatus.completed,
      tokenNumber: 4,
      feePaise: 90000,
      symptoms: 'Seasonal allergic cough checkup.',
    ),
  ];

  static final List<QueueEntry> liveQueue = [
    QueueEntry(
      id: 'q-1',
      tokenNumber: 7,
      appointmentId: 'apt-099',
      patientId: 'pat-2',
      patientName: 'Meera Iyer',
      age: 42,
      gender: 'Female',
      doctorId: 'doc-1',
      checkInTime: DateTime.now().subtract(const Duration(minutes: 25)),
      estimatedWaitMinutes: 0,
      status: QueueStatus.consulting,
      priority: PatientPriority.normal,
      chiefComplaint:
          'Post-medication blood pressure check & dizziness review.',
      ewsScore: 1,
      ewsCategory: 'Low Risk (NEWS2: 1)',
      vitals: PatientVitals(
        bloodPressure: '122/80',
        heartRate: 74,
        spo2: 97.5,
        temperature: 98.4,
        weight: 62.0,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        respiratoryRate: 16,
        source: VitalSource.triageCounter,
      ),
    ),
    QueueEntry(
      id: 'q-3',
      tokenNumber: 9,
      appointmentId: 'apt-104',
      patientId: 'pat-4',
      patientName: 'Sunita Nair',
      age: 58,
      gender: 'Female',
      doctorId: 'doc-1',
      checkInTime: DateTime.now().subtract(const Duration(minutes: 5)),
      estimatedWaitMinutes: 5,
      status: QueueStatus.waiting,
      priority: PatientPriority.urgent,
      chiefComplaint:
          'Elevated BP reading (155/95) with palpitation sensation.',
      ewsScore: 4,
      ewsCategory: 'Medium Risk (NEWS2: 4)',
      vitals: PatientVitals(
        bloodPressure: '155/95',
        heartRate: 114,
        spo2: 93.5,
        temperature: 99.2,
        weight: 68.5,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        respiratoryRate: 22,
        source: VitalSource.triageCounter,
      ),
    ),
    QueueEntry(
      id: 'q-2',
      tokenNumber: 8,
      appointmentId: 'apt-101',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      age: 26,
      gender: 'Male',
      doctorId: 'doc-1',
      checkInTime: DateTime.now().subtract(const Duration(minutes: 10)),
      estimatedWaitMinutes: 18,
      status: QueueStatus.waiting,
      priority: PatientPriority.normal,
      chiefComplaint: 'Exertional chest discomfort and fatigue.',
      ewsScore: 0,
      ewsCategory: 'Low Risk (NEWS2: 0)',
      vitals: PatientVitals(
        bloodPressure: '118/76',
        heartRate: 72,
        spo2: 99.0,
        temperature: 98.4,
        weight: 71.5,
        recordedAt: DateTime.now().subtract(const Duration(hours: 3)),
        respiratoryRate: 16,
        source: VitalSource.triageCounter,
      ),
    ),
    QueueEntry(
      id: 'q-4',
      tokenNumber: 10,
      appointmentId: 'apt-105',
      patientId: 'pat-3',
      patientName: 'Rohan Deshmukh',
      age: 34,
      gender: 'Male',
      doctorId: 'doc-1',
      checkInTime: DateTime.now(),
      estimatedWaitMinutes: 30,
      status: QueueStatus.waiting,
      priority: PatientPriority.normal,
      chiefComplaint:
          'Routine cardiac risk evaluation & lipid profile consult.',
      ewsScore: 0,
      ewsCategory: 'Low Risk (NEWS2: 0)',
      vitals: PatientVitals(
        bloodPressure: '118/76',
        heartRate: 68,
        spo2: 99.0,
        temperature: 98.2,
        weight: 74.0,
        recordedAt: DateTime.now(),
        respiratoryRate: 15,
        source: VitalSource.homeDevice,
      ),
    ),
  ];

  static final List<Prescription> samplePrescriptions = [
    Prescription(
      id: 'rx-201',
      consultationId: 'c-101',
      encounterId: 'enc-1',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      doctorId: 'doc-1',
      doctorName: 'Dr. Ananya Sharma',
      doctorSpecialty: 'Cardiology',
      department: 'Cardiology',
      date: DateTime.now().subtract(const Duration(days: 14)),
      medications: [
        Medication(
          id: 'm-1',
          name: 'Atorvastatin',
          dosage: '10 mg',
          frequency: '0-0-1',
          duration: '30 Days',
          instructions: 'After Dinner',
          startDate: DateTime.now().subtract(const Duration(days: 14)),
          endDate: DateTime.now().add(const Duration(days: 15)),
        ),
        Medication(
          id: 'm-2',
          name: 'Metoprolol Succinate',
          dosage: '25 mg',
          frequency: '1-0-0',
          duration: '30 Days',
          instructions: 'After Breakfast',
          startDate: DateTime.now().subtract(const Duration(days: 14)),
          endDate: DateTime.now().add(const Duration(days: 15)),
        ),
        Medication(
          id: 'm-3',
          name: 'Montelukast Sodium',
          dosage: '10 mg',
          frequency: '0-0-1',
          duration: '10 Days',
          instructions: 'Before Bedtime',
          startDate: DateTime.now().subtract(const Duration(days: 14)),
          endDate: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ],
      generalAdvice:
          'Reduce dietary sodium to <2g/day. 30 minutes light aerobic brisk walk daily. Avoid unconditioned sprints.',
      doctorSignature: 'Dr. Ananya Sharma (Reg. #KMC-48291)',
    ),
  ];

  static final List<LabReport> sampleLabReports = [
    LabReport(
      id: 'lab-301',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      encounterId: 'enc-2',
      testName: 'Comprehensive Lipid Profile',
      category: 'Biochemistry',
      orderedByDoctor: 'Dr. Ananya Sharma',
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      completedDate: DateTime.now().subtract(const Duration(days: 2)),
      status: ReportStatus.completed,
      items: const [
        LabTestItem(
          testName: 'Total Cholesterol',
          value: 215.0,
          unit: 'mg/dL',
          minRange: 125.0,
          maxRange: 200.0,
          status: LabResultStatus.high,
        ),
        LabTestItem(
          testName: 'HDL (Good Cholesterol)',
          value: 48.0,
          unit: 'mg/dL',
          minRange: 40.0,
          maxRange: 60.0,
          status: LabResultStatus.normal,
        ),
        LabTestItem(
          testName: 'LDL (Calculated)',
          value: 138.0,
          unit: 'mg/dL',
          minRange: 0.0,
          maxRange: 100.0,
          status: LabResultStatus.high,
        ),
        LabTestItem(
          testName: 'Triglycerides',
          value: 145.0,
          unit: 'mg/dL',
          minRange: 50.0,
          maxRange: 150.0,
          status: LabResultStatus.normal,
        ),
      ],
      labTechnicianNotes:
          'Serum mildly lipemic. Specimen drawn after 12-hour overnight fasting.',
    ),
    LabReport(
      id: 'lab-302',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      encounterId: 'enc-3',
      testName: 'Complete Blood Count (CBC) with ESR',
      category: 'Hematology',
      orderedByDoctor: 'Dr. Priya Nambiar',
      orderDate: DateTime.now().subtract(const Duration(days: 14)),
      completedDate: DateTime.now().subtract(const Duration(days: 13)),
      status: ReportStatus.completed,
      items: const [
        LabTestItem(
          testName: 'Hemoglobin',
          value: 15.2,
          unit: 'g/dL',
          minRange: 13.5,
          maxRange: 17.5,
          status: LabResultStatus.normal,
        ),
        LabTestItem(
          testName: 'Total WBC Count',
          value: 6800.0,
          unit: '/cumm',
          minRange: 4000.0,
          maxRange: 11000.0,
          status: LabResultStatus.normal,
        ),
        LabTestItem(
          testName: 'Platelet Count',
          value: 240000.0,
          unit: '/cumm',
          minRange: 150000.0,
          maxRange: 450000.0,
          status: LabResultStatus.normal,
        ),
        LabTestItem(
          testName: 'Erythrocyte Sedimentation Rate (ESR)',
          value: 12.0,
          unit: 'mm/hr',
          minRange: 0.0,
          maxRange: 15.0,
          status: LabResultStatus.normal,
        ),
      ],
    ),
  ];

  static final List<MedicalRecord> medicalRecords = [
    MedicalRecord(
      id: 'rec-1',
      patientId: 'pat-1',
      encounterId: 'enc-1',
      title: 'Cardiology Initial Assessment',
      type: MedicalRecordType.consultation,
      occurredAt: DateTime.now().subtract(const Duration(days: 14)),
      doctorName: 'Dr. Ananya Sharma',
      department: 'Cardiology',
      summary:
          'Patient presented with occasional exertional chest tightness. Vitals normal. Advised resting 12-lead ECG, Echo, and Fasting Lipid Profile.',
      tags: ['Cardiology', 'OPD Visit', 'ECG Advised'],
    ),
    MedicalRecord(
      id: 'rec-adv-1',
      patientId: 'pat-1',
      encounterId: 'enc-1',
      title: 'Advised Echocardiogram (2D Echo) — Result Pending',
      type: MedicalRecordType.advisedDiagnostic,
      occurredAt: DateTime.now().subtract(const Duration(days: 14)),
      doctorName: 'Dr. Ananya Sharma',
      department: 'Cardiology Non-Invasive Lab',
      summary:
          '2D Doppler Transthoracic Echocardiogram recommended to assess left ventricular wall motion and ejection fraction.',
      tags: ['Echo', 'Diagnostic Order', 'Pending'],
      isAdvisedPending: true,
    ),
    MedicalRecord(
      id: 'rec-2',
      patientId: 'pat-1',
      encounterId: 'enc-2',
      title: 'Fasting Lipid Profile Report',
      type: MedicalRecordType.labReport,
      occurredAt: DateTime.now().subtract(const Duration(days: 2)),
      doctorName: 'Dr. Ananya Sharma',
      department: 'Central Laboratory',
      summary:
          'Total Cholesterol 215 mg/dL (High), LDL 138 mg/dL (High). Triglycerides and HDL within optimal ranges.',
      tags: ['Biochemistry', 'Lipids', 'Fasting'],
    ),
    MedicalRecord(
      id: 'rec-3',
      patientId: 'pat-1',
      encounterId: 'enc-1',
      title: 'Digital Prescription #RX-201',
      type: MedicalRecordType.prescription,
      occurredAt: DateTime.now().subtract(const Duration(days: 14)),
      doctorName: 'Dr. Ananya Sharma',
      department: 'Cardiology',
      summary:
          'Prescribed Atorvastatin 10mg & Metoprolol 25mg for cardiovascular protection and rate regulation.',
      tags: ['Medication', 'Statin', 'Active Rx'],
    ),
  ];

  static final List<Invoice> invoices = [
    Invoice(
      id: 'inv-401',
      invoiceNumber: 'INV-2026-0891',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      encounterId: 'enc-4',
      appointmentId: 'apt-101',
      date: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      items: const [
        InvoiceLineItem(
          description:
              'Specialist Cardiology Consultation - Dr. Ananya Sharma',
          unitPricePaise: 120000,
          totalPaise: 120000,
        ),
        InvoiceLineItem(
          description: 'Hospital Facility & Digital Records Fee',
          unitPricePaise: 15000,
          totalPaise: 15000,
        ),
      ],
      subtotalPaise: 135000,
      discountPaise: 0,
      taxes: const [
        InvoiceTaxItem(label: 'GST (5%)', ratePercent: 5.0, amountPaise: 6750),
      ],
      roundingPaise: 0,
      totalPaise: 141750, // 135000 - 0 + 6750 = 141750 (₹1,417.50)
      amountPaidPaise: 0,
      balanceDuePaise: 141750,
      gstin: '27AARCG0001Z5Z1',
      status: InvoiceStatus.pending,
    ),
    Invoice(
      id: 'inv-402',
      invoiceNumber: 'INV-2026-0742',
      patientId: 'pat-1',
      patientName: 'Omkar Anarse',
      encounterId: 'enc-3',
      appointmentId: 'apt-103',
      date: DateTime.now().subtract(const Duration(days: 14)),
      dueDate: DateTime.now().subtract(const Duration(days: 7)),
      items: const [
        InvoiceLineItem(
          description: 'Pediatric OPD Consultation',
          unitPricePaise: 90000,
          totalPaise: 90000,
        ),
        InvoiceLineItem(
          description: 'Automated CBC Panel + ESR Test',
          unitPricePaise: 65000,
          totalPaise: 65000,
        ),
      ],
      subtotalPaise: 155000,
      discountPaise: 10000,
      taxes: const [
        InvoiceTaxItem(label: 'GST (5%)', ratePercent: 5.0, amountPaise: 7250),
      ],
      roundingPaise: 0,
      totalPaise: 152250, // 155000 - 10000 + 7250 = 152250 (₹1,522.50)
      amountPaidPaise: 152250,
      balanceDuePaise: 0,
      gstin: '27AARCG0001Z5Z1',
      status: InvoiceStatus.paid,
      paymentMethod: 'UPI • Axis Bank (txn_948291)',
      paidAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  static final List<NotificationItem> notifications = [
    NotificationItem(
      id: 'notif-1',
      title: 'Appointment Confirmed',
      message:
          'Your consultation with Dr. Ananya Sharma is scheduled today at 02:00 PM. Token #08.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      category: NotificationCategory.appointment,
      isRead: false,
    ),
    NotificationItem(
      id: 'notif-2',
      title: 'Lab Report Ready for Review',
      message:
          'Your Comprehensive Lipid Profile report has been verified by the chief pathologist.',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
      category: NotificationCategory.laboratory,
      isRead: true,
    ),
    NotificationItem(
      id: 'notif-3',
      title: 'Medication Refill Reminder',
      message:
          'Your 30-day course of Atorvastatin is halfway complete. Schedule your follow-up checkup.',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      category: NotificationCategory.clinical,
      isRead: true,
    ),
  ];
}
