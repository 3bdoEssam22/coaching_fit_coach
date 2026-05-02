import 'dart:io';
import 'package:coaching_fit_coach/core/constants/api_constants.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/network/dio_client.dart';
import 'package:coaching_fit_coach/features/profile/data/models/coach_profile_response.dart';
import 'package:coaching_fit_coach/features/profile/data/models/create_coach_profile_request.dart';
import 'package:coaching_fit_coach/features/profile/data/models/user_response.dart';
import 'package:dio/dio.dart';

abstract class ProfileRepository {
  Future<void> createProfile(CreateCoachProfileRequest request, {File? photo});
  Future<CoachProfileResponse> getMyProfile();
  Future<CoachProfileResponse> getProfileById(String id);
  Future<void> updateProfile({String? bio, int? experienceYears, File? photo});
  Future<UserResponse> getUser();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient _dioClient;

  ProfileRepositoryImpl(this._dioClient);

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
      throw ServerFailure(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<CoachProfileResponse> getMyProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.getMyProfile);
      return CoachProfileResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundFailure('Profile not found');
      }
      throw ServerFailure(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<UserResponse> getUser() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.getMe);
      return UserResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<CoachProfileResponse> getProfileById(String id) async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.coachProfile}/$id');
      return CoachProfileResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'An error occurred');
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
      throw ServerFailure(e.response?.data['message'] ?? 'An error occurred');
    }
  }
}
