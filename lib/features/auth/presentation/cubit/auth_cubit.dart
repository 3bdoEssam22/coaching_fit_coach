import 'package:bloc/bloc.dart';
import 'package:coaching_fit_coach/features/auth/data/models/login_request.dart';
import 'package:coaching_fit_coach/features/auth/data/models/register_request.dart';
import 'package:coaching_fit_coach/features/auth/data/repositories/auth_repository.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.login(LoginRequest(email: email, password: password));
      emit(AuthSuccess(response));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> register(RegisterRequest request) async {
    emit(AuthLoading());
    try {
      await _authRepository.register(request);
      emit(RegistrationSuccess());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
