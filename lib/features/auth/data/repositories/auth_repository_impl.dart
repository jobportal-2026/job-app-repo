import '../../../../core/network/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorageService,
  });

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    return await remoteDataSource.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );
  }

  @override
  Future<UserEntity> verifyPhone({
    required String phone,
    required String code,
  }) async {
    final userModel = await remoteDataSource.verifyPhone(phone: phone, code: code);
    await secureStorageService.saveUserMetadata(userId: userModel.id, role: userModel.role);
    return userModel;
  }

  @override
  Future<void> resendOtp({required String phone}) async {
    await remoteDataSource.resendOtp(phone: phone);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final data = await remoteDataSource.login(
      email: email,
      password: password,
      role: role,
    );

    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    final userJson = data['user'] as Map<String, dynamic>?;

    if (accessToken != null && refreshToken != null) {
      await secureStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    if (userJson != null) {
      final user = UserModel.fromJson(userJson);
      await secureStorageService.saveUserMetadata(userId: user.id, role: user.role);
      return user;
    }

    throw Exception('Login succeeded but user payload missing');
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } finally {
      await secureStorageService.clearAll();
    }
  }

  @override
  Future<void> forgotPassword({required String phone}) async {
    await remoteDataSource.forgotPassword(phone: phone);
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await remoteDataSource.resetPassword(
      phone: phone,
      code: code,
      newPassword: newPassword,
    );
  }
}
