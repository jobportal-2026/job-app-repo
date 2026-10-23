import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class WalletTransaction {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final String status;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.status,
  });
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double balance = 8450.0;
    const double totalEarned = 24600.0;
    const double pendingEscrow = 1500.0;

    final transactions = [
      const WalletTransaction(
        id: 'tx-1',
        title: 'Payout: Weekend Barista (2 shifts)',
        date: 'Today, 2:30 PM',
        amount: 1000.0,
        isCredit: true,
        status: 'COMPLETED',
      ),
      const WalletTransaction(
        id: 'tx-2',
        title: 'Bank Withdrawal to HDFC Bank (**4821)',
        date: 'Oct 04, 2026',
        amount: 5000.0,
        isCredit: false,
        status: 'COMPLETED',
      ),
      const WalletTransaction(
        id: 'tx-3',
        title: 'Payout: Tech Conference Coordinator',
        date: 'Sep 28, 2026',
        amount: 3500.0,
        isCredit: true,
        status: 'COMPLETED',
      ),
      const WalletTransaction(
        id: 'tx-4',
        title: 'Referral Bonus (Friend Joined)',
        date: 'Sep 20, 2026',
        amount: 250.0,
        isCredit: true,
        status: 'COMPLETED',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
            tooltip: 'Transaction Statements',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Instant Payout',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Earned', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              '₹${totalEarned.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('In Escrow', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              '₹${pendingEscrow.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                      label: const Text(
                        'Withdraw Money',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => context.push('/withdraw'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transactions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Transactions List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: tx.isCredit
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : const Color(0xFFEFF6FF),
                    child: Icon(
                      tx.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: tx.isCredit ? AppColors.accent : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    tx.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    tx.date,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  trailing: Text(
                    '${tx.isCredit ? '+' : '-'}₹${tx.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: tx.isCredit ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
