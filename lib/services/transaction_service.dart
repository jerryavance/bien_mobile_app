// ==========================================
// FILE: lib/services/transaction_service.dart
// Updated transaction operations for real backend
// ==========================================
import '../models/transaction_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';

class TransactionService {
  final ApiClient _api = ApiClient();

  // Get transaction history
  Future<ApiResponse<List<TransactionModel>>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (search != null) queryParams['search'] = search;

    final response = await _api.get<Map<String, dynamic>>(
      '/transaction/list',
      queryParams: queryParams,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      // Handle different response structures
      List<dynamic> transactionsList;
      
      if (response.data!.containsKey('transactions')) {
        transactionsList = response.data!['transactions'] as List;
      } else if (response.data!.containsKey('data')) {
        transactionsList = response.data!['data'] as List;
      } else if (response.data is List) {
        transactionsList = response.data as List;
      } else {
        return ApiResponse.error(message: 'Invalid response format');
      }

      final transactions = transactionsList
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(data: transactions);
    }

    return ApiResponse.error(
      message: response.message ?? 'Failed to fetch transactions',
    );
  }

  // Get single transaction details
  Future<ApiResponse<TransactionModel>> getTransaction(String transactionId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/transaction/$transactionId',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final transaction = TransactionModel.fromJson(response.data!);
      return ApiResponse.success(data: transaction);
    }

    return ApiResponse.error(
      message: response.message ?? 'Failed to fetch transaction',
    );
  }

  // Get transaction summary/statistics
  Future<ApiResponse<Map<String, dynamic>>> getTransactionSummary({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    
    if (period != null) queryParams['period'] = period;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    return await _api.get<Map<String, dynamic>>(
      '/transaction/summary',
      queryParams: queryParams,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // Download transaction receipt
  Future<ApiResponse<String>> getTransactionReceipt(String transactionId) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/transaction/$transactionId/receipt',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final receiptUrl = response.data!['receipt_url'] ?? response.data!['url'];
      return ApiResponse.success(data: receiptUrl as String);
    }

    return ApiResponse.error(message: 'Failed to get receipt');
  }

  // Check transaction status
  Future<ApiResponse<Map<String, dynamic>>> checkTransactionStatus(String transactionId) async {
    return await _api.get<Map<String, dynamic>>(
      '/transaction/$transactionId/status',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}