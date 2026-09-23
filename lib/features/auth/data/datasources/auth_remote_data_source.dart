import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          if (email.isNotEmpty) 'email': email,
          'phone': phone,
          'password': password,
          'role': role,
        },
      );
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      return apiResponse.data ?? {};
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<UserModel> verifyPhone({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/verify-phone',
        data: {
          'phone': phone,
          'code': code,
        },
      );
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data!;
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<void> resendOtp({required String phone}) async {
    try {
      await apiClient.dio.post(
        '/auth/resend-otp',
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'role': role,
        },
      );
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      return apiResponse.data ?? {};
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get('/auth/me');
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data!;
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<void> forgotPassword({required String phone}) async {
    try {
      await apiClient.dio.post(
        '/auth/forgot-password',
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    try {
      await apiClient.dio.post(
        '/auth/reset-password',
        data: {
          'phone': phone,
          'code': code,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }
}
