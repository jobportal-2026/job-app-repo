import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/status_badge.dart';

class ApplicationItem {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String pay;
  final String location;
  final String status; // 'APPLIED' | 'HIRED' | 'COMPLETED'
  final DateTime appliedAt;
  final String shiftTime;

  const ApplicationItem({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.pay,
    required this.location,
    required this.status,
    required this.appliedAt,
    required this.shiftTime,
  });
}

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<ApplicationItem> _allApplications = [
    ApplicationItem(
      id: 'app-1',
      jobId: 'job-101',
      jobTitle: 'Weekend Barista & Cashier',
      companyName: 'Blue Tokai Coffee Roasters',
      pay: '₹500 / hr',
      location: 'Indiranagar (1.8 km)',
      status: 'HIRED',
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      shiftTime: 'Sat & Sun • 9:00 AM - 2:00 PM',
    ),
    ApplicationItem(
      id: 'app-2',
      jobId: 'job-102',
      jobTitle: 'Tech Conference Event Coordinator',
      companyName: 'Hasura Events Ltd',
      pay: '₹3,500 / day',
      location: 'Whitefield (4.5 km)',
      status: 'APPLIED',
      appliedAt: DateTime.now().subtract(const Duration(hours: 14)),
      shiftTime: 'Oct 15-16 • Full Day',
    ),
    ApplicationItem(
      id: 'app-3',
      jobId: 'job-103',
      jobTitle: 'Graphic Design & Social Posters',
      companyName: 'Zomato Local Eats',
      pay: '₹8,000 / project',
      location: 'Remote / Hybrid',
      status: 'COMPLETED',
      appliedAt: DateTime.now().subtract(const Duration(days: 12)),
      shiftTime: 'Completed on Oct 2 • Paid',
    ),
    ApplicationItem(
      id: 'app-4',
      jobId: 'job-104',
      jobTitle: 'Maths & Science Tutor (Class 10)',
      companyName: 'Learners Academy',
      pay: '₹600 / hr',
      location: 'Koramangala (3.2 km)',
      status: 'APPLIED',
      appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      shiftTime: 'Mon, Wed, Fri • 5:00 PM - 7:00 PM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ApplicationItem> _filterByStatus(String status) {
    if (status == 'ALL') return _allApplications;
    return _allApplications.where((a) => a.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Applied'),
            Tab(text: 'Hired'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsList(_filterByStatus('ALL')),
          _buildApplicationsList(_filterByStatus('APPLIED')),
          _buildApplicationsList(_filterByStatus('HIRED')),
          _buildApplicationsList(_filterByStatus('COMPLETED')),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List<ApplicationItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'No applications in this category',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.companyName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BridgoStatusBadge(status: item.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(item.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const Spacer(),
                    Text(
                      item.pay,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(item.shiftTime, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (item.status == 'HIRED') ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Chat with Employer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => context.push('/chat?name=${Uri.encodeComponent(item.companyName)}&role=Employer'),
                      ),
                    ] else ...[
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => context.push('/job-details/${item.jobId}'),
                        child: const Text('View Job', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
