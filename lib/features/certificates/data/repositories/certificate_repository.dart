import 'dart:io';
import 'package:coaching_fit_coach/core/constants/api_constants.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/network/dio_client.dart';
import 'package:coaching_fit_coach/features/certificates/data/models/certificate_response.dart';
import 'package:dio/dio.dart';

abstract class CertificateRepository {
  Future<List<CertificateResponse>> getMyCertificates();
  Future<CertificateResponse> upload({
    required String title,
    required String issuingOrganization,
    required DateTime issuedDate,
    required File file,
  });
  Future<void> delete(String id);
}

class CertificateRepositoryImpl implements CertificateRepository {
  final DioClient _dioClient;

  CertificateRepositoryImpl(this._dioClient);

  @override
  Future<List<CertificateResponse>> getMyCertificates() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.myCertificates);
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => CertificateResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<CertificateResponse> upload({
    required String title,
    required String issuingOrganization,
    required DateTime issuedDate,
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'issuingOrganization': issuingOrganization,
        'issuedDate': issuedDate.toIso8601String(),
        'file': await MultipartFile.fromFile(file.path),
      });
      final response = await _dioClient.dio.post(
        ApiConstants.coachCertificate,
        data: formData,
      );
      return CertificateResponse.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'An error occurred');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.coachCertificate}/$id');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'An error occurred');
    }
  }
}
