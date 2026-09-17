import 'package:flutter/foundation.dart';

import '../../domain/models/appointment.dart';
import '../../domain/models/consultation.dart';
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
import '../../../core/backend/firebase_clinical_service.dart';
import 'mock_data.dart';
import 'domain/queue_domain_repository.dart';
import 'domain/appointment_domain_repository.dart';
import 'domain/lab_domain_repository.dart';
import 'domain/consultation_domain_repository.dart';
import 'domain/billing_domain_repository.dart';

class AarogyaRepository extends ChangeNotifier {
  static final AarogyaRepository _instance = AarogyaRepository._internal();
  factory AarogyaRepository() => _instance;

  AarogyaRepository._internal() {
    _initData();
  }

  // Modular Domain Repositories
  final QueueDomainRepository queueDomainRepo = QueueDomainRepository();
  late final AppointmentDomainRepository appointmentDomainRepo =
      AppointmentDomainRepository(queueDomainRepo);
  final LabDomainRepository labDomainRepo = LabDomainRepository();
  final ConsultationDomainRepository consultationDomainRepo =
      ConsultationDomainRepository();
  final BillingDomainRepository billingDomainRepo = BillingDomainRepository();

  // Active Session State
  late User _currentUser;
  late UserRole _activeRole;
  late PatientSession _patientSession;

  // Data Collections
  List<Doctor> _doctors = [];
  List<Patient> _patients = [];
  List<Encounter> _encounters = [];
  List<Appointment> _appointments = [];
  List<QueueEntry> _queue = [];
  final List<Consultation> _consultations = [];
  List<Prescription> _prescriptions = [];
  List<LabReport> _labReports = [];
  List<MedicalRecord> _medicalRecords = [];
  List<Invoice> _invoices = [];
  List<NotificationItem> _notifications = [];

  void _initData() {
    _currentUser = AarogyaMockData.users.first;
    _activeRole = UserRole.patient;
    _patientSession = AarogyaMockData.defaultSession;

    _doctors = List.from(AarogyaMockData.doctors);
    _patients = List.from(AarogyaMockData.samplePatients);
    _encounters = List.from(AarogyaMockData.encounters);
    _appointments = List.from(AarogyaMockData.appointments);
    _queue = List.from(AarogyaMockData.liveQueue);
    _sortQueue();
    _prescriptions = List.from(AarogyaMockData.samplePrescriptions);
    _labReports = List.from(AarogyaMockData.sampleLabReports);
    _medicalRecords = List.from(AarogyaMockData.medicalRecords);
    _invoices = List.from(AarogyaMockData.invoices);
    _notifications = List.from(AarogyaMockData.notifications);

    // Real-time Cloud Firestore Queue Synchronization
    FirebaseClinicalService().liveQueueStream.listen((cloudQueue) {
      if (cloudQueue.isNotEmpty) {
        _queue = List.from(cloudQueue);
        _sortQueue();
        notifyListeners();
      }
    });

    // Real-time Cloud Firestore Appointments Synchronization
    FirebaseClinicalService().liveAppointmentsStream.listen((cloudAppointments) {
      if (cloudAppointments.isNotEmpty) {
        _appointments = List.from(cloudAppointments);
        notifyListeners();
      }
    });

    // Real-time Cloud Firestore Prescriptions Synchronization
    FirebaseClinicalService().livePrescriptionsStream.listen((cloudPrescriptions) {
      if (cloudPrescriptions.isNotEmpty) {
        _prescriptions = List.from(cloudPrescriptions);
        notifyListeners();
      }
    });

    // Real-time Cloud Firestore Lab Reports Synchronization
    FirebaseClinicalService().liveLabReportsStream.listen((cloudLabReports) {
      if (cloudLabReports.isNotEmpty) {
        _labReports = List.from(cloudLabReports);
        notifyListeners();
      }
    });

    // Real-time Cloud Firestore Invoices Synchronization
    FirebaseClinicalService().liveInvoicesStream.listen((cloudInvoices) {
      if (cloudInvoices.isNotEmpty) {
        _invoices = List.from(cloudInvoices);
        notifyListeners();
      }
    });

    // Real-time Cloud Firestore Medical Records Synchronization
    FirebaseClinicalService().liveMedicalRecordsStream.listen((cloudRecords) {
      if (cloudRecords.isNotEmpty) {
        _medicalRecords = List.from(cloudRecords);
        notifyListeners();
      }
    });
  }

