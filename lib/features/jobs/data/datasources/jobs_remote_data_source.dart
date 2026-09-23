import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../models/job_model.dart';

class JobsRemoteDataSource {
  final ApiClient apiClient;

  JobsRemoteDataSource({required this.apiClient});

  Future<List<JobModel>> getJobs({
    String? query,
    String? category,
    String? jobType,
    String? location,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (query != null && query.isNotEmpty) 'q': query,
        if (category != null && category.isNotEmpty && category != 'All') 'category': category,
        if (jobType != null && jobType.isNotEmpty && jobType != 'All') 'jobType': jobType,
        if (location != null && location.isNotEmpty) 'location': location,
      };

      final response = await apiClient.dio.get(
        '/jobs',
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (json is Map<String, dynamic> && json['items'] is List) {
            return (json['items'] as List)
                .map((item) => JobModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <JobModel>[];
        },
      );

      return apiResponse.data ?? [];
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<JobModel> getJobById(String id) async {
    try {
      final response = await apiClient.dio.get('/jobs/$id');
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => JobModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data!;
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<JobModel> createJob({
    required String title,
    required String companyName,
    required String description,
    required String location,
    required String salaryRange,
    required String jobType,
    required String category,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/jobs',
        data: {
          'title': title,
          'companyName': companyName,
          'description': description,
          'location': location,
          'salaryRange': salaryRange,
          'jobType': jobType,
          'category': category,
        },
      );
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => JobModel.fromJson(json as Map<String, dynamic>),
      );
      return apiResponse.data!;
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }

  Future<void> applyForJob({
    required String jobId,
    String? coverLetter,
  }) async {
    try {
      await apiClient.dio.post(
        '/jobs/$jobId/apply',
        data: {
          if (coverLetter != null && coverLetter.isNotEmpty) 'coverLetter': coverLetter,
        },
      );
    } on DioException catch (e) {
      throw apiClient.handleDioError(e);
    }
  }
}
