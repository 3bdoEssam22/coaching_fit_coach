import 'package:coaching_fit_coach/core/constants/api_constants.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/network/dio_client.dart';
import 'package:coaching_fit_coach/features/auth/data/models/auth_response.dart';
import 'package:coaching_fit_coach/features/auth/data/models/login_request.dart';
import 'package:coaching_fit_coach/features/auth/data/models/register_request.dart';
import 'package:dio/dio.dart';

abstract class AuthRepository {
  Future<void> register(RegisterRequest request);
  Future<AuthResponse> login(LoginRequest request);
  Future<void> getMe();
  Future<void> confirmEmail(String userId, String token);
  Future<void> resendConfirmation(String email);
}

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;

  AuthRepositoryImpl(this._dioClient);

  String _dioFailureMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (data is String && data.isNotEmpty) return data;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check that the backend is running.';
      case DioExceptionType.connectionError:
        return 'Cannot reach the server at ${e.requestOptions.baseUrl}. Is the gateway running?';
      case DioExceptionType.badCertificate:
        return 'Bad SSL certificate.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badResponse:
        return 'Server returned ${e.response?.statusCode}.';
      case DioExceptionType.unknown:
        return e.message ?? 'Network error: ${e.error}';
    }
  }

  @override
  Future<void> register(RegisterRequest request) async {
    try {
      await _dioClient.dio.post(ApiConstants.registerCoach, data: request.toJson());
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(ApiConstants.login, data: request.toJson());
      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }

  @override
  Future<void> getMe() async {
    try {
      await _dioClient.dio.get(ApiConstants.getMe);
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }

  @override
  Future<void> confirmEmail(String userId, String token) async {
    try {
      await _dioClient.dio.get(
        ApiConstants.confirmEmail,
        queryParameters: {'userId': userId, 'token': token},
      );
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }

  @override
  Future<void> resendConfirmation(String email) async {
    try {
      await _dioClient.dio.post(
        ApiConstants.resendConfirmation,
        queryParameters: {'email': email},
      );
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }
}
