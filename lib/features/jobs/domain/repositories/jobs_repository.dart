import '../../data/models/job_model.dart';

abstract class JobsRepository {
  Future<List<JobModel>> getJobs({
    String? query,
    String? category,
    String? jobType,
    String? location,
    int page = 1,
    int limit = 20,
  });

  Future<JobModel> getJobById(String id);

  Future<JobModel> createJob({
    required String title,
    required String companyName,
    required String description,
    required String location,
    required String salaryRange,
    required String jobType,
    required String category,
  });

  Future<void> applyForJob({
    required String jobId,
    String? coverLetter,
  });
}
