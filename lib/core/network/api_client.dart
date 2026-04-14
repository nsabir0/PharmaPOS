import 'dart:io';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  String get baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:8080/api/v1';
    return 'http://localhost:8080/api/v1';
  }

  Future<Response> get(String path) async {
    try {
      return await _dio.get('$baseUrl$path');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post('$baseUrl$path', data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout. Please check your internet.');
      case DioExceptionType.receiveTimeout:
        return Exception('Server is taking too long to respond.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data is Map ? e.response?.data['message'] : null;
        
        if (statusCode == 404) return Exception('Requested resource not found (404). Check API URL.');
        if (statusCode == 500) return Exception('Internal Server Error. Please contact admin.');
        if (statusCode == 401) return Exception('Unauthorized access. Please login again.');
        
        return Exception(message ?? 'Server error: $statusCode');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
