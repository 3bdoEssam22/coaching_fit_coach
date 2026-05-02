import 'package:coaching_fit_coach/features/profile/data/models/coach_profile_response.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final CoachProfileResponse profile;

  const ProfileSuccess(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ProfileCreated extends ProfileState {}

class ProfileUpdated extends ProfileState {}
