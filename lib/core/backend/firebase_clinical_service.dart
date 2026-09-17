import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../shared/domain/models/appointment.dart';
import '../../shared/domain/models/invoice.dart';
import '../../shared/domain/models/lab_report.dart';
import '../../shared/domain/models/medical_record.dart';
import '../../shared/domain/models/prescription.dart';
import '../../shared/domain/models/queue_entry.dart';
import 'firestore_schemas.dart';

enum CloudSyncStatus {
  connected,
  syncing,
  offlineFallback,
  error;

  String get label {
    switch (this) {
      case CloudSyncStatus.connected:
        return 'Cloud Synced (Firestore Live)';
      case CloudSyncStatus.syncing:
        return 'Syncing Clinical Data...';
      case CloudSyncStatus.offlineFallback:
        return 'Offline-First Mode (Local Cache)';
      case CloudSyncStatus.error:
        return 'Sync Offline';
    }
  }
}

/// Enterprise Hybrid Cloud Firestore Service
/// Provides real-time bidirectional synchronization with resilient offline-first persistence.
class FirebaseClinicalService {
  static final FirebaseClinicalService _instance =
      FirebaseClinicalService._internal();
  factory FirebaseClinicalService() => _instance;
  FirebaseClinicalService._internal() {
    _initFirestore();
  }

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CloudSyncStatus _syncStatus = CloudSyncStatus.offlineFallback;
  CloudSyncStatus get syncStatus => _syncStatus;

  final StreamController<CloudSyncStatus> _statusController =
      StreamController<CloudSyncStatus>.broadcast();
  Stream<CloudSyncStatus> get statusStream => _statusController.stream;

  // Real-time Clinical Data Streams
  final StreamController<List<QueueEntry>> _liveQueueStream =
      StreamController<List<QueueEntry>>.broadcast();
  Stream<List<QueueEntry>> get liveQueueStream => _liveQueueStream.stream;

  final StreamController<List<Appointment>> _liveAppointmentsStream =
      StreamController<List<Appointment>>.broadcast();
  Stream<List<Appointment>> get liveAppointmentsStream =>
      _liveAppointmentsStream.stream;

  final StreamController<List<Prescription>> _livePrescriptionsStream =
      StreamController<List<Prescription>>.broadcast();
  Stream<List<Prescription>> get livePrescriptionsStream =>
      _livePrescriptionsStream.stream;

  final StreamController<List<LabReport>> _liveLabReportsStream =
      StreamController<List<LabReport>>.broadcast();
  Stream<List<LabReport>> get liveLabReportsStream =>
      _liveLabReportsStream.stream;

  final StreamController<List<Invoice>> _liveInvoicesStream =
      StreamController<List<Invoice>>.broadcast();
  Stream<List<Invoice>> get liveInvoicesStream => _liveInvoicesStream.stream;

  final StreamController<List<MedicalRecord>> _liveMedicalRecordsStream =
      StreamController<List<MedicalRecord>>.broadcast();
  Stream<List<MedicalRecord>> get liveMedicalRecordsStream =>
      _liveMedicalRecordsStream.stream;

  StreamSubscription? _queueSubscription;
  StreamSubscription? _appointmentsSubscription;
  StreamSubscription? _prescriptionsSubscription;
  StreamSubscription? _labReportsSubscription;
  StreamSubscription? _invoicesSubscription;
  StreamSubscription? _medicalRecordsSubscription;

