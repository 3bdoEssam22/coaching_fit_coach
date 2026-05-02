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
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
      role: json['role'] as String,
    );

Map<String, dynamic> _$CoachProfileResponseToJson(
        CoachProfileResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'gender': instance.gender,
      'bio': instance.bio,
      'experienceYears': instance.experienceYears,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'role': instance.role,
    };
