class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String qualifications;
  final int experienceYears;
  final double rating;
  final int reviewsCount;
  final double consultationFee;
  final String hospital;
  final String bio;
  final String avatarUrl;
  final List<String> availableDays;
  final List<String> timeSlots;
  final bool isAvailableToday;
  final bool isVerified;
  final String departmentId;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualifications,
    required this.experienceYears,
    required this.rating,
    required this.reviewsCount,
    required this.consultationFee,
    required this.hospital,
    required this.bio,
    required this.avatarUrl,
    required this.availableDays,
    required this.timeSlots,
    this.isAvailableToday = true,
    this.isVerified = true,
    this.departmentId = 'dept-cardio',
  });

  Doctor copyWith({
    String? id,
    String? name,
    String? specialty,
    String? qualifications,
    int? experienceYears,
    double? rating,
    int? reviewsCount,
    double? consultationFee,
    String? hospital,
    String? bio,
    String? avatarUrl,
    List<String>? availableDays,
    List<String>? timeSlots,
    bool? isAvailableToday,
    bool? isVerified,
    String? departmentId,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      qualifications: qualifications ?? this.qualifications,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      consultationFee: consultationFee ?? this.consultationFee,
      hospital: hospital ?? this.hospital,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      availableDays: availableDays ?? this.availableDays,
      timeSlots: timeSlots ?? this.timeSlots,
      isAvailableToday: isAvailableToday ?? this.isAvailableToday,
      isVerified: isVerified ?? this.isVerified,
      departmentId: departmentId ?? this.departmentId,
    );
  }
}
