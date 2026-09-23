class JobModel {
  final String id;
  final String title;
  final String companyName;
  final String description;
  final String location;
  final String salaryRange;
  final String jobType;
  final String category;
  final String status;
  final String employerId;
  final DateTime createdAt;
  final bool isSaved;
  final bool hasApplied;

  const JobModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.description,
    required this.location,
    required this.salaryRange,
    required this.jobType,
    required this.category,
    required this.status,
    required this.employerId,
    required this.createdAt,
    this.isSaved = false,
    this.hasApplied = false,
  });

  static String _parseString(dynamic value, String fallback) {
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      if (value['name'] is String) return value['name'] as String;
      if (value['title'] is String) return value['title'] as String;
    }
    if (value != null) return value.toString();
    return fallback;
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: _parseString(json['id'], ''),
      title: _parseString(json['title'] ?? json['name'], 'Untitled Job'),
      companyName: _parseString(json['companyName'] ?? json['company'], 'Company'),
      description: _parseString(json['description'], ''),
      location: _parseString(json['location'], 'Remote'),
      salaryRange: _parseString(json['salaryRange'] ?? json['salary'], 'Competitive'),
      jobType: _parseString(json['jobType'] ?? json['type'], 'Full-time'),
      category: _parseString(json['category'], 'General'),
      status: _parseString(json['status'], 'ACTIVE'),
      employerId: _parseString(json['employerId'] ?? json['companyId'], ''),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSaved: json['isSaved'] as bool? ?? false,
      hasApplied: json['hasApplied'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'companyName': companyName,
      'description': description,
      'location': location,
      'salaryRange': salaryRange,
      'jobType': jobType,
      'category': category,
      'status': status,
      'employerId': employerId,
      'createdAt': createdAt.toIso8601String(),
      'isSaved': isSaved,
      'hasApplied': hasApplied,
    };
  }

  JobModel copyWith({
    String? id,
    String? title,
    String? companyName,
    String? description,
    String? location,
    String? salaryRange,
    String? jobType,
    String? category,
    String? status,
    String? employerId,
    DateTime? createdAt,
    bool? isSaved,
    bool? hasApplied,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      description: description ?? this.description,
      location: location ?? this.location,
      salaryRange: salaryRange ?? this.salaryRange,
      jobType: jobType ?? this.jobType,
      category: category ?? this.category,
      status: status ?? this.status,
      employerId: employerId ?? this.employerId,
      createdAt: createdAt ?? this.createdAt,
      isSaved: isSaved ?? this.isSaved,
      hasApplied: hasApplied ?? this.hasApplied,
    );
  }
}
