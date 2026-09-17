import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';
import '../../core/auth/biometric_auth_service.dart';
import '../data/repositories/aarogya_repository.dart';
import '../data/repositories/domain/queue_domain_repository.dart';
import '../data/repositories/domain/appointment_domain_repository.dart';
import '../data/repositories/domain/lab_domain_repository.dart';
import '../data/repositories/domain/consultation_domain_repository.dart';
import '../data/repositories/domain/billing_domain_repository.dart';
import '../domain/models/appointment.dart';
import '../domain/models/doctor.dart';
import '../domain/models/invoice.dart';
import '../domain/models/lab_report.dart';
import '../domain/models/medical_record.dart';
import '../domain/models/notification_item.dart';
import '../domain/models/patient.dart';
import '../domain/models/prescription.dart';
import '../domain/models/queue_entry.dart';
import '../domain/models/user.dart';

// Theme Mode Provider (Clinical Light default)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Master Repository Provider
final repositoryProvider = ChangeNotifierProvider<AarogyaRepository>((ref) {
  return AarogyaRepository();
});

// Domain Repositories Providers (Modular Architecture)
final queueDomainRepoProvider = Provider<QueueDomainRepository>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.queueDomainRepo;
});

final appointmentDomainRepoProvider = Provider<AppointmentDomainRepository>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.appointmentDomainRepo;
});

final labDomainRepoProvider = Provider<LabDomainRepository>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.labDomainRepo;
});

final consultationDomainRepoProvider = Provider<ConsultationDomainRepository>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.consultationDomainRepo;
});

final billingDomainRepoProvider = Provider<BillingDomainRepository>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.billingDomainRepo;
});

// ============================================================================
// Riverpod AsyncNotifiers (Reactive, Modern State Management)
// ============================================================================

class QueueAsyncNotifier extends AsyncNotifier<List<QueueEntry>> {
  @override
  Future<List<QueueEntry>> build() async {
    final repo = ref.watch(queueDomainRepoProvider);
    return repo.fetchQueue();
  }

  Future<void> updateStatus(String queueId, QueueStatus newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(queueDomainRepoProvider);
      repo.updateStatus(queueId, newStatus);
      return repo.fetchQueue();
    });
  }

  Future<QueueEntry?> callNext() async {
    QueueEntry? called;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(queueDomainRepoProvider);
      called = repo.callNext();
      return repo.fetchQueue();
    });
    return called;
  }

  Future<QueueEntry> addPatient({
    required String patientName,
    required int age,
    required String gender,
    required String chiefComplaint,
    PatientPriority? priority,
    PatientVitals? vitals,
    String? appointmentId,
    String? patientId,
    String? doctorId,
  }) async {
    late QueueEntry entry;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(queueDomainRepoProvider);
      entry = repo.addPatient(
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
      return repo.fetchQueue();
    });
    return entry;
  }
}

final asyncQueueProvider =
    AsyncNotifierProvider<QueueAsyncNotifier, List<QueueEntry>>(
  QueueAsyncNotifier.new,
);

class AppointmentsAsyncNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    final repo = ref.watch(appointmentDomainRepoProvider);
    return repo.fetchAppointments();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(appointmentDomainRepoProvider);
      repo.cancelAppointment(appointmentId);
      return repo.fetchAppointments();
    });
  }

  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
    required String newTimeSlot,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(appointmentDomainRepoProvider);
      repo.rescheduleAppointment(
        appointmentId: appointmentId,
        newDateTime: newDateTime,
        newTimeSlot: newTimeSlot,
      );
      return repo.fetchAppointments();
    });
  }

  Future<QueueEntry> checkInWithVitals({
    required String appointmentId,
    required PatientVitals vitals,
    String? patientName,
    int? age,
    String? gender,
    String? chiefComplaint,
  }) async {
    late QueueEntry entry;
    state = await AsyncValue.guard(() async {
      final repo = ref.read(appointmentDomainRepoProvider);
      entry = repo.checkInAppointment(
        appointmentId: appointmentId,
        vitals: vitals,
        patientName: patientName,
        age: age,
        gender: gender,
        chiefComplaint: chiefComplaint,
      );
      ref.invalidate(asyncQueueProvider);
      return repo.fetchAppointments();
    });
    return entry;
  }
}

final asyncAppointmentsProvider =
    AsyncNotifierProvider<AppointmentsAsyncNotifier, List<Appointment>>(
  AppointmentsAsyncNotifier.new,
);

