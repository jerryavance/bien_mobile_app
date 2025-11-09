// Generic API response wrapper

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? json['status'] == 'success' ?? false,
      message: json['message'] ?? json['msg'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      errors: json['errors'],
      statusCode: json['status_code'] ?? json['statusCode'],
    );
  }

  factory ApiResponse.success({T? data, String? message}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message ?? 'Success',
      statusCode: 200,
    );
  }

  factory ApiResponse.error({String? message, Map<String, dynamic>? errors, int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message ?? 'An error occurred',
      errors: errors,
      statusCode: statusCode ?? 500,
    );
  }
}