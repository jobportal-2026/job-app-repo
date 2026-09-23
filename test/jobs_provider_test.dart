import 'package:flutter_test/flutter_test.dart';
import 'package:job_portal/features/jobs/data/models/job_model.dart';
import 'package:job_portal/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:job_portal/features/jobs/presentation/providers/jobs_provider.dart';

class MockJobsRepository implements JobsRepository {
  List<JobModel> mockJobs = [
    JobModel(
      id: 'job-1',
      title: 'Flutter Developer',
      companyName: 'AppStudio',
      description: 'Build Flutter apps',
      location: 'Remote',
      salaryRange: '\$100k',
      jobType: 'Full-time',
      category: 'Engineering',
      status: 'ACTIVE',
      employerId: 'emp-1',
      createdAt: DateTime.now(),
    ),
  ];

  bool shouldThrowError = false;

  @override
  Future<List<JobModel>> getJobs({
    String? query,
    String? category,
    String? jobType,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    if (shouldThrowError) throw Exception('Failed to load jobs');
    return mockJobs;
  }

  @override
  Future<JobModel> getJobById(String id) async {
    if (shouldThrowError) throw Exception('Job not found');
    return mockJobs.firstWhere((j) => j.id == id);
  }

  @override
  Future<JobModel> createJob({
    required String title,
    required String companyName,
    required String description,
    required String location,
    required String salaryRange,
    required String jobType,
    required String category,
  }) async {
    final newJob = JobModel(
      id: 'job-new',
      title: title,
      companyName: companyName,
      description: description,
      location: location,
      salaryRange: salaryRange,
      jobType: jobType,
      category: category,
      status: 'ACTIVE',
      employerId: 'emp-1',
      createdAt: DateTime.now(),
    );
    mockJobs.insert(0, newJob);
    return newJob;
  }

  @override
  Future<void> applyForJob({required String jobId, String? coverLetter}) async {}
}

void main() {
  late MockJobsRepository mockRepository;
  late JobsProvider jobsProvider;

  setUp(() {
    mockRepository = MockJobsRepository();
    jobsProvider = JobsProvider(jobsRepository: mockRepository);
  });

  group('JobsProvider Tests', () {
    test('fetchJobs updates job list successfully', () async {
      await jobsProvider.fetchJobs();

      expect(jobsProvider.isLoading, isFalse);
      expect(jobsProvider.jobs.length, 1);
      expect(jobsProvider.jobs.first.title, 'Flutter Developer');
    });

    test('createJob prepends new job to jobs list', () async {
      final result = await jobsProvider.createJob(
        title: 'Backend Engineer',
        companyName: 'NodeWorks',
        description: 'NestJS APIs',
        location: 'Hybrid',
        salaryRange: '\$110k',
        jobType: 'Full-time',
        category: 'Engineering',
      );

      expect(result, isTrue);
      expect(jobsProvider.jobs.first.title, 'Backend Engineer');
    });

    test('applyForJob marks job as applied', () async {
      await jobsProvider.fetchJobs();
      final success = await jobsProvider.applyForJob(jobId: 'job-1', coverLetter: 'Hello!');

      expect(success, isTrue);
      expect(jobsProvider.jobs.first.hasApplied, isTrue);
    });
  });
}