class LabReportsAsyncNotifier extends AsyncNotifier<List<LabReport>> {
  @override
  Future<List<LabReport>> build() async {
    final repo = ref.watch(labDomainRepoProvider);
    return repo.fetchReports();
  }

  Future<void> updateStatus(String reportId, ReportStatus newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(labDomainRepoProvider);
      repo.updateReportStatus(reportId, newStatus);
      return repo.fetchReports();
    });
  }
}

final asyncLabReportsProvider =
    AsyncNotifierProvider<LabReportsAsyncNotifier, List<LabReport>>(
  LabReportsAsyncNotifier.new,
);


// Authentication Service Provider
final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService();
});

// Clinical Biometric Auth Provider
final biometricAuthServiceProvider = ChangeNotifierProvider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

final isStationLockedProvider = Provider<bool>((ref) {
  final bio = ref.watch(biometricAuthServiceProvider);
  return bio.isStationLocked;
});

// Authentication State
final isAuthenticatedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.isAuthenticated;
});

// Active Session Providers
final activeRoleProvider = Provider<UserRole>((ref) {
  final auth = ref.watch(authServiceProvider);
  if (auth.isAuthenticated && auth.appUser != null) {
    return auth.currentRole;
  }
  final repo = ref.watch(repositoryProvider);
  return repo.activeRole;
});

final currentUserProvider = Provider<User>((ref) {
  final auth = ref.watch(authServiceProvider);
  if (auth.isAuthenticated && auth.appUser != null) {
    return auth.appUser!;
  }
  final repo = ref.watch(repositoryProvider);
  return repo.currentUser;
});

// Doctors & Discovery Providers
final doctorsListProvider = Provider<List<Doctor>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.doctors;
});

final doctorSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedSpecialtyFilterProvider = StateProvider<String?>((ref) => null);

final filteredDoctorsProvider = Provider<List<Doctor>>((ref) {
  final doctors = ref.watch(doctorsListProvider);
  final query = ref.watch(doctorSearchQueryProvider).toLowerCase().trim();
  final specialty = ref.watch(selectedSpecialtyFilterProvider);

  return doctors.where((doc) {
    final matchesQuery =
        query.isEmpty ||
        doc.name.toLowerCase().contains(query) ||
        doc.specialty.toLowerCase().contains(query) ||
        doc.hospital.toLowerCase().contains(query);

    final matchesSpecialty =
        specialty == null ||
        specialty == 'All' ||
        doc.specialty.toLowerCase() == specialty.toLowerCase();

    return matchesQuery && matchesSpecialty;
  }).toList();
});

// Patient & Appointments Providers
final currentPatientProfileProvider = Provider<Patient>((ref) {
  final user = ref.watch(currentUserProvider);
  final repo = ref.watch(repositoryProvider);

  return repo.patients.firstWhere(
    (p) => p.id == user.id || p.email == user.email,
    orElse: () {
      if (repo.patients.isNotEmpty) {
        final sample = repo.patients.first;
        return sample.copyWith(
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone ?? sample.phone,
        );
      }
      return Patient(
        id: user.id,
        name: user.name,
        age: 32,
        gender: 'Other',
        bloodGroup: 'O+',
        phone: user.phone ?? '+91 98765 43210',
        email: user.email,
        allergies: const ['None recorded'],
        chronicConditions: const [],
        emergencyContact: '+91 98765 43211',
        avatarUrl: user.avatarUrl ??
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=256',
        vitals: PatientVitals(
          bloodPressure: '120/80',
          heartRate: 72,
          spo2: 98,
          temperature: 98.4,
          weight: 68.0,
          recordedAt: DateTime.now(),
        ),
      );
    },
  );
});

final allPatientsProvider = Provider<List<Patient>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.patients;
});

final appointmentsProvider = Provider<List<Appointment>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.appointments;
});

// Live Queue Provider
final liveQueueProvider = Provider<List<QueueEntry>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.queue;
});

// Prescriptions Provider
final prescriptionsProvider = Provider<List<Prescription>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.prescriptions;
});

// Lab Reports Provider
final labReportsProvider = Provider<List<LabReport>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.labReports;
});

// Medical Records Provider
final medicalRecordsProvider = Provider<List<MedicalRecord>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.medicalRecords;
});

// Invoices Provider
final invoicesProvider = Provider<List<Invoice>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.invoices;
});

// Notifications Provider
final notificationsProvider = Provider<List<NotificationItem>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.notifications;
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.unreadNotificationCount;
});