  void _initFirestore() {
    try {
      if (!kIsWeb) {
        _firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
      _syncStatus = CloudSyncStatus.connected;
      _statusController.add(_syncStatus);

      // Start all real-time clinical listeners
      _listenToLiveQueue();
      _listenToAppointments();
      _listenToPrescriptions();
      _listenToLabReports();
      _listenToInvoices();
      _listenToMedicalRecords();
    } catch (e) {
      debugPrint('[FirebaseService] Local persistence init note: $e');
      _syncStatus = CloudSyncStatus.offlineFallback;
      _statusController.add(_syncStatus);
    }
  }

  /// Listen to real-time changes in the OPD live queue collection
  void _listenToLiveQueue() {
    try {
      _queueSubscription?.cancel();
      _queueSubscription = _firestore
          .collection(FirestoreCollections.liveQueue)
          .orderBy(FirestoreFields.tokenNumber)
          .snapshots()
          .listen(
            (snapshot) {
              final entries = <QueueEntry>[];
              for (final doc in snapshot.docs) {
                try {
                  final data = doc.data();
                  entries.add(
                    QueueEntry(
                      id: doc.id,
                      tokenNumber:
                          (data[FirestoreFields.tokenNumber] as num?)?.toInt() ?? 1,
                      appointmentId:
                          data['appointment_id'] as String? ?? 'apt-live',
                      patientId: data['patient_id'] as String? ?? 'pat-1',
                      patientName:
                          data[FirestoreFields.patientName] as String? ?? 'Patient',
                      age: (data[FirestoreFields.age] as num?)?.toInt() ?? 30,
                      gender: data[FirestoreFields.gender] as String? ?? 'Other',
                      doctorId:
                          data[FirestoreFields.doctorId] as String? ?? 'doc-1',
                      checkInTime: (data['check_in_time'] is Timestamp)
                          ? (data['check_in_time'] as Timestamp).toDate()
                          : DateTime.now(),
                      estimatedWaitMinutes:
                          (data[FirestoreFields.estimatedWaitMins] as num?)
                              ?.toInt() ??
                          15,
                      status: QueueStatus.values.firstWhere(
                        (s) =>
                            s.name ==
                            (data[FirestoreFields.status] as String? ?? 'waiting'),
                        orElse: () => QueueStatus.waiting,
                      ),
                      priority: PatientPriority.values.firstWhere(
                        (p) => p.name == (data['priority'] as String? ?? 'normal'),
                        orElse: () => PatientPriority.normal,
                      ),
                      chiefComplaint:
                          data['chief_complaint'] as String? ??
                          'General Consultation',
                    ),
                  );
                } catch (_) {}
              }

              if (entries.isNotEmpty) {
                _liveQueueStream.add(entries);
                _syncStatus = CloudSyncStatus.connected;
                _statusController.add(_syncStatus);
              }
            },
            onError: (e) {
              debugPrint('[FirebaseService] Live queue sync note: $e');
            },
          );
    } catch (e) {
      debugPrint('[FirebaseService] Firestore listen queue notice: $e');
    }
  }

  /// Listen to real-time changes in Appointments
  void _listenToAppointments() {
    try {
      _appointmentsSubscription?.cancel();
      _appointmentsSubscription = _firestore
          .collection(FirestoreCollections.appointments)
          .snapshots()
          .listen(
            (snapshot) {
              final appointments = <Appointment>[];
              for (final doc in snapshot.docs) {
                try {
                  final data = doc.data();
                  appointments.add(
                    Appointment(
                      id: doc.id,
                      patientId: data['patient_id'] as String? ?? 'pat-1',
                      patientName:
                          data[FirestoreFields.patientName] as String? ?? 'Patient',
                      doctorId:
                          data[FirestoreFields.doctorId] as String? ?? 'doc-1',
                      doctorName:
                          data[FirestoreFields.doctorName] as String? ?? 'Doctor',
                      specialty:
                          data['specialty'] as String? ?? 'General Physician',
                      doctorAvatar:
                          data['doctor_avatar'] as String? ??
                          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=256',
                      dateTime: (data[FirestoreFields.dateTime] is Timestamp)
                          ? (data[FirestoreFields.dateTime] as Timestamp).toDate()
                          : DateTime.now(),
                      timeSlot: data[FirestoreFields.timeSlot] as String? ?? '10:00 AM',
                      type: ConsultationType.values.firstWhere(
                        (t) =>
                            t.name ==
                            (data[FirestoreFields.consultationType] as String? ??
                                'inPerson'),
                        orElse: () => ConsultationType.inPerson,
                      ),
                      status: AppointmentStatus.values.firstWhere(
                        (s) =>
                            s.name ==
                            (data[FirestoreFields.status] as String? ??
                                'confirmed'),
                        orElse: () => AppointmentStatus.confirmed,
                      ),
                      tokenNumber:
                          (data[FirestoreFields.tokenNumber] as num?)?.toInt() ?? 1,
                      fee: (data[FirestoreFields.fee] as num?)?.toDouble() ?? 500.0,
                      symptoms: data['symptoms'] as String?,
                      notes: data['notes'] as String?,
                    ),
                  );
                } catch (_) {}
              }

              if (appointments.isNotEmpty) {
                _liveAppointmentsStream.add(appointments);
              }
            },
            onError: (e) {
              debugPrint('[FirebaseService] Appointments sync note: $e');
            },
          );
    } catch (e) {
      debugPrint('[FirebaseService] Firestore listen appointments notice: $e');
    }
  }

  /// Listen to real-time changes in Prescriptions
  void _listenToPrescriptions() {
    try {
      _prescriptionsSubscription?.cancel();
      _prescriptionsSubscription = _firestore
          .collection(FirestoreCollections.prescriptions)
          .snapshots()
          .listen(
            (snapshot) {
              final prescriptions = <Prescription>[];
              for (final doc in snapshot.docs) {
                try {
                  final data = doc.data();
                  final medsRaw = data['medications'] as List<dynamic>? ?? [];
                  final meds = medsRaw.map((m) {
                    final mMap = m as Map<String, dynamic>;
                    return Medication(
                      id: mMap['id'] as String? ?? 'med-1',
                      name: mMap['name'] as String? ?? 'Medication',
                      dosage: mMap['dosage'] as String? ?? '500mg',
                      frequency: mMap['frequency'] as String? ?? '1-0-1',
                      duration: mMap['duration'] as String? ?? '5 Days',
                      instructions: mMap['instructions'] as String? ?? 'After food',
                      startDate: mMap['start_date'] != null
                          ? DateTime.tryParse(mMap['start_date'] as String)
                          : null,
                      endDate: mMap['end_date'] != null
                          ? DateTime.tryParse(mMap['end_date'] as String)
                          : null,
                    );
                  }).toList();

                  prescriptions.add(
                    Prescription(
                      id: doc.id,
                      consultationId:
                          data['consultation_id'] as String? ?? 'c-1',
                      patientId: data['patient_id'] as String? ?? 'pat-1',
                      patientName:
                          data[FirestoreFields.patientName] as String? ?? 'Patient',
                      doctorId:
                          data[FirestoreFields.doctorId] as String? ?? 'doc-1',
                      doctorName:
                          data[FirestoreFields.doctorName] as String? ?? 'Doctor',
                      doctorSpecialty:
                          data['doctor_specialty'] as String? ??
                          'General Physician',
                      date: (data['date'] is Timestamp)
                          ? (data['date'] as Timestamp).toDate()
                          : DateTime.now(),
                      medications: meds,
                      generalAdvice: data[FirestoreFields.generalAdvice] as String?,
                      doctorSignature: data['doctor_signature'] as String?,
                    ),
                  );
                } catch (_) {}
              }

              if (prescriptions.isNotEmpty) {
                _livePrescriptionsStream.add(prescriptions);
              }
            },
            onError: (e) {
              debugPrint('[FirebaseService] Prescriptions sync note: $e');
            },
          );
    } catch (e) {
      debugPrint('[FirebaseService] Firestore listen prescriptions notice: $e');
    }
  }

  /// Listen to real-time changes in Lab Reports
  void _listenToLabReports() {
    try {
      _labReportsSubscription?.cancel();
      _labReportsSubscription = _firestore
          .collection(FirestoreCollections.labReports)
          .snapshots()
          .listen(
            (snapshot) {
              final reports = <LabReport>[];
              for (final doc in snapshot.docs) {
                try {
                  final data = doc.data();
                  final itemsRaw = data['items'] as List<dynamic>? ?? [];
                  final items = itemsRaw.map((it) {
                    final iMap = it as Map<String, dynamic>;
                    return LabTestItem(
                      testName: iMap['test_name'] as String? ?? 'Test',
                      value: (iMap['value'] as num?)?.toDouble() ?? 0.0,
                      unit: iMap['unit'] as String? ?? '',
                      minRange: (iMap['min_range'] as num?)?.toDouble() ?? 0.0,
                      maxRange: (iMap['max_range'] as num?)?.toDouble() ?? 100.0,
                      status: LabResultStatus.values.firstWhere(
                        (s) => s.name == (iMap['status'] as String? ?? 'normal'),
                        orElse: () => LabResultStatus.normal,
                      ),
                    );
                  }).toList();

                  reports.add(
                    LabReport(
                      id: doc.id,
                      patientId: data['patient_id'] as String? ?? 'pat-1',
                      patientName: data['patient_name'] as String? ?? 'Patient',
                      testName: data['test_name'] as String? ?? 'Lab Panel',
                      category: data['category'] as String? ?? 'Pathology',
                      orderedByDoctor:
                          data['ordered_by_doctor'] as String? ?? 'Doctor',
                      orderDate: (data['order_date'] is Timestamp)
                          ? (data['order_date'] as Timestamp).toDate()
                          : DateTime.now(),
                      completedDate: (data['completed_date'] is Timestamp)
                          ? (data['completed_date'] as Timestamp).toDate()
                          : null,
                      status: ReportStatus.values.firstWhere(
                        (s) =>
                            s.name ==
                            (data[FirestoreFields.status] as String? ??
                                'completed'),
                        orElse: () => ReportStatus.completed,
                      ),
                      items: items,
                      labTechnicianNotes: data['technician_notes'] as String?,
                    ),
                  );
                } catch (_) {}
              }

              if (reports.isNotEmpty) {
                _liveLabReportsStream.add(reports);
              }
            },
            onError: (e) {
              debugPrint('[FirebaseService] Lab reports sync note: $e');
            },
          );
    } catch (e) {
      debugPrint('[FirebaseService] Firestore listen lab reports notice: $e');
    }
  }

  /// Listen to real-time changes in Invoices
  void _listenToInvoices() {
    try {
      _invoicesSubscription?.cancel();
      _invoicesSubscription = _firestore
          .collection(FirestoreCollections.invoices)
          .snapshots()
          .listen(
            (snapshot) {
              final invoices = <Invoice>[];
              for (final doc in snapshot.docs) {
                try {
                  final data = doc.data();
                  final itemsRaw = data['items'] as List<dynamic>? ?? [];
                  final items = itemsRaw.map((it) {
                    final iMap = it as Map<String, dynamic>;
                    return InvoiceLineItem(
                      description:
                          iMap['description'] as String? ?? 'Clinical Service',
                      quantity: (iMap['quantity'] as num?)?.toInt() ?? 1,
                      unitPrice:
                          (iMap['unit_price'] as num?)?.toDouble() ?? 500.0,
                      total: (iMap['total'] as num?)?.toDouble() ?? 500.0,
                    );
                  }).toList();

                  invoices.add(
                    Invoice(
                      id: doc.id,
                      invoiceNumber:
                          data['invoice_number'] as String? ?? 'INV-LIVE',
                      patientId: data['patient_id'] as String? ?? 'pat-1',
                      patientName: data['patient_name'] as String? ?? 'Patient',
                      appointmentId: data['appointment_id'] as String?,
                      date: (data['date'] is Timestamp)
                          ? (data['date'] as Timestamp).toDate()
                          : DateTime.now(),
                      dueDate: (data['due_date'] is Timestamp)
                          ? (data['due_date'] as Timestamp).toDate()
                          : DateTime.now().add(const Duration(days: 3)),
                      items: items,
                      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 500.0,
                      tax: (data['tax'] as num?)?.toDouble() ?? 25.0,
                      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
                      totalAmount:
                          (data['total_amount'] as num?)?.toDouble() ?? 525.0,
                      status: InvoiceStatus.values.firstWhere(
                        (s) =>
                            s.name ==
                            (data[FirestoreFields.status] as String? ??
                                'pending'),
                        orElse: () => InvoiceStatus.pending,
                      ),
                      paymentMethod: data['payment_method'] as String?,
                      paidAt: (data['paid_at'] is Timestamp)
                          ? (data['paid_at'] as Timestamp).toDate()
                          : null,
                    ),
                  );
                } catch (_) {}
              }

              if (invoices.isNotEmpty) {
                _liveInvoicesStream.add(invoices);
              }
            },
            onError: (e) {
              debugPrint('[FirebaseService] Invoices sync note: $e');
            },
          );
    } catch (e) {
      debugPrint('[FirebaseService] Firestore listen invoices notice: $e');
    }
  }

  /// Listen to real-time changes in Medical Records
  void _listenToMedicalRecords() {
    try {
      _medicalRecordsSubscription?.cancel();
      _medicalRecordsSubscription = _firestore
          .collection(FirestoreCollections.medicalRecords)
          .snapshots()
          .listen(
            (snapshot) {
              final records = <MedicalRecord>[];
              for (final doc in snapshot.docs) {
                try {
                  final data = doc.data();
                  records.add(
                    MedicalRecord(
                      id: doc.id,
                      patientId: data['patient_id'] as String? ?? 'pat-1',
                      title: data['title'] as String? ?? 'Medical Record',
                      type: MedicalRecordType.values.firstWhere(
                        (t) =>
                            t.name ==
                            (data['type'] as String? ?? 'consultation'),
                        orElse: () => MedicalRecordType.consultation,
                      ),
                      date: (data['date'] is Timestamp)
                          ? (data['date'] as Timestamp).toDate()
                          : DateTime.now(),
                      doctorName:
                          data[FirestoreFields.doctorName] as String? ?? 'Doctor',
                      department: data['department'] as String? ?? 'OPD',
                      summary: data['summary'] as String? ?? '',
                      attachmentUrl: data['attachment_url'] as String?,
                      tags: (data['tags'] as List<dynamic>?)
                              ?.map((t) => t.toString())
                              .toList() ??
                          const [],
                    ),
                  );
                } catch (_) {}
              }

              if (records.isNotEmpty) {
                _liveMedicalRecordsStream.add(records);
              }
            },
            onError: (e) {
              debugPrint('[FirebaseService] Medical records sync note: $e');
            },
          );
    } catch (e) {
      debugPrint('[FirebaseService] Firestore listen medical records notice: $e');
    }
  }

  /// Sync Appointment to Cloud Firestore
  Future<bool> syncAppointment(Appointment appointment) async {
    try {
      _statusController.add(CloudSyncStatus.syncing);
      await _firestore
          .collection(FirestoreCollections.appointments)
          .doc(appointment.id)
          .set({
            FirestoreFields.id: appointment.id,
            'patient_id': appointment.patientId,
            FirestoreFields.patientName: appointment.patientName,
            FirestoreFields.doctorId: appointment.doctorId,
            FirestoreFields.doctorName: appointment.doctorName,
            'specialty': appointment.specialty,
            'doctor_avatar': appointment.doctorAvatar,
            FirestoreFields.dateTime: Timestamp.fromDate(appointment.dateTime),
            FirestoreFields.timeSlot: appointment.timeSlot,
            FirestoreFields.consultationType: appointment.type.name,
            FirestoreFields.status: appointment.status.name,
            FirestoreFields.fee: appointment.fee,
            FirestoreFields.tokenNumber: appointment.tokenNumber,
            'symptoms': appointment.symptoms,
            'notes': appointment.notes,
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      _statusController.add(CloudSyncStatus.connected);
      return true;
    } catch (e) {
      debugPrint('[FirebaseService] Sync appointment notice: $e');
      _statusController.add(CloudSyncStatus.offlineFallback);
      return false;
    }
  }

  /// Sync Queue Entry to Cloud Firestore
  Future<bool> syncQueueEntry(QueueEntry entry) async {
    try {
      _statusController.add(CloudSyncStatus.syncing);
      await _firestore
          .collection(FirestoreCollections.liveQueue)
          .doc(entry.id)
          .set({
            FirestoreFields.id: entry.id,
            FirestoreFields.tokenNumber: entry.tokenNumber,
            'appointment_id': entry.appointmentId,
            'patient_id': entry.patientId,
            FirestoreFields.patientName: entry.patientName,
            FirestoreFields.age: entry.age,
            FirestoreFields.gender: entry.gender,
            FirestoreFields.doctorId: entry.doctorId,
            'check_in_time': Timestamp.fromDate(entry.checkInTime),
            FirestoreFields.estimatedWaitMins: entry.estimatedWaitMinutes,
            FirestoreFields.status: entry.status.name,
            'priority': entry.priority.name,
            'chief_complaint': entry.chiefComplaint,
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      _statusController.add(CloudSyncStatus.connected);
      return true;
    } catch (e) {
      debugPrint('[FirebaseService] Sync queue notice: $e');
      _statusController.add(CloudSyncStatus.offlineFallback);
      return false;
    }
  }

  /// Sync Prescription to Cloud Firestore
  Future<bool> syncPrescription(Prescription rx) async {
    try {
      _statusController.add(CloudSyncStatus.syncing);
      await _firestore
          .collection(FirestoreCollections.prescriptions)
          .doc(rx.id)
          .set({
            FirestoreFields.id: rx.id,
            'consultation_id': rx.consultationId,
            'patient_id': rx.patientId,
            FirestoreFields.patientName: rx.patientName,
            FirestoreFields.doctorId: rx.doctorId,
            FirestoreFields.doctorName: rx.doctorName,
            'doctor_specialty': rx.doctorSpecialty,
            'date': Timestamp.fromDate(rx.date),
            FirestoreFields.generalAdvice: rx.generalAdvice,
            'doctor_signature': rx.doctorSignature,
            'medications': rx.medications
                .map(
                  (m) => {
                    'id': m.id,
                    'name': m.name,
                    'dosage': m.dosage,
                    'frequency': m.frequency,
                    'duration': m.duration,
                    'instructions': m.instructions,
                    if (m.startDate != null)
                      'start_date': m.startDate!.toIso8601String(),
                    if (m.endDate != null)
                      'end_date': m.endDate!.toIso8601String(),
                  },
                )
                .toList(),
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      _statusController.add(CloudSyncStatus.connected);
      return true;
    } catch (e) {
      debugPrint('[FirebaseService] Sync prescription notice: $e');
      _statusController.add(CloudSyncStatus.offlineFallback);
      return false;
    }
  }

  /// Sync Diagnostic Lab Report to Cloud Firestore
  Future<bool> syncLabReport(LabReport report) async {
    try {
      _statusController.add(CloudSyncStatus.syncing);
      await _firestore
          .collection(FirestoreCollections.labReports)
          .doc(report.id)
          .set({
            FirestoreFields.id: report.id,
            'patient_id': report.patientId,
            'patient_name': report.patientName,
            'test_name': report.testName,
            'category': report.category,
            'ordered_by_doctor': report.orderedByDoctor,
            'order_date': Timestamp.fromDate(report.orderDate),
            'completed_date': report.completedDate != null
                ? Timestamp.fromDate(report.completedDate!)
                : null,
            FirestoreFields.status: report.status.name,
            'items': report.items
                .map(
                  (r) => {
                    'test_name': r.testName,
                    'value': r.value,
                    'unit': r.unit,
                    'min_range': r.minRange,
                    'max_range': r.maxRange,
                    'status': r.status.name,
                  },
                )
                .toList(),
            'technician_notes': report.labTechnicianNotes,
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      _statusController.add(CloudSyncStatus.connected);
      return true;
    } catch (e) {
      debugPrint('[FirebaseService] Sync lab report notice: $e');
      _statusController.add(CloudSyncStatus.offlineFallback);
      return false;
    }
  }

  /// Sync Invoice to Cloud Firestore
  Future<bool> syncInvoice(Invoice invoice) async {
    try {
      _statusController.add(CloudSyncStatus.syncing);
      await _firestore
          .collection(FirestoreCollections.invoices)
          .doc(invoice.id)
          .set({
            FirestoreFields.id: invoice.id,
            'invoice_number': invoice.invoiceNumber,
            'patient_id': invoice.patientId,
            'patient_name': invoice.patientName,
            'appointment_id': invoice.appointmentId,
            'date': Timestamp.fromDate(invoice.date),
            'due_date': Timestamp.fromDate(invoice.dueDate),
            'items': invoice.items
                .map(
                  (it) => {
                    'description': it.description,
                    'quantity': it.quantity,
                    'unit_price': it.unitPrice,
                    'total': it.total,
                  },
                )
                .toList(),
            'subtotal': invoice.subtotal,
            'tax': invoice.tax,
            'discount': invoice.discount,
            'total_amount': invoice.totalAmount,
            FirestoreFields.status: invoice.status.name,
            'payment_method': invoice.paymentMethod,
            'paid_at': invoice.paidAt != null
                ? Timestamp.fromDate(invoice.paidAt!)
                : null,
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      _statusController.add(CloudSyncStatus.connected);
      return true;
    } catch (e) {
      debugPrint('[FirebaseService] Sync invoice notice: $e');
      _statusController.add(CloudSyncStatus.offlineFallback);
      return false;
    }
  }

  /// Sync Medical Record to Cloud Firestore
  Future<bool> syncMedicalRecord(MedicalRecord record) async {
    try {
      _statusController.add(CloudSyncStatus.syncing);
      await _firestore
          .collection(FirestoreCollections.medicalRecords)
          .doc(record.id)
          .set({
            FirestoreFields.id: record.id,
            'patient_id': record.patientId,
            'title': record.title,
            'type': record.type.name,
            'date': Timestamp.fromDate(record.date),
            FirestoreFields.doctorName: record.doctorName,
            'department': record.department,
            'summary': record.summary,
            'attachment_url': record.attachmentUrl,
            'tags': record.tags,
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      _statusController.add(CloudSyncStatus.connected);
      return true;
    } catch (e) {
      debugPrint('[FirebaseService] Sync medical record notice: $e');
      _statusController.add(CloudSyncStatus.offlineFallback);
      return false;
    }
  }

  /// Broadcast local queue update
  void broadcastQueueUpdate(List<QueueEntry> queue) {
    _liveQueueStream.add(queue);
  }

  void dispose() {
    _queueSubscription?.cancel();
    _appointmentsSubscription?.cancel();
    _prescriptionsSubscription?.cancel();
    _labReportsSubscription?.cancel();
    _invoicesSubscription?.cancel();
    _medicalRecordsSubscription?.cancel();
    _statusController.close();
    _liveQueueStream.close();
    _liveAppointmentsStream.close();
    _livePrescriptionsStream.close();
    _liveLabReportsStream.close();
    _liveInvoicesStream.close();
    _liveMedicalRecordsStream.close();
  }
}
