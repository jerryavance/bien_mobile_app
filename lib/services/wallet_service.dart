// ==========================================
// FILE: lib/services/wallet_service.dart
// FIXED: Properly handle validation_ref from API response
// ==========================================
import 'package:uuid/uuid.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../models/api_response.dart';
import 'api_client.dart';
import 'storage_service.dart';

class WalletService {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();
  final _uuid = const Uuid();

  // ==========================================
  // TRANSACTION VALIDATION - FIXED
  // ==========================================

  /// Validate transaction before processing
  Future<ApiResponse<Map<String, dynamic>>> validateTransaction({
    required String accountType,
    required String transactionType,
    required String identifier,
    required double amount,
    String? sourceAccountId,
  }) async {
    try {
      final reference = _generateReference();
      final currentAccountId = sourceAccountId ?? 
          await _storage.getAccountId() ?? '';

      final body = {
        'accountType': accountType,
        'transactionType': transactionType,
        'identifier': identifier,
        'amount': amount.toString(),
        'reference': reference,
        'source_account_id': currentAccountId,
      };

      print('Validating transaction: $body');

      // With the fixed ApiResponse, fromJson now receives the FULL response
      // Response structure: {success, type, validation_ref, data: {...}}
      final response = await _api.post<Map<String, dynamic>>(
        '/transaction/validate',
        body: body,
        fromJson: (fullResponse) {
          // fullResponse is the complete JSON with validation_ref at root level
          if (fullResponse is Map<String, dynamic>) {
            // Extract key fields from root level
            final validationRef = fullResponse['validation_ref'];
            final type = fullResponse['type'];
            final data = fullResponse['data'] as Map<String, dynamic>?;
            
            // Merge everything into one map for easy access
            return {
              'validation_ref': validationRef,
              'type': type,
              if (data != null) ...data,
            };
          }
          return fullResponse as Map<String, dynamic>;
        },
      );

      print('Validation response success: ${response.success}');
      print('Validation response data: ${response.data}');

      if (response.success && response.data != null) {
        final validationRef = response.data!['validation_ref'] as String?;
        
        if (validationRef == null) {
          print('ERROR: validation_ref not found in response data');
          print('Available keys: ${response.data!.keys.toList()}');
          return ApiResponse.error(message: 'Validation reference not received from server');
        }
        
        await _storage.saveValidationRef(validationRef);
        print('✓ Validation successful. Ref: $validationRef');
        
        return ApiResponse.success(data: response.data!);
      }

      return ApiResponse.error(
        message: response.message ?? 'Validation failed',
      );
    } catch (e) {
      print('WalletService.validateTransaction error: $e');
      return ApiResponse.error(message: 'Validation error: $e');
    }
  }

  // ==========================================
  // TOP-UP (DEPOSIT) - FIXED
  // ==========================================

  /// Top-up wallet from mobile money
  // Future<ApiResponse<TransactionModel>> topUp({
  //   required String source,
  //   required String phoneNumber,
  //   required double amount,
  //   String? destinationAccountId,
  //   String? note,
  // }) async {
  //   try {
  //     print('Starting top-up: $source, $phoneNumber, $amount');

  //     // Step 1: Validate transaction
  //     final validation = await validateTransaction(
  //       accountType: source,
  //       transactionType: 'Deposit',
  //       identifier: phoneNumber,
  //       amount: amount,
  //       sourceAccountId: destinationAccountId,
  //     );

  //     if (!validation.success || validation.data == null) {
  //       print('Validation failed: ${validation.message}');
  //       return ApiResponse.error(
  //         message: validation.message ?? 'Validation failed',
  //       );
  //     }

  //     // FIXED: Get validation_ref from the response
  //     final validationRef = validation.data!['validation_ref'] as String?;
      
  //     if (validationRef == null) {
  //       print('Error: validation_ref is null in validation response');
  //       return ApiResponse.error(
  //         message: 'Validation reference not received',
  //       );
  //     }

  //     print('Validation successful. Processing payment with ref: $validationRef');

  //     // Step 2: Process payment
  //     final payment = await processPayment(
  //       validationRef: validationRef,
  //       note: note ?? 'Top-up from $source',
  //       sourceOfFunds: 'mobile_money',
  //     );

  //     return payment;
  //   } catch (e) {
  //     print('WalletService.topUp error: $e');
  //     return ApiResponse.error(message: 'Top-up failed: $e');
  //   }
  // }


    Future<ApiResponse<TransactionModel>> topUp({
    required String source,
    required String phoneNumber,
    required double amount,
    String? destinationAccountId,
    String? note,
    }) async {
      try {
        print('Starting top-up: source=$source, phone=$phoneNumber, amount=$amount');

        // Step 1: Validate transaction
        final validation = await validateTransaction(
          accountType: source, // 'mtn' or 'airtel' - from getTopUpMethods()
          transactionType: 'Deposit',
          identifier: phoneNumber,
          amount: amount,
          sourceAccountId: destinationAccountId,
        );

        if (!validation.success || validation.data == null) {
          print('Validation failed: ${validation.message}');
          return ApiResponse.error(
            message: validation.message ?? 'Validation failed',
          );
        }

        final validationRef = validation.data!['validation_ref'] as String?;
        if (validationRef == null) {
          return ApiResponse.error(
            message: 'Validation reference not received',
          );
        }

        print('✓ Validation successful. Ref: $validationRef');

        // Step 2: Process payment
        // CRITICAL FIX: source_of_funds must be 'mtn' or 'airtel' (the payment method)
        // NOT 'wallet' and NOT 'mobile_money'
        final payment = await processPayment(
          validationRef: validationRef,
          note: note ?? 'Top-up from $source',
          sourceOfFunds: source, // Pass the exact method: 'mtn' or 'airtel'
        );

        return payment;
      } catch (e) {
        print('WalletService.topUp error: $e');
        return ApiResponse.error(message: 'Top-up failed: $e');
      }
    }

