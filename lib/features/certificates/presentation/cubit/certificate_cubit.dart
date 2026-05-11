import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:coaching_fit_coach/features/certificates/data/repositories/certificate_repository.dart';
import 'package:coaching_fit_coach/features/certificates/presentation/cubit/certificate_state.dart';

class CertificateCubit extends Cubit<CertificateState> {
  final CertificateRepository _repository;

  CertificateCubit(this._repository) : super(CertificateInitial());

  Future<void> loadCertificates() async {
    emit(CertificateLoading());
    try {
      final certs = await _repository.getMyCertificates();
      emit(CertificateLoaded(certs));
    } catch (e) {
      emit(CertificateError(e.toString()));
    }
  }

  Future<void> upload({
    required String title,
    required String issuingOrganization,
    required DateTime issuedDate,
    required File file,
  }) async {
    emit(CertificateUploading());
    try {
      final cert = await _repository.upload(
        title: title,
        issuingOrganization: issuingOrganization,
        issuedDate: issuedDate,
        file: file,
      );
      emit(CertificateUploadSuccess(cert));
    } catch (e) {
      emit(CertificateUploadError(e.toString()));
    }
  }

  Future<void> delete(String id) async {
    emit(CertificateDeleting());
    try {
      await _repository.delete(id);
      emit(CertificateDeleteSuccess());
    } catch (e) {
      emit(CertificateDeleteError(e.toString()));
    }
  }
}
