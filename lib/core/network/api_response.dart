class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<ApiFieldError>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final hasStandardKeys = json.containsKey('success') || json.containsKey('data');
    if (!hasStandardKeys && fromJsonT != null) {
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: fromJsonT(json),
      );
    }

    dynamic extractedData;
    if (json['data'] != null && fromJsonT != null) {
      extractedData = fromJsonT(json['data']);
    } else if (json['data'] is T) {
      extractedData = json['data'] as T;
    }

    String messageStr = '';
    if (json['message'] is String) {
      messageStr = json['message'] as String;
    } else if (json['message'] is List) {
      messageStr = (json['message'] as List).join(', ');
    } else if (json['message'] != null) {
      messageStr = json['message'].toString();
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: messageStr,
      data: extractedData as T?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => ApiFieldError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ApiFieldError {
  final String field;
  final String message;

  ApiFieldError({
    required this.field,
    required this.message,
  });

  factory ApiFieldError.fromJson(Map<String, dynamic> json) {
    return ApiFieldError(
      field: json['field'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
