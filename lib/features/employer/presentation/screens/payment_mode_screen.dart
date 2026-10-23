import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';

class PaymentModeScreen extends StatefulWidget {
  final Map<String, dynamic> jobDraft;

  const PaymentModeScreen({
    super.key,
    required this.jobDraft,
  });

  @override
  State<PaymentModeScreen> createState() => _PaymentModeScreenState();
}

class _PaymentModeScreenState extends State<PaymentModeScreen> {
  String _selectedMode = 'PACK'; // 'PAY_PER_HIRE' | 'PACK'
  bool _isPublishing = false;
  final int _remainingPackCredits = 8;

  Future<void> _handleConfirm() async {
    setState(() => _isPublishing = true);

    final title = widget.jobDraft['title'] ?? 'Job';
    final companyName = widget.jobDraft['companyName'] ?? 'Bridgo Partner';
    final location = widget.jobDraft['location'] ?? 'Bengaluru';
    final salary = widget.jobDraft['salary'] ?? '₹500 / hr';
    final description = widget.jobDraft['description'] ?? '';
    final category = widget.jobDraft['category'] ?? 'General';
    final jobType = widget.jobDraft['jobType'] ?? 'Flexible';

    final success = await context.read<JobsProvider>().createJob(
      title: title,
      companyName: companyName,
      description: description,
      location: location,
      salaryRange: salary,
      jobType: jobType,
      category: category,
    );

    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (success) {
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
                'Job Published Successfully!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Your job "$title" is now live. Candidates within 15 km are being notified.',
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
                  child: const Text('View Live Listing', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<JobsProvider>().errorMessage ?? 'Failed to publish job'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Payment Mode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Preview Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('JOB SUMMARY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    widget.jobDraft['title'] ?? 'Title',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(widget.jobDraft['salary'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const Text(' • '),
                      Text(widget.jobDraft['location'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'How would you like to pay for hires?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose between per-hire pricing or use your discounted hiring pack.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Option 1: Pay Per Hire
            InkWell(
              onTap: () => setState(() => _selectedMode = 'PAY_PER_HIRE'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedMode == 'PAY_PER_HIRE' ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedMode == 'PAY_PER_HIRE' ? AppColors.primary : AppColors.cardBorder,
                    width: _selectedMode == 'PAY_PER_HIRE' ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _selectedMode == 'PAY_PER_HIRE' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _selectedMode == 'PAY_PER_HIRE' ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Option 1: Pay Per Hire',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text(
                                '₹99 / hire',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Post job for free now. Only pay the platform matching fee (₹99) once you decide to hire a candidate.',
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Option 2: Use Hiring Pack
            InkWell(
              onTap: () => setState(() => _selectedMode = 'PACK'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedMode == 'PACK' ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedMode == 'PACK' ? AppColors.primary : AppColors.cardBorder,
                    width: _selectedMode == 'PACK' ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _selectedMode == 'PACK' ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: _selectedMode == 'PACK' ? AppColors.primary : AppColors.textMuted,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Option 2: Use Hiring Pack',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$_remainingPackCredits left',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Deduct 1 hire credit automatically from your active Growth Pack when you confirm candidate hiring.',
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => context.push('/packs'),
                            child: const Text(
                              'Need more credits? View Hiring Packs →',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),

            // Confirm & Publish Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isPublishing ? null : _handleConfirm,
                child: _isPublishing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Confirm & Publish Job Listing',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
