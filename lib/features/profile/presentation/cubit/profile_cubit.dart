import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/features/profile/data/repositories/profile_repository.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final SecureStorage _secureStorage;

  ProfileCubit(this._profileRepository, this._secureStorage) : super(ProfileInitial());

  Future<void> createProfile({
    required String gender,
    required String bio,
    required int experienceYears,
    File? photo,
  }) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.createProfile(
        gender: gender,
        bio: bio,
        experienceYears: experienceYears,
        photo: photo,
      );
      await _secureStorage.writeHasProfile(true);
      emit(ProfileCreated());
    } catch (e) {
      emit(ProfileFailure((e as Failure).message));
    }
  }

  Future<void> getMyProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.getMyProfile();
      final fullName = await _secureStorage.readFullName() ?? 'Coach';
      final isActive = await _secureStorage.readIsActive();
      emit(ProfileSuccess(profile, fullName: fullName, isActive: isActive));
    } catch (e) {
      emit(ProfileFailure((e as Failure).message));
    }
  }

  Future<void> updateProfile({String? bio, int? experienceYears, File? photo}) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.updateProfile(
        bio: bio,
        experienceYears: experienceYears,
        photo: photo,
      );
      emit(ProfileUpdated());
    } catch (e) {
      emit(ProfileFailure((e as Failure).message));
    }
  }
}
