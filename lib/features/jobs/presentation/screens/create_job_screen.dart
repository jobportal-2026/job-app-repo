import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../providers/jobs_provider.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Engineering';
  String _selectedJobType = 'Full-time';

  final _categories = ['Engineering', 'Design', 'Marketing', 'Sales', 'Product', 'General'];
  final _jobTypes = ['Full-time', 'Part-time', 'Contract', 'Remote', 'Internship'];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitJob() async {
    debugPrint('Publish Job Listing button tapped');
    if (_formKey.currentState!.validate()) {
      debugPrint('Job form validated successfully, submitting request: title="${_titleController.text.trim()}", company="${_companyController.text.trim()}", category="$_selectedCategory", jobType="$_selectedJobType"');
      final jobsProvider = context.read<JobsProvider>();
      final success = await jobsProvider.createJob(
        title: _titleController.text.trim(),
        companyName: _companyController.text.trim(),
        location: _locationController.text.trim(),
        salaryRange: _salaryController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        jobType: _selectedJobType,
      );

      if (mounted) {
        if (success) {
          debugPrint('Job publication succeeded!');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job posted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (jobsProvider.errorMessage != null) {
          debugPrint('Job publication failed with error: ${jobsProvider.errorMessage}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jobsProvider.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      debugPrint('Job form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsProvider = context.watch<JobsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a New Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  hintText: 'e.g. Senior Flutter Developer',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter job title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'e.g. Acme Corp',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter company name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g. San Francisco, CA / Remote',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary Range',
                  hintText: 'e.g. \$120k - \$150k / year',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter salary range' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedJobType,
                decoration: const InputDecoration(labelText: 'Job Type'),
                items: _jobTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedJobType = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  hintText: 'Describe requirements, responsibilities, and benefits...',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'Publish Job Listing',
                isLoading: jobsProvider.isSubmitting,
                onPressed: _submitJob,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
