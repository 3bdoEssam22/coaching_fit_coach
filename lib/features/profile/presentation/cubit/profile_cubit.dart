import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:coaching_fit_coach/features/profile/data/models/create_coach_profile_request.dart';
import 'package:coaching_fit_coach/features/profile/data/repositories/profile_repository.dart';
import 'package:coaching_fit_coach/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository) : super(ProfileInitial());

  Future<void> createProfile(CreateCoachProfileRequest request, {File? photo}) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.createProfile(request, photo: photo);
      emit(ProfileCreated());
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> getMyProfile() async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.getMyProfile();
      final user = await _profileRepository.getUser();
      emit(ProfileSuccess(profile, user));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateProfile({String? bio, int? experienceYears, File? photo}) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.updateProfile(bio: bio, experienceYears: experienceYears, photo: photo);
      emit(ProfileUpdated());
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
