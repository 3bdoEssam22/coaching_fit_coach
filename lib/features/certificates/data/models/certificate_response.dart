import 'package:json_annotation/json_annotation.dart';

part 'certificate_response.g.dart';

@JsonSerializable()
class CertificateResponse {
  final String id;
  final String coachProfileId;
  final String title;
  final String issuingOrganization;
  final DateTime issuedDate;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final String status;
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const CertificateResponse({
    required this.id,
    required this.coachProfileId,
    required this.title,
    required this.issuingOrganization,
    required this.issuedDate,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.status,
    this.rejectionReason,
    this.reviewedAt,
    required this.createdAt,
  });

  factory CertificateResponse.fromJson(Map<String, dynamic> json) =>
      _$CertificateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CertificateResponseToJson(this);
}
