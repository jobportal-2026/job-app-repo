import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String phone;

  const VerifyPhoneScreen({super.key, required this.phone});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _codeController = TextEditingController();
  Timer? _resendTimer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _otpInitiated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_otpInitiated) {
        _otpInitiated = true;
        _initOtpFlow();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String _getTargetPhone() {
    final authProvider = context.read<AuthProvider>();
    String target = widget.phone.trim();
    if (target.isEmpty) {
      target = (authProvider.pendingPhone ?? authProvider.currentUser?.phone ?? '').trim();
    }
    if (target.isNotEmpty && !target.startsWith('+')) {
      target = '+$target';
    }
    return target;
  }

  void _startResendTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _initOtpFlow() {
    final targetPhone = _getTargetPhone();
    if (targetPhone.isNotEmpty) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isOtpSending) return;
      _startResendTimer();
      authProvider.sendFirebaseOtp(
        phone: targetPhone,
        onAutoVerifiedSuccess: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Phone verified automatically!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/');
          }
        },
      );
    }
  }

  void _onVerify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final targetPhone = _getTargetPhone();

    debugPrint('Verify button tapped, phone: $targetPhone, code: $code');

    final success = await authProvider.verifyFirebaseOtp(
      phone: targetPhone,
      smsCode: code,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone verified successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/');
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onResendOtp() async {
    if (!_canResend) return;
    final authProvider = context.read<AuthProvider>();
    final targetPhone = _getTargetPhone();
    if (targetPhone.isEmpty) return;

    _startResendTimer();
    await authProvider.sendFirebaseOtp(
      phone: targetPhone,
      onAutoVerifiedSuccess: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone verified automatically!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/');
        }
      },
    );

    if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final targetPhone = _getTargetPhone();

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter 6-Digit Code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                targetPhone.isNotEmpty
                    ? 'We sent a verification code to $targetPhone'
                    : 'Enter the verification code sent to your phone',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              if (authProvider.isOtpSending)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Sending real-time SMS code...',
                        style: TextStyle(fontSize: 13, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

              if (authProvider.isOtpSent && authProvider.otpSentMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.otpSentMessage!,
                          style: const TextStyle(fontSize: 13, color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),

              CustomTextField(
                controller: _codeController,
                label: 'OTP Code',
                hint: '123456',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(
                  Icons.security,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Verify OTP',
                isLoading: authProvider.isLoading,
                onPressed: _onVerify,
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: _canResend && !authProvider.isOtpSending ? _onResendOtp : null,
                child: Text(
                  _canResend
                      ? 'Resend SMS Code'
                      : 'Resend Code in ${_secondsRemaining}s',
                  style: TextStyle(
                    color: _canResend ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
