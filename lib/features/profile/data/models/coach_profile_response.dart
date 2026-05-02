import 'package:json_annotation/json_annotation.dart';

part 'coach_profile_response.g.dart';

int _experienceYearsFromJson(dynamic json) {
  if (json is int) {
    return json;
  }
  if (json is String) {
    return int.tryParse(json) ?? 0;
  }
  return 0;
}

@JsonSerializable()
class CoachProfileResponse {
  final String id;
  final String userId;
  final String gender;
  final String bio;
  @JsonKey(fromJson: _experienceYearsFromJson)
  final int experienceYears;
  final String? profilePhotoUrl;
  final bool isActive;
  final String role;
  final DateTime createdAt;

  CoachProfileResponse({
    required this.id,
    required this.userId,
    required this.gender,
    required this.bio,
    required this.experienceYears,
    this.profilePhotoUrl,
    required this.isActive,
    required this.role,
    required this.createdAt,
  });

  factory CoachProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$CoachProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CoachProfileResponseToJson(this);
}
