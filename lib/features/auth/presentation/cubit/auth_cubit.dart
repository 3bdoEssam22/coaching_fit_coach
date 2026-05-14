import 'package:bloc/bloc.dart';
import 'package:coaching_fit_coach/core/errors/failures.dart';
import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/features/auth/data/models/login_request.dart';
import 'package:coaching_fit_coach/features/auth/data/models/register_request.dart';
import 'package:coaching_fit_coach/features/auth/data/repositories/auth_repository.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SecureStorage _secureStorage;

  AuthCubit(this._authRepository, this._secureStorage) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(LoginRequest(email: email, password: password));
      await _secureStorage.writeToken(response.token ?? '');
      await _secureStorage.writeUserId(response.userId);
      await _secureStorage.writeRole(response.role);
      await _secureStorage.writeIsActive(response.isActive);
      await _secureStorage.writeFullName(response.fullName);
      emit(AuthSuccess(response));
    } catch (e) {
      emit(AuthFailure((e as Failure).message));
    }
  }

  Future<void> register(RegisterRequest request) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(request);
      emit(RegistrationSuccess());
    } catch (e) {
      emit(AuthFailure((e as Failure).message));
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
    emit(AuthInitial());
  }
}
