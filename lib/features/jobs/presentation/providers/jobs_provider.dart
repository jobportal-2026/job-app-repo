import 'package:flutter/material.dart';
import '../../data/models/job_model.dart';
import '../../domain/repositories/jobs_repository.dart';

class JobsProvider extends ChangeNotifier {
  final JobsRepository jobsRepository;

  List<JobModel> _jobs = [];
  JobModel? _selectedJob;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedJobType = 'All';

  JobsProvider({required this.jobsRepository});

  List<JobModel> get jobs => _jobs;
  JobModel? get selectedJob => _selectedJob;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedJobType => _selectedJobType;

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchJobs();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    fetchJobs();
  }

  void setJobType(String jobType) {
    _selectedJobType = jobType;
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedJobs = await jobsRepository.getJobs(
        query: _searchQuery,
        category: _selectedCategory,
        jobType: _selectedJobType,
      );
      _jobs = fetchedJobs;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getJobDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedJob = await jobsRepository.getJobById(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createJob({
    required String title,
    required String companyName,
    required String description,
    required String location,
    required String salaryRange,
    required String jobType,
    required String category,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newJob = await jobsRepository.createJob(
        title: title,
        companyName: companyName,
        description: description,
        location: location,
        salaryRange: salaryRange,
        jobType: jobType,
        category: category,
      );
      _jobs.insert(0, newJob);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> applyForJob({
    required String jobId,
    String? coverLetter,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await jobsRepository.applyForJob(
        jobId: jobId,
        coverLetter: coverLetter,
      );
      // Mark job as applied locally
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index != -1) {
        _jobs[index] = _jobs[index].copyWith(hasApplied: true);
      }
      if (_selectedJob?.id == jobId) {
        _selectedJob = _selectedJob?.copyWith(hasApplied: true);
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
