// ==========================================
// FIXED: Generic API response wrapper
// Now properly handles responses with root-level fields
// ==========================================

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
    // CRITICAL FIX: For responses that have important fields at root level
    // (like validation_ref), we need to pass the FULL json to fromJsonT
    // so it can extract both root-level and nested 'data' fields
    
    dynamic parsedData;
    
    if (fromJsonT != null) {
      // Check if there are important root-level fields besides 'data'
      final hasRootLevelFields = json.keys.any((key) => 
        key != 'success' && 
        key != 'message' && 
        key != 'msg' && 
        key != 'status' && 
        key != 'errors' && 
        key != 'status_code' && 
        key != 'statusCode' &&
        key != 'data'
      );
      
      if (hasRootLevelFields) {
        // Pass the ENTIRE json object so fromJsonT can access root fields
        // like 'validation_ref', 'type', etc.
        parsedData = fromJsonT(json);
      } else if (json['data'] != null) {
        // Standard case: only 'data' field matters
        parsedData = fromJsonT(json['data']);
      } else {
        parsedData = json['data'];
      }
    } else {
      parsedData = json['data'];
    }
    
    return ApiResponse<T>(
      success: json['success'] ?? json['status'] == 'success' ?? false,
      message: json['message'] ?? json['msg'],
      data: parsedData,
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

  factory ApiResponse.error({
    String? message, 
    Map<String, dynamic>? errors, 
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message ?? 'An error occurred',
      errors: errors,
      statusCode: statusCode ?? 500,
    );
  }
}