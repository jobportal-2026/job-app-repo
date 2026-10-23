import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebasePhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;
  bool _isSending = false;

  String? get currentVerificationId => _verificationId;
  bool get isSending => _isSending;

  /// Send real-time OTP via Firebase SMS
  Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorMessage) onError,
    void Function(PhoneAuthCredential credential)? onAutoVerified,
    void Function(String verificationId)? onTimeout,
  }) async {
    if (_isSending) {
      debugPrint('[FirebasePhoneAuth] Request already in flight for $phone, skipping duplicate.');
      return;
    }

    _isSending = true;
    try {
      debugPrint('[FirebasePhoneAuth] Sending OTP to $phone');
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          _isSending = false;
          debugPrint('[FirebasePhoneAuth] Auto-retrieval completed!');
          if (onAutoVerified != null) {
            onAutoVerified(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSending = false;
          debugPrint('[FirebasePhoneAuth] Verification failed: ${e.code} - ${e.message}');
          onError(e.message ?? 'Verification failed (${e.code})');
        },
        codeSent: (String verificationId, int? resendToken) {
          _isSending = false;
          debugPrint('[FirebasePhoneAuth] Code sent, verificationId: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _isSending = false;
          debugPrint('[FirebasePhoneAuth] Auto retrieval timeout for $verificationId');
          _verificationId = verificationId;
          if (onTimeout != null) {
            onTimeout(verificationId);
          }
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      _isSending = false;
      debugPrint('[FirebasePhoneAuth] Unexpected error sending OTP: $e');
      onError(e.toString());
    }
  }

  /// Verify entered SMS OTP code and retrieve Firebase ID token
  Future<String?> verifySmsCode(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('No active verification session. Please request a new OTP.');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode.trim(),
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return await userCredential.user?.getIdToken();
  }

  /// Sign in with auto-retrieved credential and return ID token
  Future<String?> signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    return await userCredential.user?.getIdToken();
  }

  /// Reset current verification state
  void reset() {
    _verificationId = null;
    _resendToken = null;
    _isSending = false;
  }
}