  // Security Guard: asserts record patientId matches active patient session
  void _guardPatientId(String recordPatientId, String recordType, String recordId) {
    if (_activeRole == UserRole.patient && recordPatientId != _patientSession.patientId) {
      debugPrint(
        'SECURITY ALERT: PatientMismatchException on $recordType ($recordId). '
        'Expected: ${_patientSession.patientId}, Actual: $recordPatientId',
      );
      throw PatientMismatchException(
        expectedPatientId: _patientSession.patientId,
        actualPatientId: recordPatientId,
        recordType: recordType,
        recordId: recordId,
      );
    }
  }

  // Getters
  User get currentUser => _currentUser;
  UserRole get activeRole => _activeRole;
  PatientSession get patientSession => _patientSession;
  List<Doctor> get doctors => List.unmodifiable(_doctors);
  List<Patient> get patients => List.unmodifiable(_patients);
  List<Encounter> get encounters => List.unmodifiable(_encounters);

  List<Appointment> get appointments {
    if (_activeRole == UserRole.patient) {
      for (final a in _appointments) {
        _guardPatientId(a.patientId, 'Appointment', a.id);
      }
    }
    return List.unmodifiable(_appointments);
  }

  List<QueueEntry> get queue => List.unmodifiable(_queue);
  List<Consultation> get consultations => List.unmodifiable(_consultations);

  List<Prescription> get prescriptions {
    if (_activeRole == UserRole.patient) {
      for (final rx in _prescriptions) {
        _guardPatientId(rx.patientId, 'Prescription', rx.id);
      }
    }
    return List.unmodifiable(_prescriptions);
  }

  List<LabReport> get labReports {
    if (_activeRole == UserRole.patient) {
      for (final lr in _labReports) {
        _guardPatientId(lr.patientId, 'LabReport', lr.id);
      }
    }
    return List.unmodifiable(_labReports);
  }

  List<MedicalRecord> get medicalRecords {
    if (_activeRole == UserRole.patient) {
      for (final mr in _medicalRecords) {
        _guardPatientId(mr.patientId, 'MedicalRecord', mr.id);
      }
    }
    final sorted = List<MedicalRecord>.from(_medicalRecords);
    sorted.sort((a, b) => MedicalRecord.compareEvents(a, b, descending: true));
    return List.unmodifiable(sorted);
  }

  List<Invoice> get invoices {
    if (_activeRole == UserRole.patient) {
      for (final inv in _invoices) {
        _guardPatientId(inv.patientId, 'Invoice', inv.id);
      }
    }
    return List.unmodifiable(_invoices);
  }

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  // Exact Integer Paise Financial Summaries
  int get totalPendingDuesPaise => _invoices
      .where((i) => i.status == InvoiceStatus.pending)
      .fold<int>(0, (sum, i) => sum + i.balanceDuePaise);

  int get totalSettledPaise => _invoices
      .where((i) => i.status == InvoiceStatus.paid)
      .fold<int>(0, (sum, i) => sum + i.amountPaidPaise);

  double get totalPendingDues => totalPendingDuesPaise / 100.0;
  double get totalSettled => totalSettledPaise / 100.0;

  // Active Prescriptions Derived Count
  int get activePrescriptionsCount => _prescriptions
      .where((p) => p.hasActiveMedications())
      .length;

  // Role & Session Switching
  void switchRole(UserRole newRole) {
    _activeRole = newRole;
    switch (newRole) {
      case UserRole.patient:
        _currentUser = AarogyaMockData.users[0];
        _patientSession = AarogyaMockData.defaultSession;
        break;
      case UserRole.doctor:
        _currentUser = AarogyaMockData.users[1];
        break;
      case UserRole.admin:
        _currentUser = AarogyaMockData.users[2];
        break;
      default:
        _currentUser = AarogyaMockData.users[0].copyWith(role: newRole);
    }
    notifyListeners();
  }

  void setPatientSession(PatientSession session) {
    _patientSession = session;
    notifyListeners();
  }

  void setCurrentUser(User user) {
    _currentUser = user;
    _activeRole = user.role;
    notifyListeners();
  }

