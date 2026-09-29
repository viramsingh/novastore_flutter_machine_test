import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  final Dio dio;

  ApiClient({Dio? customDio})
      : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: ApiConstants.connectTimeout,
                receiveTimeout: ApiConstants.receiveTimeout,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );
  }

  void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  ApiException handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException('Connection timed out. Please check your internet.', error.response?.statusCode);
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          String msg = 'Request failed';
          if (data is Map && data.containsKey('message')) {
            msg = data['message'].toString();
          } else if (error.response?.statusMessage != null) {
            msg = error.response!.statusMessage!;
          }
          return ApiException(msg, error.response?.statusCode);
        case DioExceptionType.connectionError:
          return ApiException('No internet connection or server unreachable.', null);
        case DioExceptionType.cancel:
          return ApiException('Request was cancelled.', null);
        default:
          return ApiException(error.message ?? 'An unexpected network error occurred.', null);
      }
    }
    return ApiException(error.toString(), null);
  }
}
