import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  });

  Future<UserEntity> verifyPhone({
    required String phone,
    required String code,
  });

  Future<void> resendOtp({
    required String phone,
  });

  Future<UserEntity> login({
    required String email,
    required String password,
    required String role,
  });

  Future<UserEntity> getCurrentUser();

  Future<void> logout();

  Future<void> forgotPassword({
    required String phone,
  });

  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  });
}
