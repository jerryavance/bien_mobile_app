// ==========================================
// FILE: lib/services/transaction_service.dart
// Transaction operations (All Product transactions)
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
    TransactionType? type,
    TransactionStatus? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (type != null) queryParams['type'] = type.name;
    if (status != null) queryParams['status'] = status.name;

    return await _api.get(
      '/transactions',
      queryParams: queryParams,
      fromJson: (data) => (data as List).map((e) => TransactionModel.fromJson(e)).toList(),
    );
  }

  // Get single transaction
  Future<ApiResponse<TransactionModel>> getTransaction(String id) async {
    return await _api.get(
      '/transactions/$id',
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }

  // Buy airtime
  Future<ApiResponse<TransactionModel>> buyAirtime({
    required String network,
    required String phoneNumber,
    required double amount,
  }) async {
    return await _api.post(
      '/products/airtime',
      body: {
        'network': network,
        'phone_number': phoneNumber,
        'amount': amount,
      },
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }

  // Buy data bundle
  Future<ApiResponse<TransactionModel>> buyDataBundle({
    required String network,
    required String phoneNumber,
    required String bundleId,
  }) async {
    return await _api.post(
      '/products/data',
      body: {
        'network': network,
        'phone_number': phoneNumber,
        'bundle_id': bundleId,
      },
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }

  // Pay utility
  Future<ApiResponse<TransactionModel>> payUtility({
    required String provider,
    required String accountNumber,
    required double amount,
  }) async {
    return await _api.post(
      '/products/utility',
      body: {
        'provider': provider,
        'account_number': accountNumber,
        'amount': amount,
      },
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }

  // Pay school fees
  Future<ApiResponse<TransactionModel>> paySchoolFees({
    required String system,
    required String studentNumber,
    required String schoolCode,
    required double amount,
  }) async {
    return await _api.post(
      '/products/school-fees',
      body: {
        'system': system,
        'student_number': studentNumber,
        'school_code': schoolCode,
        'amount': amount,
      },
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }

  // Pay merchant
  Future<ApiResponse<TransactionModel>> payMerchant({
    required String merchantId,
    required double amount,
  }) async {
    return await _api.post(
      '/products/merchant',
      body: {
        'merchant_id': merchantId,
        'amount': amount,
      },
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }
}