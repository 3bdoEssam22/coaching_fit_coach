// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      token: _stringFromJson(json['token']),
      role: _stringFromJson(json['role']),
      userId: _stringFromJson(json['userId']),
      fullName: _stringFromJson(json['fullName']),
      isActive: json['isActive'] as bool? ?? false,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'role': instance.role,
      'userId': instance.userId,
      'fullName': instance.fullName,
      'isActive': instance.isActive,
    };
