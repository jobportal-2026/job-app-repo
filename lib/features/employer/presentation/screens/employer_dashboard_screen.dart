import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/candidate_card_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';

class EmployerDashboardScreen extends StatelessWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final jobsProvider = context.watch<JobsProvider>();
    final user = authProvider.currentUser;

    final mockRecentApplicants = [
      const CandidateModel(
        id: 'cand-1',
        name: 'Priya Sharma',
        title: 'Certified Barista & Cashier',
        rating: 4.9,
        reviewsCount: 22,
        distanceKm: 1.8,
        skills: ['Espresso Machines', 'Customer Service', 'POS Billing', 'Inventory'],
        availability: 'Weekends • Immediate',
        hourlyRate: '₹450/hr',
        experience: '2 years at CCD & Starbucks part-time',
        education: 'B.Sc Economics (Final Year), Mount Carmel',
        about: 'Passionate specialty coffee enthusiast with over 2 years of specialty brewing and high-rush hospitality experience.',
        phone: '+91 98765 43210',
        email: 'priya.sharma@example.com',
      ),
      const CandidateModel(
        id: 'cand-2',
        name: 'Rahul Verma',
        title: 'Tech Event Coordinator & AV Tech',
        rating: 4.8,
        reviewsCount: 14,
        distanceKm: 3.4,
        skills: ['Stage Management', 'Live Audio/Video', 'Crowd Management', 'Registration'],
        availability: 'Flexible • Weekday Evenings & Weekends',
        hourlyRate: '₹3,000/day',
        experience: 'Coordinated 6 major university conferences and hackathons',
        education: 'B.Tech CS, RV College',
        about: 'Energetic coordinator experienced with logistics, audio/visual setups, and quick problem solving under tight event schedules.',
        phone: '+91 98765 11223',
        email: 'rahul.verma@example.com',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<JobsProvider>().fetchJobs();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${user?.name ?? "Business Partner"} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage your job postings and hire verified talent',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Metric Stats Grid (Total Hires, Active Jobs, Pack Credits)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.people_alt_outlined,
                      label: 'Total Hires',
                      value: '24',
                      trend: '+4 this week',
                      color: AppColors.primary,
                      onTap: () => context.push('/applicants'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      icon: Icons.work_outline_rounded,
                      label: 'Active Jobs',
                      value: '${jobsProvider.jobs.isNotEmpty ? jobsProvider.jobs.length : 3}',
                      trend: '12 new applicants',
                      color: AppColors.secondary,
                      onTap: () => context.push('/'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hiring Pack Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.inventory_2_outlined, color: Colors.amberAccent, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Growth Hiring Pack (Active)',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '8 hire credits remaining',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => context.push('/packs'),
                      child: const Text('Buy Packs', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions (2.1 Wireframe)
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionBtn(
                      icon: Icons.add_circle_outline,
                      label: 'Post New Job',
                      sub: 'Find talent in 5 min',
                      color: AppColors.primary,
                      onTap: () => context.push('/create-job'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionBtn(
                      icon: Icons.how_to_reg_outlined,
                      label: 'View Applicants',
                      sub: '18 candidates ready',
                      color: AppColors.accent,
                      onTap: () => context.push('/applicants'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Applicants Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Matching Candidates',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => context.push('/applicants'),
                    child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...mockRecentApplicants.map((cand) {
                return CandidateCardWidget(
                  candidate: cand,
                  onTap: () {
                    context.push('/candidate-details', extra: cand);
                  },
                  onHire: () {
                    context.push(
                      '/employer-payment?candidateName=${Uri.encodeComponent(cand.name)}&title=${Uri.encodeComponent(cand.title)}&amount=450',
                    );
                  },
                  onChat: () {
                    context.push('/chat?name=${Uri.encodeComponent(cand.name)}&role=Candidate');
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String trend,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted.withValues(alpha: 0.8)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(trend, style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
