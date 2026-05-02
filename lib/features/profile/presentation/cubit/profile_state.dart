import 'package:coaching_fit_coach/features/profile/data/models/coach_profile_response.dart';
import 'package:coaching_fit_coach/features/profile/data/models/user_response.dart';
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
  final UserResponse user;

  const ProfileSuccess(this.profile, this.user);

  @override
  List<Object?> get props => [profile, user];
}

class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class ProfileCreated extends ProfileState {}

class ProfileUpdated extends ProfileState {}
