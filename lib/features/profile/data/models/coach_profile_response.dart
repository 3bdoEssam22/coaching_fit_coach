import 'package:json_annotation/json_annotation.dart';

part 'coach_profile_response.g.dart';

@JsonSerializable()
class CoachProfileResponse {
  final String id;
  final String userId;
  final String gender;
  final String bio;
  final int experienceYears;
  final String? photoUrl;
  final bool isActive;

  CoachProfileResponse({
    required this.id,
    required this.userId,
    required this.gender,
    required this.bio,
    required this.experienceYears,
    this.photoUrl,
    required this.isActive,
  });

  factory CoachProfileResponse.fromJson(Map<String, dynamic> json) => _$CoachProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CoachProfileResponseToJson(this);
}
