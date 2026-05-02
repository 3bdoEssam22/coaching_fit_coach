import 'package:dio/dio.dart';
import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:go_router/go_router.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  final GoRouter _router;

  ApiInterceptor(this._secureStorage, this._router);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.clearAll();
      _router.go('/login');
    }
    return super.onError(err, handler);
  }
}
