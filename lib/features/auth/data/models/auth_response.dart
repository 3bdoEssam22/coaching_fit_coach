import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

String _stringFromJson(dynamic json) => json.toString();

@JsonSerializable()
class AuthResponse {
  @JsonKey(fromJson: _stringFromJson)
  final String token;
  @JsonKey(fromJson: _stringFromJson)
  final String role;
  @JsonKey(fromJson: _stringFromJson)
  final String userId;

  AuthResponse({required this.token, required this.role, required this.userId});

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

