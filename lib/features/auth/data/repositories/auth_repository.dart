import 'package:coaching_fit_coach/core/constants/api_constants.dart';
import 'package:coaching_fit_coach/core/errors/dio_error_handler.dart';
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

  @override
  Future<void> register(RegisterRequest request) async {
    try {
      await _dioClient.dio.post(ApiConstants.registerCoach, data: request.toJson());
    } on DioException catch (e) {
      throw ServerFailure(dioFailureMessage(e));
    }
  }

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.dio.post(ApiConstants.login, data: request.toJson());
      return AuthResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(dioFailureMessage(e));
    }
  }

  @override
  Future<void> getMe() async {
    try {
      await _dioClient.dio.get(ApiConstants.getMe);
    } on DioException catch (e) {
      throw ServerFailure(dioFailureMessage(e));
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
      throw ServerFailure(dioFailureMessage(e));
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
      throw ServerFailure(dioFailureMessage(e));
    }
  }
}
