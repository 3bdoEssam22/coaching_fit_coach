import 'dart:io';
import 'package:coaching_fit_coach/core/constants/api_constants.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/network/dio_client.dart';
import 'package:coaching_fit_coach/features/profile/data/models/coach_profile_response.dart';
import 'package:coaching_fit_coach/features/profile/data/models/create_coach_profile_request.dart';

import 'package:dio/dio.dart';

abstract class ProfileRepository {
  Future<void> createProfile(CreateCoachProfileRequest request, {File? photo});
  Future<CoachProfileResponse> getMyProfile();
  Future<CoachProfileResponse> getProfileById(String id);
  Future<void> updateProfile({String? bio, int? experienceYears, File? photo});
}

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient _dioClient;

  ProfileRepositoryImpl(this._dioClient);

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
  Future<void> createProfile(CreateCoachProfileRequest request, {File? photo}) async {
    try {
      final formData = FormData.fromMap({
        'gender': request.gender,
        'bio': request.bio,
        'experienceYears': request.experienceYears,
        if (photo != null) 'photo': await MultipartFile.fromFile(photo.path),
      });
      await _dioClient.dio.post(ApiConstants.coachProfile, data: formData);
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }

  @override
  Future<CoachProfileResponse> getMyProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.getMyProfile);
      return CoachProfileResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundFailure('Profile not found');
      }
      throw ServerFailure(_dioFailureMessage(e));
    }
  }



  @override
  Future<CoachProfileResponse> getProfileById(String id) async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.coachProfile}/$id');
      return CoachProfileResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }

  @override
  Future<void> updateProfile({String? bio, int? experienceYears, File? photo}) async {
    try {
      final formData = FormData.fromMap({
        if (bio != null) 'bio': bio,
        if (experienceYears != null) 'experienceYears': experienceYears,
        if (photo != null) 'photo': await MultipartFile.fromFile(photo.path),
      });
      await _dioClient.dio.put(ApiConstants.coachProfile, data: formData);
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }
}
