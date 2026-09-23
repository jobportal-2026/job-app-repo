import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, pendingVerification }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthStatus _status = AuthStatus.unauthenticated;
  UserEntity? _currentUser;
  String? _errorMessage;
  String? _pendingPhone;
  bool _isLoading = false;

  AuthProvider({required this.authRepository});

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get pendingPhone => _pendingPhone;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      final user = await authRepository.getCurrentUser();
      _currentUser = user;
      _status = user.phoneVerified ? AuthStatus.authenticated : AuthStatus.pendingVerification;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await authRepository.login(
        email: email,
        password: password,
        role: role,
      );
      _currentUser = user;
      _status = user.phoneVerified ? AuthStatus.authenticated : AuthStatus.pendingVerification;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final data = await authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      _pendingPhone = data['phone'] as String? ?? phone;
      _status = AuthStatus.pendingVerification;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyPhone({required String phone, required String code}) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await authRepository.verifyPhone(phone: phone, code: code);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendOtp({required String phone}) async {
    _setError(null);
    try {
      await authRepository.resendOtp(phone: phone);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await authRepository.logout();
    } finally {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _setLoading(false);
    }
  }
}
