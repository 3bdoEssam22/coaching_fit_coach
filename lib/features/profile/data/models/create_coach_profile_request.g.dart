// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_coach_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateCoachProfileRequest _$CreateCoachProfileRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCoachProfileRequest(
      gender: json['gender'] as String,
      bio: json['bio'] as String,
      experienceYears: (json['experienceYears'] as num).toInt(),
    );

Map<String, dynamic> _$CreateCoachProfileRequestToJson(
        CreateCoachProfileRequest instance) =>
    <String, dynamic>{
      'gender': instance.gender,
      'bio': instance.bio,
      'experienceYears': instance.experienceYears,
    };
