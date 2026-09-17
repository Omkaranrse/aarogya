import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/shared/data/repositories/aarogya_repository.dart';
import 'package:aarogya/shared/data/repositories/mock_data.dart';
import 'package:aarogya/shared/domain/models/encounter.dart';
import 'package:aarogya/shared/domain/models/invoice.dart';
import 'package:aarogya/shared/domain/models/lab_report.dart';
import 'package:aarogya/shared/domain/models/medical_record.dart';
import 'package:aarogya/shared/domain/models/patient.dart';
import 'package:aarogya/shared/domain/models/patient_session.dart';
import 'package:aarogya/shared/domain/models/prescription.dart';
import 'package:aarogya/core/clinical/reference_range_service.dart';

void main() {
  group('Phase P0.1 — Patient Identity Integrity & Security Guard Tests', () {
    test('PatientSession holds subject patientId', () {
      final session = PatientSession(
        patientId: 'pat-1',
        patientName: 'Omkar Anarse',
        sessionStartedAt: DateTime(2026, 9, 1),
      );
      expect(session.patientId, 'pat-1');
      expect(session.patientName, 'Omkar Anarse');
    });

    test('Accessing clinical records for mismatched patient throws PatientMismatchException', () {
      final repo = AarogyaRepository();
      repo.setPatientSession(
        PatientSession(
          patientId: 'pat-DIFFERENT-999',
          patientName: 'Rajesh Verma',
          sessionStartedAt: DateTime.now(),
        ),
      );

      expect(
        () => repo.appointments,
        throwsA(isA<PatientMismatchException>()),
      );

      expect(
        () => repo.prescriptions,
        throwsA(isA<PatientMismatchException>()),
      );

      expect(
        () => repo.invoices,
        throwsA(isA<PatientMismatchException>()),
      );

      expect(
        () => repo.labReports,
        throwsA(isA<PatientMismatchException>()),
      );

      expect(
        () => repo.medicalRecords,
        throwsA(isA<PatientMismatchException>()),
      );

      // Restore session
      repo.setPatientSession(AarogyaMockData.defaultSession);
    });

    test('Seeded mock data reconciles to a single patient session subject', () {
      final repo = AarogyaRepository();
      repo.setPatientSession(AarogyaMockData.defaultSession);

      for (final apt in repo.appointments) {
        expect(apt.patientId, 'pat-1');
      }
      for (final rx in repo.prescriptions) {
        expect(rx.patientId, 'pat-1');
      }
      for (final inv in repo.invoices) {
        expect(inv.patientId, 'pat-1');
      }
      for (final lr in repo.labReports) {
        expect(lr.patientId, 'pat-1');
      }
      for (final mr in repo.medicalRecords) {
        expect(mr.patientId, 'pat-1');
      }
    });
  });

  group('Phase P0.2 — Invoice Arithmetic & Integer Paise Reconciliation', () {
    test('Invoice total equals subtotal - discount + taxes + rounding in integer paise', () {
      final invoice = Invoice(
        id: 'inv-test-1',
        invoiceNumber: 'INV-TEST-001',
        patientId: 'pat-1',
        patientName: 'Omkar Anarse',
        date: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        items: const [
          InvoiceLineItem(
            description: 'Consultation Fee',
            quantity: 1,
            unitPricePaise: 120000, // ₹1200.00
            totalPaise: 120000,
          ),
          InvoiceLineItem(
            description: 'Facility Charge',
            quantity: 1,
            unitPricePaise: 15000, // ₹150.00
            totalPaise: 15000,
          ),
        ],
        subtotalPaise: 135000, // ₹1350.00
        discountPaise: 10000, // ₹100.00
        taxes: const [
          InvoiceTaxItem(
            label: 'GST (5%)',
            ratePercent: 5.0,
            amountPaise: 6250, // 5% of 125000 = ₹62.50
          ),
        ],
        roundingPaise: 0,
        totalPaise: 131250, // 135000 - 10000 + 6250 = 131250 (₹1312.50)
        amountPaidPaise: 100000,
        balanceDuePaise: 31250,
        status: InvoiceStatus.pending,
      );

      expect(invoice.computedTotalPaise, 131250);
      expect(invoice.totalPaise, 131250);
      expect(invoice.balanceDuePaise, 31250);
      expect(invoice.totalAmount, 1312.50);
      expect(invoice.balanceDue, 312.50);
    });

    test('Every seeded mock invoice satisfies exact arithmetic assertion', () {
      for (final invoice in AarogyaMockData.invoices) {
        expect(
          invoice.computedTotalPaise,
          invoice.totalPaise,
          reason: 'Mismatch in invoice ${invoice.invoiceNumber}',
        );
        expect(
          invoice.balanceDuePaise,
          invoice.totalPaise - invoice.amountPaidPaise,
        );
      }
    });

    test('Summary tiles (Pending Dues & Settled) equal the fold over invoices', () {
      final repo = AarogyaRepository();
      repo.setPatientSession(AarogyaMockData.defaultSession);

      final expectedPending = repo.invoices
          .where((i) => i.status == InvoiceStatus.pending)
          .fold<int>(0, (sum, i) => sum + i.balanceDuePaise);

      final expectedSettled = repo.invoices
          .where((i) => i.status == InvoiceStatus.paid)
          .fold<int>(0, (sum, i) => sum + i.amountPaidPaise);

      expect(repo.totalPendingDuesPaise, expectedPending);
      expect(repo.totalSettledPaise, expectedSettled);
      expect(repo.totalPendingDues, expectedPending / 100.0);
      expect(repo.totalSettled, expectedSettled / 100.0);
    });
  });

  group('Phase P0.3 — Timeline Ordering & Canonical Date Consistency', () {
    test('MedicalRecords are strictly sorted by occurredAt descending with stable ID tiebreaker', () {
      final now = DateTime.now();
      final records = [
        MedicalRecord(
          id: 'rec-c',
          patientId: 'pat-1',
          title: 'Older Event',
          type: MedicalRecordType.consultation,
          occurredAt: now.subtract(const Duration(days: 10)),
          doctorName: 'Dr. A',
          department: 'Cardiology',
          summary: 'Summary C',
        ),
        MedicalRecord(
          id: 'rec-a',
          patientId: 'pat-1',
          title: 'Same Time Event A',
          type: MedicalRecordType.prescription,
          occurredAt: now.subtract(const Duration(days: 2)),
          doctorName: 'Dr. B',
          department: 'Cardiology',
          summary: 'Summary A',
        ),
        MedicalRecord(
          id: 'rec-b',
          patientId: 'pat-1',
          title: 'Same Time Event B',
          type: MedicalRecordType.labReport,
          occurredAt: now.subtract(const Duration(days: 2)),
          doctorName: 'Dr. C',
          department: 'Lab',
          summary: 'Summary B',
        ),
        MedicalRecord(
          id: 'rec-d',
          patientId: 'pat-1',
          title: 'Newest Event',
          type: MedicalRecordType.consultation,
          occurredAt: now,
          doctorName: 'Dr. D',
          department: 'OPD',
          summary: 'Summary D',
        ),
      ];

      records.sort((a, b) => MedicalRecord.compareEvents(a, b, descending: true));

      expect(records[0].id, 'rec-d'); // Newest
      expect(records[1].id, 'rec-b'); // Same time, tiebreaker on ID descending
      expect(records[2].id, 'rec-a');
      expect(records[3].id, 'rec-c'); // Oldest
    });

    test('MedicalRecord date getter matches canonical occurredAt', () {
      final time = DateTime.utc(2026, 9, 15, 10, 30);
      final record = MedicalRecord(
        id: 'rec-test',
        patientId: 'pat-1',
        title: 'Diagnostic Test',
        type: MedicalRecordType.labReport,
        occurredAt: time,
        doctorName: 'Dr. Test',
        department: 'Diagnostic',
        summary: 'Test summary',
      );

      expect(record.date, time);
      expect(record.occurredAt, time);
    });
  });

  group('Phase P0.4 — Prescription Lifecycle & Day-Boundary Math', () {
    test('Medication ending yesterday, today, tomorrow classifies accurately across day boundaries', () {
      final now = DateTime(2026, 9, 17, 15, 30); // 3:30 PM today

      final medEndingYesterday = Medication(
        id: 'm-yest',
        name: 'Drug A',
        dosage: '10mg',
        frequency: '1-0-0',
        duration: '5 Days',
        instructions: 'After breakfast',
        startDate: DateTime(2026, 9, 10),
        endDate: DateTime(2026, 9, 16), // Yesterday
      );

      final medEndingToday = Medication(
        id: 'm-today',
        name: 'Drug B',
        dosage: '20mg',
        frequency: '0-0-1',
        duration: '7 Days',
        instructions: 'After dinner',
        startDate: DateTime(2026, 9, 11),
        endDate: DateTime(2026, 9, 17), // Today
      );

      final medEndingTomorrow = Medication(
        id: 'm-tomo',
        name: 'Drug C',
        dosage: '500mg',
        frequency: '1-0-1',
        duration: '10 Days',
        instructions: 'After food',
        startDate: DateTime(2026, 9, 12),
        endDate: DateTime(2026, 9, 18), // Tomorrow
      );

      final medStartingTomorrow = Medication(
        id: 'm-sched',
        name: 'Drug D',
        dosage: '5mg',
        frequency: '1-0-0',
        duration: '14 Days',
        instructions: 'Morning',
        startDate: DateTime(2026, 9, 18), // Starts tomorrow
        endDate: DateTime(2026, 10, 1),
      );

      expect(medEndingYesterday.getStatus(now), MedicationStatus.completed);
      expect(medEndingToday.getStatus(now), MedicationStatus.active);
      expect(medEndingTomorrow.getStatus(now), MedicationStatus.active);
      expect(medStartingTomorrow.getStatus(now), MedicationStatus.scheduled);
    });

    test('Days remaining and current day calculation is exact without wall-clock off-by-one errors', () {
      final today = DateTime(2026, 9, 17, 23, 59); // late evening
      final med = Medication(
        id: 'm-stat',
        name: 'Atorvastatin',
        dosage: '10mg',
        frequency: '0-0-1',
        duration: '30 Days',
        instructions: 'After food',
        startDate: DateTime(2026, 9, 3, 8, 0), // 14 days ago
        endDate: DateTime(2026, 10, 2, 20, 0), // 15 days ahead
      );

      expect(med.totalDays, 30);
      expect(med.currentDay(today), 15);
      expect(med.daysRemaining(today), 15);
      expect(med.progressLabel(today), 'Day 15 of 30');
    });

    test('Prescription active count derives from active medications only', () {
      final rxActive = Prescription(
        id: 'rx-1',
        consultationId: 'c-1',
        patientId: 'pat-1',
        patientName: 'Omkar Anarse',
        doctorId: 'doc-1',
        doctorName: 'Dr. Sharma',
        doctorSpecialty: 'Cardiology',
        date: DateTime.now().subtract(const Duration(days: 14)),
        medications: [
          Medication(
            id: 'm-1',
            name: 'Active Drug',
            dosage: '10mg',
            frequency: '1-0-0',
            duration: '30 Days',
            instructions: 'Morning',
            startDate: DateTime.now().subtract(const Duration(days: 14)),
            endDate: DateTime.now().add(const Duration(days: 16)),
          ),
          Medication(
            id: 'm-2',
            name: 'Completed Drug',
            dosage: '5mg',
            frequency: '0-0-1',
            duration: '5 Days',
            instructions: 'Night',
            startDate: DateTime.now().subtract(const Duration(days: 14)),
            endDate: DateTime.now().subtract(const Duration(days: 9)),
          ),
        ],
      );

      final rxCompleted = Prescription(
        id: 'rx-2',
        consultationId: 'c-2',
        patientId: 'pat-1',
        patientName: 'Omkar Anarse',
        doctorId: 'doc-1',
        doctorName: 'Dr. Sharma',
        doctorSpecialty: 'Cardiology',
        date: DateTime.now().subtract(const Duration(days: 30)),
        medications: [
          Medication(
            id: 'm-3',
            name: 'Expired Drug',
            dosage: '500mg',
            frequency: '1-0-1',
            duration: '5 Days',
            instructions: 'After food',
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now().subtract(const Duration(days: 25)),
          ),
        ],
      );

      expect(rxActive.hasActiveMedications(), isTrue);
      expect(rxActive.activeMedicationsCount(), 1);
      expect(rxActive.statusLabel(), 'Active');

      expect(rxCompleted.hasActiveMedications(), isFalse);
      expect(rxCompleted.activeMedicationsCount(), 0);
      expect(rxCompleted.statusLabel(), 'Completed');
    });
  });

  group('Phase P0.5 — Vitals Provenance & Staleness Tests', () {
    test('PatientVitals carries source and provenance label', () {
      final time = DateTime(2026, 9, 17, 10, 30);
      final vitals = PatientVitals(
        bloodPressure: '120/80',
        heartRate: 72,
        spo2: 99.0,
        temperature: 98.4,
        weight: 70.0,
        recordedAt: time,
        source: VitalSource.triageCounter,
      );

      expect(vitals.source.displayName, 'OPD Triage Desk');
      expect(vitals.provenanceLabel, 'as of 10:30 · OPD Triage Desk');
    });

    test('PatientVitals detects staleness after configurable duration threshold', () {
      final staleTime = DateTime.now().subtract(const Duration(hours: 6));
      final freshTime = DateTime.now().subtract(const Duration(minutes: 30));

      final staleVitals = PatientVitals(
        bloodPressure: '120/80',
        heartRate: 72,
        spo2: 99.0,
        temperature: 98.4,
        weight: 70.0,
        recordedAt: staleTime,
      );

      final freshVitals = PatientVitals(
        bloodPressure: '120/80',
        heartRate: 72,
        spo2: 99.0,
        temperature: 98.4,
        weight: 70.0,
        recordedAt: freshTime,
      );

      expect(staleVitals.isStale(threshold: const Duration(hours: 4)), isTrue);
      expect(freshVitals.isStale(threshold: const Duration(hours: 4)), isFalse);
    });
  });

  group('Phase P0.6 — Encounter-Scoped Records & Advised Diagnostics Tests', () {
    test('Encounter entity groups clinical records across specialties', () {
      final encounter = Encounter(
        id: 'enc-cardio-1',
        patientId: 'pat-1',
        doctorId: 'doc-1',
        doctorName: 'Dr. Ananya Sharma',
        department: 'Cardiology',
        occurredAt: DateTime.now().subtract(const Duration(days: 14)),
        type: EncounterType.opdConsultation,
        summary: 'Initial cardiology evaluation.',
      );

      expect(encounter.department, 'Cardiology');
      expect(encounter.type.displayName, 'OPD Consultation');
    });

    test('Advised diagnostic tests are explicitly represented as pending timeline records', () {
      final advisedRecord = MedicalRecord(
        id: 'rec-adv-1',
        patientId: 'pat-1',
        encounterId: 'enc-1',
        title: 'Advised 2D Echocardiogram — Result Pending',
        type: MedicalRecordType.advisedDiagnostic,
        occurredAt: DateTime.now().subtract(const Duration(days: 14)),
        doctorName: 'Dr. Ananya Sharma',
        department: 'Cardiology Non-Invasive Lab',
        summary: 'Advised 2D Echo for LV function.',
        isAdvisedPending: true,
      );

      expect(advisedRecord.isAdvisedPending, isTrue);
      expect(advisedRecord.type, MedicalRecordType.advisedDiagnostic);
      expect(advisedRecord.type.displayName, 'Advised Test — Pending');
    });

    test('ReferenceRangeService returns consistent labels and glyphs for laboratory tests', () {
      final ldlEval = ReferenceRangeService.evaluate(
        testName: 'LDL Cholesterol',
        value: 138.0,
        minRange: 0.0,
        maxRange: 100.0,
      );

      expect(ldlEval.status, LabResultStatus.high);
      expect(ldlEval.label, 'High');
      expect(ldlEval.glyph, '↑');
      expect(ldlEval.spokenSemantics, 'LDL Cholesterol, 138.0 mg/dL, high, reference range up to 100.0.');

      final hdlEval = ReferenceRangeService.evaluate(
        testName: 'HDL Cholesterol',
        value: 48.0,
        minRange: 40.0,
        maxRange: 60.0,
      );

      expect(hdlEval.status, LabResultStatus.normal);
      expect(hdlEval.label, 'Normal');
      expect(hdlEval.glyph, '●');
    });
  });
}
