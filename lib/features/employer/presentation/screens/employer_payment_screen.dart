import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class EmployerPaymentScreen extends StatefulWidget {
  final String candidateName;
  final String jobTitle;
  final double candidatePayAmount;

  const EmployerPaymentScreen({
    super.key,
    required this.candidateName,
    required this.jobTitle,
    this.candidatePayAmount = 450.0,
  });

  @override
  State<EmployerPaymentScreen> createState() => _EmployerPaymentScreenState();
}

class _EmployerPaymentScreenState extends State<EmployerPaymentScreen> {
  String _selectedPaymentMethod = 'UPI'; // 'UPI' | 'CARD' | 'PACK'
  bool _isProcessing = false;

  final double _platformFee = 99.0;
  final double _taxGst = 17.82; // 18% GST on platform fee

  @override
  Widget build(BuildContext context) {
    final double totalPayable = widget.candidatePayAmount + _platformFee + _taxGst;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout & Hire Candidate'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate & Job summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      widget.candidateName.isNotEmpty ? widget.candidateName[0] : 'C',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.candidateName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.jobTitle,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bill Breakdown (Wireframe 2.7)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 14),
                  _billRow('Candidate Shift Pay (Deposit)', '₹${widget.candidatePayAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _billRow('Bridgo Platform Match Fee', '₹${_platformFee.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _billRow('GST (18% on platform fee)', '₹${_taxGst.toStringAsFixed(2)}'),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        '₹${totalPayable.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment method selection
            const Text(
              'Select Payment Option',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _paymentOptionTile(
              id: 'UPI',
              icon: Icons.account_balance_wallet_outlined,
              title: 'Instant UPI (Google Pay, PhonePe, Paytm)',
              subtitle: 'Zero transaction charges',
            ),
            const SizedBox(height: 8),
            _paymentOptionTile(
              id: 'PACK',
              icon: Icons.inventory_2_outlined,
              title: 'Use Active Pack Credit (8 left)',
              subtitle: 'Waives ₹99 platform fee completely',
            ),
            const SizedBox(height: 8),
            _paymentOptionTile(
              id: 'CARD',
              icon: Icons.credit_card_outlined,
              title: 'Corporate Credit / Debit Card',
              subtitle: 'Visa, MasterCard, RuPay, Amex',
            ),
            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isProcessing ? null : _handlePaymentSuccess,
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Pay ₹${totalPayable.toStringAsFixed(0)} & Confirm Hire',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _billRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
        Text(amount, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _paymentOptionTile({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePaymentSuccess() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 42),
            ),
            const SizedBox(height: 16),
            const Text(
              'Candidate Hired!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'You have successfully hired ${widget.candidateName}. An automated agreement and shift schedule has been shared in your chat.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/');
                },
                child: const Text('Go to Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
