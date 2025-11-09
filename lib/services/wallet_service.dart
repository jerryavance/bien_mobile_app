// ==========================================
// FILE: lib/services/wallet_service.dart
// Wallet operations
// ==========================================
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';

class WalletService {
  final ApiClient _api = ApiClient();

  // Get wallet balance
  Future<ApiResponse<WalletModel>> getWallet() async {
    return await _api.get(
      '/wallet',
      fromJson: (data) => WalletModel.fromJson(data),
    );
  }

  // Top-up wallet
  Future<ApiResponse<TransactionModel>> topUp({
    required String source, // MTN, AIRTEL, FLEXIPAY
    required String phoneNumber,
    required double amount,
  }) async {
    return await _api.post(
      '/wallet/topup',
      body: {
        'source': source,
        'phone_number': phoneNumber,
        'amount': amount,
      },
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }

  // Cash out
  Future<ApiResponse<TransactionModel>> cashOut({
    required String method, // MOBILE_MONEY, BANK, BIEN_TRANSFER
    required String destination,
    required double amount,
    Map<String, dynamic>? additionalData,
  }) async {
    return await _api.post(
      '/wallet/cashout',
      body: {
        'method': method,
        'destination': destination,
        'amount': amount,
        ...?additionalData,
      },
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }

  // Bien to Bien transfer
  Future<ApiResponse<TransactionModel>> transfer({
    required String recipientId,
    required double amount,
    String? note,
  }) async {
    return await _api.post(
      '/wallet/transfer',
      body: {
        'recipient_id': recipientId,
        'amount': amount,
        'note': note,
      },
      fromJson: (data) => TransactionModel.fromJson(data),
    );
  }
}