  // Appointment Actions
  Appointment bookAppointment({
    required Doctor doctor,
    required DateTime date,
    required String timeSlot,
    required ConsultationType type,
    String? symptoms,
    String? notes,
  }) {
    final token = _appointments.length + 1;
    final aptId =
        'apt-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final encId =
        'enc-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final feePaise = (doctor.consultationFee * 100).round();

    final appointment = Appointment(
      id: aptId,
      patientId: _patientSession.patientId,
      patientName: _patientSession.patientName,
      encounterId: encId,
      doctorId: doctor.id,
      doctorName: doctor.name,
      specialty: doctor.specialty,
      doctorAvatar: doctor.avatarUrl,
      dateTime: date,
      timeSlot: timeSlot,
      type: type,
      status: AppointmentStatus.confirmed,
      tokenNumber: token,
      feePaise: feePaise,
      symptoms: symptoms,
      notes: notes,
    );

    _appointments.insert(0, appointment);
    FirebaseClinicalService().syncAppointment(appointment);

    // Create encounter record
    final encounter = Encounter(
      id: encId,
      patientId: _patientSession.patientId,
      doctorId: doctor.id,
      doctorName: doctor.name,
      department: doctor.specialty,
      occurredAt: date,
      type: type == ConsultationType.inPerson
          ? EncounterType.opdConsultation
          : EncounterType.teleConsultation,
      summary: 'Appointment booked with ${doctor.name}. Symptoms: ${symptoms ?? 'General checkup'}.',
    );
    _encounters.insert(0, encounter);

    // Create matching invoice in exact integer paise
    final invId =
        'inv-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final taxPaise = (feePaise * 0.05).round();
    final totalPaise = feePaise + taxPaise;

    final invoice = Invoice(
      id: invId,
      invoiceNumber:
          'INV-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      patientId: _patientSession.patientId,
      patientName: _patientSession.patientName,
      encounterId: encId,
      appointmentId: aptId,
      date: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 3)),
      items: [
        InvoiceLineItem(
          description: '${doctor.specialty} Consultation - ${doctor.name}',
          unitPricePaise: feePaise,
          totalPaise: feePaise,
        ),
      ],
      subtotalPaise: feePaise,
      discountPaise: 0,
      taxes: [
        InvoiceTaxItem(label: 'GST (5%)', ratePercent: 5.0, amountPaise: taxPaise),
      ],
      roundingPaise: 0,
      totalPaise: totalPaise,
      amountPaidPaise: 0,
      balanceDuePaise: totalPaise,
      gstin: '27AARCG0001Z5Z1',
      status: InvoiceStatus.pending,
    );
    _invoices.insert(0, invoice);
    FirebaseClinicalService().syncInvoice(invoice);

    // Notification
    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Appointment Booked',
        message:
            'Your visit with ${doctor.name} on ${date.day}/${date.month} at $timeSlot is confirmed.',
        timestamp: DateTime.now(),
        category: NotificationCategory.appointment,
      ),
    );

    notifyListeners();
    return appointment;
  }

  void cancelAppointment(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      FirebaseClinicalService().syncAppointment(_appointments[index]);
      notifyListeners();
    }
  }

  void rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTimeSlot,
  }) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final oldApt = _appointments[index];
      _appointments[index] = oldApt.copyWith(
        dateTime: newDate,
        timeSlot: newTimeSlot,
        status: AppointmentStatus.confirmed,
      );
      FirebaseClinicalService().syncAppointment(_appointments[index]);

      _notifications.insert(
        0,
        NotificationItem(
          id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Appointment Rescheduled',
          message:
              'Consultation with ${oldApt.doctorName} rescheduled to ${newDate.day}/${newDate.month} at $newTimeSlot.',
          timestamp: DateTime.now(),
          category: NotificationCategory.appointment,
        ),
      );

      notifyListeners();
    }
  }

  // Clinical Queue Prioritization
  void _sortQueue() {
    _queue.sort((a, b) {
      if (a.status == QueueStatus.consulting && b.status != QueueStatus.consulting) return -1;
      if (b.status == QueueStatus.consulting && a.status != QueueStatus.consulting) return 1;

      if (a.status == QueueStatus.waiting && b.status != QueueStatus.waiting) return -1;
      if (b.status == QueueStatus.waiting && a.status != QueueStatus.waiting) return 1;

      if (a.status == QueueStatus.waiting && b.status == QueueStatus.waiting) {
        final priorityRank = {
          PatientPriority.emergency: 0,
          PatientPriority.urgent: 1,
          PatientPriority.normal: 2,
        };
        final rankA = priorityRank[a.priority] ?? 2;
        final rankB = priorityRank[b.priority] ?? 2;
        if (rankA != rankB) {
          return rankA.compareTo(rankB);
        }
      }

      return a.tokenNumber.compareTo(b.tokenNumber);
    });
  }

  // Queue Actions
  void updateQueueStatus(String queueId, QueueStatus newStatus) {
    final index = _queue.indexWhere((q) => q.id == queueId);
    if (index != -1) {
      if (newStatus == QueueStatus.consulting) {
        for (int i = 0; i < _queue.length; i++) {
          if (_queue[i].status == QueueStatus.consulting) {
            _queue[i] = _queue[i].copyWith(status: QueueStatus.waiting);
          }
        }
      }
      _queue[index] = _queue[index].copyWith(status: newStatus);
      FirebaseClinicalService().syncQueueEntry(_queue[index]);
      _sortQueue();
      notifyListeners();
    }
  }

  QueueEntry? callNextInQueue() {
    int nextWaitingIndex = _queue.indexWhere(
      (q) => q.status == QueueStatus.waiting && q.priority == PatientPriority.emergency,
    );
    if (nextWaitingIndex == -1) {
      nextWaitingIndex = _queue.indexWhere(
        (q) => q.status == QueueStatus.waiting && q.priority == PatientPriority.urgent,
      );
    }
    if (nextWaitingIndex == -1) {
      nextWaitingIndex = _queue.indexWhere(
        (q) => q.status == QueueStatus.waiting,
      );
    }

    if (nextWaitingIndex != -1) {
      for (int i = 0; i < _queue.length; i++) {
        if (_queue[i].status == QueueStatus.consulting) {
          _queue[i] = _queue[i].copyWith(status: QueueStatus.completed);
          FirebaseClinicalService().syncQueueEntry(_queue[i]);
        }
      }
      _queue[nextWaitingIndex] = _queue[nextWaitingIndex].copyWith(
        status: QueueStatus.consulting,
      );
      final called = _queue[nextWaitingIndex];
      FirebaseClinicalService().syncQueueEntry(called);
      _sortQueue();
      notifyListeners();
      return called;
    }
    return null;
  }

  QueueEntry addPatientToQueue({
    required String patientName,
    required int age,
    required String gender,
    required String chiefComplaint,
    PatientPriority priority = PatientPriority.normal,
    PatientVitals? vitals,
    String? appointmentId,
    String? patientId,
    String? doctorId,
  }) {
    final newEntry = queueDomainRepo.addPatient(
      patientName: patientName,
      age: age,
      gender: gender,
      chiefComplaint: chiefComplaint,
      priority: priority,
      vitals: vitals,
      appointmentId: appointmentId,
      patientId: patientId,
      doctorId: doctorId,
    );

    _queue = List.from(queueDomainRepo.queue);

    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'OPD Token #${newEntry.tokenNumber} Issued',
        message:
            '$patientName registered via ABHA. Assigned Token #${newEntry.tokenNumber}. Priority: ${newEntry.priority.displayName}${newEntry.ewsScore != null ? ' (NEWS2: ${newEntry.ewsScore})' : ''}.',
        timestamp: DateTime.now(),
        category: NotificationCategory.appointment,
      ),
    );

    notifyListeners();
    return newEntry;
  }

  QueueEntry checkInAppointment({
    required String appointmentId,
    required PatientVitals vitals,
    String? patientName,
    int? age,
    String? gender,
    String? chiefComplaint,
  }) {
    final newEntry = appointmentDomainRepo.checkInAppointment(
      appointmentId: appointmentId,
      vitals: vitals,
      patientName: patientName,
      age: age,
      gender: gender,
      chiefComplaint: chiefComplaint,
    );

    _queue = List.from(queueDomainRepo.queue);
    _appointments = List.from(appointmentDomainRepo.appointments);

    _notifications.insert(
      0,
      NotificationItem(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Patient Checked In • Token #${newEntry.tokenNumber}',
        message:
            '${newEntry.patientName} checked in with vitals. Clinical Triage: ${newEntry.priority.displayName}${newEntry.ewsScore != null ? ' (NEWS2: ${newEntry.ewsScore})' : ''}.',
        timestamp: DateTime.now(),
        category: NotificationCategory.appointment,
      ),
    );

    notifyListeners();
    return newEntry;
  }

  // Clinical Consultation Completion
  void completeConsultation({
    required String appointmentId,
    required Patient patient,
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
    final encId = 'enc-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final consultation = Consultation(
      id: consultationId,
      appointmentId: appointmentId,
      patientId: patient.id,
      patientName: patient.name,
      doctorId: _currentUser.id,
      doctorName: _currentUser.name,
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

    // Create prescription if medications present
    if (medications.isNotEmpty) {
      final rx = Prescription(
        id: 'rx-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        consultationId: consultationId,
        encounterId: encId,
        patientId: patient.id,
        patientName: patient.name,
        doctorId: _currentUser.id,
        doctorName: _currentUser.name,
        doctorSpecialty: _currentUser.specialty ?? 'General Physician',
        department: _currentUser.department ?? 'Cardiology',
        date: DateTime.now(),
        medications: medications,
        generalAdvice: clinicalNotes,
        doctorSignature: '${_currentUser.name} (Reg. #AAROGYA-9921)',
      );
      _prescriptions.insert(0, rx);
      FirebaseClinicalService().syncPrescription(rx);

      final recRx = MedicalRecord(
        id: 'rec-rx-${DateTime.now().millisecondsSinceEpoch}',
        patientId: patient.id,
        encounterId: encId,
        title: 'Prescription for $diagnosis',
        type: MedicalRecordType.prescription,
        occurredAt: DateTime.now(),
        doctorName: _currentUser.name,
        department: _currentUser.department ?? 'OPD',
        summary:
            'Prescribed ${medications.length} medications. $clinicalNotes',
        tags: [diagnosis, 'Prescription'],
      );
      _medicalRecords.insert(0, recRx);
      FirebaseClinicalService().syncMedicalRecord(recRx);
    }

    // Add consultation to medical records
    final recConsult = MedicalRecord(
      id: 'rec-c-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patient.id,
      encounterId: encId,
      title: 'Clinical Consultation - $diagnosis',
      type: MedicalRecordType.consultation,
      occurredAt: DateTime.now(),
      doctorName: _currentUser.name,
      department: _currentUser.department ?? 'OPD',
      summary:
          'Diagnosis: $diagnosis. Symptoms: ${symptoms.join(', ')}. $clinicalNotes',
      tags: [diagnosis, 'Consultation'],
    );
    _medicalRecords.insert(0, recConsult);
    FirebaseClinicalService().syncMedicalRecord(recConsult);

    // Add advised tests as pending diagnostic records if advised
    for (final test in orderedLabTests) {
      final recAdvised = MedicalRecord(
        id: 'rec-adv-${DateTime.now().millisecondsSinceEpoch}-${test.hashCode}',
        patientId: patient.id,
        encounterId: encId,
        title: 'Advised $test — Result Pending',
        type: MedicalRecordType.advisedDiagnostic,
        occurredAt: DateTime.now(),
        doctorName: _currentUser.name,
        department: _currentUser.department ?? 'OPD',
        summary: 'Diagnostic test $test advised by ${_currentUser.name}. Result pending specimen collection.',
        tags: [test, 'Pending Diagnostic'],
        isAdvisedPending: true,
      );
      _medicalRecords.insert(0, recAdvised);
      FirebaseClinicalService().syncMedicalRecord(recAdvised);
    }

    // Update appointment status to completed
    final aptIndex = _appointments.indexWhere((a) => a.id == appointmentId);
    if (aptIndex != -1) {
      _appointments[aptIndex] = _appointments[aptIndex].copyWith(
        status: AppointmentStatus.completed,
      );
    }

    // Update matching queue entry if any
    final queueIndex = _queue.indexWhere(
      (q) => q.appointmentId == appointmentId,
    );
    if (queueIndex != -1) {
      _queue[queueIndex] = _queue[queueIndex].copyWith(
        status: QueueStatus.completed,
      );
    }

    notifyListeners();
  }

  // Payment Processing
  void payInvoice(String invoiceId, String paymentMethod) {
    final index = _invoices.indexWhere((inv) => inv.id == invoiceId);
    if (index != -1) {
      final inv = _invoices[index];
      _invoices[index] = inv.copyWith(
        status: InvoiceStatus.paid,
        amountPaidPaise: inv.totalPaise,
        balanceDuePaise: 0,
        paymentMethod: paymentMethod,
        paidAt: DateTime.now(),
      );
      FirebaseClinicalService().syncInvoice(_invoices[index]);

      _notifications.insert(
        0,
        NotificationItem(
          id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Payment Successful',
          message:
              'Invoice ${_invoices[index].invoiceNumber} for ₹${_invoices[index].totalAmount.toStringAsFixed(0)} settled via $paymentMethod.',
          timestamp: DateTime.now(),
          category: NotificationCategory.billing,
        ),
      );

      notifyListeners();
    }
  }

  // Doctor Management (Admin)
  void toggleDoctorStatus(String doctorId) {
    final index = _doctors.indexWhere((d) => d.id == doctorId);
    if (index != -1) {
      final doc = _doctors[index];
      _doctors[index] = doc.copyWith(isAvailableToday: !doc.isAvailableToday);
      notifyListeners();
    }
  }

  void addDoctor(Doctor doctor) {
    _doctors.insert(0, doctor);
    notifyListeners();
  }

  void addLabReport(LabReport report) {
    _labReports.insert(0, report);
    FirebaseClinicalService().syncLabReport(report);
    notifyListeners();
  }

  // Notification Actions
  void markAllNotificationsAsRead() {
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();
  }

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  @override
  // ignore: must_call_super
  void dispose() {
    // Singleton instance persists across transient provider scopes
  }
}
