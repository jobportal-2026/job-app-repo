import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';
import '../../../jobs/presentation/widgets/job_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final List<String> _categories = ['All', 'Engineering', 'Design', 'Marketing', 'Sales', 'Product'];

  @override
  void initState() {
    super.initState();
    debugPrint('HomeScreen loaded/initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('HomeScreen fetching jobs...');
      context.read<JobsProvider>().fetchJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final jobsProvider = context.watch<JobsProvider>();
    final user = authProvider.currentUser;
    final isEmployer = user?.role == 'employer';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridgo Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          debugPrint('HomeScreen reloaded / pull-to-refresh triggered');
          await context.read<JobsProvider>().fetchJobs();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.name ?? "User"}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEmployer ? 'Post & manage job openings' : 'Find your dream job',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onSubmitted: (val) {
                        context.read<JobsProvider>().setSearchQuery(val.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search jobs, skills, or companies...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<JobsProvider>().setSearchQuery('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Categories horizontal scroll
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = jobsProvider.selectedCategory == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: AppColors.surface,
                            onSelected: (_) {
                              context.read<JobsProvider>().setCategory(category);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Latest Opportunities',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (isEmployer)
                          SizedBox(
                            height: 38,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Post Job'),
                              onPressed: () => context.push('/create-job'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (jobsProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (jobsProvider.jobs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        jobsProvider.errorMessage ?? 'No jobs found matching your criteria.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final job = jobsProvider.jobs[index];
                      return JobCardWidget(
                        job: job,
                        onTap: () => context.push('/job-details/${job.id}'),
                      );
                    },
                    childCount: jobsProvider.jobs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
