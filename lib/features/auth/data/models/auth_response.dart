import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final String? token;        // null on register, present on login
  final DateTime? expiresAt;  // null on register

  AuthResponse({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    this.token,
    this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

