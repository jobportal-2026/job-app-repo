import 'package:dio/dio.dart';
import '../config/env_config.dart';
import 'api_exceptions.dart';
import 'api_response.dart';
import 'secure_storage_service.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService secureStorageService;

  ApiClient({required this.secureStorageService, Dio? customDio}) {
    dio =
        customDio ??
        Dio(
          BaseOptions(
            baseUrl: EnvConfig.baseUrl,
            connectTimeout: const Duration(
              milliseconds: EnvConfig.connectionTimeoutMs,
            ),
            receiveTimeout: const Duration(
              milliseconds: EnvConfig.receiveTimeoutMs,
            ),
            headers: {'Content-Type': 'application/json'},
          ),
        );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await secureStorageService.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/login') &&
              !error.requestOptions.path.contains('/auth/refresh')) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              try {
                final retryResponse = await _retryRequest(error.requestOptions);
                return handler.resolve(retryResponse);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await secureStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final refreshDio = Dio(BaseOptions(baseUrl: EnvConfig.baseUrl));
      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final apiResp = ApiResponse.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      if (apiResp.success && apiResp.data != null) {
        final newAccess = apiResp.data!['accessToken'] as String?;
        final newRefresh = apiResp.data!['refreshToken'] as String?;
        if (newAccess != null && newRefresh != null) {
          await secureStorageService.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh,
          );
          return true;
        }
      }
    } catch (_) {
      await secureStorageService.clearAll();
    }
    return false;
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await secureStorageService.getAccessToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
    );
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  ApiException handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    final response = error.response;
    if (response == null) return NetworkException('No response from server');

    final data = response.data;
    String message = 'An unexpected error occurred';
    List<ApiFieldError>? fieldErrors;

    if (data is Map<String, dynamic>) {
      final apiResponse = ApiResponse.fromJson(data, null);
      message = apiResponse.message.isNotEmpty ? apiResponse.message : message;
      fieldErrors = apiResponse.errors;
    }

    switch (response.statusCode) {
      case 400:
        if (fieldErrors != null && fieldErrors.isNotEmpty) {
          final details = fieldErrors
              .map((e) => '${e.field}: ${e.message}')
              .join('\n');
          return BadRequestException(
            details,
            statusCode: 400,
            errors: fieldErrors,
          );
        }
        return BadRequestException(
          message,
          statusCode: 400,
          errors: fieldErrors,
        );
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(
          message,
          statusCode: 403,
          errors: fieldErrors,
        );
      case 409:
        return ConflictException(message, statusCode: 409, errors: fieldErrors);
      case 429:
        return RateLimitException(
          message,
          statusCode: 429,
          errors: fieldErrors,
        );
      case 500:
      default:
        return ServerException(message, response.statusCode);
    }
  }
}
