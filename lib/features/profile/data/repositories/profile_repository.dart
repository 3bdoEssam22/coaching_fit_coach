import 'dart:io';
import 'package:coaching_fit_coach/core/constants/api_constants.dart';
import 'package:coaching_fit_coach/core/errors/dio_error_handler.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/network/dio_client.dart';
import 'package:coaching_fit_coach/features/profile/data/models/coach_profile_response.dart';
import 'package:coaching_fit_coach/features/profile/domain/entities/coach_profile.dart';
import 'package:dio/dio.dart';

abstract class ProfileRepository {
  Future<void> createProfile({
    required String gender,
    required String bio,
    required int experienceYears,
    File? photo,
  });
  Future<CoachProfile> getMyProfile();
  Future<CoachProfile> getProfileById(String id);
  Future<void> updateProfile({String? bio, int? experienceYears, File? photo});
}

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient _dioClient;

  ProfileRepositoryImpl(this._dioClient);

  CoachProfile _toEntity(CoachProfileResponse r) => CoachProfile(
        id: r.id,
        userId: r.userId,
        gender: r.gender,
        bio: r.bio,
        experienceYears: r.experienceYears,
        profilePhotoUrl: r.profilePhotoUrl,
        createdAt: r.createdAt,
      );

  @override
  Future<void> createProfile({
    required String gender,
    required String bio,
    required int experienceYears,
    File? photo,
  }) async {
    try {
      final formData = FormData.fromMap({
        'gender': gender,
        'bio': bio,
        'experienceYears': experienceYears,
        if (photo != null) 'photo': await MultipartFile.fromFile(photo.path),
      });
      await _dioClient.dio.post(ApiConstants.coachProfile, data: formData);
    } on DioException catch (e) {
      throw ServerFailure(dioFailureMessage(e));
    }
  }

  @override
  Future<CoachProfile> getMyProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.getMyProfile);
      return _toEntity(CoachProfileResponse.fromJson(response.data['data']));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundFailure('Profile not found');
      }
      throw ServerFailure(dioFailureMessage(e));
    }
  }

  @override
  Future<CoachProfile> getProfileById(String id) async {
    try {
      final response = await _dioClient.dio.get('${ApiConstants.coachProfile}/$id');
      return _toEntity(CoachProfileResponse.fromJson(response.data['data']));
    } on DioException catch (e) {
      throw ServerFailure(dioFailureMessage(e));
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
      throw ServerFailure(dioFailureMessage(e));
    }
  }
}
