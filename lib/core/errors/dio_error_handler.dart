import 'package:dio/dio.dart';

String dioFailureMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] is String) return data['message'] as String;
  if (data is String && data.isNotEmpty) return data;
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Connection timed out. Check that the backend is running.';
    case DioExceptionType.connectionError:
      return 'Cannot reach the server at ${e.requestOptions.baseUrl}. Is the gateway running?';
    case DioExceptionType.badCertificate:
      return 'Bad SSL certificate.';
    case DioExceptionType.cancel:
      return 'Request was cancelled.';
    case DioExceptionType.badResponse:
      return 'Server returned ${e.response?.statusCode}.';
    case DioExceptionType.unknown:
      return e.message ?? 'Network error: ${e.error}';
  }
}
