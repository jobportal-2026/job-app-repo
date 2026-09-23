import 'package:flutter_test/flutter_test.dart';
import 'package:job_portal/features/jobs/data/models/job_model.dart';

void main() {
  group('JobModel Unit Tests', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'id': 'job-123',
        'title': 'Senior Flutter Engineer',
        'companyName': 'TechCorp',
        'description': 'Building innovative mobile apps',
        'location': 'Remote',
        'salaryRange': '\$130k - \$160k',
        'jobType': 'Full-time',
        'category': 'Engineering',
        'status': 'ACTIVE',
        'employerId': 'emp-456',
        'isSaved': true,
        'hasApplied': false,
      };

      final job = JobModel.fromJson(json);

      expect(job.id, 'job-123');
      expect(job.title, 'Senior Flutter Engineer');
      expect(job.companyName, 'TechCorp');
      expect(job.location, 'Remote');
      expect(job.salaryRange, '\$130k - \$160k');
      expect(job.isSaved, isTrue);
      expect(job.hasApplied, isFalse);
    });

    test('toJson produces correct Map structure', () {
      final job = JobModel(
        id: 'job-789',
        title: 'UI/UX Designer',
        companyName: 'DesignCo',
        description: 'Creating user centric interfaces',
        location: 'New York, NY',
        salaryRange: '\$100k - \$120k',
        jobType: 'Contract',
        category: 'Design',
        status: 'ACTIVE',
        employerId: 'emp-101',
        createdAt: DateTime.parse('2026-09-01T12:00:00.000Z'),
        isSaved: false,
        hasApplied: true,
      );

      final json = job.toJson();

      expect(json['id'], 'job-789');
      expect(json['title'], 'UI/UX Designer');
      expect(json['hasApplied'], isTrue);
      expect(json['jobType'], 'Contract');
    });

    test('copyWith updates specified fields only', () {
      final initialJob = JobModel(
        id: '1',
        title: 'Developer',
        companyName: 'Corp',
        description: 'Desc',
        location: 'Remote',
        salaryRange: '\$90k',
        jobType: 'Full-time',
        category: 'Tech',
        status: 'ACTIVE',
        employerId: 'emp-1',
        createdAt: DateTime.now(),
      );

      final updatedJob = initialJob.copyWith(hasApplied: true, title: 'Lead Developer');

      expect(updatedJob.id, '1');
      expect(updatedJob.title, 'Lead Developer');
      expect(updatedJob.hasApplied, isTrue);
      expect(updatedJob.companyName, 'Corp');
    });
  });
}
