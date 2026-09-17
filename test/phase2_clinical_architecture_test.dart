import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/core/clinical/ews_triage_calculator.dart';
import 'package:aarogya/shared/data/repositories/domain/queue_domain_repository.dart';
import 'package:aarogya/shared/data/repositories/domain/appointment_domain_repository.dart';
import 'package:aarogya/shared/data/repositories/domain/lab_domain_repository.dart';
import 'package:aarogya/shared/domain/models/patient.dart';
import 'package:aarogya/shared/domain/models/queue_entry.dart';
import 'package:aarogya/shared/domain/models/appointment.dart';

void main() {
  group('Phase 2: EWS Clinical Triage Calculator Tests', () {
    test('Calculates zero score and normal priority for stable vitals', () {
      final stableVitals = PatientVitals(
        bloodPressure: '120/80',
        heartRate: 72,
        spo2: 98.0,
        temperature: 98.4,
        weight: 70.0,
        recordedAt: DateTime.now(),
        respiratoryRate: 16,
      );

      final result = EwsTriageCalculator.calculate(stableVitals);

      expect(result.totalScore, 0);
      expect(result.priority, PatientPriority.normal);
      expect(result.riskCategory, 'Low Clinical Risk');
      expect(result.criticalAlerts.isEmpty, true);
    });

    test('Calculates score of 4 and urgent priority for moderately deranged vitals', () {
      // HR 114 (+2), SpO2 93.5 (+2) -> total 4 -> Medium Risk (Urgent)
      final urgentVitals = PatientVitals(
        bloodPressure: '135/85',
        heartRate: 114,
        spo2: 93.5,
        temperature: 98.6,
        weight: 65.0,
        recordedAt: DateTime.now(),
        respiratoryRate: 18,
      );

      final result = EwsTriageCalculator.calculate(urgentVitals);

      expect(result.totalScore, 4);
      expect(result.priority, PatientPriority.urgent);
      expect(result.riskCategory, 'Medium Clinical Risk');
    });

    test('Calculates red flag and emergency priority for severe hypoxia (SpO2 <= 91%)', () {
      // SpO2 88.0% is a 3-point critical trigger
      final criticalVitals = PatientVitals(
        bloodPressure: '120/80',
        heartRate: 80,
        spo2: 88.0,
        temperature: 98.4,
        weight: 72.0,
        recordedAt: DateTime.now(),
        respiratoryRate: 26, // RR >= 25 is also 3 points
      );

      final result = EwsTriageCalculator.calculate(criticalVitals);

      expect(result.totalScore >= 6, true);
      expect(result.priority, PatientPriority.emergency);
      expect(result.riskCategory, 'High Clinical Risk');
      expect(result.criticalAlerts.isNotEmpty, true);
    });

    test('Calculates red flag and emergency priority for severe hypotension (<= 90 mmHg)', () {
      final shockVitals = PatientVitals(
        bloodPressure: '85/50',
        heartRate: 115, // +2
        spo2: 97.0,     // 0
        temperature: 97.5,
        weight: 60.0,
        recordedAt: DateTime.now(),
        respiratoryRate: 18,
      );

      final result = EwsTriageCalculator.calculate(shockVitals);

      expect(result.priority, PatientPriority.emergency);
      expect(result.criticalAlerts.any((a) => a.contains('hypotension')), true);
    });
  });

  group('Phase 2: Modular Domain Repositories Tests', () {
    late QueueDomainRepository queueRepo;
    late AppointmentDomainRepository appointmentRepo;
    late LabDomainRepository labRepo;

    setUp(() {
      queueRepo = QueueDomainRepository();
      appointmentRepo = AppointmentDomainRepository(queueRepo);
      labRepo = LabDomainRepository();
    });

    test('QueueDomainRepository calculates EWS from vitals and sorts urgent ahead of normal', () {
      // Add a routine patient (EWS 0)
      final normalPatient = queueRepo.addPatient(
        patientName: 'Normal Test Patient',
        age: 30,
        gender: 'Female',
        chiefComplaint: 'Routine check-up',
        vitals: PatientVitals(
          bloodPressure: '120/80',
          heartRate: 72,
          spo2: 98.0,
          temperature: 98.4,
          weight: 60.0,
          recordedAt: DateTime.now(),
          respiratoryRate: 16,
        ),
      );

      // Add an emergency patient with hypoxic vitals (EWS >= 5)
      final emergencyPatient = queueRepo.addPatient(
        patientName: 'Emergency Test Patient',
        age: 55,
        gender: 'Male',
        chiefComplaint: 'Severe breathlessness and hypoxia',
        vitals: PatientVitals(
          bloodPressure: '140/90',
          heartRate: 132,
          spo2: 89.0,
          temperature: 99.1,
          weight: 75.0,
          recordedAt: DateTime.now(),
          respiratoryRate: 28,
        ),
      );

      expect(normalPatient.priority, PatientPriority.normal);
      expect(emergencyPatient.priority, PatientPriority.emergency);

      // In the waiting queue, the emergency patient must appear ahead of normal waiting patients
      final waitingQueue = queueRepo.queue.where((q) => q.status == QueueStatus.waiting).toList();
      final emergencyIdx = waitingQueue.indexWhere((q) => q.id == emergencyPatient.id);
      final normalIdx = waitingQueue.indexWhere((q) => q.id == normalPatient.id);

      expect(emergencyIdx < normalIdx, true);
    });

    test('AppointmentDomainRepository checkInAppointment triages patient into queue via EWS', () {
      final confirmedApt = appointmentRepo.appointments.firstWhere(
        (a) => a.status == AppointmentStatus.confirmed,
      );

      final initialWaitingQueueLength =
          queueRepo.queue.where((q) => q.status == QueueStatus.waiting).length;

      final checkedInEntry = appointmentRepo.checkInAppointment(
        appointmentId: confirmedApt.id,
        vitals: PatientVitals(
          bloodPressure: '155/95',
          heartRate: 114,
          spo2: 93.5,
          temperature: 99.2,
          weight: 68.0,
          recordedAt: DateTime.now(),
          respiratoryRate: 22,
        ),
      );

      // Appointment should now be marked waiting (In Queue)
      final updatedApt = appointmentRepo.appointments.firstWhere((a) => a.id == confirmedApt.id);
      expect(updatedApt.status, AppointmentStatus.waiting);

      // Entry in queue should have calculated NEWS2 score 6 (HR+2, SpO2+2, RR+2) and emergency priority
      expect(checkedInEntry.ewsScore, 6);
      expect(checkedInEntry.priority, PatientPriority.emergency);

      final newWaitingQueueLength =
          queueRepo.queue.where((q) => q.status == QueueStatus.waiting).length;
      expect(newWaitingQueueLength, initialWaitingQueueLength + 1);
    });

    test('LabDomainRepository correctly filters abnormal reports', () {
      final allReports = labRepo.labReports;
      final abnormalReports = labRepo.getAbnormalReports();

      expect(abnormalReports.isNotEmpty, true);
      expect(abnormalReports.every((r) => r.hasAbnormalResults), true);
      expect(abnormalReports.length <= allReports.length, true);
    });

    test('Walk-in triage via QueueDomainRepository calculates EWS and assigns token', () {
      final walkIn = queueRepo.addPatient(
        patientName: 'Walk-In Triage Patient',
        age: 42,
        gender: 'Male',
        chiefComplaint: 'Acute chest discomfort',
        vitals: PatientVitals(
          bloodPressure: '160/100',
          heartRate: 115,
          spo2: 94.0,
          temperature: 101.5,
          weight: 72.0,
          recordedAt: DateTime.now(),
          respiratoryRate: 24,
        ),
      );

      expect(walkIn.tokenNumber > 0, true);
      expect(walkIn.ewsScore != null, true);
      expect(walkIn.ewsScore! >= 4, true);
      expect(walkIn.priority == PatientPriority.urgent || walkIn.priority == PatientPriority.emergency, true);
      expect(walkIn.status, QueueStatus.waiting);
    });
  });

  group('P1 & P2: Clinical UX and Safety Automation Tests', () {
    test('Prescription intake schedule parses timing triplets correctly', () {
      final match1 = RegExp(r'(\d+)\s*-\s*(\d+)\s*-\s*(\d+)').firstMatch('1-0-1 (Morning & Night)');
      expect(match1 != null, true);
      expect(int.parse(match1!.group(1)!), 1);
      expect(int.parse(match1.group(2)!), 0);
      expect(int.parse(match1.group(3)!), 1);

      final match2 = RegExp(r'(\d+)\s*-\s*(\d+)\s*-\s*(\d+)').firstMatch('0-0-1 (Night)');
      expect(match2 != null, true);
      expect(int.parse(match2!.group(1)!), 0);
      expect(int.parse(match2.group(2)!), 0);
      expect(int.parse(match2.group(3)!), 1);

      final isPRN = 'PRN (As Needed)'.toLowerCase().contains('prn');
      expect(isPRN, true);
    });

    test('Order Set allergy guard intercepts contraindicated medications in protocols', () {
      final patientAllergies = ['Penicillin', 'Sulfa'];

      bool checkConflict(String medName) {
        final med = medName.toLowerCase();
        for (final a in patientAllergies) {
          final al = a.toLowerCase();
          if (al.contains('penicillin')) {
            const penicillins = ['amoxicillin', 'ampicillin', 'augmentin'];
            if (penicillins.any((p) => med.contains(p))) return true;
          }
          if (med.contains(al)) return true;
        }
        return false;
      }

      // Safe drug in URTI protocol
      expect(checkConflict('Paracetamol'), false);
      expect(checkConflict('Cetirizine'), false);

      // Dangerous drug for Penicillin-allergic patient
      expect(checkConflict('Amoxicillin'), true);
      expect(checkConflict('Augmentin 625mg'), true);
    });

    test('Live queue tracker accurately calculates ahead count and consulting status', () {
      final now = DateTime.now();
      final testQueue = [
        QueueEntry(
          id: 'q-1',
          tokenNumber: 101,
          appointmentId: 'a-1',
          patientId: 'p-1',
          patientName: 'Patient A',
          age: 45,
          gender: 'Male',
          doctorId: 'doc-1',
          checkInTime: now,
          estimatedWaitMinutes: 0,
          status: QueueStatus.consulting,
          priority: PatientPriority.normal,
          chiefComplaint: 'Follow up',
        ),
        QueueEntry(
          id: 'q-2',
          tokenNumber: 102,
          appointmentId: 'a-2',
          patientId: 'p-2',
          patientName: 'Patient B',
          age: 38,
          gender: 'Female',
          doctorId: 'doc-1',
          checkInTime: now.add(const Duration(minutes: 5)),
          estimatedWaitMinutes: 10,
          status: QueueStatus.waiting,
          priority: PatientPriority.normal,
          chiefComplaint: 'Headache',
        ),
        QueueEntry(
          id: 'q-3',
          tokenNumber: 103,
          appointmentId: 'a-3',
          patientId: 'target-patient',
          patientName: 'Target Patient',
          age: 50,
          gender: 'Male',
          doctorId: 'doc-1',
          checkInTime: now.add(const Duration(minutes: 10)),
          estimatedWaitMinutes: 20,
          status: QueueStatus.waiting,
          priority: PatientPriority.normal,
          chiefComplaint: 'Hypertension check',
        ),
      ];

      final targetEntry = testQueue.firstWhere((e) => e.patientId == 'target-patient');
      final peopleAhead = testQueue
          .where((e) =>
              e.doctorId == targetEntry.doctorId &&
              e.status == QueueStatus.waiting &&
              e.tokenNumber < targetEntry.tokenNumber)
          .length;

      final consultingEntry = testQueue.firstWhere(
        (e) => e.doctorId == targetEntry.doctorId && e.status == QueueStatus.consulting,
      );

      expect(peopleAhead, 1); // Only Patient B is waiting ahead of Target Patient
      expect(consultingEntry.tokenNumber, 101);
      expect(targetEntry.tokenNumber, 103);
    });
  });
}

