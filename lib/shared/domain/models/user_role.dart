enum UserRole {
  patient,
  doctor,
  admin,
  receptionist,
  labTechnician;

  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.admin:
        return 'Hospital Admin';
      case UserRole.receptionist:
        return 'Receptionist';
      case UserRole.labTechnician:
        return 'Lab Technician';
    }
  }
}
