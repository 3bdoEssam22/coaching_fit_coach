// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoachProfileResponse _$CoachProfileResponseFromJson(
        Map<String, dynamic> json) =>
    CoachProfileResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      gender: json['gender'] as String,
      bio: json['bio'] as String,
      experienceYears: (json['experienceYears'] as num).toInt(),
      photoUrl: json['photoUrl'] as String?,
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$CoachProfileResponseToJson(
        CoachProfileResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'gender': instance.gender,
      'bio': instance.bio,
      'experienceYears': instance.experienceYears,
      'photoUrl': instance.photoUrl,
      'isActive': instance.isActive,
    };
