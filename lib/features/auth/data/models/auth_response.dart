import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

String _stringFromJson(dynamic json) => json?.toString() ?? '';

@JsonSerializable()
class AuthResponse {
  @JsonKey(fromJson: _stringFromJson)
  final String? token;
  @JsonKey(fromJson: _stringFromJson)
  final String? refreshToken;
  @JsonKey(fromJson: _stringFromJson)
  final String role;
  @JsonKey(fromJson: _stringFromJson)
  final String userId;
  @JsonKey(fromJson: _stringFromJson)
  final String fullName;
  final bool isActive;

  AuthResponse({
    this.token,
    this.refreshToken,
    required this.role,
    required this.userId,
    required this.fullName,
    this.isActive = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}