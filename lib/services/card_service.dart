// ==========================================
// FILE: lib/services/card_service.dart
// Verve card API integration (Interswitch)
// ==========================================
import '../models/card_models.dart';
import '../models/transaction_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import 'storage_service.dart';

class CardService {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  // ==========================================
  // CARD MANAGEMENT
  // ==========================================

  /// Get all user cards
  Future<ApiResponse<List<CardModel>>> getCards() async {
    try {
      print('CardService: Fetching user cards');

      final response = await _api.get<List<dynamic>>(
        '/cards/list',
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final cards = response.data!
            .map((card) => CardModel.fromJson(card as Map<String, dynamic>))
            .toList();

        print('✅ Fetched ${cards.length} cards');
        return ApiResponse.success(data: cards);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch cards',
      );
    } catch (e) {
      print('❌ CardService.getCards error: $e');
      return ApiResponse.error(message: 'Error fetching cards: $e');
    }
  }

  /// Get single card details
  Future<ApiResponse<CardModel>> getCard(String cardId) async {
    try {
      print('CardService: Fetching card: $cardId');

      final response = await _api.get<Map<String, dynamic>>(
        '/cards/$cardId',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final card = CardModel.fromJson(response.data!);
        print('✅ Card fetched successfully');
        return ApiResponse.success(data: card);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch card',
      );
    } catch (e) {
      print('❌ CardService.getCard error: $e');
      return ApiResponse.error(message: 'Error fetching card: $e');
    }
  }

  // ==========================================
  // CARD STATUS MANAGEMENT
  // ==========================================

  /// Freeze card
  Future<ApiResponse<CardModel>> freezeCard(String cardId) async {
    try {
      print('CardService: Freezing card: $cardId');

      final response = await _api.post<Map<String, dynamic>>(
        '/cards/$cardId/freeze',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final card = CardModel.fromJson(response.data!);
        print('✅ Card frozen successfully');
        return ApiResponse.success(data: card);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to freeze card',
      );
    } catch (e) {
      print('❌ CardService.freezeCard error: $e');
      return ApiResponse.error(message: 'Error freezing card: $e');
    }
  }

  /// Unfreeze card
  Future<ApiResponse<CardModel>> unfreezeCard(String cardId) async {
    try {
      print('CardService: Unfreezing card: $cardId');

      final response = await _api.post<Map<String, dynamic>>(
        '/cards/$cardId/unfreeze',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final card = CardModel.fromJson(response.data!);
        print('✅ Card unfrozen successfully');
        return ApiResponse.success(data: card);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to unfreeze card',
      );
    } catch (e) {
      print('❌ CardService.unfreezeCard error: $e');
      return ApiResponse.error(message: 'Error unfreezing card: $e');
    }
  }

  /// Block card
  Future<ApiResponse<CardModel>> blockCard(String cardId) async {
    try {
      print('CardService: Blocking card: $cardId');

      final response = await _api.post<Map<String, dynamic>>(
        '/cards/$cardId/block',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final card = CardModel.fromJson(response.data!);
        print('✅ Card blocked successfully');
        return ApiResponse.success(data: card);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to block card',
      );
    } catch (e) {
      print('❌ CardService.blockCard error: $e');
      return ApiResponse.error(message: 'Error blocking card: $e');
    }
  }

  // ==========================================
  // CARD TRANSACTIONS
  // ==========================================

  /// Top-up card (validate)
  Future<ApiResponse<Map<String, dynamic>>> validateCardTopUp({
    required String cardId,
    required double amount,
    required String source,
  }) async {
    try {
      final body = {
        'card_id': cardId,
        'amount': amount,
        'source': source,
      };

      print('CardService: Validating card top-up: $body');

      final response = await _api.post<Map<String, dynamic>>(
        '/cards/topup/validate',
        body: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        print('✅ Card top-up validation successful');
        return ApiResponse.success(data: response.data!);
      }

      return ApiResponse.error(
        message: response.message ?? 'Top-up validation failed',
      );
    } catch (e) {
      print('❌ CardService.validateCardTopUp error: $e');
      return ApiResponse.error(message: 'Validation error: $e');
    }
  }

  /// Complete card top-up
  Future<ApiResponse<TransactionModel>> completeCardTopUp({
    required String validationRef,
    String? note,
  }) async {
    try {
      final body = {
        'validation_ref': validationRef,
        'note': note ?? 'Card top-up',
      };

      print('CardService: Completing card top-up');

      final response = await _api.post<Map<String, dynamic>>(
        '/cards/topup/complete',
        body: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final transaction = TransactionModel.fromJson(response.data!);
        print('✅ Card top-up successful');
        return ApiResponse.success(data: transaction);
      }

      return ApiResponse.error(
        message: response.message ?? 'Top-up failed',
      );
    } catch (e) {
      print('❌ CardService.completeCardTopUp error: $e');
      return ApiResponse.error(message: 'Top-up error: $e');
    }
  }

  /// Transfer from card (validate)
  Future<ApiResponse<Map<String, dynamic>>> validateCardTransfer({
    required String cardId,
    required double amount,
    required String destination,
    required String destinationType, // 'wallet', 'bank', 'mobile'
  }) async {
    try {
      final body = {
        'card_id': cardId,
        'amount': amount,
        'destination': destination,
        'destination_type': destinationType,
      };

      print('CardService: Validating card transfer: $body');

      final response = await _api.post<Map<String, dynamic>>(
        '/cards/transfer/validate',
        body: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        print('✅ Card transfer validation successful');
        return ApiResponse.success(data: response.data!);
      }

      return ApiResponse.error(
        message: response.message ?? 'Transfer validation failed',
      );
    } catch (e) {
      print('❌ CardService.validateCardTransfer error: $e');
      return ApiResponse.error(message: 'Validation error: $e');
    }
  }

  /// Complete card transfer
  Future<ApiResponse<TransactionModel>> completeCardTransfer({
    required String validationRef,
    String? note,
  }) async {
    try {
      final body = {
        'validation_ref': validationRef,
        'note': note ?? 'Card transfer',
      };

      print('CardService: Completing card transfer');

      final response = await _api.post<Map<String, dynamic>>(
        '/cards/transfer/complete',
        body: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final transaction = TransactionModel.fromJson(response.data!);
        print('✅ Card transfer successful');
        return ApiResponse.success(data: transaction);
      }

      return ApiResponse.error(
        message: response.message ?? 'Transfer failed',
      );
    } catch (e) {
      print('❌ CardService.completeCardTransfer error: $e');
      return ApiResponse.error(message: 'Transfer error: $e');
    }
  }

  /// Get card transactions
  Future<ApiResponse<List<CardTransaction>>> getCardTransactions(
    String cardId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('CardService: Fetching transactions for card: $cardId');

      final response = await _api.get<List<dynamic>>(
        '/cards/$cardId/transactions',
        queryParams: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
        fromJson: (data) => data as List<dynamic>,
      );

      if (response.success && response.data != null) {
        final transactions = response.data!
            .map((txn) => CardTransaction.fromJson(txn as Map<String, dynamic>))
            .toList();

        print('✅ Fetched ${transactions.length} transactions');
        return ApiResponse.success(data: transactions);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch transactions',
      );
    } catch (e) {
      print('❌ CardService.getCardTransactions error: $e');
      return ApiResponse.error(message: 'Error fetching transactions: $e');
    }
  }
}