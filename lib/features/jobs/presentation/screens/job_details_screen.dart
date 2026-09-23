import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/jobs_provider.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _coverLetterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().getJobDetails(widget.jobId);
    });
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  void _showApplyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit Application',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Include an optional cover letter to stand out to the employer.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _coverLetterController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell the employer why you are a great fit...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Consumer<JobsProvider>(
                builder: (context, jobsProvider, _) {
                  return PrimaryButton(
                    text: 'Submit Application',
                    isLoading: jobsProvider.isSubmitting,
                    onPressed: () async {
                      final success = await jobsProvider.applyForJob(
                        jobId: widget.jobId,
                        coverLetter: _coverLetterController.text.trim(),
                      );
                      if (context.mounted) {
                        Navigator.pop(bottomSheetContext);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Application submitted successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        } else if (jobsProvider.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(jobsProvider.errorMessage!),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.watch<JobsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final job = jobsProvider.selectedJob;
    final isEmployee = authProvider.currentUser?.role == 'employee';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: jobsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : job == null
              ? Center(
                  child: Text(
                    jobsProvider.errorMessage ?? 'Job not found',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : 'B',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.companyName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _detailChip(Icons.location_on_outlined, job.location),
                          _detailChip(Icons.work_outline, job.jobType),
                          _detailChip(Icons.category_outlined, job.category),
                          _detailChip(Icons.attach_money, job.salaryRange),
                        ],
                      ),
                      const Divider(height: 40),
                      const Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        job.description.isNotEmpty
                            ? job.description
                            : 'No detailed description provided by employer.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: job != null && isEmployee
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  text: job.hasApplied ? 'Already Applied' : 'Apply Now',
                  onPressed: job.hasApplied ? null : () => _showApplyModal(context),
                ),
              ),
            )
          : null,
    );
  }

  Widget _detailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
