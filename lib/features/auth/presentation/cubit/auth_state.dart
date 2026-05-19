import 'package:equatable/equatable.dart';

enum AuthNextStep {
  onboarding,
  login,
  createProfile,
  pendingApproval,
  viewProfile,
}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthNextStep nextStep;

  const AuthSuccess(this.nextStep);

  @override
  List<Object?> get props => [nextStep];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class RegistrationSuccess extends AuthState {}
