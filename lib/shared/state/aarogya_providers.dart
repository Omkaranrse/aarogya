import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/aarogya_repository.dart';
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

// Theme Mode Provider (Dark Glass default for futuristic medical look)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// Master Repository Provider
final repositoryProvider = ChangeNotifierProvider<AarogyaRepository>((ref) {
  return AarogyaRepository();
});

// Active Session Providers
final activeRoleProvider = Provider<UserRole>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.activeRole;
});

final currentUserProvider = Provider<User>((ref) {
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
    final matchesQuery = query.isEmpty ||
        doc.name.toLowerCase().contains(query) ||
        doc.specialty.toLowerCase().contains(query) ||
        doc.hospital.toLowerCase().contains(query);

    final matchesSpecialty = specialty == null ||
        specialty == 'All' ||
        doc.specialty.toLowerCase() == specialty.toLowerCase();

    return matchesQuery && matchesSpecialty;
  }).toList();
});

// Patient & Appointments Providers
final currentPatientProfileProvider = Provider<Patient>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.patients.first;
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
