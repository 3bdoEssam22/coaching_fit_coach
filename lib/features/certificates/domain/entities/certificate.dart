class Certificate {
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

  const Certificate({
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
}
