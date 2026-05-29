// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateResponse _$CertificateResponseFromJson(Map<String, dynamic> json) =>
    CertificateResponse(
      id: json['id'] as String,
      coachProfileId: json['coachProfileId'] as String,
      title: json['title'] as String,
      issuingOrganization: json['issuingOrganization'] as String,
      issuedDate: DateTime.parse(json['issuedDate'] as String),
      fileUrl: json['fileUrl'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      status: json['status'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CertificateResponseToJson(
        CertificateResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'coachProfileId': instance.coachProfileId,
      'title': instance.title,
      'issuingOrganization': instance.issuingOrganization,
      'issuedDate': instance.issuedDate.toIso8601String(),
      'fileUrl': instance.fileUrl,
      'fileName': instance.fileName,
      'fileType': instance.fileType,
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