  // ==========================================
  // CASH OUT (WITHDRAW) - FIXED
  // ==========================================

  /// Cash out to mobile money or bank
  Future<ApiResponse<TransactionModel>> cashOut({
    required String method,
    required String destination,
    required double amount,
    String? sourceAccountId,
    String? note,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('Starting cash out: $method, $destination, $amount');

      final validation = await validateTransaction(
        accountType: method,
        transactionType: 'Withdraw',
        identifier: destination,
        amount: amount,
        sourceAccountId: sourceAccountId,
      );

      if (!validation.success || validation.data == null) {
        return ApiResponse.error(
          message: validation.message ?? 'Validation failed',
        );
      }

      final validationRef = validation.data!['validation_ref'] as String?;
      
      if (validationRef == null) {
        return ApiResponse.error(
          message: 'Validation reference not received',
        );
      }

      print('Validation successful. Processing payment...');

      final payment = await processPayment(
        validationRef: validationRef,
        note: note ?? 'Cash out to $method',
        sourceOfFunds: 'wallet',
      );

      return payment;
    } catch (e) {
      print('WalletService.cashOut error: $e');
      return ApiResponse.error(message: 'Cash out failed: $e');
    }
  }

  // ==========================================
  // BIEN TO BIEN TRANSFER - FIXED
  // ==========================================

  /// Transfer to another Bien user
  Future<ApiResponse<TransactionModel>> transfer({
    required String recipientId,
    required double amount,
    String? note,
    String? sourceAccountId,
  }) async {
    try {
      print('Starting transfer: $recipientId, $amount');

      final validation = await validateTransaction(
        accountType: 'wallet',
        transactionType: 'Transfer',
        identifier: recipientId,
        amount: amount,
        sourceAccountId: sourceAccountId,
      );

      if (!validation.success || validation.data == null) {
        return ApiResponse.error(
          message: validation.message ?? 'Validation failed',
        );
      }

      final validationRef = validation.data!['validation_ref'] as String?;
      
      if (validationRef == null) {
        return ApiResponse.error(
          message: 'Validation reference not received',
        );
      }

      print('Validation successful. Processing payment...');

      final payment = await processPayment(
        validationRef: validationRef,
        note: note ?? 'Transfer to Bien user',
        sourceOfFunds: 'wallet',
      );

      return payment;
    } catch (e) {
      print('WalletService.transfer error: $e');
      return ApiResponse.error(message: 'Transfer failed: $e');
    }
  }

  // ==========================================
  // WALLET OPERATIONS
  // ==========================================

  Future<ApiResponse<WalletModel>> getWallet() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/wallet/balance',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final walletData = response.data!['wallet'] as Map<String, dynamic>;
        final accounts = response.data!['accounts'] as List;
        
        double balance = 0;
        String accountId = '';
        if (accounts.isNotEmpty) {
          final mainAccount = accounts.first as Map<String, dynamic>;
          balance = (mainAccount['balance'] ?? 0).toDouble();
          accountId = mainAccount['id'] ?? '';
        }

        final wallet = WalletModel(
          id: walletData['id'] ?? '',
          userId: walletData['user_id'] ?? '',
          balance: balance,
          currency: accounts.isNotEmpty 
              ? (accounts.first as Map<String, dynamic>)['currency'] ?? 'UGX'
              : 'UGX',
          isActive: walletData['status'] == 'active',
          lastUpdated: DateTime.parse(
            walletData['updated_at'] ?? DateTime.now().toIso8601String(),
          ),
        );

        if (accountId.isNotEmpty) {
          await _storage.saveAccountId(accountId);
        }

