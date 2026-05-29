import 'package:bloc/bloc.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/features/auth/data/models/login_request.dart';
import 'package:coaching_fit_coach/features/auth/data/models/register_request.dart';
import 'package:coaching_fit_coach/features/auth/data/repositories/auth_repository.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_state.dart';
import 'package:coaching_fit_coach/features/profile/data/repositories/profile_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final SecureStorage _secureStorage;

  AuthCubit(
    this._authRepository,
    this._profileRepository,
    this._secureStorage,
  ) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository
          .login(LoginRequest(email: email, password: password));
      await _secureStorage.writeToken(response.token ?? '');
      await _secureStorage.writeUserId(response.userId);
      await _secureStorage.writeRole(response.role);
      await _secureStorage.writeIsActive(response.isActive);
      await _secureStorage.writeFullName(response.fullName);
      if (response.refreshToken != null && response.refreshToken!.isNotEmpty) {
        await _secureStorage.writeRefreshToken(response.refreshToken!);
      }
      emit(AuthSuccess(await _resolvePostAuthStep(response.isActive)));
    } catch (e) {
      emit(AuthFailure((e as Failure).message));
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      ));
      emit(RegistrationSuccess());
    } catch (e) {
      emit(AuthFailure((e as Failure).message));
    }
  }

  Future<void> resolveSession() async {
    final token = await _secureStorage.readToken();
    if (token == null) {
      emit(const AuthSuccess(AuthNextStep.onboarding));
      return;
    }
    try {
      final isActive = await _secureStorage.readIsActive();
      emit(AuthSuccess(await _resolvePostAuthStep(isActive)));
    } catch (_) {
      await _secureStorage.clearAll();
      emit(const AuthSuccess(AuthNextStep.login));
    }
  }

  Future<AuthNextStep> _resolvePostAuthStep(bool isActive) async {
    try {
      await _profileRepository.getMyProfile();
      await _secureStorage.writeHasProfile(true);
      return isActive ? AuthNextStep.viewProfile : AuthNextStep.pendingApproval;
    } on NotFoundFailure {
      await _secureStorage.writeHasProfile(false);
      return AuthNextStep.createProfile;
    }
  }

  Future<void> logout() async {
    final rt = await _secureStorage.readRefreshToken();
    if (rt != null && rt.isNotEmpty) {
      try {
        await _authRepository.revoke(rt);
      } catch (_) {}
    }
    await _secureStorage.clearAll();
    emit(AuthInitial());
  }
}
