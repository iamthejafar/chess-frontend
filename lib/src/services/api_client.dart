import 'package:chess/src/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../comman/constants.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Authorization': 'Bearer token',
              'Content-Type': 'application/json',
            },
          ),
        );

  Future<void> addAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Response> post(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      // await addAuthToken(await StorageService().getAuthToken());
      // await addAuthToken("token");
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      debugPrint("Error post $e");
      return _handleError(e);
    }
  }

  Future<Response> get(
      String endpoint) async {
    try {
      // await addAuthToken(await StorageService().getAuthToken());
      // await addAuthToken("token");
      final response = await _dio.get(endpoint);
      return response;
    } on DioException catch (e) {
      debugPrint("Error get $e");
      return _handleError(e);
    }
  }

  Response _handleError(DioException error) {
    String errorMessage = 'Unknown error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleBadResponse(error.response);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Network error';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad certificate';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Connection error';
        break;
    }

    throw ApiException(
        message: errorMessage, statusCode: error.response?.statusCode);
  }

  String _handleBadResponse(Response? response) {
    if (response == null) return 'No response from server';

    switch (response.statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Unexpected error: ${response.statusCode}';
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}