        return ApiResponse.success(data: wallet);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch wallet',
      );
    } catch (e) {
      print('WalletService.getWallet error: $e');
      return ApiResponse.error(message: 'Error fetching wallet: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAccountDetails(
    String accountId,
  ) async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/wallet/accounts/$accountId',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return ApiResponse.success(data: response.data!['account']);
      }

      return ApiResponse.error(
        message: response.message ?? 'Failed to fetch account details',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Error fetching account: $e');
    }
  }

  // ==========================================
  // PAYMENT PROCESSING
  // ==========================================

  Future<ApiResponse<TransactionModel>> processPayment({
    required String validationRef,
    String? note,
    String? sourceOfFunds,
  }) async {
    try {
      final paymentRef = _generateReference();

      final body = {
        'note': note ?? '',
        'source_of_funds': sourceOfFunds ?? 'wallet',
        'validationRef': validationRef,
        'reference': paymentRef,
      };

      print('Processing payment: $body');

      final response = await _api.post<Map<String, dynamic>>(
        '/transaction/pay',
        body: body,
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final txData = response.data!;
        
        final transaction = TransactionModel(
          id: txData['tran_id'] ?? _uuid.v4(),
          userId: txData['sender_account_id'] ?? '',
          type: _mapTransactionType(txData),
          status: TransactionStatus.completed,
          amount: double.parse(txData['amount'] ?? '0'),
          fee: _calculateFee(txData['charges']),
          currency: txData['currency'] ?? 'UGX',
          reference: txData['tran_id'],
          description: _buildDescription(txData),
          metadata: txData,
          createdAt: DateTime.now(),
          completedAt: DateTime.now(),
        );

        return ApiResponse.success(data: transaction);
      }

      return ApiResponse.error(
        message: response.message ?? 'Payment failed',
      );
    } catch (e) {
      print('WalletService.processPayment error: $e');
      return ApiResponse.error(message: 'Payment error: $e');
    }
  }

  // ==========================================
  // GET PAYMENT METHODS
  // ==========================================

  Future<ApiResponse<List<Map<String, dynamic>>>> getTopUpMethods() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/transaction/topmethods',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final methods = response.data!['methods'] as List;
        return ApiResponse.success(
          data: methods.map((m) => m as Map<String, dynamic>).toList(),
        );
      }

      return ApiResponse.error(message: 'Failed to fetch methods');
    } catch (e) {
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getCashOutMethods() async {
    try {
      final response = await _api.get<Map<String, dynamic>>(
        '/transaction/cashmethods',
        fromJson: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final methods = response.data!['methods'] as List;
        return ApiResponse.success(
          data: methods.map((m) => m as Map<String, dynamic>).toList(),
        );
      }

      return ApiResponse.error(message: 'Failed to fetch methods');
    } catch (e) {
      return ApiResponse.error(message: 'Error: $e');
    }
  }

  // ==========================================
  // PLACEHOLDER METHODS
  // ==========================================

  Future<ApiResponse<TransactionModel>> buyAirtime({
    required String network,
    required String phoneNumber,
    required double amount,
    String? sourceAccountId,
  }) async {
    return ApiResponse.error(message: 'Airtime purchase not yet implemented');
  }

  Future<ApiResponse<TransactionModel>> buyDataBundle({
    required String network,
    required String phoneNumber,
    required String bundleId,
    String? sourceAccountId,
  }) async {
    return ApiResponse.error(message: 'Data bundle not yet implemented');
  }

  Future<ApiResponse<TransactionModel>> payUtility({
    required String provider,
    required String accountNumber,
    required double amount,
    String? sourceAccountId,
  }) async {
    return ApiResponse.error(message: 'Utility payment not yet implemented');
  }

  Future<ApiResponse<TransactionModel>> paySchoolFees({
    required String system,
    required String studentNumber,
    required String schoolCode,
    required double amount,
    String? sourceAccountId,
  }) async {
    return ApiResponse.error(message: 'School fees not yet implemented');
  }

  Future<ApiResponse<TransactionModel>> payMerchant({
    required String merchantId,
    required double amount,
    String? sourceAccountId,
  }) async {
    return ApiResponse.error(message: 'Merchant payment not yet implemented');
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  String _generateReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _uuid.v4().substring(0, 8);
    return 'TXN$timestamp$random';
  }

  TransactionType _mapTransactionType(Map<String, dynamic> data) {
    if (data.containsKey('sender_account_id') && 
        data.containsKey('recipient_account_id')) {
      return TransactionType.transfer;
    }
    return TransactionType.transfer;
  }

  double _calculateFee(dynamic charges) {
    if (charges == null) return 0;
    if (charges is Map) {
      final charge = charges['charge'] ?? 0;
      final tax = charges['tax'] ?? 0;
      return (charge + tax).toDouble();
    }
    return 0;
  }

  String _buildDescription(Map<String, dynamic> data) {
    final recipientName = data['recipient_full_name'] ?? 'Unknown';
    final amount = data['amount'] ?? '0';
    final currency = data['currency'] ?? 'UGX';
    return 'Payment of $currency $amount to $recipientName';
  }
}
















// // ==========================================
// // FILE: lib/services/wallet_service.dart
// // Real backend API integration for wallet operations
// // ==========================================
// import 'package:uuid/uuid.dart';
// import '../models/wallet_model.dart';
// import '../models/transaction_model.dart';
// import '../models/api_response.dart';
// import 'api_client.dart';
// import 'storage_service.dart';

// class WalletService {
//   final ApiClient _api = ApiClient();
//   final StorageService _storage = StorageService();
//   final _uuid = const Uuid();

//   // ==========================================
//   // WALLET OPERATIONS
//   // ==========================================

//   /// Get wallet balance and accounts
//   Future<ApiResponse<WalletModel>> getWallet() async {
//     try {
//       final response = await _api.get<Map<String, dynamic>>(
//         '/wallet/balance',
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         final walletData = response.data!['wallet'] as Map<String, dynamic>;
//         final accounts = response.data!['accounts'] as List;
        
//         // Get main account balance
//         double balance = 0;
//         String accountId = '';
//         if (accounts.isNotEmpty) {
//           final mainAccount = accounts.first as Map<String, dynamic>;
//           balance = (mainAccount['balance'] ?? 0).toDouble();
//           accountId = mainAccount['id'] ?? '';
//         }

