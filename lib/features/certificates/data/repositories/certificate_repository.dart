import 'dart:io';
import 'package:coaching_fit_coach/core/constants/api_constants.dart';
import 'package:coaching_fit_coach/core/errors/dio_error_handler.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/network/dio_client.dart';
import 'package:coaching_fit_coach/features/certificates/data/models/certificate_response.dart';
import 'package:coaching_fit_coach/features/certificates/domain/entities/certificate.dart';
import 'package:dio/dio.dart';

abstract class CertificateRepository {
  Future<List<Certificate>> getMyCertificates();
  Future<Certificate> upload({
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

  Certificate _toEntity(CertificateResponse r) => Certificate(
        id: r.id,
        coachProfileId: r.coachProfileId,
        title: r.title,
        issuingOrganization: r.issuingOrganization,
        issuedDate: r.issuedDate,
        fileUrl: r.fileUrl,
        fileName: r.fileName,
        fileType: r.fileType,
        status: r.status,
        rejectionReason: r.rejectionReason,
        reviewedAt: r.reviewedAt,
        createdAt: r.createdAt,
      );

  @override
  Future<List<Certificate>> getMyCertificates() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.myCertificates);
      final raw = response.data['data'];
      final data = raw is List ? raw : <dynamic>[];
      return data
          .map((e) => _toEntity(CertificateResponse.fromJson(e as Map<String, dynamic>)))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure(dioFailureMessage(e));
    }
  }

  @override
  Future<Certificate> upload({
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
      return _toEntity(CertificateResponse.fromJson(response.data['data']));
    } on DioException catch (e) {
      throw ServerFailure(dioFailureMessage(e));
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _dioClient.dio.delete('${ApiConstants.coachCertificate}/$id');
    } on DioException catch (e) {
      throw ServerFailure(dioFailureMessage(e));
    }
  }
}
