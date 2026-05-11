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
  Future<List<CertificateResponse>> getMyCertificates() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.myCertificates);
      final raw = response.data['data'];
      final data = raw is List ? raw : <dynamic>[];
      return data
          .map((e) => CertificateResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
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
      throw ServerFailure(_dioFailureMessage(e));
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.coachCertificate}/$id');
    } on DioException catch (e) {
      throw ServerFailure(_dioFailureMessage(e));
    }
  }
}
