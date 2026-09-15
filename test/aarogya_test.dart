import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/shared/data/repositories/aarogya_repository.dart';
import 'package:aarogya/shared/domain/models/appointment.dart';
import 'package:aarogya/shared/domain/models/invoice.dart';
import 'package:aarogya/shared/domain/models/prescription.dart';
import 'package:aarogya/shared/domain/models/queue_entry.dart';
import 'package:aarogya/shared/domain/models/user_role.dart';

void main() {
  group('AarogyaRepository Unit Tests', () {
    late AarogyaRepository repo;

    setUp(() {
      repo = AarogyaRepository();
    });

    test('Initial repository state loaded with seed clinical data', () {
      expect(repo.doctors.isNotEmpty, true);
      expect(repo.patients.isNotEmpty, true);
      expect(repo.appointments.isNotEmpty, true);
      expect(repo.queue.isNotEmpty, true);
      expect(repo.activeRole, UserRole.patient);
    });

    test('Switch role updates active role and session user', () {
      repo.switchRole(UserRole.doctor);
      expect(repo.activeRole, UserRole.doctor);
      expect(repo.currentUser.name.contains('Dr.'), true);

      repo.switchRole(UserRole.admin);
      expect(repo.activeRole, UserRole.admin);
    });

    test('Booking an appointment generates confirmed appointment, invoice, and notification', () {
      final doc = repo.doctors.first;
      final initialAptCount = repo.appointments.length;
      final initialInvCount = repo.invoices.length;

      final apt = repo.bookAppointment(
        doctor: doc,
        date: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '10:00 AM',
        type: ConsultationType.inPerson,
        symptoms: 'Routine cardio check',
      );

      expect(repo.appointments.length, initialAptCount + 1);
      expect(repo.invoices.length, initialInvCount + 1);
      expect(apt.status, AppointmentStatus.confirmed);
      expect(apt.fee, doc.consultationFee);
      expect(apt.doctorName, doc.name);
    });

    test('Queue status updates and call next in queue', () {
      final initialWaiting = repo.queue.where((q) => q.status == QueueStatus.waiting).toList();
      expect(initialWaiting.isNotEmpty, true);

      repo.callNextInQueue();
      final consulting = repo.queue.where((q) => q.status == QueueStatus.consulting).toList();
      expect(consulting.isNotEmpty, true);
    });

    test('Complete consultation generates signed prescription and medical record', () {
      final patient = repo.patients.first;
      final initialRxCount = repo.prescriptions.length;
      final initialRecordsCount = repo.medicalRecords.length;

      repo.completeConsultation(
        appointmentId: 'apt-test-1',
        patient: patient,
        chiefComplaint: 'Mild palpitations',
        symptoms: ['Chest tightness', 'Fatigue'],
        vitals: patient.vitals,
        diagnosis: 'Mild Sinus Tachycardia',
        clinicalNotes: 'Advised rest and hydration.',
        medications: [
          const Medication(
            id: 'm-test',
            name: 'Metoprolol',
            dosage: '25 mg',
            frequency: '1-0-0',
            duration: '14 Days',
            instructions: 'After breakfast',
          ),
        ],
        orderedLabTests: ['Resting 12-Lead ECG'],
      );

      expect(repo.prescriptions.length, initialRxCount + 1);
      expect(repo.medicalRecords.length, initialRecordsCount + 2); // consultation + prescription
    });

    test('Paying invoice updates invoice status to paid and registers receipt', () {
      final pendingInv = repo.invoices.firstWhere((inv) => inv.status == InvoiceStatus.pending);
      repo.payInvoice(pendingInv.id, 'UPI (test@upi)');

      final updated = repo.invoices.firstWhere((inv) => inv.id == pendingInv.id);
      expect(updated.status, InvoiceStatus.paid);
      expect(updated.paymentMethod, 'UPI (test@upi)');
    });
  });
}
