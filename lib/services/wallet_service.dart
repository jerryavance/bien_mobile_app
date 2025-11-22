// ==========================================
// FILE: lib/services/wallet_service.dart
// Updated wallet operations for real backend
// ==========================================
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';

class WalletService {
  final ApiClient _api = ApiClient();

  // Get wallet balance
  Future<ApiResponse<WalletModel>> getWallet() async {
    final response = await _api.get<Map<String, dynamic>>(
      '/wallet/balance',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final wallet = WalletModel.fromJson(response.data!);
      return ApiResponse.success(data: wallet);
    }

    return ApiResponse.error(message: response.message ?? 'Failed to fetch wallet');
  }

  // Get account details
  Future<ApiResponse<Map<String, dynamic>>> getAccountDetails(String accountId) async {
    return await _api.get<Map<String, dynamic>>(
      '/wallet/accounts/$accountId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // Validate transaction before processing
  Future<ApiResponse<Map<String, dynamic>>> validateTransaction({
    required String transactionType,
    required Map<String, dynamic> transactionData,
  }) async {
    return await _api.post<Map<String, dynamic>>(
      '/transaction/validate',
      body: {
        'transactionType': transactionType,
        ...transactionData,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // Process payment (unified endpoint for all payment types)
  Future<ApiResponse<TransactionModel>> processPayment({
    required String paymentType, // 'topup', 'cashout', 'transfer', 'airtime', etc.
    required Map<String, dynamic> paymentData,
  }) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/transaction/pay',
      body: {
        'paymentType': paymentType,
        ...paymentData,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      final transaction = TransactionModel.fromJson(response.data!);
      return ApiResponse.success(data: transaction);
    }

    return ApiResponse.error(message: response.message ?? 'Payment failed');
  }

  // Top-up wallet (deposit)
  Future<ApiResponse<TransactionModel>> topUp({
    required String source, // 'MTN', 'AIRTEL', etc.
    required String phoneNumber,
    required double amount,
    String? destinationAccountId,
  }) async {
    return await processPayment(
      paymentType: 'topup',
      paymentData: {
        'source': source,
        'phoneNumber': phoneNumber,
        'amount': amount,
        if (destinationAccountId != null) 'destinationAccountId': destinationAccountId,
      },
    );
  }

  // Cash out (withdraw)
  Future<ApiResponse<TransactionModel>> cashOut({
    required String method, // 'mobile_money', 'bank_transfer'
    required String destination, // phone number or account number
    required double amount,
    String? sourceAccountId,
    Map<String, dynamic>? additionalData,
  }) async {
    return await processPayment(
      paymentType: 'cashout',
      paymentData: {
        'method': method,
        'destination': destination,
        'amount': amount,
        if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
        if (additionalData != null) ...additionalData,
      },
    );
  }

  // Bien to Bien transfer
  Future<ApiResponse<TransactionModel>> transfer({
    required String recipientId,
    required double amount,
    String? note,
    String? sourceAccountId,
  }) async {
    return await processPayment(
      paymentType: 'transfer',
      paymentData: {
        'recipientId': recipientId,
        'amount': amount,
        if (note != null) 'note': note,
        if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
      },
    );
  }

  // Buy airtime
  Future<ApiResponse<TransactionModel>> buyAirtime({
    required String network,
    required String phoneNumber,
    required double amount,
    String? sourceAccountId,
  }) async {
    return await processPayment(
      paymentType: 'airtime',
      paymentData: {
        'network': network,
        'phoneNumber': phoneNumber,
        'amount': amount,
        if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
      },
    );
  }

  // Buy data bundle
  Future<ApiResponse<TransactionModel>> buyDataBundle({
    required String network,
    required String phoneNumber,
    required String bundleId,
    String? sourceAccountId,
  }) async {
    return await processPayment(
      paymentType: 'data',
      paymentData: {
        'network': network,
        'phoneNumber': phoneNumber,
        'bundleId': bundleId,
        if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
      },
    );
  }

  // Pay utility bill
  Future<ApiResponse<TransactionModel>> payUtility({
    required String provider,
    required String accountNumber,
    required double amount,
    String? sourceAccountId,
  }) async {
    return await processPayment(
      paymentType: 'utility',
      paymentData: {
        'provider': provider,
        'accountNumber': accountNumber,
        'amount': amount,
        if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
      },
    );
  }

  // Pay school fees
  Future<ApiResponse<TransactionModel>> paySchoolFees({
    required String system,
    required String studentNumber,
    required String schoolCode,
    required double amount,
    String? sourceAccountId,
  }) async {
    return await processPayment(
      paymentType: 'school_fees',
      paymentData: {
        'system': system,
        'studentNumber': studentNumber,
        'schoolCode': schoolCode,
        'amount': amount,
        if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
      },
    );
  }

  // Pay merchant
  Future<ApiResponse<TransactionModel>> payMerchant({
    required String merchantId,
    required double amount,
    String? sourceAccountId,
  }) async {
    return await processPayment(
      paymentType: 'merchant',
      paymentData: {
        'merchantId': merchantId,
        'amount': amount,
        if (sourceAccountId != null) 'sourceAccountId': sourceAccountId,
      },
    );
  }
}