import 'package:chess/dotenv.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Response wrapper for type-safe responses
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final int? statusCode;

  ApiResponse({
    this.data,
    this.message,
    required this.success,
    this.statusCode,
  });

  factory ApiResponse.fromResponse(
    Response response, {
    T Function(dynamic)? fromJson,
  }) {
    final data = response.data;
    return ApiResponse<T>(
      data: fromJson != null && data != null ? fromJson(data) : data as T?,
      message: data is Map ? data['message'] as String? : null,
      success: response.statusCode! >= 200 && response.statusCode! < 300,
      statusCode: response.statusCode,
    );
  }
}

/// Main API Client
class ApiClient {
  late final Dio _dio;
  String? _authToken;

  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio();
    _initializeInterceptors();
    _configureDefaults();
  }

  /// Current base URL configured for all API calls.
  String get baseUrl => _dio.options.baseUrl;

  /// Resolve a relative API endpoint into a full absolute URL.
  String resolveUrl(String endpoint) {
    final normalized = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    return Uri.parse(baseUrl).resolve(normalized).toString();
  }

  /// Configure default options
  void _configureDefaults() {
    _dio.options = BaseOptions(
      baseUrl: liveUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (status) => status! < 500,
    );
  }

  /// Initialize interceptors
  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          if (kDebugMode) {
            debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
            debugPrint('Headers: ${options.headers}');
            debugPrint('Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
            debugPrint('Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint(
              'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            );
            debugPrint('Message: ${error.message}');
            debugPrint('Response: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Set base URL
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Update headers
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Handle errors uniformly
  ApiException _handleError(DioException error) {
    String message;
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        final data = error.response?.data;
        message = data is Map
            ? (data['message'] ?? data['error'] ?? 'Server error occurred')
            : 'Server error occurred';
        break;

      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;

      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;

      default:
        message = error.message ?? 'An unexpected error occurred';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response, fromJson: fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response, fromJson: fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response, fromJson: fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response, fromJson: fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromResponse(response, fromJson: fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    required String fileKey,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      if ((filePath == null || filePath.isEmpty) &&
          (fileBytes == null || fileBytes.isEmpty)) {
        throw ApiException(
          message: 'Either filePath or fileBytes must be provided.',
        );
      }

      final multipartFile = fileBytes != null && fileBytes.isNotEmpty
          ? MultipartFile.fromBytes(
              fileBytes,
              filename: fileName ?? 'upload.bin',
            )
          : await MultipartFile.fromFile(filePath!, filename: fileName);

      final formData = FormData.fromMap({fileKey: multipartFile, ...?data});

      final response = await _dio.post(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return ApiResponse.fromResponse(response, fromJson: fromJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download file
  Future<void> downloadFile(
    String endpoint,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        endpoint,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get raw Dio instance for advanced usage
  Dio get dio => _dio;
}