//         final wallet = WalletModel(
//           id: walletData['id'] ?? '',
//           userId: walletData['user_id'] ?? '',
//           balance: balance,
//           currency: accounts.isNotEmpty 
//               ? (accounts.first as Map<String, dynamic>)['currency'] ?? 'UGX'
//               : 'UGX',
//           isActive: walletData['status'] == 'active',
//           lastUpdated: DateTime.parse(
//             walletData['updated_at'] ?? DateTime.now().toIso8601String(),
//           ),
//         );

//         // Store account ID for future transactions
//         if (accountId.isNotEmpty) {
//           await _storage.saveAccountId(accountId);
//         }

//         return ApiResponse.success(data: wallet);
//       }

//       return ApiResponse.error(
//         message: response.message ?? 'Failed to fetch wallet',
//       );
//     } catch (e) {
//       print('WalletService.getWallet error: $e');
//       return ApiResponse.error(message: 'Error fetching wallet: $e');
//     }
//   }

//   /// Get account details
//   Future<ApiResponse<Map<String, dynamic>>> getAccountDetails(
//     String accountId,
//   ) async {
//     try {
//       final response = await _api.get<Map<String, dynamic>>(
//         '/wallet/accounts/$accountId',
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         return ApiResponse.success(data: response.data!['account']);
//       }

//       return ApiResponse.error(
//         message: response.message ?? 'Failed to fetch account details',
//       );
//     } catch (e) {
//       return ApiResponse.error(message: 'Error fetching account: $e');
//     }
//   }

//   // ==========================================
//   // TRANSACTION VALIDATION
//   // ==========================================

