import 'package:coaching_fit_coach/features/profile/domain/entities/coach_profile.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final CoachProfile profile;
  final String fullName;
  final bool isActive;

  const ProfileSuccess(this.profile, {required this.fullName, required this.isActive});

  @override
  List<Object?> get props => [profile, fullName, isActive];
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileCreated extends ProfileState {}

class ProfileUpdated extends ProfileState {}
