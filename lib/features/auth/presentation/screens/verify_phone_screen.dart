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

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onVerify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    String targetPhone = widget.phone.trim();
    if (targetPhone.isEmpty) {
      targetPhone =
          (authProvider.pendingPhone ?? authProvider.currentUser?.phone ?? '')
              .trim();
    }
    if (targetPhone.isNotEmpty && !targetPhone.startsWith('+')) {
      targetPhone = '+$targetPhone';
    }

    debugPrint('Verify button tapped, phone: $targetPhone, code: $code');

    final success = await authProvider.verifyPhone(
      phone: targetPhone,
      code: code,
    );

    debugPrint(
      'Verify result success: $success, error: ${authProvider.errorMessage}',
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
    final authProvider = context.read<AuthProvider>();
    String targetPhone = widget.phone.trim();
    if (targetPhone.isEmpty) {
      targetPhone =
          (authProvider.pendingPhone ?? authProvider.currentUser?.phone ?? '')
              .trim();
    }
    if (targetPhone.isNotEmpty && !targetPhone.startsWith('+')) {
      targetPhone = '+$targetPhone';
    }

    final success = await authProvider.resendOtp(phone: targetPhone);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'OTP resend request sent'
                : (authProvider.errorMessage ?? 'Failed to resend OTP'),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
                'We sent a verification code to ${widget.phone}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              if (widget.phone.isEmpty)
                CustomTextField(
                  controller: TextEditingController(
                    text: authProvider.pendingPhone,
                  ),
                  label: 'Phone Number',
                  hint: '+14155552671',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              if (widget.phone.isEmpty) const SizedBox(height: 16),

              CustomTextField(
                controller: _codeController,
                label: 'OTP Code',
                hint: '482913',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(
                  Icons.security,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Verify',
                isLoading: authProvider.isLoading,
                onPressed: _onVerify,
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: _onResendOtp,
                child: const Text('Resend Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
