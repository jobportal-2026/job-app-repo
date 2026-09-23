import '../../domain/repositories/jobs_repository.dart';
import '../datasources/jobs_remote_data_source.dart';
import '../models/job_model.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource remoteDataSource;

  JobsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<JobModel>> getJobs({
    String? query,
    String? category,
    String? jobType,
    String? location,
    int page = 1,
    int limit = 20,
  }) {
    return remoteDataSource.getJobs(
      query: query,
      category: category,
      jobType: jobType,
      location: location,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<JobModel> getJobById(String id) {
    return remoteDataSource.getJobById(id);
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
  }) {
    return remoteDataSource.createJob(
      title: title,
      companyName: companyName,
      description: description,
      location: location,
      salaryRange: salaryRange,
      jobType: jobType,
      category: category,
    );
  }

  @override
  Future<void> applyForJob({
    required String jobId,
    String? coverLetter,
  }) {
    return remoteDataSource.applyForJob(
      jobId: jobId,
      coverLetter: coverLetter,
    );
  }
}
