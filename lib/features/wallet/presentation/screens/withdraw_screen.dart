import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController(text: '2000');
  final _upiController = TextEditingController(text: 'alexjohnson@oksbi');
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _holderNameController = TextEditingController(text: 'Alex Johnson');

  String _selectedMethod = 'UPI'; // 'UPI' | 'BANK'
  bool _isProcessing = false;
  final double _availableBalance = 8450.0;

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    super.dispose();
  }

  void _setQuickAmount(double amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _handleWithdraw() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid withdrawal amount'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (amount > _availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal amount exceeds available balance'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_selectedMethod == 'UPI' && _upiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your UPI ID'), backgroundColor: AppColors.error),
      );
      return;
    }

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
              'Withdrawal Requested!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${amount.toStringAsFixed(0)} will be credited to your ${_selectedMethod == "UPI" ? "UPI ID (${_upiController.text})" : "Bank Account"} within 15-30 minutes.',
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
                  context.pop();
                },
                child: const Text('Back to Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Withdraw Funds'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Available to withdraw:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  Text(
                    '₹${_availableBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Amount Input
            const Text(
              'Enter Amount (₹)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => _amountController.clear(),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Amount Chips
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('+₹500'),
                  onPressed: () => _setQuickAmount(500),
                ),
                ActionChip(
                  label: const Text('+₹1,000'),
                  onPressed: () => _setQuickAmount(1000),
                ),
                ActionChip(
                  label: const Text('+₹2,000'),
                  onPressed: () => _setQuickAmount(2000),
                ),
                ActionChip(
                  label: const Text('Withdraw Max'),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  onPressed: () => _setQuickAmount(_availableBalance),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Select Method
            const Text(
              'Select Payout Method',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Method 1: UPI
            InkWell(
              onTap: () => setState(() => _selectedMethod = 'UPI'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMethod == 'UPI' ? AppColors.primary : AppColors.cardBorder,
                    width: _selectedMethod == 'UPI' ? 2 : 1,
                  ),
                  color: _selectedMethod == 'UPI' ? AppColors.primary.withValues(alpha: 0.04) : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedMethod == 'UPI' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _selectedMethod == 'UPI' ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UPI (Google Pay / PhonePe / Paytm)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Instant payout within 5 minutes', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Method 2: Bank Transfer
            InkWell(
              onTap: () => setState(() => _selectedMethod = 'BANK'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMethod == 'BANK' ? AppColors.primary : AppColors.cardBorder,
                    width: _selectedMethod == 'BANK' ? 2 : 1,
                  ),
                  color: _selectedMethod == 'BANK' ? AppColors.primary.withValues(alpha: 0.04) : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedMethod == 'BANK' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _selectedMethod == 'BANK' ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.account_balance_outlined, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Direct Bank Transfer (NEFT / IMPS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Takes 1-2 hours depending on bank', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Method detail fields
            if (_selectedMethod == 'UPI') ...[
              const Text('UPI ID (VPA)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _upiController,
                decoration: InputDecoration(
                  hintText: 'e.g. yourname@oksbi',
                  prefixIcon: const Icon(Icons.alternate_email, color: AppColors.primary, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              const Text('Account Holder Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _holderNameController,
                decoration: InputDecoration(
                  hintText: 'Full name as per bank record',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Account Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 50100234918231',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('IFSC Code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _ifscController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. HDFC0001234',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Confirm Withdraw Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleWithdraw,
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Confirm Withdrawal',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
