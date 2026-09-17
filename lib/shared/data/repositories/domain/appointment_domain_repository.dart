import '../../../../core/backend/firebase_clinical_service.dart';
import '../../../domain/models/appointment.dart';
import '../../../domain/models/patient.dart';
import '../../../domain/models/queue_entry.dart';
import '../mock_data.dart';
import 'queue_domain_repository.dart';

/// Domain Repository for managing patient appointments, booking,
/// rescheduling, and vitals-driven clinical check-in.
class AppointmentDomainRepository {
  List<Appointment> _appointments = [];
  final QueueDomainRepository _queueRepo;

  AppointmentDomainRepository(this._queueRepo) {
    _appointments = List.from(AarogyaMockData.appointments);
  }

  List<Appointment> get appointments => List.unmodifiable(_appointments);

  Future<List<Appointment>> fetchAppointments() async {
    return List.unmodifiable(_appointments);
  }

  void syncFromCloud(List<Appointment> cloudAppointments) {
    if (cloudAppointments.isNotEmpty) {
      _appointments = List.from(cloudAppointments);
    }
  }

  Appointment bookAppointment({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String specialty,
    required String doctorAvatar,
    required DateTime dateTime,
    required String timeSlot,
    required ConsultationType type,
    required double fee,
    String? symptoms,
    String? notes,
  }) {
    final token = _appointments.length + 1;
    final aptId = 'apt-${DateTime.now().millisecondsSinceEpoch}';

    final appointment = Appointment(
      id: aptId,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      doctorAvatar: doctorAvatar,
      dateTime: dateTime,
      timeSlot: timeSlot,
      type: type,
      status: AppointmentStatus.confirmed,
      tokenNumber: token,
      fee: fee,
      symptoms: symptoms,
      notes: notes,
    );

    _appointments.insert(0, appointment);
    FirebaseClinicalService().syncAppointment(appointment);
    return appointment;
  }

  void cancelAppointment(String appointmentId) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(
        status: AppointmentStatus.cancelled,
      );
      FirebaseClinicalService().syncAppointment(_appointments[index]);
    }
  }

  void rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
    required String newTimeSlot,
  }) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final oldApt = _appointments[index];
      _appointments[index] = oldApt.copyWith(
        dateTime: newDateTime,
        timeSlot: newTimeSlot,
        status: AppointmentStatus.confirmed,
      );
      FirebaseClinicalService().syncAppointment(_appointments[index]);
    }
  }

  /// Checks in a patient for an appointment using physiological vitals.
  /// Transitions appointment status to [AppointmentStatus.waiting] and
  /// automatically triages into the live queue via NEWS2 scoring.
  QueueEntry checkInAppointment({
    required String appointmentId,
    required PatientVitals vitals,
    String? patientName,
    int? age,
    String? gender,
    String? chiefComplaint,
  }) {
    final aptIndex = _appointments.indexWhere((a) => a.id == appointmentId);
    Appointment? apt;
    if (aptIndex != -1) {
      _appointments[aptIndex] = _appointments[aptIndex].copyWith(
        status: AppointmentStatus.waiting,
      );
      FirebaseClinicalService().syncAppointment(_appointments[aptIndex]);
      apt = _appointments[aptIndex];
    }

    final entry = _queueRepo.addPatient(
      patientName: patientName ?? apt?.patientName ?? 'Checked-in Patient',
      age: age ?? 35,
      gender: gender ?? 'Unknown',
      chiefComplaint: chiefComplaint ?? apt?.symptoms ?? 'OPD Check-in Consultation',
      vitals: vitals,
      appointmentId: appointmentId,
      patientId: apt?.patientId,
      doctorId: apt?.doctorId,
    );

    return entry;
  }
}
