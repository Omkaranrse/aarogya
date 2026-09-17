class PatientVitals {
  final String bloodPressure;
  final int heartRate;
  final double spo2;
  final double temperature;
  final double weight;
  final DateTime recordedAt;
  final int? respiratoryRate;

  const PatientVitals({
    required this.bloodPressure,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.weight,
    required this.recordedAt,
    this.respiratoryRate,
  });

  PatientVitals copyWith({
    String? bloodPressure,
    int? heartRate,
    double? spo2,
    double? temperature,
    double? weight,
    DateTime? recordedAt,
    int? respiratoryRate,
  }) {
    return PatientVitals(
      bloodPressure: bloodPressure ?? this.bloodPressure,
      heartRate: heartRate ?? this.heartRate,
      spo2: spo2 ?? this.spo2,
      temperature: temperature ?? this.temperature,
      weight: weight ?? this.weight,
      recordedAt: recordedAt ?? this.recordedAt,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
    );
  }
}

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final String phone;
  final String email;
  final List<String> allergies;
  final List<String> chronicConditions;
  final PatientVitals vitals;
  final String emergencyContact;
  final String avatarUrl;

  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.phone,
    required this.email,
    required this.allergies,
    required this.chronicConditions,
    required this.vitals,
    required this.emergencyContact,
    required this.avatarUrl,
  });

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? bloodGroup,
    String? phone,
    String? email,
    List<String>? allergies,
    List<String>? chronicConditions,
    PatientVitals? vitals,
    String? emergencyContact,
    String? avatarUrl,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      vitals: vitals ?? this.vitals,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
