import 'package:json_annotation/json_annotation.dart';

part 'create_coach_profile_request.g.dart';

@JsonSerializable()
class CreateCoachProfileRequest {
  final String gender;
  final String bio;
  final int experienceYears;

  CreateCoachProfileRequest({
    required this.gender,
    required this.bio,
    required this.experienceYears,
  });

  Map<String, dynamic> toJson() => _$CreateCoachProfileRequestToJson(this);
}
