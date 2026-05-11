import 'package:coaching_fit_coach/features/certificates/data/models/certificate_response.dart';
import 'package:equatable/equatable.dart';

abstract class CertificateState extends Equatable {
  const CertificateState();

  @override
  List<Object?> get props => [];
}

class CertificateInitial extends CertificateState {}

class CertificateLoading extends CertificateState {}

class CertificateLoaded extends CertificateState {
  final List<CertificateResponse> certificates;
  const CertificateLoaded(this.certificates);

  @override
  List<Object?> get props => [certificates];
}

class CertificateError extends CertificateState {
  final String message;
  const CertificateError(this.message);

  @override
  List<Object?> get props => [message];
}

class CertificateUploading extends CertificateState {}

class CertificateUploadSuccess extends CertificateState {
  final CertificateResponse certificate;
  const CertificateUploadSuccess(this.certificate);

  @override
  List<Object?> get props => [certificate];
}

class CertificateUploadError extends CertificateState {
  final String message;
  const CertificateUploadError(this.message);

  @override
  List<Object?> get props => [message];
}

class CertificateDeleting extends CertificateState {}

class CertificateDeleteSuccess extends CertificateState {}

class CertificateDeleteError extends CertificateState {
  final String message;
  const CertificateDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
