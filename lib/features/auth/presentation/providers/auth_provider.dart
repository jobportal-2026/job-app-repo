import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/datasources/firebase_phone_auth_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, pendingVerification }

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final FirebasePhoneAuthService firebasePhoneAuthService;

  AuthStatus _status = AuthStatus.unauthenticated;
  UserEntity? _currentUser;
  String? _errorMessage;
  String? _pendingPhone;
  bool _isSubmitting = false;
  bool _isCheckingAuth = false;
  Future<void>? _authCheckFuture;

  // Firebase OTP specific states
  bool _isOtpSending = false;
  bool _isOtpSent = false;
  String? _otpSentMessage;

  AuthProvider({
    required this.authRepository,
    FirebasePhoneAuthService? firebasePhoneAuthService,
  }) : firebasePhoneAuthService = firebasePhoneAuthService ?? FirebasePhoneAuthService();

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get pendingPhone => _pendingPhone;
  bool get isLoading => _isSubmitting;
  bool get isCheckingAuth => _isCheckingAuth;
  Future<void>? get authCheckFuture => _authCheckFuture;
  bool get isOtpSending => _isOtpSending;
  bool get isOtpSent => _isOtpSent;
  String? get otpSentMessage => _otpSentMessage;

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() {
    _authCheckFuture = _performAuthCheck();
    return _authCheckFuture!;
  }

  Future<void> _performAuthCheck() async {
    _isCheckingAuth = true;
    _status = AuthStatus.authenticating;
    notifyListeners();
    try {
      final user = await authRepository.getCurrentUser();
      _currentUser = user;
      _status = user.phoneVerified ? AuthStatus.authenticated : AuthStatus.pendingVerification;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    _setSubmitting(true);
    _setError(null);
    try {
      final user = await authRepository.login(
        email: email,
        password: password,
        role: role,
      );
      _currentUser = user;
      _status = user.phoneVerified ? AuthStatus.authenticated : AuthStatus.pendingVerification;
      _setSubmitting(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSubmitting(false);
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
    _setSubmitting(true);
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
      _setSubmitting(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSubmitting(false);
      return false;
    }
  }

  /// Send real-time OTP SMS via Firebase
  Future<void> sendFirebaseOtp({
    required String phone,
    void Function()? onAutoVerifiedSuccess,
  }) async {
    _isOtpSending = true;
    _errorMessage = null;
    _otpSentMessage = null;
    notifyListeners();

    await firebasePhoneAuthService.sendOtp(
      phone: phone,
      onCodeSent: (verificationId) {
        _isOtpSending = false;
        _isOtpSent = true;
        _otpSentMessage = 'Verification code sent to $phone';
        notifyListeners();
      },
      onError: (error) {
        _isOtpSending = false;
        _errorMessage = error;
        notifyListeners();
      },
      onAutoVerified: (credential) async {
        debugPrint('[AuthProvider] Auto verified on Android device');
        try {
          final idToken = await firebasePhoneAuthService.signInWithCredential(credential);
          if (idToken != null) {
            await verifyPhoneWithFirebaseToken(phone: phone, firebaseToken: idToken);
            if (onAutoVerifiedSuccess != null) {
              onAutoVerifiedSuccess();
            }
          }
        } catch (e) {
          _setError(e.toString());
        }
      },
    );
  }

  /// Verify entered SMS OTP code via Firebase, with graceful backend OTP fallback
  Future<bool> verifyFirebaseOtp({
    required String phone,
    required String smsCode,
  }) async {
    _setSubmitting(true);
    _setError(null);
    try {
      String? idToken;
      try {
        idToken = await firebasePhoneAuthService.verifySmsCode(smsCode);
      } catch (fbErr) {
        debugPrint('[AuthProvider] Firebase verify fallback: $fbErr');
      }

      final user = await authRepository.verifyPhone(
        phone: phone,
        code: smsCode,
        firebaseToken: idToken,
      );

      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setSubmitting(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSubmitting(false);
      return false;
    }
  }

  /// Verify using Firebase Token directly (e.g. from auto-retrieval)
  Future<bool> verifyPhoneWithFirebaseToken({
    required String phone,
    required String firebaseToken,
  }) async {
    _setSubmitting(true);
    _setError(null);
    try {
      final user = await authRepository.verifyPhone(
        phone: phone,
        firebaseToken: firebaseToken,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setSubmitting(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSubmitting(false);
      return false;
    }
  }

  Future<bool> verifyPhone({
    required String phone,
    String? code,
    String? firebaseToken,
  }) async {
    _setSubmitting(true);
    _setError(null);
    try {
      final user = await authRepository.verifyPhone(
        phone: phone,
        code: code,
        firebaseToken: firebaseToken,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setSubmitting(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setSubmitting(false);
      return false;
    }
  }

  Future<bool> resendOtp({required String phone}) async {
    _setError(null);
    try {
      await sendFirebaseOtp(phone: phone);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    _setSubmitting(true);
    try {
      await FirebaseAuth.instance.signOut();
      await authRepository.logout();
    } finally {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _setSubmitting(false);
    }
  }
}

