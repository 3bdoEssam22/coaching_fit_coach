class CoachProfile {
  final String id;
  final String userId;
  final String gender;
  final String bio;
  final int experienceYears;
  final String? profilePhotoUrl;
  final DateTime createdAt;

  const CoachProfile({
    required this.id,
    required this.userId,
    required this.gender,
    required this.bio,
    required this.experienceYears,
    this.profilePhotoUrl,
    required this.createdAt,
  });
}
