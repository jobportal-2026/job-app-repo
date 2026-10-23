import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController(text: 'Blue Tokai Indiranagar');
  final _locationController = TextEditingController(text: 'Indiranagar, Bengaluru');
  final _salaryController = TextEditingController(text: '₹500 / hr');
  final _durationController = TextEditingController(text: '4 hrs/day • Weekends (Sat-Sun)');
  final _descriptionController = TextEditingController(
    text: 'Looking for an enthusiastic part-time barista to handle customer orders, POS billing, and prepare espresso drinks during morning weekend rush hours.',
  );

  String _selectedCategory = 'Hospitality';
  String _selectedJobType = 'Part-time';

  final _categories = ['Hospitality', 'Events & Coordination', 'Retail & Sales', 'Tutoring', 'Engineering', 'Design', 'General'];
  final _jobTypes = ['Part-time', 'Hourly Gig', 'Weekends Only', 'Contract', 'Full-time'];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      final jobDraft = {
        'title': _titleController.text.trim(),
        'companyName': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'salary': _salaryController.text.trim(),
        'duration': _durationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'jobType': _selectedJobType,
      };

      context.push('/payment-mode', extra: jobDraft);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // Step indicator
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Step 1 of 2', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  const Text('Job Details & Requirements', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  hintText: 'e.g. Weekend Barista & Cashier',
                  prefixIcon: Icon(Icons.title_rounded, color: AppColors.primary),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter job title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company / Business Name',
                  hintText: 'e.g. Blue Tokai Coffee Roasters',
                  prefixIcon: Icon(Icons.storefront_outlined, color: AppColors.primary),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter company name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salaryController,
                      decoration: const InputDecoration(
                        labelText: 'Pay (Rate / Salary)',
                        hintText: 'e.g. ₹500 / hr',
                        prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter pay rate' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration / Timings',
                        hintText: 'e.g. 4 hrs/day',
                        prefixIcon: Icon(Icons.schedule, color: AppColors.primary),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter duration' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location / Work Address',
                  hintText: 'e.g. Indiranagar 100ft Road, Bengaluru',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedJobType,
                      decoration: const InputDecoration(labelText: 'Work Type'),
                      items: _jobTypes.map((type) => DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedJobType = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Job Description & Requirements',
                  hintText: 'Describe role duties, working hours, and student perks...',
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                text: 'Next: Select Payment Mode →',
                onPressed: _onNext,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