//   /// Validate transaction before processing
//   Future<ApiResponse<Map<String, dynamic>>> validateTransaction({
//     required String accountType, // 'airtel', 'mtn', 'wallet', 'account'
//     required String transactionType, // 'Deposit', 'Withdraw', 'Transfer'
//     required String identifier, // phone number, wallet code, or accountID
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     try {
//       final reference = _generateReference();
//       final currentAccountId = sourceAccountId ?? 
//           await _storage.getAccountId() ?? '';

//       final body = {
//         'accountType': accountType,
//         'transactionType': transactionType,
//         'identifier': identifier,
//         'amount': amount.toString(),
//         'reference': reference,
//         'source_account_id': currentAccountId,
//       };

//       print('Validating transaction: $body');

//       final response = await _api.post<Map<String, dynamic>>(
//         '/transaction/validate',
//         body: body,
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         // The validation_ref is at root level, not in data
//         final validationRef = response.data!['validation_ref'] as String?;
//         if (validationRef != null) {
//           await _storage.saveValidationRef(validationRef);
//           print('Validation successful. Ref: $validationRef');
//         }
        
//         return ApiResponse.success(data: response.data);
//       }

//       return ApiResponse.error(
//         message: response.message ?? 'Validation failed',
//       );
//     } catch (e) {
//       print('WalletService.validateTransaction error: $e');
//       return ApiResponse.error(message: 'Validation error: $e');
//     }
//   }

//   // ==========================================
//   // PAYMENT PROCESSING
//   // ==========================================

//   /// Process payment after validation
//   Future<ApiResponse<TransactionModel>> processPayment({
//     required String validationRef,
//     String? note,
//     String? sourceOfFunds,
//   }) async {
//     try {
//       final paymentRef = _generateReference();

//       final body = {
//         'note': note ?? '',
//         'source_of_funds': sourceOfFunds ?? 'wallet',
//         'validationRef': validationRef,
//         'reference': paymentRef,
//       };

//       print('Processing payment: $body');

//       final response = await _api.post<Map<String, dynamic>>(
//         '/transaction/pay',
//         body: body,
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         final txData = response.data!;
        
//         // Map API response to TransactionModel
//         final transaction = TransactionModel(
//           id: txData['tran_id'] ?? _uuid.v4(),
//           userId: txData['sender_account_id'] ?? '',
//           type: _mapTransactionType(txData),
//           status: TransactionStatus.completed,
//           amount: double.parse(txData['amount'] ?? '0'),
//           fee: _calculateFee(txData['charges']),
//           currency: txData['currency'] ?? 'UGX',
//           reference: txData['tran_id'],
//           description: _buildDescription(txData),
//           metadata: txData,
//           createdAt: DateTime.now(),
//           completedAt: DateTime.now(),
//         );

//         return ApiResponse.success(data: transaction);
//       }

//       return ApiResponse.error(
//         message: response.message ?? 'Payment failed',
//       );
//     } catch (e) {
//       print('WalletService.processPayment error: $e');
//       return ApiResponse.error(message: 'Payment error: $e');
//     }
//   }

//   // ==========================================
//   // TOP-UP (DEPOSIT)
//   // ==========================================

//   /// Top-up wallet from mobile money
//   Future<ApiResponse<TransactionModel>> topUp({
//     required String source, // 'mtn' or 'airtel' (method_id from API)
//     required String phoneNumber,
//     required double amount,
//     String? destinationAccountId,
//     String? note,
//   }) async {
//     try {
//       print('Starting top-up: $source, $phoneNumber, $amount');

//       // Step 1: Validate transaction
//       // Use the source as-is (should be method_id like 'mtn' or 'airtel')
//       final validation = await validateTransaction(
//         accountType: source,  // Don't lowercase - use exactly as provided
//         transactionType: 'Deposit',
//         identifier: phoneNumber,
//         amount: amount,
//         sourceAccountId: destinationAccountId,
//       );

//       if (!validation.success || validation.data == null) {
//         return ApiResponse.error(
//           message: validation.message ?? 'Validation failed',
//         );
//       }

//       // Get validation_ref from root level of response
//       final validationRef = validation.data!['validation_ref'] as String?;
      
//       if (validationRef == null) {
//         return ApiResponse.error(
//           message: 'Validation reference not received',
//         );
//       }

//       print('Validation successful. Processing payment...');

//       // Step 2: Process payment
//       final payment = await processPayment(
//         validationRef: validationRef,
//         note: note ?? 'Top-up from $source',
//         sourceOfFunds: 'mobile_money',
//       );

//       return payment;
//     } catch (e) {
//       print('WalletService.topUp error: $e');
//       return ApiResponse.error(message: 'Top-up failed: $e');
//     }
//   }

//   // ==========================================
//   // CASH OUT (WITHDRAW)
//   // ==========================================

//   /// Cash out to mobile money or bank
//   Future<ApiResponse<TransactionModel>> cashOut({
//     required String method, // 'mtn', 'airtel', or 'account' for bank
//     required String destination, // phone number or account number
//     required double amount,
//     String? sourceAccountId,
//     String? note,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     try {
//       print('Starting cash out: $method, $destination, $amount');

//       // Step 1: Validate transaction
//       final validation = await validateTransaction(
//         accountType: method,  // Use as-is
//         transactionType: 'Withdraw',
//         identifier: destination,
//         amount: amount,
//         sourceAccountId: sourceAccountId,
//       );

//       if (!validation.success || validation.data == null) {
//         return ApiResponse.error(
//           message: validation.message ?? 'Validation failed',
//         );
//       }

//       final validationRef = validation.data!['validation_ref'] as String?;
      
//       if (validationRef == null) {
//         return ApiResponse.error(
//           message: 'Validation reference not received',
//         );
//       }

//       print('Validation successful. Processing payment...');

//       // Step 2: Process payment
//       final payment = await processPayment(
//         validationRef: validationRef,
//         note: note ?? 'Cash out to $method',
//         sourceOfFunds: 'wallet',
//       );

//       return payment;
//     } catch (e) {
//       print('WalletService.cashOut error: $e');
//       return ApiResponse.error(message: 'Cash out failed: $e');
//     }
//   }

//   // ==========================================
//   // BIEN TO BIEN TRANSFER
//   // ==========================================

//   /// Transfer to another Bien user
//   Future<ApiResponse<TransactionModel>> transfer({
//     required String recipientId, // phone number or wallet code
//     required double amount,
//     String? note,
//     String? sourceAccountId,
//   }) async {
//     try {
//       print('Starting transfer: $recipientId, $amount');

//       // Step 1: Validate transaction
//       final validation = await validateTransaction(
//         accountType: 'wallet',
//         transactionType: 'Transfer',
//         identifier: recipientId,
//         amount: amount,
//         sourceAccountId: sourceAccountId,
//       );

//       if (!validation.success || validation.data == null) {
//         return ApiResponse.error(
//           message: validation.message ?? 'Validation failed',
//         );
//       }

//       final validationRef = validation.data!['validation_ref'] as String?;
      
//       if (validationRef == null) {
//         return ApiResponse.error(
//           message: 'Validation reference not received',
//         );
//       }

//       print('Validation successful. Processing payment...');

//       // Step 2: Process payment
//       final payment = await processPayment(
//         validationRef: validationRef,
//         note: note ?? 'Transfer to Bien user',
//         sourceOfFunds: 'wallet',
//       );

//       return payment;
//     } catch (e) {
//       print('WalletService.transfer error: $e');
//       return ApiResponse.error(message: 'Transfer failed: $e');
//     }
//   }

//   // ==========================================
//   // GET PAYMENT METHODS
//   // ==========================================

//   /// Get available top-up methods
//   Future<ApiResponse<List<Map<String, dynamic>>>> getTopUpMethods() async {
//     try {
//       final response = await _api.get<Map<String, dynamic>>(
//         '/transaction/topmethods',
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         final methods = response.data!['methods'] as List;
//         return ApiResponse.success(
//           data: methods.map((m) => m as Map<String, dynamic>).toList(),
//         );
//       }

//       return ApiResponse.error(message: 'Failed to fetch methods');
//     } catch (e) {
//       return ApiResponse.error(message: 'Error: $e');
//     }
//   }

//   /// Get available cash-out methods
//   Future<ApiResponse<List<Map<String, dynamic>>>> getCashOutMethods() async {
//     try {
//       final response = await _api.get<Map<String, dynamic>>(
//         '/transaction/cashmethods',
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         final methods = response.data!['methods'] as List;
//         return ApiResponse.success(
//           data: methods.map((m) => m as Map<String, dynamic>).toList(),
//         );
//       }

//       return ApiResponse.error(message: 'Failed to fetch methods');
//     } catch (e) {
//       return ApiResponse.error(message: 'Error: $e');
//     }
//   }

//   // ==========================================
//   // UTILITY METHODS
//   // ==========================================

//   /// Buy airtime (placeholder - implement when API is available)
//   Future<ApiResponse<TransactionModel>> buyAirtime({
//     required String network,
//     required String phoneNumber,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when airtime API is available
//     return ApiResponse.error(message: 'Airtime purchase not yet implemented');
//   }

//   /// Buy data bundle (placeholder)
//   Future<ApiResponse<TransactionModel>> buyDataBundle({
//     required String network,
//     required String phoneNumber,
//     required String bundleId,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when data bundle API is available
//     return ApiResponse.error(message: 'Data bundle not yet implemented');
//   }

//   /// Pay utility bill (placeholder)
//   Future<ApiResponse<TransactionModel>> payUtility({
//     required String provider,
//     required String accountNumber,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when utility payment API is available
//     return ApiResponse.error(message: 'Utility payment not yet implemented');
//   }

//   /// Pay school fees (placeholder)
//   Future<ApiResponse<TransactionModel>> paySchoolFees({
//     required String system,
//     required String studentNumber,
//     required String schoolCode,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when school fees API is available
//     return ApiResponse.error(message: 'School fees not yet implemented');
//   }

//   /// Pay merchant (placeholder)
//   Future<ApiResponse<TransactionModel>> payMerchant({
//     required String merchantId,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when merchant payment API is available
//     return ApiResponse.error(message: 'Merchant payment not yet implemented');
//   }

//   // ==========================================
//   // HELPER METHODS
//   // ==========================================

//   String _generateReference() {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final random = _uuid.v4().substring(0, 8);
//     return 'TXN$timestamp$random';
//   }

//   TransactionType _mapTransactionType(Map<String, dynamic> data) {
//     // Determine transaction type based on API response
//     if (data.containsKey('sender_account_id') && 
//         data.containsKey('recipient_account_id')) {
//       return TransactionType.transfer;
//     }
//     // Default to transfer for now
//     return TransactionType.transfer;
//   }

//   double _calculateFee(dynamic charges) {
//     if (charges == null) return 0;
//     if (charges is Map) {
//       final charge = charges['charge'] ?? 0;
//       final tax = charges['tax'] ?? 0;
//       return (charge + tax).toDouble();
//     }
//     return 0;
//   }

//   String _buildDescription(Map<String, dynamic> data) {
//     final recipientName = data['recipient_full_name'] ?? 'Unknown';
//     final amount = data['amount'] ?? '0';
//     final currency = data['currency'] ?? 'UGX';
//     return 'Payment of $currency $amount to $recipientName';
//   }
// }















// // ==========================================
// // FILE: lib/services/wallet_service.dart
// // Real backend API integration for wallet operations
// // ==========================================
// import 'package:uuid/uuid.dart';
// import '../models/wallet_model.dart';
// import '../models/transaction_model.dart';
// import '../models/api_response.dart';
// import 'api_client.dart';
// import 'storage_service.dart';

// class WalletService {
//   final ApiClient _api = ApiClient();
//   final StorageService _storage = StorageService();
//   final _uuid = const Uuid();

//   // ==========================================
//   // WALLET OPERATIONS
//   // ==========================================

//   /// Get wallet balance and accounts
//   Future<ApiResponse<WalletModel>> getWallet() async {
//     try {
//       final response = await _api.get<Map<String, dynamic>>(
//         '/wallet/balance',
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         final walletData = response.data!['wallet'] as Map<String, dynamic>;
//         final accounts = response.data!['accounts'] as List;
        
//         // Get main account balance
//         double balance = 0;
//         String accountId = '';
//         if (accounts.isNotEmpty) {
//           final mainAccount = accounts.first as Map<String, dynamic>;
//           balance = (mainAccount['balance'] ?? 0).toDouble();
//           accountId = mainAccount['id'] ?? '';
//         }

//         final wallet = WalletModel(
//           id: walletData['id'] ?? '',
//           userId: walletData['user_id'] ?? '',
//           balance: balance,
//           currency: accounts.isNotEmpty 
//               ? (accounts.first as Map<String, dynamic>)['currency'] ?? 'UGX'
//               : 'UGX',
//           isActive: walletData['status'] == 'active',
//           lastUpdated: DateTime.parse(
//             walletData['updated_at'] ?? DateTime.now().toIso8601String(),
//           ),
//         );

//         // Store account ID for future transactions
//         if (accountId.isNotEmpty) {
//           await _storage.saveAccountId(accountId);
//         }

//         return ApiResponse.success(data: wallet);
//       }

//       return ApiResponse.error(
//         message: response.message ?? 'Failed to fetch wallet',
//       );
//     } catch (e) {
//       print('WalletService.getWallet error: $e');
//       return ApiResponse.error(message: 'Error fetching wallet: $e');
//     }
//   }

//   /// Get account details
//   Future<ApiResponse<Map<String, dynamic>>> getAccountDetails(
//     String accountId,
//   ) async {
//     try {
//       final response = await _api.get<Map<String, dynamic>>(
//         '/wallet/accounts/$accountId',
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         return ApiResponse.success(data: response.data!['account']);
//       }

//       return ApiResponse.error(
//         message: response.message ?? 'Failed to fetch account details',
//       );
//     } catch (e) {
//       return ApiResponse.error(message: 'Error fetching account: $e');
//     }
//   }

//   // ==========================================
//   // TRANSACTION VALIDATION
//   // ==========================================

//   /// Validate transaction before processing
//   Future<ApiResponse<Map<String, dynamic>>> validateTransaction({
//     required String accountType, // 'airtel', 'mtn', 'wallet', 'account'
//     required String transactionType, // 'Deposit', 'Withdraw', 'Transfer'
//     required String identifier, // phone number, wallet code, or accountID
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     try {
//       final reference = _generateReference();
//       final currentAccountId = sourceAccountId ?? 
//           await _storage.getAccountId() ?? '';

//       final body = {
//         'accountType': accountType,
//         'transactionType': transactionType,
//         'identifier': identifier,
//         'amount': amount.toString(),
//         'reference': reference,
//         'source_account_id': currentAccountId,
//       };

//       print('Validating transaction: $body');

//       final response = await _api.post<Map<String, dynamic>>(
//         '/transaction/validate',
//         body: body,
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         // Store validation reference for payment
//         final validationRef = response.data!['validation_ref'] as String?;
//         if (validationRef != null) {
//           await _storage.saveValidationRef(validationRef);
//         }
        
//         return ApiResponse.success(data: response.data);
//       }

//       return ApiResponse.error(
//         message: response.message ?? 'Validation failed',
//       );
//     } catch (e) {
//       print('WalletService.validateTransaction error: $e');
//       return ApiResponse.error(message: 'Validation error: $e');
//     }
//   }

//   // ==========================================
//   // PAYMENT PROCESSING
//   // ==========================================

//   /// Process payment after validation
//   Future<ApiResponse<TransactionModel>> processPayment({
//     required String validationRef,
//     String? note,
//     String? sourceOfFunds,
//   }) async {
//     try {
//       final paymentRef = _generateReference();

//       final body = {
//         'note': note ?? '',
//         'source_of_funds': sourceOfFunds ?? 'wallet',
//         'validationRef': validationRef,
//         'reference': paymentRef,
//       };

//       print('Processing payment: $body');

//       final response = await _api.post<Map<String, dynamic>>(
//         '/transaction/pay',
//         body: body,
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         final txData = response.data!;
        
//         // Map API response to TransactionModel
//         final transaction = TransactionModel(
//           id: txData['tran_id'] ?? _uuid.v4(),
//           userId: txData['sender_account_id'] ?? '',
//           type: _mapTransactionType(txData),
//           status: TransactionStatus.completed,
//           amount: double.parse(txData['amount'] ?? '0'),
//           fee: _calculateFee(txData['charges']),
//           currency: txData['currency'] ?? 'UGX',
//           reference: txData['tran_id'],
//           description: _buildDescription(txData),
//           metadata: txData,
//           createdAt: DateTime.now(),
//           completedAt: DateTime.now(),
//         );

//         return ApiResponse.success(data: transaction);
//       }

//       return ApiResponse.error(
//         message: response.message ?? 'Payment failed',
//       );
//     } catch (e) {
//       print('WalletService.processPayment error: $e');
//       return ApiResponse.error(message: 'Payment error: $e');
//     }
//   }

//   // ==========================================
//   // TOP-UP (DEPOSIT)
//   // ==========================================

//   /// Top-up wallet from mobile money
//   Future<ApiResponse<TransactionModel>> topUp({
//     required String source, // 'mtn' or 'airtel'
//     required String phoneNumber,
//     required double amount,
//     String? destinationAccountId,
//     String? note,
//   }) async {
//     try {
//       print('Starting top-up: $source, $phoneNumber, $amount');

//       // Step 1: Validate transaction
//       final validation = await validateTransaction(
//         accountType: source.toLowerCase(),
//         transactionType: 'Deposit',
//         identifier: phoneNumber,
//         amount: amount,
//         sourceAccountId: destinationAccountId,
//       );

//       if (!validation.success || validation.data == null) {
//         return ApiResponse.error(
//           message: validation.message ?? 'Validation failed',
//         );
//       }

//       final validationRef = validation.data!['validation_ref'] as String;

//       // Step 2: Process payment
//       final payment = await processPayment(
//         validationRef: validationRef,
//         note: note ?? 'Top-up from $source',
//         sourceOfFunds: 'mobile_money',
//       );

//       return payment;
//     } catch (e) {
//       print('WalletService.topUp error: $e');
//       return ApiResponse.error(message: 'Top-up failed: $e');
//     }
//   }

//   // ==========================================
//   // CASH OUT (WITHDRAW)
//   // ==========================================

//   /// Cash out to mobile money or bank
//   Future<ApiResponse<TransactionModel>> cashOut({
//     required String method, // 'mtn', 'airtel', or 'account' for bank
//     required String destination, // phone number or account number
//     required double amount,
//     String? sourceAccountId,
//     String? note,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     try {
//       print('Starting cash out: $method, $destination, $amount');

//       // Step 1: Validate transaction
//       final validation = await validateTransaction(
//         accountType: method.toLowerCase(),
//         transactionType: 'Withdraw',
//         identifier: destination,
//         amount: amount,
//         sourceAccountId: sourceAccountId,
//       );

//       if (!validation.success || validation.data == null) {
//         return ApiResponse.error(
//           message: validation.message ?? 'Validation failed',
//         );
//       }

//       final validationRef = validation.data!['validation_ref'] as String;

//       // Step 2: Process payment
//       final payment = await processPayment(
//         validationRef: validationRef,
//         note: note ?? 'Cash out to $method',
//         sourceOfFunds: 'wallet',
//       );

//       return payment;
//     } catch (e) {
//       print('WalletService.cashOut error: $e');
//       return ApiResponse.error(message: 'Cash out failed: $e');
//     }
//   }

//   // ==========================================
//   // BIEN TO BIEN TRANSFER
//   // ==========================================

//   /// Transfer to another Bien user
//   Future<ApiResponse<TransactionModel>> transfer({
//     required String recipientId, // phone number or wallet code
//     required double amount,
//     String? note,
//     String? sourceAccountId,
//   }) async {
//     try {
//       print('Starting transfer: $recipientId, $amount');

//       // Step 1: Validate transaction
//       final validation = await validateTransaction(
//         accountType: 'wallet',
//         transactionType: 'Transfer',
//         identifier: recipientId,
//         amount: amount,
//         sourceAccountId: sourceAccountId,
//       );

//       if (!validation.success || validation.data == null) {
//         return ApiResponse.error(
//           message: validation.message ?? 'Validation failed',
//         );
//       }

//       final validationRef = validation.data!['validation_ref'] as String;

//       // Step 2: Process payment
//       final payment = await processPayment(
//         validationRef: validationRef,
//         note: note ?? 'Transfer to Bien user',
//         sourceOfFunds: 'wallet',
//       );

//       return payment;
//     } catch (e) {
//       print('WalletService.transfer error: $e');
//       return ApiResponse.error(message: 'Transfer failed: $e');
//     }
//   }

//   // ==========================================
//   // GET PAYMENT METHODS
//   // ==========================================

//   /// Get available top-up methods
//   Future<ApiResponse<List<Map<String, dynamic>>>> getTopUpMethods() async {
//     try {
//       final response = await _api.get<Map<String, dynamic>>(
//         '/transaction/topmethods',
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         final methods = response.data!['methods'] as List;
//         return ApiResponse.success(
//           data: methods.map((m) => m as Map<String, dynamic>).toList(),
//         );
//       }

//       return ApiResponse.error(message: 'Failed to fetch methods');
//     } catch (e) {
//       return ApiResponse.error(message: 'Error: $e');
//     }
//   }

//   /// Get available cash-out methods
//   Future<ApiResponse<List<Map<String, dynamic>>>> getCashOutMethods() async {
//     try {
//       final response = await _api.get<Map<String, dynamic>>(
//         '/transaction/cashmethods',
//         fromJson: (data) => data as Map<String, dynamic>,
//       );

//       if (response.success && response.data != null) {
//         final methods = response.data!['methods'] as List;
//         return ApiResponse.success(
//           data: methods.map((m) => m as Map<String, dynamic>).toList(),
//         );
//       }

//       return ApiResponse.error(message: 'Failed to fetch methods');
//     } catch (e) {
//       return ApiResponse.error(message: 'Error: $e');
//     }
//   }

//   // ==========================================
//   // UTILITY METHODS
//   // ==========================================

//   /// Buy airtime (placeholder - implement when API is available)
//   Future<ApiResponse<TransactionModel>> buyAirtime({
//     required String network,
//     required String phoneNumber,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when airtime API is available
//     return ApiResponse.error(message: 'Airtime purchase not yet implemented');
//   }

//   /// Buy data bundle (placeholder)
//   Future<ApiResponse<TransactionModel>> buyDataBundle({
//     required String network,
//     required String phoneNumber,
//     required String bundleId,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when data bundle API is available
//     return ApiResponse.error(message: 'Data bundle not yet implemented');
//   }

//   /// Pay utility bill (placeholder)
//   Future<ApiResponse<TransactionModel>> payUtility({
//     required String provider,
//     required String accountNumber,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when utility payment API is available
//     return ApiResponse.error(message: 'Utility payment not yet implemented');
//   }

//   /// Pay school fees (placeholder)
//   Future<ApiResponse<TransactionModel>> paySchoolFees({
//     required String system,
//     required String studentNumber,
//     required String schoolCode,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when school fees API is available
//     return ApiResponse.error(message: 'School fees not yet implemented');
//   }

//   /// Pay merchant (placeholder)
//   Future<ApiResponse<TransactionModel>> payMerchant({
//     required String merchantId,
//     required double amount,
//     String? sourceAccountId,
//   }) async {
//     // TODO: Implement when merchant payment API is available
//     return ApiResponse.error(message: 'Merchant payment not yet implemented');
//   }

//   // ==========================================
//   // HELPER METHODS
//   // ==========================================

//   String _generateReference() {
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final random = _uuid.v4().substring(0, 8);
//     return 'TXN$timestamp$random';
//   }

//   TransactionType _mapTransactionType(Map<String, dynamic> data) {
//     // Determine transaction type based on API response
//     if (data.containsKey('sender_account_id') && 
//         data.containsKey('recipient_account_id')) {
//       return TransactionType.transfer;
//     }
//     // Default to transfer for now
//     return TransactionType.transfer;
//   }

//   double _calculateFee(dynamic charges) {
//     if (charges == null) return 0;
//     if (charges is Map) {
//       final charge = charges['charge'] ?? 0;
//       final tax = charges['tax'] ?? 0;
//       return (charge + tax).toDouble();
//     }
//     return 0;
//   }

//   String _buildDescription(Map<String, dynamic> data) {
//     final recipientName = data['recipient_full_name'] ?? 'Unknown';
//     final amount = data['amount'] ?? '0';
//     final currency = data['currency'] ?? 'UGX';
//     return 'Payment of $currency $amount to $recipientName';
//   }
// }