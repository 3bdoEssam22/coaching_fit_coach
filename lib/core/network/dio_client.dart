import 'package:coaching_fit_coach/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:coaching_fit_coach/core/network/api_interceptor.dart';

class DioClient {
  final Dio _dio;
  final ApiInterceptor _apiInterceptor;

  DioClient(this._dio, this._apiInterceptor) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(_apiInterceptor);
  }

  Dio get dio => _dio;
}
